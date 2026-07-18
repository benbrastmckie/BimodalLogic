# Faithful E[Σ] negation path — retiring `KampPrior.lean:562` without an arity-4 engine

**Task 379, hard-mode research dispatch (H2/H3/H4/H5).** READ-ONLY: no `Theories/` edits; `lake
build` unaffected. Reference-grounding **Tier 1** (literature-backed, Rabinovich 2014). Primary
source read directly from PDF pages 4–6 (the `.md`/`.md.bak` transcription is corrupt — cited by
PDF page only). Adversarial self-verification pass included (§H4).

**Headline.** The `KampPrior.lean:562` mandate is *correct and now largely actionable*. Rabinovich's
faithful mechanism is unambiguous in the source (Def 3.1 / Def 4.1 / Prop 4.3), and — a finding the
`03` roadmap did not capture — **most of the E[Σ] re-architecture scaffold is already built and
sorry-free** on the `ExistsForallFormula`/`efSat`/`sigE` side, off the live import path. The
2-variable arbitrary-pin negation engine (`prop42_efSat_negation_general`) that report `06`
recommended building as "option (b)" **has since been landed, green.** The residual to retire `:562`
is now three concrete pieces (conjunction closure, the negation-case assembly, and the spine
rewire), not the near-total rebuild the `03` roadmap depicts. The one genuinely-unbuilt combinatorial
core is conjunction closure on the disjunctive object (`conjInterleave`), and the highest residual
risk is the completeness-interface rewire, not any recurrence of the K₄/arity-4 wall.

---

## 1. How Rabinovich ACTUALLY handles arity ≥ 2 (Q1) — the source mechanism, extracted

Read directly from PDF pp. 4–6. The mechanism has **four** load-bearing devices, and none of them
is an arity-4 (or arity-≥2) *joint type*:

1. **Atoms are unary throughout (Def 3.1, p.4).** An ∃∀-formula is
   `ψ(z₀,…,z_m) := ∃x_n…∃x₀ [ (⋀ₖ z_k = x_{i_k}) ∧ (x_n > … > x₀) ∧ ⋀_{j=0}^{n} α_j(x_j) ∧
   ⋀_{j=1}^{n} (∀y)_{>x_{j-1}}^{<x_j} β_j(y) ∧ (∀y)_{>x_n} β_{n+1}(y) ∧ (∀y)^{<x₀} β_0(y) ]`,
   where **α_j, β_j are quantifier-free formulas with ONE variable** (p.4, verbatim). The *only*
   binary relation anywhere is the linear order `<`, and it appears **solely** as the single
   descending chain `x_n > … > x₀` — a **total order on the existential witnesses (a path)**, never
   as an independent order-atom placed on every pair. There is no "joint type over a tuple"; the
   configuration's type is a **conjunction of unary point-types `α_j(x_j)` and unary interval-types
   `β_j`** quantified over the open interval `(x_{j-1}, x_j)`.

2. **Free variables are PINNED, not independent arity (Def 3.1, p.4).** The `m+1` free variables
   `z₀…z_m` are each identified with one existential witness via `z_k = x_{i_k}`, `i_k ∈ {0…n}`.
   A formula with `m+1` free variables therefore does **not** induce an `(m+1)`-ary joint type — the
   free variables merely *name* points along the single chain. Arity of free variables is decoupled
   from the (unary) arity of atoms.

3. **The ≤2-free-variable cap (Lemma 3.2(2), p.4).** "Every ∃∀-formula is equivalent to a
   conjunction of ∃∀-formulas with at most two free variables." This is the explicit device that
   bounds every downstream obligation — in particular the negation machinery (§2) — to **two** free
   variables. It is *why joint types over many points are never needed* (the KampPrior comment's own
   summary, corroborated verbatim here).

4. **E[Σ] folds PROCESSED DEPTH into unary atoms (Def 4.1, p.5 + collapse note, p.6).**
   `E[Σ] := Σ ∪ {A | A a TL(Until,Since)-formula over Σ}` — a **unary** predicate-name expansion;
   in the canonical expansion each `A` is interpreted as `{a | M,a ⊨ A}`. The collapse note (p.6):
   *a TL formula over E[Σ] predicates is equivalent to a TL formula over Σ, hence to an **atomic**
   formula in the canonical expansion.* So an already-processed subformula re-enters a larger ∃∀
   only as a **unary atom `α_j(x_j) = A(x_j)`**, quantifier-depth 0. Processed depth **collapses to a
   unary atom** instead of accumulating as arity.

**How this sidesteps the K₄ order-atom problem (the crux of Q1).** The repo's `NormalForm`
representation is the diverging party: `AtomKind.order (i j : Fin n) (h : i ≠ j)`
(`NormalForm.lean:60`) places an order atom on **every ordered pair**, so an arity-`n` normal form is
the complete graph `Kₙ` — and `NormalForm sig (k+1) n = (AtomKind sig n → Bool) × (NormalForm sig k
(n+1) → Bool)` (`rfl`, `ESigmaExpansion.lean:148` `raw_descent_grows_arity`) grows arity `n → n+1`
per depth descent, reaching arity 4 (= `K₄`) at `k ≥ 2`. A cut at any anchor separates nothing
because every pair is order-constrained. Rabinovich never incurs this because (a) his order is a
single **path** `x_n > … > x₀`, not a `Kₙ` of independent order-atoms, and (b) depth folds into
**unary** E[Σ]-atoms (device 4), so the depth-`(k+1)` obligation over `sig` at arity `n` is an
arity-**`n`** obligation over the expansion — `NormalForm (sigE sig F) 0 n = (AtomKind (sigE sig F) n
→ Bool)` (`rfl`, `esigma_target_is_arity_n`), the `Fin.cons x env` layer eliminated
(`esigma_descent`, `ESigmaExpansion.lean:170`). **Answer to Q1: Rabinovich does not reduce
arbitrary-arity ∃∀ formulas by collapsing them; he never forms them. Atoms are unary by construction
(Def 3.1); the ≤2-free-variable cap (Lemma 3.2(2)) bounds negation; and depth folds to unary atoms
(Def 4.1). The temporal translation therefore only ever faces unary (Prop 3.5) and 2-variable
(Prop 4.2) obligations.** This is a faithful mechanism, present in the source — not a gap to invent.

---

## 2. Negation-closure under E[Σ], and the 2-variable engine's role (Q2)

### 2a. `prop42_efSat_negation_general` is a REUSED PRIMITIVE, not orthogonal

Rabinovich's Prop 4.3 negation case (p.6, verbatim structure):

- **φ a single ∃∀-formula:** by Lemma 3.2(2) `φ ≡ ⋀ᵢ ψᵢ` (ψᵢ have ≤2 free vars); so `¬φ ≡ ∨ᵢ ¬ψᵢ`;
  by **Prop 4.2** each `¬ψᵢ ≡ ∨∃∀ γᵢ`; flatten to `∨ᵢ∨ⱼ γᵢʲ`. *(No conjunction closure here.)*
- **φ a disjunction `∨φᵢ` (the IH's actual shape, always ∨∃∀):** `¬φ ≡ ⋀ᵢ ¬φᵢ`; each `¬φᵢ ≡ ∨∃∀`
  by the above; then **`⋀` of ∨∃∀ ≡ ∨∃∀ by Lemma 3.4 conjunction-closure**. *(Conjunction closure
  is load-bearing here — confirms report `05`.)*

The 2-variable engine `prop42_efSat_negation_general` (`Prop42NegationGeneral.lean:977`, green,
sorry-free) **is exactly Prop 4.2** at the leaf of this recursion. Its mechanism is faithful to
Section 5 / PDF p.7: it splits the single ordered chain of the general two-free-variable object
`ψ(z₀,z₁)` at its two pinned points `z₀=x_m, z₁=x_k` into three consecutive pieces —
`belowFormula` (ψ₀, one-free-var → TL(Since) via Prop 3.5), `middleBracket` (φ, cap-free
endpoint-pinned, negated by `VVecEA2.negFix_iff` = Lemma 5.1), `aboveFormula` (ψ₁, one-free-var →
TL(Until)) — and reassembles `¬ψ = ¬ψ₀ ∨ ¬φ ∨ ¬ψ₁` by `VVecEA2.disj`
(`efSat_decompose_tl`, `:875`; `negLeftClauseTL`/`negRightClauseTL`; `prop42_efSat_negation_general`,
`:977`). So the reuse seam is precise:

> **Prop 4.3 negation case → (Lemma 3.4 conj-closure over disjuncts) → per-disjunct single-∃∀
> negation → (Lemma 3.2(2) `augTarget_iff`) → per-pair `pairProject` → `prop42_efSat_negation_general`.**

The engine is the **per-2-free-variable-projection base case**. It is reused, not orthogonal.

### 2b. The strict-order `z₀<z₁` gating seam — dissolved for K₄, benign trichotomy for gating

Two distinct questions were conflated by the prior construction task; the E[Σ] encoding resolves them
differently:

- **Does E[Σ] dissolve the K₄/arity wall?** **Yes, decisively.** `efSat`'s witness is a single
  `StrictMono x : Fin (n+1) → carrier` (a path), with **unary** `pointType`/`intervalType` and
  E[Σ]-unary atoms. There is no joint-arity type and no complete-graph of order-atoms. Consequently
  the anchor-split *works*: `gluedChain` (`ExistsForallLemmas.lean`) glues pairwise-projection chains
  into one global chain, and **`augTarget_iff` (Lemma 3.2(2), `:696`) holds at the arity-2 cap**,
  sorry-free. This is the exact operation that fails on `NormalForm` at arity 4 and succeeds here.

- **Does E[Σ] dissolve the `z₀<z₁` gating?** **Not by itself — but it renders it benign.** The engine
  is gated `env 0 < env 1` (`prop42_efSat_negation_general`, `:983`); the consumer
  `pairwiseProjections` (`ExistsForallLemmas.lean:138`) enumerates **all ordered pairs**
  `(k,l) ∈ Fin r × Fin r` (both `(k,l)` and `(l,k)`, plus the diagonal `(k,k)`), each evaluated on
  `![env k, env l]`. Because `x` is `StrictMono`, the pins fix the arrangement: `ψ.pin k ≠ ψ.pin l ⟹
  env k ≠ env l` (so one of the two orientations `(k,l)`/`(l,k)` in the enumeration satisfies
  `env·<env·`, matching the engine's gate), and `ψ.pin k = ψ.pin l ⟹ env k = env l` (a **degenerate
  1-free-variable** obligation, handled directly by Prop 3.5 negation as in `negLeftClause`). The
  engine already internally covers the reversed `m ≥ k` branch (returns `VVecEA2.trivialTrue`, sound
  because the object is unsatisfiable under `z₀<z₁`; `:995`). So the gating collapses to a **bounded
  trichotomy over a total order at the consumer boundary** — mechanical bookkeeping, not the
  intractable interface.

**Does this dissolve the interface question the prior construction task hit?** *The specific one, yes.*
Report `06` §3 diagnosed the blocker as: the *old* engine `prop42_veeSat_negation`
(`Prop42ExistsForall.lean:435`) only accepted `EndpointPinnedCapTrivial` inputs, while the consumer
(`augConjSat` over `pairwiseProjections`) feeds **arbitrary-pin, contentful-cap** objects; folding
caps to trivial is unsound (it discards the predicate content negation must invert). Report `06`'s
prescribed fix was "option (b): build a direct arbitrary-pin Prop 4.2." **That engine is now built**
(`prop42_efSat_negation_general`, arbitrary pins, contentful caps, three-piece TL-level split). The
cap-triviality interface mismatch is therefore *gone*. What remains is the (new but bounded)
trichotomy-lift from the `env0<env1`-gated engine to the unordered-pair enumeration — glue, not a wall.

---

## 3. H3 reference-grounding table (Rabinovich PDF → concept → Lean → status)

Cited by PDF page only (source `~/Projects/Literature/sources/rabinovich_2014/…pdf`). Status:
**exists** = built + sorry-free; **to-build** = genuine new content; **to-rearchitect** = structural
rewire of the live spine. Line estimates are for the *remaining* work.

| Rabinovich (PDF §/p.) | Concept | Target Lean signature / anchor | Status | Est. lines |
|---|---|---|---|---|
| Def 3.1, p.4 | ∃∀-object: ordered chain + unary α/β + pinned free vars | `ExistsForallFormula sig F r` (`n`, `pin`, `pointType`, `intervalType`); `efSat` (`ExistsForallFormula.lean:81–127`) | **exists** | 0 |
| Def 3.3, p.4 | ∨∃∀ (disjunction of ∃∀) | `VeeExistsForall sig F r`; `veeSat` (`VeeExistsForall.lean:35–43`) | **exists** | 0 |
| Lemma 3.2(2), p.4 | ≤2-free-var arity cap | `augTarget_iff` (`ExistsForallLemmas.lean:696`) | **exists** | 0 |
| Lemma 3.2(3), p.4 | ∃ closure of ∃∀ | `lemma_32_3` / `dropPin` (`ExistsForallLemmas.lean:191`) | **exists** | 0 |
| Lemma 3.4 (∨, ∃), p.5 | ∨∃∀ closed under disjunction, ∃ | `veeSat_append` (`:69`); `veeSat_exists` (`ExistsForallLemmas.lean:213`) | **exists** | 0 |
| **Lemma 3.2(1) / Lemma 3.4 (∧), p.4–5** | **∨∃∀ closed under CONJUNCTION** | `conjInterleave` + `conjInterleave_iff`; `veeConj` + `veeConj_iff` (VeeExistsForall) | **to-build** | 620–830 |
| Prop 3.5, p.5 | ∃∀ (1 free var) → TL(Until/Since) chain | `translateProp35` / `translateProp35_correct`; `translateRight`/`translateLeft` | **exists** | 0 |
| Prop 4.2 (Section 5 / p.7) | negation of ≤2-free-var ∃∀ → ∨∃∀ | `prop42_efSat_negation_general` + `efSat_decompose_tl` (`Prop42NegationGeneral.lean:977, 875`) | **exists** | 0 |
| Def 4.1 + collapse note, p.5–6 | E[Σ] unary expansion + canonical structure + atom-collapse | `sigE`, `canonExpand`, `atom_eval_new/_old`, `esigma_descent` (`ESigmaExpansion.lean:63,100,122,170`) | **exists** | 0 |
| Prop 4.3, p.6 | structural induction FO → ∨∃∀ (atom/lt/¬/∨/∃) | `translate : MonadicFormula sig m → VeeExistsForall sig F m` + uniform `_correct` (new; the Boneyard `Prop43.lean` scaffold is over `VVecEA_m` and BLOCKED — do not reuse) | **to-build** | 500–800 |
| Prop 4.3 ¬-case assembly | ¬(∨∃∀) via 3.2(2)+4.2+3.4-∧ | `efSat_negation_general` (single-∃∀, over unordered pairs) → `veeSat_negation` (∨∃∀) | **to-build** | 300–500 |
| Thm 4.4, p.6 | FO(1 free var) → TL = Prop 4.3 + Prop 3.5 | rewire `kamp_prior_expressive_completeness` / `nf_characterizable_temporal_prior`; delete `nf_nvar_exist_all_depths` incl. `:562` sorry | **to-rearchitect** | 300–600 |
| Def 4.1 `hcapture` discharge | fold each existential into a fresh E[Σ] atom | discharge `esigma_descent`'s `hcapture` on the live spine (Prop 3.5 / Lemma 3.2(2) instance) | **to-build** | 200–500 |

Assets marked **exists** are all confirmed sorry-free (grep audit: doc-comment "sorry" mentions only)
and sit **off the live import path** — `KampPrior.lean` does not import them, so building against them
never touches the green spine until the final rewire.

---

## 4. The faithful re-architecture path (phased) — closing `:562` without an arity-4 engine

The path *dissolves* the `_k+2` arm rather than filling it. Every step lands green + sorry-free + off
the live import path (new files under `Kamp/`, imported by nothing live) until the final rewire,
mirroring how `Prop42NegationGeneral.lean` / `ExistsForallLemmas.lean` already sit off-path.
**`prop42_efSat_negation_general` is reused verbatim as the per-pair base case in Phase β.**

### Phase α — Conjunction closure on the disjunctive object [to-build; the combinatorial core]
- **Deliver:** `conjInterleave (ψ₁ ψ₂ : ExistsForallFormula sig F r) : VeeExistsForall sig F r` +
  `conjInterleave_iff` (the ∃∀×∃∀ → ∨∃∀ order-preserving-merge closure, Lemma 3.2(1)); then
  `veeConj` + `veeConj_iff` (distribute ∧ over ∨, Lemma 3.4-∧).
- **Mechanism (faithful):** two `efSat` chains live in one carrier with one linear order; enumerate
  order-preserving merges of `Fin(n₁+1) ⊎ Fin(n₂+1)` (a **path merge**, not a joint type),
  conjoining unary point/interval types per merged slot. Merged object is again a single ordered
  chain — **no arity growth, no K₄.** Reference template: `BracketFormula.conjFull` recursion
  (`VecEAConjFull.lean:325`) for the type-merge bookkeeping.
- **Depends on:** existing foundations only. **Est. 620–830 lines** (report `06` §1: ~500–650 for
  `conjInterleave` alone; the (←) glue direction is short once the merge datatype is right). Highest
  combinatorial density; likely 2 sub-dispatches (def+forward, then backward).

### Phase β — Single-∃∀ negation over unordered pairs [to-build; reuses the built engine]
- **Deliver:** `efSat_negation_general (ψ : ExistsForallFormula sig F r) : ∃ Φ : VeeExistsForall …,
  ∀ env, StrictMono env → (¬ efSat N env ψ ↔ veeSat N env Φ)`.
- **Mechanism (faithful):** `¬efSat ψ` ↔ `¬augConjSat (augTarget ψ)` (`augTarget_iff`, Lemma 3.2(2),
  **exists**) ↔ `(∨_{(k,l)} ¬efSat (pairProject ψ k l) on ![env k, env l]) ∨ ¬efSat (existenceSentence
  ψ)`. Each per-pair `¬efSat (pairProject ψ k l)` is discharged by **`prop42_efSat_negation_general`**
  (Prop 4.2, **exists**) in the orientation the `StrictMono` pins force; the diagonal `pin k = pin l`
  is the 1-free-var Prop 3.5 negation; the existence sentence (`r=0`) negates via the same engine at
  arity 0/1. Flatten disjuncts via `veeSat_append` (**exists**).
- **Depends on:** α (only for the ∨∃∀ re-assembly if the pair-disjunction must itself be conjoined;
  the single-∃∀ case is pure De Morgan + engine). **Est. 300–500 lines**, mostly the trichotomy/pin
  bookkeeping and the existence-sentence negation.

### Phase γ — ∨∃∀ negation [to-build; consumes α + β]
- **Deliver:** `veeSat_negation (Φ : VeeExistsForall sig F r) : ∃ Φ', ∀ env, StrictMono env →
  (¬ veeSat N env Φ ↔ veeSat N env Φ')`.
- **Mechanism (faithful):** `¬veeSat (∨φᵢ) = ⋀ᵢ ¬φᵢ`; each `¬φᵢ` is ∨∃∀ by β; reassemble `⋀` of
  ∨∃∀ into ∨∃∀ by **`veeConj_iff`** (Phase α). This is precisely the paper's "closed under
  conjunction (Lemma 3.4)" step in the Prop 4.3 negation case (p.6). **Est. 100–200 lines** (glue).

### Phase δ — Structural Prop 4.3 over `MonadicFormula` [to-build; the crux, heavy reuse]
- **Deliver:** uniform `translate : MonadicFormula sig m → VeeExistsForall sig F m` + `translate_correct
  (∀ M atomMap env, StrictMono env → (veeSat (translate φ) ↔ eval φ))`, by **structural induction over
  the formula** (no NF-depth, no arity tower). Cases: **atom** (endpoint predicate); **lt** (decided
  by indices under `StrictMono`); **and** (`veeConj`, α); **or** (`veeSat_append`); **not** (Phase γ);
  **ex** (`veeSat_exists`, Lemma 3.4). Processed content enters as an E[Σ] atom (Def 4.1) — **no arity
  growth ever arises.**
- **Note:** do **not** revive `Prop43.lean` — it is over `VVecEA_m`/`MonadicFormula` and its uniform
  connective cases are documented BLOCKED (`Prop43.lean:120–170`). The new `translate` is over the
  `efSat`/`VeeExistsForall` object where the missing pieces (α, γ) are supplied by this plan.
- **Depends on:** α, β, γ. **Est. 500–800 lines.**

### Phase ε — Discharge `esigma_descent.hcapture` + Prop 3.5 lift to ∨∃∀ [to-build]
- **Deliver:** the ∨-lift of Prop 3.5 (`VeeExistsForall` with one free var → TL via `translateProp35`
  disjunct-wise) and the discharge of `esigma_descent`'s `hcapture` on the live spine (each folded
  existential captured by a fresh E[Σ] atom evaluated at the anchor). **Est. 200–500 lines.**

### Phase ζ — Rewire the spine + retire `:562` [to-rearchitect; highest interface risk]
- **Deliver:** re-express `kamp_prior_expressive_completeness` / `US_expressively_complete_over_prior`
  /`nf_characterizable_temporal_prior` through Thm 4.4 = Prop 4.3 (δ) + Prop 3.5 (ε); **delete the
  entire `nf_nvar_exist_all_depths` match, including the `:562` sorry.** Bridge the object language:
  the spine currently consumes `NormalForm sig k n`; the new path produces TL from `MonadicFormula`.
  Either translate `NormalForm → MonadicFormula` at the interface or restate the spine's completeness
  claim over `MonadicFormula`. **Verification:** `#print axioms completeness_discrete` no longer lists
  `sorryAx`. **Est. 300–600 lines.** (Phase I archival of the dead arity-4 apparatus is owned by
  task 359, post-rewire.)

**Where `prop42_efSat_negation_general` is reused (explicit):** Phase β, as the per-pair
`¬efSat (pairProject ψ k l)` discharger — the base case of the negation recursion. It is *not*
re-derived and *not* orthogonal; it is the landed Prop 4.2 primitive.

---

## 5. Cross-check of the `03` roadmap vs. Rabinovich + reconcile with `05`/`06` (Q3)

**The `03` roadmap is faithful in its *diagnosis* but materially STALE/divergent in its *inventory of
built assets*.** Corrections:

1. **`03` Phase A ("E[Σ] feasibility GO/NO-GO gate … must run first") is already GO — built.** `sigE`
   (`ESigmaExpansion.lean:63`) realizes Def 4.1 with `sig.preds ⊕ {A // A ∈ F}` and *derived*
   `Fintype`/`DecidableEq`; `esigma_descent` (`:170`) proves the arity-**preserving** descent with the
   `rfl` contrast facts `raw_descent_grows_arity`/`esigma_target_is_arity_n`. The roadmap's flagged
   "highest-risk unknown" — the `Fintype` faithfulness tension (§5 of `03`) — **is resolved**: the
   finite stage-indexed expansion works (`finite_F_suffices_per_stage`, `:90`). Phase A is not a
   pending gate; it has passed.
2. **`03` Phases B, C, D (E[Σ] layer, Def 3.1 object, Lemma 3.2/3.4) are substantially built.**
   `ExistsForallFormula`/`efSat` (Def 3.1), `augTarget_iff` (Lemma 3.2(2)), `lemma_32_3`/`dropPin`
   (Lemma 3.2(3)), `veeSat_append`/`veeSat_exists` (Lemma 3.4 ∨/∃), `canonExpand` + atom-collapse —
   all **exist, sorry-free.** The roadmap presents these as unbuilt "[NEW]" phases.
3. **`03` Phase F (Prop 4.2 re-target) is done as a from-scratch general engine**, not a "re-target of
   `VVecEA2.negFix_iff`": `prop42_efSat_negation_general` is the arbitrary-pin Prop 4.2 over `efSat`
   (with `negFix_iff` reused only for the cap-free middle piece).
4. **What `03` gets right and remains valid:** the *diagnosis* (the arity-4 obligation is off-paper;
   discharging `:562` in the present architecture needs a prohibited novel engine; the faithful route
   is the E[Σ]/Def 3.1 structural induction), the *strategic note* (do not discharge `:562` in place;
   dissolve the arm), and Phases **G, H, I** as the genuine remaining crux (= this report's Phases
   δ, ζ, and task 359 cleanup). `03`'s warning against adopting `NfEFold`'s `nf_eval_efold`
   (retains arity `n+1`) is also still correct and is respected by the `efSat` path.

**Reconciliation with `05` (do not re-tread; build on):** `05`'s verdict — conjunction-closure
(Lemma 3.2(1)/3.4-∧) is **load-bearing inside the negation case**, not off-path — is **confirmed by
the source** (Prop 4.3 negation case, ∨∃∀ sub-case, p.6) and is why **Phase α is on the critical
path** of this plan (it is not optional cleanup). `05`'s rebuttal of the "no conjunction case ⟹
off-path" non-sequitur stands.

**Reconciliation with `06` (do not re-tread; build on):** `06`'s "option (b)" — build a direct
arbitrary-pin Prop 4.2 rather than fold caps to trivial (option (a), unsound) — is **confirmed and now
LANDED** as `prop42_efSat_negation_general`. `06`'s step ordering (A: `conjInterleave`; B: `veeConj`;
C: general negation; D: Prop 4.3 + DoD) maps onto this report's Phases α, α, β/γ, δ/ζ. `06`'s
sequencing discipline (each green + sorry-free + off-path; do NOT force with a placeholder `sorry`)
is adopted verbatim. The one update: `06`'s step C is **partially complete** (the engine exists; the
unordered-pair assembly `efSat_negation_general` does not).

---

## H4. Adversarial self-verification pass

Applied the Claim Verification Bar to every load-bearing claim; challenged the proposed path for
recurrence of the K₄ / `z₀<z₁` walls.

### Claim verification table

| Claim | Source / counterexample probe | Verification method | Confidence |
|---|---|---|---|
| Rabinovich's α_j/β_j are unary; order is a single path, not Kₙ | PDF p.4 Def 3.1 read directly | PDF page image (pp.4) | High |
| ≤2-free-var cap is Lemma 3.2(2); bounds negation | PDF p.4; used in Prop 4.3 ¬-case p.6 | PDF page image (pp.4,6) | High |
| E[Σ] is unary + collapses TL-over-E[Σ] to an atom | PDF p.5 Def 4.1 + p.6 collapse note | PDF page image (pp.5–6) | High |
| `prop42_efSat_negation_general` exists, green, sorry-free, faithful to p.7 three-piece split | file read + `grep -c sorry` = 0 (doc-only) | `Prop42NegationGeneral.lean:977`; grep audit | High |
| `augTarget_iff` (Lemma 3.2(2)) exists, sorry-free | file read + grep | `ExistsForallLemmas.lean:696` | High |
| `sigE`/`esigma_descent` exist, arity-preserving, sorry-free | file read + grep (sorry = doc-only) | `ESigmaExpansion.lean:63,170` | High |
| Conjunction closure (`conjInterleave`) is UNBUILT | grep across `Kamp/` returned only a docstring hit | `grep -rn conjInterleave` (0 defs) | High |
| No structural Prop 4.3 over `efSat`/`VeeExistsForall` exists | grep; `Prop43.lean` is over `VVecEA_m`, BLOCKED | `grep`; `Prop43.lean:120–170` | High |
| K₄ source is `AtomKind.order` on every pair | file read | `NormalForm.lean:60` | High |
| E[Σ] path avoids K₄ (path merge, unary atoms) | reasoned from `efSat` = single `StrictMono` chain | file read of `efSat`, `gluedChain`, `augTarget_iff` | Medium-High |
| `z₀<z₁` gating reduces to benign trichotomy at consumer | reasoned from `pairwiseProjections` = all ordered pairs + `StrictMono` injectivity | file read `ExistsForallLemmas.lean:138`; not yet machine-checked as an assembled lemma | Medium |

### Refutation attempts (where could this hit the same walls?)

- **R1 — Could `conjInterleave` (Phase α) resurrect an arity-≥2 joint type / K₄?** *No.* The merge of
  two `StrictMono` chains is again a single `StrictMono` chain; types stay **unary** conjoined
  per-slot. There is no product-of-orders and no order-atom-per-pair. The risk is **combinatorial
  proof volume** (order-preserving merge enumeration + four-way type-origin bookkeeping), not a
  fundamental obstruction. **Residual risk: MEDIUM (effort/complexity), not a wall.**
- **R2 — Could the `z₀<z₁` gate re-block Phase β the way it blocked the prior task?** The prior block
  (report `06`) was a *cap-triviality type mismatch*, now removed by the general engine. The remaining
  gating is a trichotomy over a total order, covered by the all-ordered-pairs enumeration + diagonal.
  **BUT** this has **not** yet been assembled as a lemma — the `Medium` confidence row above. A
  careless implementation that tries to call the engine in the wrong orientation, or mishandles the
  `pin k = pin l` diagonal (which must route to the 1-free-var Prop 3.5 negation, not the pair engine),
  could stall. **Residual risk: MEDIUM — the seam is bounded but genuinely new glue.**
- **R3 — Is conjunction closure *really* required, or can Prop 4.3 be restructured to avoid it?**
  `Prop43.lean:169` gestures at a DNF/"single negation at top" restructuring. Report `05` adversarially
  rebutted this: with `and` primitive in `MonadicFormula` and the IH always delivering ∨∃∀, the
  negation case genuinely lands in the conjunction-closure sub-case (p.6). The source confirms it.
  **Conjunction closure is on the critical path. Residual risk: LOW that it can be avoided (it cannot).**
- **R4 — The spine rewire (Phase ζ): does the `NormalForm`↔`MonadicFormula` object-language gap hide a
  wall?** This is the **largest unquantified risk.** Retiring `:562` is not "delete the arm" — the
  completeness spine (`kamp_prior_expressive_completeness`, `no_gaps_discrete_model_surgery`) is stated
  over `NormalForm`, and the new path produces TL from `MonadicFormula`. The bridge (translate at the
  interface, or restate over `MonadicFormula`) and the discharge of `esigma_descent.hcapture` (Phase ε)
  are where the *real* mathematics of "connecting the two representations" lives. `hcapture` is
  currently a hypothesis, not discharged; its discharge is exactly the Prop 3.5 / Lemma 3.2(2) instance
  on the live spine. **Residual risk: HIGH on Phase ζ (+ε) — this is the true crux, not Phase α.**
- **R5 — Does the literature actually support the faithful unary route (or is this inventing a
  mechanism the source lacks)?** **The source supports it unambiguously** (Def 3.1 unary atoms +
  pinning; Lemma 3.2(2) cap; Def 4.1 unary E[Σ] + collapse; Prop 4.3 structural induction). This is
  **not** a case of the source genuinely lacking the mechanism. The prohibited object was the *arity-4
  realization engine* the repo's `NormalForm` forced — and Rabinovich indeed never incurs it. The
  faithful route is real. **This is a legitimate positive finding, not an invented one.**

### Contradiction log

No unresolved contradictions among the sources read. One apparent tension resolved: `03`'s framing
("Phase A gate must run first, everything conditional on GO") vs. the built state (`sigE`/`esigma_descent`
exist). Resolution by precedence (direct file evidence > older roadmap prose): **the gate has passed;
`03`'s Phase-A framing is stale.** Recorded in §5.

### Recommendations modified after verification

- Elevated **Phase ζ/ε (spine rewire + `hcapture` discharge)** from the roadmap's "structural, no new
  theorem content" framing to the **highest-risk, genuine-content crux** — R4 shows it is not
  mechanical.
- Down-scoped the overall effort relative to `03`: Phases A–F of `03` are largely **exists**; the
  actionable remainder is α, β, γ, δ, ε, ζ (this report), reusing the landed engine.

---

## 6. Direct answers (for the parent)

- **Q1:** Rabinovich never forms arity-≥2 joint types. Atoms are unary (Def 3.1, p.4); free vars are
  pinned to a single ordered chain (not independent arity); Lemma 3.2(2) (p.4) caps negation at 2 free
  vars; E[Σ] (Def 4.1, p.5) + the p.6 collapse fold processed depth into **unary** atoms. The K₄
  problem is a `NormalForm`-only artifact (`AtomKind.order` on every pair, `NormalForm.lean:60`); the
  `efSat` path is a single `StrictMono` **path**, so anchor-split/`augTarget_iff` succeed at arity-2.
- **Q2:** `prop42_efSat_negation_general` is a **reused primitive** — the per-2-free-variable-projection
  base case of the Prop 4.3 negation recursion (Phase β), reached via `augTarget_iff` (Lemma 3.2(2)).
  E[Σ] **dissolves the K₄/arity wall** (unary atoms + path merge) but **not** the `z₀<z₁` gate; the gate
  becomes a benign trichotomy over the total order at the consumer. The **specific** interface blocker
  report `06` hit (cap-triviality mismatch) **is dissolved** — precisely because the general engine
  report `06` prescribed has since been built.
- **Q3:** The `03` roadmap's *diagnosis* is faithful, but its *asset inventory is stale*: `sigE`,
  `esigma_descent`, the Def 3.1 object, Lemma 3.2(2)/(3), Lemma 3.4 (∨/∃), Prop 3.5, and Prop 4.2
  (general) are all **built + sorry-free**, not pending "[NEW]" phases; Phase A's "gate" has passed.
  Genuine remainder = conjunction closure (α), negation assembly (β/γ), structural Prop 4.3 (δ),
  Prop 3.5-lift + `hcapture` (ε), spine rewire (ζ). Reconciles with `05` (conjunction closure is
  load-bearing — confirmed, hence Phase α is critical-path) and `06` (option (b) engine — confirmed,
  landed).

## Key anchors (quick reference)

- Blocker + mandate: `KampPrior.lean:545–562`. K₄ source: `NormalForm.lean:60` (`AtomKind.order`).
- Built E[Σ]/`efSat` scaffold (all sorry-free, off-path): `ExistsForallFormula.lean:81–127`;
  `ExistsForallLemmas.lean:138,191,213,325–351,696`; `VeeExistsForall.lean:35–69`;
  `ESigmaExpansion.lean:63,100,122,148,154,170`; `Prop42NegationGeneral.lean:875,977`;
  `translateProp35` (`Prop35Assembly.lean`).
- BLOCKED / do-not-reuse: `Prop43.lean:120–170` (uniform Prop 4.3 over `VVecEA_m`);
  vacuity guard `EANegationClosure.lean:748` (`neg_2var_vec_ea`), `Prop42Vacuity.lean`.
- Rabinovich PDF pp. 4–6 (Def 3.1, Lemma 3.2, Lemma 3.4, Prop 3.5, Def 4.1, Prop 4.2, Prop 4.3,
  Thm 4.4), p.7 (Prop 4.2 / Lemma 5.1 proof). Cite by page; `.md` corrupt.

**Durable-anchor note:** the eventual `Theories/` headers for the new modules must cite Rabinovich
PDF pages and sibling module/section names (e.g. "the `efSat` three-piece split,
`Prop42NegationGeneral`"), never task numbers (per `no-task-references-in-deliverables.md`). Task
numbers in this `specs/` report are permitted.
