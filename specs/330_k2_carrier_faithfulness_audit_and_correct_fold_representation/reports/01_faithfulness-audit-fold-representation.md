# Task 330 — k=2 Carrier Faithfulness Audit + Correct-Fold-Representation Determination

**Task**: 330 — foundational faithfulness audit of the k=2 carrier route against Rabinovich 2014
(ground truth), and decisive determination of the correct fold representation at quantifier
depth ≥ 2.
**Dispatch**: hard-mode lean4 research (H2 anti-analysis / H3 reference-grounding /
H4 adversarial verification / H5 divergence), `--lit` active (Rabinovich 2014 in corpus:
`~/Projects/Literature/sources/rabinovich_2014/`).
**Session**: sess_1783467994_0da061
**Date**: 2026-07-07
**Deliverable**: determination report (research — NOT carrier/proof code). No Lean file edited.

---

## VERDICT (one line)

**REDESIGN.** Primary case **(B)** — Rabinovich's normal-form fold genuinely requires the
*navigated* characteristic (nested `Until`/`Since`, Prop 3.5 / Cor 5.4), so the constant-arity
static carrier targeted the wrong object — with case **(C)** as the exact factorization
mechanism (the depth-2 normal form does NOT factor into per-`(zone, χ : NormalForm sig 1 1)`
monadic obligations). Case **(A)** is rejected in its literal form: the fix is *not* higher
*static* arity. **Task 327's NO-GO is CORRECT and faithful — it is not a fixable encoding
artifact at the current design's arity; the k=2 completeness target itself remains reachable,
but only via the navigated / witness-growing representation, not via the constant-arity E[Σ]
fold engine.**

---

## Literature availability (mandated check)

`literature-search.sh "Rabinovich normal form E Sigma fold arity"` returned `[]` (FTS index has
no entry), BUT the paper **is** present and was read directly:

- Per-repo sub-index `specs/literature-index.json` lists `doc_id: rabinovich_2014`.
- Global index `~/Projects/Literature/index.json` → `sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.{md,pdf}`.
- The corpus **`.md` is a curated SUMMARY** (2,721 tokens) — it labels the normal form **Def 3.1**
  and the fold **Cor 5.4**; it contains **no literal "Definition 4.1"**.
- **The PDF was read directly (pages 5–7)** to verify the actual Def 4.1 / Prop 3.5 / Prop 4.3
  / Prop 4.2 text. All Part-2 arity claims below are grounded in the PDF, not inferred.

**This resolves an H4 concern up front**: report 05 and multiple Lean records cite a "Def 4.1
E[Σ]-fold (PDF p.5–6)". The actual **Definition 4.1 (PDF p.5) is NOT a fold** (see Part 2 §1).

---

## PART 1 — Obstacle Consolidation (machine-grounded)

**Claim: G6 (:1609–1641), F4 (309/320, :5689–5765), and the k=2 NO-GO (327, :8760–8825) are
three surfacings of ONE obstruction** — *an arity-1 monadic channel cannot carry the joint
coupling of an inner existential witness to multiple fixed anchors.* All three regions,
signatures, and goal states below were re-verified against the CURRENT tree
(`NfMultiAnchorBridge.lean`, 8,827 lines; `NfEFold.lean`, 541 lines) this dispatch — prior
line numbers were stale and are corrected here.

### The shared structural core (verified signatures)

`NormalForm` (`lean_hover_info`-confirmed, `Bimodal.Metalogic.WeakCanonical.NormalForm`):

```
NormalForm sig : ℕ → ℕ → Type
  depth 0    : AtomKind sig n → Bool
  depth k+1  : (AtomKind sig n → Bool) × (NormalForm sig k (n+1) → Bool)
```

Hover doc: *"Normal form type mirroring **Doets' n-characteristics (Def 1.6.1)**, defined by
recursion on quantifier depth."* The native depth-`(k+1)` quant layer ranges over
`NormalForm sig k (n+1)` — **arity-GROWING** (one extra variable per quantifier round), and it
is a **DOETS** characteristic, not a Rabinovich ∃∀-formula (this is the root of Part 2).

The constant-arity fold's E-atom (`NfEFold.lean:69`):

```
abbrev EAtomDom (sig) (k n) : Type := ZoneSpec n × NormalForm sig k 1
```

i.e. the fold *replaces* the arity-growing `NormalForm sig k (n+1)` sub-form by
(static zone of the fresh point vs the `n` fixed anchors) × (the fresh point's own
**arity-1** depth-`k` characteristic). `ZoneSpec n := Fin n → Bool × Bool` (`NfEFold.lean:52`)
is a *static* order-position tuple. **The lossy step is exactly this factorization at `k ≥ 1`:**
a depth-`k` (`k≥1`) characteristic `χ : NormalForm sig k 1` has its *own* nested existential
witness, which must see the `n` anchors — but `χ` reads only its single fresh point.

### The three surfacings

| # | Record | Verified file:line | Env / goal | Why arity-1 is insufficient (exact) |
|---|--------|--------------------|-----------|-------------------------------------|
| (i) | **G6 barrier** (task 309 R2 NO-GO) | `NfMultiAnchorBridge.lean:1609–1641`; residual :1629–1636 | `⊢ ∀ sub_nf : NormalForm sig 0 4, (∃ x₁, …[x₁,w,x,t]…) ↔ qnf.2 sub_nf`, only `h_atom : nf_eval_nf M 0 3 [w,x,t] qnf.1` in context | env `[x₁,w,x,t]` couples bracket witness `w` to BOTH fixed endpoints `x,t` (plus fresh `x₁`). "No `VecEA2 1` monadic component … can supply it; **requires a NAVIGATED arity-3 characteristic** (reading `w` while `x,t` are navigated in) — **exactly what G6 bars**." |
| (ii) | **F4 carrier-shape defect** (task 309 Ph 13.35; 320 follow-up) | `NfMultiAnchorBridge.lean:5689–5765` | channel-(i) content `= charK (nfk_projFresh σ)` for ALL 7 zones (`rfl`-confirmed, probe A :5705–5714) | the discriminating **per-sub JOINT content** "rides `σ.2`"; channel (i) is a function of `nfk_projFresh σ` (the `σ.1`-level, arity-1 fresh type) ALONE with `witnessZone` DISCARDED. Two subs equal on `nfk_projFresh` but differing on inner-witness structure get byte-identical content. Counterexample at `M=ℤ` (4 elements, :5741–5748). |
| (iii) | **k=2 NO-GO** (task 327 P1 gate) | `NfMultiAnchorBridge.lean:8760–8825` | crux goal (:8788–8792): `zs' : ZoneSpec 4`, `⊢ (∃ v, zoneHolds M [x₁,w,x,t] zs' v ∧ …) ↔ sub.2 (nf0_assemble zs' χ' sub.1)`; only `hmon : nf_eval_nf M 1 1 (fun _ ↦ x₁) (nfk_projFresh sub)` = **`ZoneSpec 1`** available | goal needs `v`'s zone against full arity-4 env `[x₁,w,x,t]`; `hmon` supplies `v`-vs-`x₁` only. `exact hmon.2.1 zs' χ'` → *"argument `zs'` has type `ZoneSpec 4` but is expected to have type `ZoneSpec 1`"* — **the decisive certification: constant arity = 1.** Same arity-4 residual as (i), now at the OUTER quant layer. |

**Consolidation verdict**: identical obstruction at three loci. (i) is the *inner* arity-3
evaluation; (iii) is (i) re-formed one quant-layer *out* (the 327 record itself states it is a
"mirror of the R2 NO-GO :1609–1641"); (ii) is the *carrier-side* symptom (the channel that was
supposed to store the joint content stores only the arity-1 projection). In every case the
missing quantity is the **navigated (multi-anchor) coupling** that the fixed
`VecEA2 1` / `nfk_projFresh` / `χ : NormalForm sig 1 1` **arity-1** slot cannot hold. The three
`ZoneSpec n` arities tell the whole story: the goal always needs `ZoneSpec 4` (`v` vs
`[x₁,w,x,t]`); the constant-arity channel always supplies `ZoneSpec 1`.

---

## PART 2 — Faithfulness Audit + Correct-Solution Determination

### §1 — What Rabinovich's normal form and fold ACTUALLY are (PDF-verified)

**Definition 4.1 (PDF p.5, verbatim reading) is the E[Σ] EXPANSION, not a fold.**
> "We denote by `E[Σ]` the set of unary predicate names `Σ ∪ {A | A is a TL(Until,Since)-formula
> over Σ}`. The canonical TL(Until,Since)-expansion of `M` … interprets each predicate name
> `A ∈ E[Σ]` as `{a ∈ M | M,a ⊨ A}`."

Def 4.1 enriches the *alphabet* with one **unary** predicate per TL formula (TL-formulas-as-atoms).
It says nothing about arity, folding, or zones. **The "constant-arity E[Σ]-fold (Def 4.1)"
cited throughout report 05 and the Lean records is a MIS-CITATION** — no such object exists in
the paper.

**The actual fold is Prop 3.5 / Cor 5.4 — NAVIGATED nested Until/Since.** The ∃∀-formula
(Prop 3.5, PDF p.5, verbatim):

```
ψ(z₀) = ∃xₙ … ∃x₁∃x₀ [ z₀ = x_k ∧ (xₙ > … > x₁ > x₀)
                        ∧ ⋀_{j=0}^n α_j(x_j)
                        ∧ ⋀_{j=1}^n (∀y)^{<x_j}_{>x_{j-1}} β_j(y)
                        ∧ (∀y)^{<x₀} β₀(y) ∧ (∀y)_{>xₙ} β_{n+1}(y) ]
```

is folded to (PDF p.5, verbatim):

```
A_k ∧ (B_{k+1} Until (A_{k+1} ∧ (B_{k+2} Until … (A_n ∧ (B_n Until (A_n ∧ □B_{n+1}))) …)))
   ∧ (Since-dual)
```

**Three faithfulness facts follow, each PDF-verified:**

1. **Point/interval types `α_j`, `β_j` are QUANTIFIER-FREE.** Lemma 5.1 (PDF p.7) states
   "where `α_i, β_i` are quantifier free". A Rabinovich ∃∀-block **never** carries a depth-1
   point type. Depth lives in the E[Σ] *atoms* (TL-formulas-as-unary-predicates), keeping the
   block FLAT.

2. **Higher FO quantifier depth is discharged by STRUCTURAL INDUCTION (Prop 4.3, PDF p.6), not
   nesting.** Proof by induction on the FO formula: negation via Prop 4.2, ∃ via Lemma 3.4.
   Each round **re-flattens** to a *new disjunction of flat ∃∀-formulas*. There is no
   depth-indexed nested characteristic anywhere in the construction.

3. **The arity discipline** (answering the task's KEY QUESTION): free variables (anchors) are
   capped at **≤ 2** (Lemma 3.2(2), PDF p.4); the existential **witness block grows** (`n`
   points `x₀ < … < xₙ`) but is **jointly ordered** and carries only quantifier-free types; the
   fold result is a set of **one-free-variable (arity-1) TL formulas** whose multi-point
   coupling is carried by **NAVIGATION** (the `Until` reach: each nested `Until` internally
   quantifies the next witness and couples it to the current point via the interval predicate
   `B_j`).

**Answer to the KEY QUESTION.** Rabinovich's fold *is* "constant arity" only in the sense that
each `F_i` is a one-free-variable TL formula — but that constancy is achieved by **navigation
(Until/Since reach) plus the E[Σ]-atom device**, NOT by a static `ZoneSpec n × NormalForm sig k 1`
product. The Lean encoding **mis-rendered** this navigated-monadic-over-E[Σ] fold as a **static
arity-1** fold. The "arity-1" the Lean design pinned is the arity of a *static* characteristic;
Rabinovich's "arity-1" is the arity of a *navigating* TL formula over an enriched alphabet. They
are different quantities.

### §2 — Where the Lean encoding diverges from the source (the pinpoint)

| Aspect | Rabinovich (PDF-verified) | Lean encoding | Divergence |
|--------|---------------------------|---------------|------------|
| Normal-form object | Flat ∃∀-block over **E[Σ]** (TL-atoms), Def 3.1 / Prop 3.5 p.4–5 | **Doets** depth-indexed `NormalForm sig k n`, quant layer over `NormalForm sig k (n+1)` (hover-confirmed) | **Wrong normal form.** Doets nesting ≠ Rabinovich flat ∃∀. |
| Point type at an ∃-point | **Quantifier-free** `α_j` (Lemma 5.1 p.7) | depth-`k` `χ : NormalForm sig k 1` (may be `k≥1`) | Depth-1 point types are impossible in Rabinovich; this is the object 327 cannot fold. |
| Multi-anchor coupling | **Navigation** — `Until`/`Since` reach (Prop 3.5 fold p.5) | **static** `ZoneSpec n` tuple + arity-1 `χ` (`EAtomDom`, NfEFold:69) | Navigation replaced by a static product → loses the `v`-vs-`{w,x,t}` coupling (the arity-4 residual). |
| Higher FO depth | **Structural induction / re-flatten** (Prop 4.3 p.6), using Prop 4.2 negation | fold a single depth-`k` characteristic in place (`nf_quant_layer_fold_k2_gate`) | No re-flattening step; the design tries to carry depth-2 in one nested object. |
| "E[Σ]-fold" citation | Def 4.1 = alphabet expansion (p.5), NOT a fold | cited as a "constant-arity E[Σ]-fold" | Mis-citation propagated from report 05 into the carrier design bet. |

**Consequence for report 05's central claims (the audit target).**
- Report 05 §"H3 Reference-Grounding" and §"Literature Grounding" assert the constant-arity E[Σ]
  fold is "the machine encoding of Rabinovich's normal-form characterization at one higher
  quantifier depth" and "faithful … the zone reconstruction IS the normal-form characterization."
  **This is FALSE as stated.** Rabinovich has no per-`(zone, depth-1 χ)` characterization; his
  characterization is a flat ∃∀-block over E[Σ] with quantifier-free types, folded by navigation.
- Report 05 correctly hedged that route (a) `nf_eval_nf1_cons_factor` "may be FALSE in clean
  form" and correctly gated it behind P1. **P1 (task 327) then PROVED it false for all routes.**
  The residual error is not the gating logic; it is the belief that route (b) "E[Σ] `efold_of_nfk`"
  would dodge the barrier "because [it] is designed exactly to avoid arity growth." The E[Σ]
  efold avoids arity growth precisely *by* pinning the characteristic to arity 1 — which is the
  barrier, not the escape.

### §3 — Deciding among (A) / (B) / (C)

- **(A) — REJECTED in its literal form.** (A) claims the faithful encoding uses *higher/growing
  static arity* and that pinning to 1 is the whole error. But Rabinovich's per-point types are
  **arity-1 and quantifier-free**; the growth is in the jointly-ordered *witness block* and the
  coupling is *navigational*, not a higher static per-point arity. (A) is *partly right* that G6
  (which bars the navigated characteristic) is a **self-imposed** restriction contradicting the
  source — but its prescription ("use higher static arity") is wrong.
- **(B) — HOLDS (primary).** Rabinovich's fold is *intrinsically* navigated (nested Until/Since,
  Prop 3.5 / Cor 5.4). The current design was explicitly chosen to *avoid* the navigated
  characteristic (G6, :1632–1634). The source shows navigation is **required**, so the
  constant-arity static carrier "targeted the wrong object." This is the verdict-bearing case.
- **(C) — HOLDS (mechanism of B).** The depth-2 normal form does **not** factor into
  per-`(zone, χ : NormalForm sig 1 1)` monadic obligations — that factorization has no
  counterpart in Rabinovich (his point types are quantifier-free/depth-0 over E[Σ]). 327's
  crux goal (`ZoneSpec 4` needed, `ZoneSpec 1` supplied) is the machine proof that this
  factorization is not how the object factors. **The reachable target** is a *disjunction of
  flat ∃∀-blocks over E[Σ]* with witness-growing brackets, folded by navigation.

### §4 — The correct NormalForm/carrier shape and its cost (the REDESIGN)

**Faithful representation** (Rabinovich-exact): the depth-2 obligation must be a **disjunction of
flat ∃∀-blocks over the E[Σ] alphabet** — jointly-ordered, *witness-growing* bracket, with
**quantifier-free** point/interval types (TL-formulas-as-atoms), folded by **navigating
`Until`/`Since`** (Prop 3.5), with higher FO depth discharged by **Prop 4.3 structural
induction** using the **landed** Prop 4.2 negation closure.

**These assets already exist in the tree** (so REDESIGN is not from scratch):

| Faithful ingredient | Landed Lean asset (verified) |
|---------------------|------------------------------|
| Witness-growing (arity-growing) two-anchor carrier — §5 bracket `[α₀,…,αₙ](z₀,z₁)`, witnesses grow, anchors capped ≤2 | `BracketEndCharCarrierV := NormalForm sig k 3 → VVecEA2` (`NfMultiAnchorBridge.lean:1872`); correctness spec `BracketCarrierCorrectV` (:1881) |
| Navigated fold literals (Until/Since reach) | `epL`/`epR` Since/Until, `bracketBuildLeft`/`bracketBuildRight` chains (Phase-1 blocks, :1676–1739) |
| **Prop 4.2 negation closure** (the hard induction step of Prop 4.3) | `neg_2var_vec_ea` (`EANegationClosure.lean:722`), `VVecEA2` machinery — LANDED, proven |
| Interior joint channel + pins (task 325/326) | `kvE_subChain2V` (:6955), `kvE_subBracket2V_sound_of_outer` (:7910), `_complete` (:8159) — interior zones only |

**Cost** (the "navigated-characteristic cost the current design was chosen to avoid"):
1. Abandon the constant-arity fold engine (`nf_quant_layer_fold_k2_gate`) and the `nfk`-split-kit
   (`nfk_assemble`/`nfk_dropFresh`/`nfk_zoneSpec` — never existed; do NOT build them).
2. Re-express each depth-1 sub-form's contribution through the **witness-growing `VVecEA2`**
   disjunction rather than a per-`(zone, depth-1 χ)` obligation — witness lists grow per disjunct
   (`S_L.permutations × S_R.permutations`, :1929–1931), so the carrier is larger and the
   soundness/completeness dischargers are per-*arrangement*, not per-*zone-pair*.
3. Wire the **Prop 4.3 induction** (re-flatten) explicitly, consuming landed `neg_2var_vec_ea`,
   rather than folding a single Doets depth-2 characteristic in place.
4. Navigation complexity: exterior-zone witnesses (`zPastX`/`zFutT`) are positioned by
   `Since`/`Until` **reach** (never an `x₁ < e_i` relative-position literal — LITMUS retained).

**Why the target is still REACHABLE (not RE-SCOPE at the completeness level):** the hardest
component of the faithful route — Prop 4.2 negation closure — is already landed and proven; the
witness-growing carrier type and its correctness spec are landed; the interior zones are landed
(task 326). What 327 refuted is one *engine shape*, not the completeness theorem. Hence REDESIGN,
not RE-SCOPE. (A narrower RE-SCOPE fallback is named in "Downstream Impact" should the navigated
fold + induction wiring exceed budget.)

---

## H3 Reference-Grounding — Tier 1 (literature-backed: Rabinovich 2014), 5-column

Every load-bearing claim grounded to BOTH a Rabinovich location (PDF-verified) AND a Lean
file:line (tree-verified this dispatch).

| Source | Prop / Location (PDF-verified) | Lean Identifier | Type Signature / State (tree-verified) | Status |
|--------|-------------------------------|-----------------|----------------------------------------|--------|
| Rabinovich | **Def 4.1**, p.5 — `E[Σ] = Σ ∪ {A \| A a TL formula}`, TL-atoms; **NOT a fold** | `EAtomDom` | `NfEFold.lean:69` `:= ZoneSpec n × NormalForm sig k 1` | **MIS-RENDERED** — Lean static product ≠ Def 4.1 alphabet expansion |
| Rabinovich | **Prop 3.5 fold**, p.5 — nested `Until`/`Since`, quantifier-free `α_j`/`β_j` | `epL`/`epR`, `bracketBuildLeft/Right` | Phase-1 blocks `NfMultiAnchorBridge.lean:1676–1739` | LANDED (navigated literals) but SET ASIDE for constant-arity fold |
| Rabinovich | **Prop 3.5 ∃∀-block**, p.5 — `∃xₙ…∃x₀`, jointly ordered, witness-growing | `BracketEndCharCarrierV` / `BracketCarrierCorrectV` | `NfMultiAnchorBridge.lean:1872` `NormalForm sig k 3 → VVecEA2`; :1881 | LANDED (witness-growing) — the faithful carrier shape |
| Rabinovich | **Lemma 3.2(2)**, p.4 — ≤2 free anchors | `VVecEA2.holds` two-point signature | `VecEAFormula:276` (anchors capped at type level) | LANDED — cap is a type invariant |
| Rabinovich | **Prop 4.2**, p.6 / §5 — negation closure of ∃∀ (≤2 free vars) over Dedekind chains | `neg_2var_vec_ea` | `EANegationClosure.lean:722` | **LANDED, PROVEN** — the hard step of the faithful route |
| Rabinovich | **Prop 4.3**, p.6 — every FO formula ≡ ∨ of ∃∀ by structural induction (re-flatten) | (no engine) | — | **MISSING** — the induction wiring the redesign must add |
| Rabinovich | **Prop 3.5 navigation** — coupling via `Until`/`Since` reach | `nfk_projFresh` / `χ : NormalForm sig 1 1` | `NfMultiAnchorBridge.lean:3668`; crux `:8788–8792` | **INSUFFICIENT** — arity-1 static; cannot carry navigated coupling (327 NO-GO) |
| Doets (not Rabinovich) | n-characteristics, Def 1.6.1 (per hover doc) | `NormalForm` | `NormalForm sig : ℕ→ℕ→Type`; depth k+1 `= (AtomKind→Bool)×(NormalForm sig k (n+1)→Bool)` | LANDED — but this is DOETS, a different normal form than Rabinovich's |
| Rabinovich | **Cor 5.4 / md:154–157** — `F_n:=α_n; F_{i-1}:=α_{i-1}∧(β_i Until F_i)` | `nf_quant_layer_fold_k2_gate` (proposed) | 327 crux `ZoneSpec 4` needed vs `ZoneSpec 1` supplied | **REFUTED** at constant arity (327 WHOLE-TASK NO-GO) |

---

## H5 Divergence Audit (focus_prompt contains "audit")

### Divergence table

| Target | Churn count | Last-attempted approach | Failure reason |
|--------|-------------|-------------------------|----------------|
| depth-1 arity-3 evaluation carrier | 1 (task 309 R2) | `VecEA2 1` monadic bracket | arity-4 residual `[x₁,w,x,t]`; needs navigated arity-3 char (G6-barred) |
| k=2 correctness gate, per-sub joint content | 2 (309 Ph 13.3, 13.35 = F3, F4) | uniformized channels (i)/(ii) | channels carry `nfk_projFresh σ` (σ.1) only; joint content rides `σ.2`, discarded |
| depth-2 outer quant-layer fold | 1 (task 327 P1) | constant-arity E[Σ] `efold` + `nfk`-split-kit | `ZoneSpec 4` needed, `ZoneSpec 1` supplied; false at all 3 routes |
| **root cause (all three)** | 3 strikes on ONE obstruction | static arity-1 characteristic vs navigated coupling | **the constant-arity design contradicts Rabinovich's navigated fold (Prop 3.5)** |

### Postmortem — root cause of repeated failures

The three failures are not three problems; they are one architectural mismatch surfacing at three
loci (inner eval, carrier channel, outer fold). The mismatch: the design adopted a **Doets nested
depth-indexed** normal form and a **static constant-arity** fold, then cited Rabinovich Def 4.1 /
Prop 4.3 as the faithfulness warrant. But Def 4.1 is an *alphabet expansion* (not a fold) and
Rabinovich's actual fold (Prop 3.5) is **navigated**, over **flat** ∃∀-blocks with
**quantifier-free** point types, with depth handled by **re-flattening induction** (Prop 4.3).
The constant-arity carrier was specifically built to *avoid* navigation (G6). Because navigation
is exactly the mechanism that carries multi-anchor coupling, every attempt to avoid it re-hit the
same arity-4 residual. G6 is therefore a **self-imposed** guard that fights the source.

### Sorry inventory

| Identifier | Current state | Type | Why stuck |
|------------|---------------|------|-----------|
| (none) | — | — | All three NO-GO records are inert `/-! -/` docs; **0 live `sorry`**, 0 partial carriers, 0 new axioms (327 summary; verified). No sorry to inventory. |

### Type-mismatch analysis

| Theorem / probe | Expected type | Actual type | Mismatch |
|-----------------|---------------|-------------|----------|
| `exact hmon.2.1 zs' χ'` (327 crux) | `zoneHolds M [x₁,w,x,t] zs' v` (`zs' : ZoneSpec 4`) | `zoneHolds M (fun _ ↦ x₁) ?m v` (`ZoneSpec 1`) | arity 4 vs 1 — the decisive certification |
| `exact h_atom sub_nf` (G6 residual) | arity-4 `(∃x₁ …[x₁,w,x,t]…) ↔ qnf.2 sub_nf` | arity-3 `h_atom : nf_eval_nf M 0 3 [w,x,t] qnf.1` | `qnf.2` discarded by atom-only carrier |
| `exact ⟨e 0, he⟩` (F4 probe B) | `nf_eval_nf M 1 4 (cons (e 0) [w,x,t]) σ` | `nf_eval_nf M 1 4 (insertEnv e t) σ` | provider rebinds `w,x` (`e 1=w, e 2=x` unprovable) |

### Corrected Lean-ready targets (exact signatures the next dispatch should attempt)

1. **Do NOT build** `nfk_assemble` / `nfk_dropFresh` / `nfk_zoneSpec` /
   `nf_eval_nf1_cons_factor` / `efold_of_nfk` — all bottom out on the refuted arity-1 factor.
2. **Target instead** a navigated fold over the landed witness-growing carrier:
   `theorem kvE_fold_navigated {sig} (M) (x t : M.carrier) (qnf : NormalForm sig k 3) :
   (BracketEndCharCarrierV-instance qnf).holds M atomMap x t ↔
   ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x fun _ => t)) qnf)` — i.e. discharge
   `BracketCarrierCorrectV` (`:1881`) for the k≥1 instance via `VVecEA2` witness-growth +
   `neg_2var_vec_ea` (`EANegationClosure:722`) for the negative/exclusion segments, NOT a
   per-`(zone, χ:NormalForm sig 1 1)` reduction.
3. **Wire Prop 4.3 induction** (re-flatten to `∨` of flat blocks) explicitly — the currently
   missing ingredient (H3 table row "Prop 4.3 … MISSING").

---

## Adversarial Self-Verification (H4, MANDATORY)

I attempted to REFUTE the verdict "REDESIGN / (B)+(C)" — actively hunting for a reading under
which 327's NO-GO is a fixable constant-arity artifact (GO), or under which the target is truly
unreachable (RE-SCOPE).

### Claim Verification Table

| Claim | Source / Counterexample tried | Verification Method | Confidence |
|-------|-------------------------------|---------------------|------------|
| `NormalForm` depth-`k+1` quant layer is arity-GROWING (`NormalForm sig k (n+1)`) and is a **Doets** characteristic | tried: maybe it is already Rabinovich-flat | `lean_hover_info`-confirmed type signature + hover doc "mirroring Doets' n-characteristics" | **High** |
| The fold E-atom pins the characteristic to **arity 1** (`NormalForm sig k 1`) | tried: maybe `k` there still carries anchors | `NfEFold.lean:69` `EAtomDom := ZoneSpec n × NormalForm sig k 1` (read) | **High** |
| **Def 4.1 is NOT a fold** (it is the E[Σ] alphabet expansion) | report 05 + Lean records repeatedly cite "Def 4.1 E[Σ]-fold" | **PDF p.5 read directly** (verbatim quote) | **High** |
| Rabinovich's point types `α_j` are **quantifier-free** (no depth-1 point type exists) | tried: maybe §5 allows quantified `α` | **PDF p.7 Lemma 5.1** "where `α_i, β_i` are quantifier free" (read) | **High** |
| Higher FO depth is handled by **induction/re-flatten** (Prop 4.3), not nesting | tried: maybe nesting is implicit | **PDF p.6 Prop 4.3** proof by structural induction (read) | **High** |
| The three records (G6/F4/k2) are ONE obstruction | tried: maybe F4 is a distinct carrier bug | read all three regions; all reduce to `ZoneSpec 4` needed vs `ZoneSpec 1`/`nfk_projFresh` supplied | **High** |
| 327's NO-GO is CORRECT (not an artifact fixable at arity-1) | tried route (c): any new arity-1 χ argument | 327 record :8815–8819 semantic argument (models differing only in inner-witness position, agreeing on all arity-1 projections, distinguished by LHS) + PDF navigation requirement | **High** |
| The faithful route is REACHABLE (REDESIGN, not RE-SCOPE) | tried: maybe Prop 4.2 is also missing → RE-SCOPE | `neg_2var_vec_ea` present & proven at `EANegationClosure:722`; `BracketEndCharCarrierV`/`BracketCarrierCorrectV` landed :1872/:1881 | **Medium-High** |
| Case (A) "higher static arity" is the fix | tried: is arity-growing STATIC carrier enough? | witness-growing `VecEA2 n` (:1848) is *witness* growth (still navigated brackets), not higher *static* per-point arity; PDF navigation is essential | **Medium-High** |
| Def 4.1 "iterated fold p.6 note" cited by Lean (:1919) exists | Lean cites a "Def 4.1 p.6 note on iterated folds" | **could NOT verify** — PDF p.5 Def 4.1 has one footnote (E[Σ] element notation), no "iterated fold" note; p.6 is Prop 4.2/4.3 | **Low — flagged** |

### Contradiction Log

**Resolved contradiction (the task's stated unresolved contradiction).** Report 05 ASSERTED
E[Σ] faithfulness + barrier-avoidance; task 327 PROVED clean-fold impossibility at arity-1.
**Resolution via precedence (primary source > prior artifact assertion):** the PDF shows report
05's faithfulness warrant rests on a mis-citation (Def 4.1 is not a fold) and a misreading
(Rabinovich's fold is navigated, not static-constant-arity). 327's machine proof is therefore
*consistent with the source*: the constant-arity object it refuted is not Rabinovich's object.
No unresolved contradiction remains — the two artifacts were measuring different objects; the
source adjudicates in 327's favor.

**One LOW-confidence residual (flagged, not resolved):** several Lean records cite a "Def 4.1
p.6 note on iterated folds" (`:1919`) that I could not locate in the PDF (p.5 Def 4.1 has only
the E[Σ]-element footnote; p.6 is Prop 4.2/4.3). Downstream risk: if such a note exists in a
version of the paper I did not read, it *might* license an iterated constant-arity fold. Resolving
check not yet performed: read the full PDF pp.1–4 and any appendix for a second Def-4.1 remark.
**This does not change the verdict** — even granting an iterated fold, the arity-1 characteristic
still cannot carry the navigated coupling (327's semantic argument at :8815–8819 is
representation-independent).

### Recommendations modified after verification

- **Initial instinct** was verdict (C) alone ("wrong factorization"). **Revised** to primary (B)
  with (C) as mechanism, after PDF p.5 confirmed the fold is *intrinsically navigated* — the
  actionable prescription is "adopt navigation," which is (B).
- **Considered RE-SCOPE**, then **downgraded to a fallback** only, after confirming Prop 4.2 is
  landed and the witness-growing carrier exists — the completeness target is reachable.

### Completeness confidence

**Medium-High.** Every Part-1 file:line and every Part-2 Rabinovich claim was verified against
the current tree / the PDF directly this dispatch. The single LOW item (the "iterated fold p.6
note") is flagged and shown non-decisive.

---

## Downstream Impact

### Task 321 (the audited architecture)
- **Report 05's foundational bet is REFUTED at the source level**, not merely at the provability
  gate: the P1 → {P2, P3} → v6 architecture is built on the constant-arity E[Σ] fold, which is
  both unprovable (327) AND unfaithful (this audit).
- **Action: `/revise 321` → v6 = REDESIGN** around the navigated / witness-growing route:
  consume the landed `BracketEndCharCarrierV` (:1872) + `neg_2var_vec_ea` (:722) + task-326
  interior closers; add the Prop 4.3 re-flatten induction; drop all `nfk`-split-kit / `efold_of_nfk`
  phases. If the navigated fold + induction wiring exceeds a single re-plan's budget, the
  **RE-SCOPE fallback** is: narrow `BracketCarrierCorrectVPrior` to the interior-zone + boundary
  fragment already reachable (task 326 + `epL`/`epR`/`ptW` point channels), deferring the full
  exterior-navigated completeness to a follow-up.
- Binding constraints preserved: purely additive; `kvE2_body` / `bracketEndChar_kvE2` /
  `kvE_subChain2V` / `BracketCarrierCorrectVPrior` / `EANegation` / F1–F4 records byte-identical;
  no `x₁ < e_i` literal (LITMUS).

### Tasks 328 (P2 engine) / 329 (P3 dischargers)
- **Premise NOT recoverable as stated.** Both were defined to build/consume the constant-arity
  fold engine (`nf_quant_layer_fold_k2_gate` + `nfk`-split-kit) that 327 refuted and this audit
  finds unfaithful. 327 already directs "do NOT start P2/P3."
- **Action:** ABANDON 328/329 as specified, OR REDEFINE — 328 → build the *navigated*
  witness-growing fold (`kvE_fold_navigated` shape above) over `BracketCarrierCorrectV`, not the
  constant-arity engine; 329 → per-*arrangement* dischargers over the `VVecEA2` channels
  (`epL`/`epR`/`ptW` + interior pins), not per-`(zone, χ:NormalForm sig 1 1)`. Cleanest is to fold
  the redefined work into 321 v6 rather than retain 328/329's constant-arity premise.

---

## Recommendation (concrete)

**VERDICT: REDESIGN.** Adopt the navigated / witness-growing representation faithful to
Rabinovich Prop 3.5 / Cor 5.4 (fold) + Prop 4.3 (re-flatten induction) over the E[Σ] alphabet
(Def 4.1), consuming the LANDED Prop 4.2 negation closure (`EANegationClosure:722`) and
witness-growing carrier (`NfMultiAnchorBridge:1872/1881`). Primary case **(B)**; mechanism **(C)**;
**(A)** rejected literally. Do NOT re-attempt any constant-arity-1 fold. `/revise 321` to v6 on
the navigated route (RE-SCOPE the correctness target only if v6 exceeds budget); ABANDON-or-redefine
328/329 off their refuted constant-arity premise.
