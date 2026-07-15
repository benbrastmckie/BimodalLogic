# Task 376 — Is the seam refutation a U/S expressive gap (Stavi), or something else?

**Session**: sess_1784138518_4af6d5 · **Agent**: lean-research-hard-agent (H2/H3/H4) · **Date**: 2026-07-15
**Mode**: lean4 `--hard --lit` · reference grounding **Tier 1** (literature-backed)
**Focus**: proof bug or genuine expressive gap (Stavi)
**Machine artifact**: `specs/376_arity_general_zone_decomposed_char_engine/reports/05_expressive-gap-probe.lean`
— compiled `lake env lean`, **exit 0, zero warnings**. Three theorems, all sorry-free and axiom-clean
(`#print axioms` = `[propext, Classical.choice, Quot.sound]`, no `sorryAx`).

---

## VERDICT: **HYPOTHESIS REFUTED** — the gap is NOT the same obstruction. Do not pivot to Stavi.

The reframing hypothesis is **wrong**, and it is wrong for a reason that is machine-checked rather
than argued: **the seam refutation never mentions the object language at all.**

I generalized the reports/02+03 refutation by replacing the temporal-truth side with an *opaque*
predicate `truth : M.carrier → NormalForm sig (k+1) 4 → Prop`. The identical proof goes through
(`crossRender_languageIndependent`, sorry-free, axiom-clean). Since no property of `Formula`,
`temporal_truth`, `U`, or `S` is used anywhere, **no change to the connective set can affect the
outcome**. To make this concrete rather than abstract, I instantiated the generalization at the
repo's *own* Stavi semantics with an arbitrary Stavi-valued char engine:

```
staviSeam_refuted  -- compiled, sorry-free, axiom-clean
  (charStavi : (j : Nat) → NormalForm sig j 4 → StaviFormula)   -- ANY Stavi char engine
  (iff_w0 : ∀ σ u, stavi_temporal_truth M atomMap u (charStavi (k+1) σ) ↔ nf_eval[u,w0,x,t] σ)
  (iff_w' : ∀ σ u, stavi_temporal_truth M atomMap u (charStavi (k+1) σ) ↔ nf_eval[u,w',x,t] σ)
  : False
```

**A Stavi-valued char engine dies at exactly the same diagonal, by the same proof.** Adopting
Stavi connectives buys the seam nothing whatsoever. This is not a judgement call — it is a
compiled theorem covering *every possible* Stavi char engine, including ones not yet written.

Three further facts independently confirm the refutation of the hypothesis:

1. **A separating witness exists.** Over **(ℝ,<) with trivial interp** — a Dedekind-complete,
   gap-free flow where GHR93 says plainly "*The case of Dedekind complete flows is simple. Since
   and until form a G_j-basis*" (p.93), so U/S is already expressively complete and Stavi is
   redundant — the seam refutation still **fires** (ℝ is order-homogeneous fixing `(-∞,t]`). The
   refutation lives where the U/S gap is *absent*. The two cannot be the same obstruction.
2. **Gappedness is not a hypothesis of the refutation.** `crossRender_languageIndependent`
   assumes only `M : OrderedMonadicStructure sig` (= `MonadicStructure` + `LinearOrder`,
   `MonadicFO.lean:103-104`) and two distinct points. No density, no gaps, no Dedekind
   (in)completeness. Gappedness — the entire subject matter of GHR93 Lemma 3 — appears nowhere.
3. **The premise of the hypothesis is factually incorrect.** Stavi is *not* an unnamed scope
   change: it is **already fully formalized in this repo** (`StaviConnectives.lean:135`
   `StaviFormula`, `:157` `stavi_temporal_truth`, plus `EFGames/StaviCompleteness.lean`). If Stavi
   were the fix, it was already reachable without any scope change at all.

**The good news**: this is a clean refutation that costs the project nothing and saves it from a
large, wrong scope change. The reports/03 Frozen-Constraint Assessment (routes A/B/C) **stands
unmodified** — and, as §4 below shows, the literature actively *endorses* its route A.

---

## Q1 — What exactly is the U/S expressive gap over gapped time?

All page citations are to the source PDF (`sources/gabbay_1993/Gabbay_Hodkinson_Reynolds_1993_
Temporal_expressive_completeness_gaps.pdf`), verified this session against the `.md` conversions
(see §Fidelity below).

**The setting** (Def 8.1, p.108) — and this is the crux:

- Monadic FO side: "*first order formulas φ(x) in the 'monadic' language with `=`, `<` and a unary
  relation symbol Q for every atom q ∈ L*". **One free variable `x`. No constants.**
- Temporal side: "*a temporal formula will be one built from the atoms of L using the Boolean
  connectives and the binary temporal connectives U, S, U' and S'*". **No constants. No parameters.**
- Structures: `N = (T,<,h)` with `h : L → P(T)` — order plus a valuation, **no distinguished points**.

**The statement** (Theorem 3 [GPSS], p.97; formalized p.108-109):

> `{U,S,U',S'}` is expressively complete over all linear time — for all L-formulas **φ(x)** there
> is a temporal formula A such that for all **t ∈ N**, `N ⊨ φ(t)` iff `N ⊨ A(t)`.

**The precise flow class where U/S fails** (Lemmas 2 and 3, p.97):

| Result | Statement | Flow class |
|---|---|---|
| Lemma 2 (p.97) | `{U,S}` **is** expressively complete; "*Kamp's pioneering theorem is then a special case*" | flows with **only isolated gaps** (incl. all Dedekind-complete flows) |
| Lemma 3 (p.97) | `{U,S}` **is not** expressively complete | **general** linear time; a **single non-isolated gap** suffices |

A gap is "*a supremum-less non-empty proper initial segment of the order*"; "*Dedekind complete
orders then are those without gaps*" (p.93-94).

**The counterexample property** (Lemma 3 proof, p.97): the flow `T` is built from copies of `Z`
(one per negative integer, then one per integer), with a single non-isolated gap between the two
parts. The inexpressible property is **γ₀⁻(p)** — "there is an *isolated* p-gap just behind" — a
**gap-sensitive unary property**. The mechanism is *indistinguishability*: on "nice" p-structures
(p constant on each Z-copy; p and ¬p both cofinal each way), an induction shows **every `{U,S}`
formula collapses to one of `p`, `¬p`, `⊤`, `⊥`** — too coarse to track γ₀⁻, which two nice
structures disagree on.

**So the U/S gap is:** a gap *between two one-dimensional, parameter-free languages*
(`{U,S}` ⊊ `{U,S,U',S'}`), measured against monadic FO **in one free variable**, biting **only**
on flows with non-isolated gaps. Stavi's `U'`/`S'` close it by adding the power to see *across* a
gap — while remaining unary and parameter-free.

---

## Q2 — Is that the SAME obstruction as the seam refutations? **No.** (This is the deliverable.)

Both arguments involve (ℚ,<), and that coincidence is what generated the hypothesis. It is a
coincidence **of witness**, not **of mechanism**. Side by side:

| | **GHR93 U/S gap** | **Seam refutation** (reports/02+03) |
|---|---|---|
| What is compared | `{U,S}`-definable sets vs monadic-FO-definable sets | a **1-point** truth-set vs a **4-point** relation's fiber |
| Free variables / dimension | 1 vs 1 (Def 8.1, p.108) | **1 vs 4** — `truth u σ` vs `nf_eval[u,w,x,t] σ` |
| Bites when | flow has a **non-isolated gap** (Lemma 3, p.97) | model has an **anchor-fixing automorphism** moving `w0↦w'` |
| Fails to bite when | only isolated gaps (Lemma 2) — e.g. **(ℝ,<)**, **(ℤ,<)** | anchors are **rigid/definable** (no such automorphism) |
| Depends on the language? | **Yes** — it *is* a statement about the connective set | **No** — `crossRender_languageIndependent` (compiled) |
| Depends on gaps? | **Yes**, essentially | **No** — no gap/density hypothesis appears |
| Fixed by adding connectives? | **Yes** — that is Theorem 3 | **No** — `staviSeam_refuted` (compiled) |

The two rows that settle it are the last three, and all three are machine-checked.

### The decisive separating witness: (ℝ,<) with trivial interp

- **Gap side**: ℝ is Dedekind complete ⟹ no gaps (p.93-94 definition) ⟹ Lemma 2 applies ⟹ `{U,S}`
  is **already expressively complete**; GHR93 p.93 states it outright ("*Since and until form a
  G_j-basis*"). **Stavi is redundant here — U'(A,B) is literally definable from U/S** by the Lemma 2
  identity. So the U/S gap **does not exist** in this flow.
- **Seam side**: ℝ with trivial interp is order-homogeneous fixing `(-∞,t]` pointwise — for
  `w0, w' > t` there is an increasing bijection of ℝ fixing `(-∞,t]` and mapping `w0 ↦ w'`
  (piecewise-linear), trivially preserving a constant interp. So reports/03's render-symmetry
  transport applies and the seam refutation **fires in full**.

**A flow where the U/S gap is absent and the seam refutation is present.** The obstructions are
therefore distinct — and since the refutation survives in the very flows where Stavi is *provably
definable away*, Stavi cannot be its cure. (This is robust to the one soft spot in the source: §2
(p.93) and Def 8.3 (p.109) treat ±∞ slightly differently. Either way ℝ's gaps are *at worst
isolated*, so Lemma 2 applies and the conclusion is unchanged.)

### What the refutation actually turns on — stated exactly

The orchestrator's framing was right about the mechanism and only wrong about its classification:

> `charFib`'s truth at the evaluation point is `w`-independent, so an anchor-fixing automorphism
> transports the biconditional between distinct renders `w0 ≠ w'`.

That is correct, and it is **not** the U/S insufficiency mechanism (which is an
*indistinguishability/collapse* argument over nice structures, p.97 — not an automorphism
argument, and not about parameters at all). It is the classical **automorphism-invariance
criterion for undefinability**: a definable set must be invariant under every automorphism fixing
its parameters. Since `charFib σ` is a *parameter-free* formula, its truth-set is invariant under
**every** interp-preserving order-automorphism; the seam demands it equal the `w`-fiber of a
relation that such an automorphism *moves*. Contradiction.

**Crucially, that criterion is language-independent.** Automorphism invariance holds for *any*
language whose semantics is defined compositionally from `<` and `interp` — U/S, U/S+Stavi, full
monadic FO, even L_∞ω. This is exactly why `crossRender_languageIndependent` compiles: enriching
connectives never escapes an invariance argument. **Anything you can add to the connective set,
you can also transport.**

---

## Q3 — What Stavi would add, and what it would cost. **Moot — twice over.**

Answered for completeness, since the answer is more decisive than "not needed":

1. **Stavi is already here.** `StaviConnectives.lean:135` defines `StaviFormula` (`stavi_untl`,
   `stavi_snce` = `U'`, `S'`); `:157` defines `stavi_temporal_truth` with the GHR93 FO table for
   `U'` inlined. `EFGames/StaviCompleteness.lean` targets `stavi_expressive_completeness` (3 open
   sorries at :2405, :2487, :2857 per its header). Adopting Stavi is **not** a scope change beyond
   routes A/B/C — it is an *existing* asset. The hypothesis's premise ("a scope change none of
   routes A/B/C currently name") is factually mistaken.

2. **The type signature already forecloses it.** Compare:
   ```
   temporal_truth       M atomMap (t : M.carrier) : Formula      → Prop
   stavi_temporal_truth M atomMap (t : M.carrier) : StaviFormula → Prop   -- StaviConnectives.lean:157
   ```
   **Both take exactly ONE point.** Stavi adds constructors to the *formula* argument; it does not
   add a `w` slot to the *point* argument. The seam needs a second point. No connective can supply
   one — connectives change which 1-ary sets are definable, never the arity. **This is visible in
   the type, before any semantics is chosen**, which is precisely why `staviSeam_refuted` needs no
   new proof: it is the same proof with a different opaque instantiation.

3. **Would it change the object language (`Theories/Bimodal/Syntax/`)?** It would not need to —
   `StaviFormula` is defined in the Metalogic layer wrapping `Syntax.Formula` via `| base (φ :
   Formula)`, deliberately keeping TM's object language untouched. Moot regardless, per (2).

4. **Does Stavi even apply to the repo's intended flows?** The repo's temporal domain is
   parametric (`Semantics/Validity.lean:32`: "*Temporal types include Int, Rat, Real, and custom
   bounded types*"), with a distinguished discrete fragment (`valid_discrete`, `Validity.lean:180`,
   for the DF/DP discreteness axioms). **For the discrete fragment the repo has already proved
   Stavi vacuous**: `flatten_stavi` (`StaviConnectives.lean:441`) maps `U'`/`S'` to `⊥` because
   "*U'(A,B) and S'(A,B) are ALWAYS FALSE on discrete orders (no Dedekind gaps exist)*", and
   `flatten_stavi_correct` (`:492`) proves this sound. So on discrete flows Stavi is **provably
   redundant, in-repo**. It is live only for the `Rat`-like flows — which is exactly where the
   *homogeneity* (not the gappedness) makes the seam refutation bite.

---

## Q4 — What the obstruction actually is, in classical terms (and its name)

**It is a dimension/arity mismatch plus anchor-undefinability — not an expressiveness deficiency.**

The literature does offer a name, and GHR93 supplies it on **p.93**, in the framing sentences
before Def 1.6:

> "*Of special interest for applications are one or two dimensional temporal logics over a linear
> flow of time. In intuitive terms we are evaluating formulas at points or at intervals (or pairs
> of points).*"

The classical parameter is **dimension**: how many points a formula is evaluated at. GHR93 Def 1.6
then defines pure past/future and separation strictly for **one-dimensional** connectives, and
Theorem 2 (p.93) ties separation to a `G_j`-basis in that same one-dimensional setting.

Against that vocabulary the two problems are cleanly different, and neither is a proof bug:

- **GHR93's problem**: *within* dimension 1, which connective sets are expressively complete for
  monadic FO in **one** free variable? Answer: `{U,S}` iff only isolated gaps (Lemma 2); otherwise
  you need Stavi (Theorem 3). **A question about connectives, at fixed dimension.**
- **The seam's problem**: the seam asks a **dimension-1** object (`temporal_truth u (charFib σ)`,
  one evaluation point, no constants) to be equivalent to a **dimension-4** object
  (`nf_eval[u,w,x,t] σ`). That is not a question about connectives at all — it is a **type error
  in the dimension**, which is why it survives every language change. The repo's own task slug
  names it: **`arity_general_zone_decomposed_char_engine`**. *The arity was the problem all along.*

The precise classical statement of why it cannot be patched: `w` is not **definable** from the
anchors `(x,t)` in a homogeneous model. The governing principle is the **automorphism-invariance
criterion for undefinability** (the elementary direction of Svenonius/Beth-style definability
theory): a set definable with parameters `P` is invariant under `Aut(M / P)`. Homogeneous flows
have `Aut(M / {x,t})` acting non-trivially on the renders, so **no formula in any invariant
language** — however many connectives you add — can single out one render's fiber.

There are exactly two classical escapes, and both are already in reports/03's route list:

- **Give the formula the parameter** → `charFib w σ`. Classically: move from a one-dimensional to
  an **anchored / multi-dimensional (two-dimensional)** temporal logic — precisely the distinction
  GHR93 p.93 draws. **This is reports/03 route (A)**, and it is the classically correct fix. Note
  how Kamp-style proofs normally dodge this: the characteristic formula is evaluated *at* the
  anchor and the anchor is internalized by U/S nesting, so no parameter is ever needed. This seam
  broke that discipline by trying to characterize a 4-anchor tuple with a 1-point formula.
- **Make the anchors definable** → restrict to flows with no non-trivial anchor-fixing
  automorphism. **This is reports/03 route (C)**.

**Caveat on route (C), flagged for the plan (Medium confidence — argued, not compiled).**
Restricting to *discrete* flows is **not** sufficient to rescue the `∀ w` seam, and the
distinction matters. The automorphism is only needed to manufacture the *second* iff in the `∃ w`
form (reports/03). The `∀ w` form (reports/02 Theorem 1) needs **no automorphism at all** — only
two distinct points that both render `qnf`, i.e. that share a **depth-(k+2) characteristic**. At
*bounded* depth, distinct points can share a characteristic even in rigid flows like (ℤ,<) (e.g.
two points both "far future of `t`" beyond the depth's discriminating power). So route (C)'s real
requirement is **per-`qnf` render-uniqueness at depth k+2**, which is strictly stronger than
discreteness and is not obviously satisfiable uniformly. **If the plan pursues route (C), this
should be certified first** — it is a ~1-phase probe, and it is the cheapest of the three routes to
kill or confirm.

---

## Reference grounding (Tier 1)

| Source | Prop / Location | Lean identifier | Type signature / fact | Status |
|--------|-----------------|-----------------|-----------------------|--------|
| GHR93 Def 8.1 (**p.108**) | expressive-completeness setting | — | temporal formulas built from atoms + Booleans + `U,S,U',S'`; monadic FO `φ(x)` over `=,<,Q`; **one free variable, no constants** | **PDF-verified this session** (`pdftotext -f 20-21` matches `.md`) |
| GHR93 Theorem 3 [GPSS] (**p.97**, formalized p.108-109) | `{U,S,U',S'}` expressively complete over all linear time | `stavi_expressive_completeness` (target) | `∀ φ(x) ∃ A ∀ t, N ⊨ φ(t) ↔ N ⊨ A(t)` — **unary** | **PDF-verified**; repo target has 3 sorries (`StaviCompleteness.lean` header: :2405, :2487, :2857) |
| GHR93 Lemma 2 (**p.97**) | only-isolated-gaps ⟹ `{U,S}` complete; "*Kamp's … theorem is a special case*" | `flatten_stavi_correct` (discrete analogue) | `U'(A,B) = γ⁺(B) ∧ U(¬B, γ⁺(B) ∨ A)` | **PDF-verified** |
| GHR93 **p.93** | "*Dedekind complete flows … Since and until form a G_j-basis*" | — | ⟹ Stavi redundant over (ℝ,<) | **PDF-verified** — grounds the separating witness |
| GHR93 Lemma 3 (**p.97**) | `{U,S}` not complete in general linear time | — | flow `T` = Z-copies, single non-isolated gap; `γ₀⁻(p)` inexpressible; nice-structure collapse to `p/¬p/⊤/⊥` | **PDF-verified** |
| GHR93 §2 (**p.93-94**) | gap = supremum-less non-empty proper initial segment; Dedekind complete = gapless | — | "*nowhere in the rationals is there a gap of any order at all*" | **PDF-verified** |
| GHR93 **p.93** (pre-Def 1.6) | "*one or two dimensional temporal logics … evaluating formulas at points or at … pairs of points*" | — | the classical **name** for the seam obstruction: **dimension** | **PDF-verified** |
| Stavi connectives (repo) | `StaviConnectives.lean:135` | `StaviFormula` | `base (φ : Formula) \| stavi_untl \| stavi_snce \| …` — wraps Syntax, does not alter it | Read-confirmed |
| Stavi semantics (repo) | `StaviConnectives.lean:157` | `stavi_temporal_truth` | `M → atomMap → (t : M.carrier) → StaviFormula → Prop` — **ONE point, same as `temporal_truth`** | Read-confirmed — the arity point, in the type |
| Stavi vacuous on discrete (repo) | `StaviConnectives.lean:441,492` | `flatten_stavi`, `flatten_stavi_correct` | `U'`/`S' ↦ ⊥`; "*ALWAYS FALSE on discrete orders*" | Read-confirmed |
| Seam `∀ M` range | `MonadicFO.lean:103-104` | `OrderedMonadicStructure` | `MonadicStructure sig` + `carrier_order : LinearOrder carrier` — **no density/Dedekind/gap constraint** | Read-confirmed |
| Repo flow class | `Semantics/Validity.lean:32,180` | `valid_discrete` | "*Temporal types include Int, Rat, Real*"; discrete fragment for DF/DP | Read-confirmed |
| **Language-independence** | this report | `crossRender_languageIndependent` (probe) | opaque `truth : M.carrier → NormalForm sig (k+1) 4 → Prop` ⟹ `False` | **compiled sorry-free, axiom-clean** |
| **Faithfulness** | this report | `crossRender_plainUS` (probe) | reports/03 `crossRender_from_two_iffs` = the `temporal_truth` instance | **compiled sorry-free, axiom-clean** |
| **Stavi refuted** | this report | `staviSeam_refuted` (probe) | ANY `charStavi` + `stavi_temporal_truth` ⟹ `False` | **compiled sorry-free, axiom-clean** |

### Fidelity (binding hazard — discharged for every load-bearing claim)

The sub-index flags `gabbay_1993_sec03`/`sec05` with `provenance_fidelity: null`. **I verified every
load-bearing claim against the source PDF this session** (`pdftotext` at printed pp. 93, 97,
108-109; PDF page = printed − 88). The `.md` conversions **match the PDF text layer** at all cited
points — no drops or inversions of the kind that afflict `rabinovich_2014`.

**Residual disclosed**: this volume is scanned, so `pdftotext` returns the *same OCR layer* the
`.md` was derived from. My check therefore proves *conversion* fidelity, not *OCR* fidelity. The
OCR is visibly mangled in glyphs (`ί/` for `U`, `7` for `γ`) but the cited sentences are legible
and internally consistent across three independent sections, and Theorem 3 / Lemma 2 / Lemma 3 are
the standard, widely-known GPSS-Stavi and Kamp results. Confidence **High**. No verdict here rests
on a marginal reading: the verdict rests on the **compiled** probe, with the literature supplying
only the *classification*.

---

## Adversarial Self-Verification

Per H4 I attacked hardest the claim with the most expensive consequence if wrong. Note the risk is
**asymmetric**: a false "same gap" sends the project on a large wrong scope change (the failure
mode the orchestrator explicitly asked me to guard against), while a false "not the same gap"
merely leaves routes A/B/C in place — where reports/03 already left them. I therefore tried to
*prove the hypothesis right* and failed; the record is below.

| Claim | Source/Counterexample |
|-------|------------------------|
| The refutation is independent of the object language | `crossRender_languageIndependent` — opaque `truth`, compiled `lake env lean` exit 0, `#print axioms` = `[propext, Classical.choice, Quot.sound]`, no `sorryAx` |
| The generalization is faithful (not a weaker cousin) | `crossRender_plainUS` derives reports/03's `crossRender_from_two_iffs` verbatim as the `temporal_truth` instance — compiled, axiom-clean |
| **Adding Stavi does not rescue the seam** | `staviSeam_refuted` — repo's own `stavi_temporal_truth` + **arbitrary** `charStavi`, compiled sorry-free, axiom-clean |
| The U/S gap is about a **unary** language | GHR93 Def 8.1 **p.108**, PDF-verified: "*first order formulas φ(x)*"; Theorem 3 quantifies `∀ t, N ⊨ φ(t) ↔ N ⊨ A(t)` |
| The U/S gap requires **non-isolated gaps** | GHR93 Lemma 2 vs Lemma 3, **p.97**, PDF-verified |
| The seam refutation requires **no** gaps | `crossRender_languageIndependent` hypotheses: `M : OrderedMonadicStructure` (`MonadicFO.lean:103-104` = `MonadicStructure` + `LinearOrder` only) + `w' ≠ w0`. Gappedness is not in the statement |
| **Separating witness**: refutation fires where the U/S gap is absent | (ℝ,<) trivial interp: Dedekind complete ⟹ gapless (p.93-94) ⟹ Lemma 2 ⟹ U/S complete, and p.93 "*Since and until form a G_j-basis*"; yet ℝ is homogeneous fixing `(-∞,t]` ⟹ reports/03 transport applies |
| Stavi is already in-repo (premise of hypothesis false) | `StaviConnectives.lean:135` (`StaviFormula`), `:157` (`stavi_temporal_truth`), `EFGames/StaviCompleteness.lean` |
| Stavi cannot add a `w` slot | Type: `stavi_temporal_truth M atomMap (t : M.carrier) : StaviFormula → Prop` — one point, identical arity to `temporal_truth` (`StaviConnectives.lean:157`) |
| Stavi is provably vacuous on the repo's discrete fragment | `flatten_stavi` (`:441`) maps `U'`/`S' ↦ ⊥`; `flatten_stavi_correct` (`:492`) proves it, given Succ/Pred/Archimedean |
| The literature names the real obstruction | GHR93 **p.93**, PDF-verified: "*one or two dimensional temporal logics … evaluating formulas at points or at intervals (or pairs of points)*" |
| Route (C) is not rescued by discreteness alone | reports/02 Theorem 1 (`∀ w` form) needs no automorphism — only two co-characteristic renders, which bounded depth permits even in (ℤ,<). **Medium confidence — argued, not compiled** |

**Steelman attempts (I tried to save the hypothesis; each failed):**

1. *"(ℚ,<) really is a flow where U/S is incomplete — so isn't the gap implicated?"* **The strongest
   objection, and the origin of the hypothesis.** It is true that ℚ has only unranked gaps ("*nowhere
   in the rationals is there a gap of any order at all*", p.94), so Lemma 2 does not apply to ℚ and
   U/S is indeed incomplete there. But this is a **coincidence of witness, not of mechanism**: ℚ is
   doing *two unrelated jobs*. For GHR93 it is (potentially) gapped; for the seam it is
   **homogeneous**. The (ℝ,<) witness severs them — ℝ is homogeneous but gapless, and the refutation
   fires there while the gap does not exist. Rejected.
2. *"Maybe the seam needs more expressiveness to define the anchors, and Stavi provides it."*
   Self-defeating: in a homogeneous model **no** formula in **any** automorphism-invariant language
   defines the anchors — that is the content of the invariance criterion, and it is why the compiled
   theorem is language-agnostic. Adding connectives adds definable sets *and* leaves them invariant.
   To define an anchor you need a **constant/parameter**, i.e. route (A). Rejected.
3. *"Perhaps `charFib σ` implicitly pins the anchors via σ's content."* This is the seam's actual
   design intent, and it is exactly what the diagonal σ* refutes: σ* is `char[w',w0,x,t]`, so its
   content *does* record the order bits, yet the parameter-free LHS still cannot tell the `w0`-fiber
   from the `w'`-fiber. σ's content is available on both sides and is not the discriminator; the
   missing `w` argument is. Rejected.
4. *"Could the refutation be a proof bug after all — an artifact of `Fin.cons` env plumbing?"* No:
   the collision bottoms out in `lt_irrefl w'` via `nf_eval_nf_atom_layer` on the `.order` atom, and
   it now reproduces under a fully opaque `truth`. A plumbing artifact could not survive abstraction
   of the entire semantics. It is a genuine mathematical obstruction, not a bug.

**Contradiction Log.**

1. **Orchestrator's hypothesis ("the gap IS the obstruction; add Stavi") vs. this audit
   (REFUTED).** RESOLVED against the hypothesis. Precedence: compiled, axiom-clean theorem
   (`staviSeam_refuted`) > argued classification from titles. The hypothesis was well-motivated —
   (ℚ,<) genuinely appears in both stories — but the shared witness is not a shared mechanism, and
   the hypothesis's stated premise ("a scope change none of routes A/B/C name") is independently
   false since Stavi is already formalized in-repo.
2. **"reports/02+03 correctly invoke (ℚ,<) homogeneity" vs. "(ℚ,<) is also the U/S-gap flow".** NOT
   a contradiction. Both are true of ℚ and neither implies the other; §Q2's table and the (ℝ,<)
   witness separate the properties. reports/02+03 use *only* the homogeneity, never gappedness —
   verified by inspecting their hypotheses, which contain no gap/density assumption.

**No unresolved contradictions.** The one Medium-confidence claim (route (C) needs
render-uniqueness, not merely discreteness) is flagged inline and does not bear on the verdict.

---

## What this means for the plan (actionable)

1. **Do not add Stavi. Do not open a scope change.** `staviSeam_refuted` is a compiled, axiom-clean
   theorem covering every possible Stavi char engine. This dispatch's cost is fully repaid by the
   pivot it prevents.
2. **reports/03's Frozen-Constraint Assessment stands unmodified.** Routes (A)/(B)/(C) remain the
   decision, and the user's choice among them is unchanged by this finding.
3. **The literature actively endorses route (A).** "Give the formula its anchor" (`charFib w σ`) is
   the classically correct fix — the move from a one-dimensional to an anchored/two-dimensional
   temporal logic that GHR93 p.93 names explicitly. Route (A) is not merely the biggest-blast-radius
   option; it is **the one the classical theory says is right**. That is new information for the
   route decision, and it argues for (A) over (C).
4. **If route (C) is preferred for cost, certify it first.** Its real requirement is per-`qnf`
   render-uniqueness at depth k+2 — **stronger than discreteness**, and not obviously satisfiable.
   A ~1-phase probe kills or confirms it cheaply, and should precede any commitment.
5. **No new blocker, no re-implementation.** The Phase-2 green milestone and the Phase-1 CLEARED
   soundness result are untouched; this dispatch wrote only specs-side artifacts.

## References

- `specs/376_.../reports/05_expressive-gap-probe.lean` — this session's compiled artifact
  (`crossRender_languageIndependent`, `crossRender_plainUS`, `staviSeam_refuted`)
- `sources/gabbay_1993/…_Temporal_expressive_completeness_gaps.pdf` — pp. 93, 97, 108-109 (verified)
- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean:135,157,441,492`
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (3 open sorries)
- `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean:103-104` (`OrderedMonadicStructure`)
- `Theories/Bimodal/Semantics/Validity.lean:32,180` (flow class, `valid_discrete`)
- `specs/376_.../reports/02_split-seam-certification.md`, `03_existential-w-seam.md` (+ probes)
