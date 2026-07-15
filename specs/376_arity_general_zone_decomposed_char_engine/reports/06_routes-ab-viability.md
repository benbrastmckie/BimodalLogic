# Task 376 — Routes A & B Viability: Alternative Exclusion Machinery and `w`-Indexing Coherence

**Session**: sess_1784138518_4af6d5 · **Agent**: lean-research-hard-agent (H2/H3/H4) · **Date**: 2026-07-15
**Mode**: lean4 `--hard --lit` · Tier 1 (literature-backed) · **Focus**: routes A and B viability
**Machine artifact**: `specs/376_arity_general_zone_decomposed_char_engine/reports/06_routes-ab-probe.lean`
— compiled `lake env lean`, exit 0, **zero warnings**. Five theorems, **all sorry-free and
axiom-clean** (`#print axioms` = `[propext, Classical.choice, Quot.sound]`, no `sorryAx`).

---

## VERDICT

| Route | Verdict | Basis |
|-------|---------|-------|
| **A** — `w`-index the char engine | **REFUTED (compiled) *and* incoherent** | `wIndexedSeam_refuted` (sorry-free); plus a type-level category error; plus contrary to the source |
| **B** — rework the 7 exclusion obligations | **Impossible as stated; correct as a DIRECTION** | Its stated frozen-carrier form has no handle to re-argue from; its underlying direction is the source's own design |

**Ranked for mathematical correctness as the long-term approach: B is the principled fix; A is a
workaround that cannot work.** Not a close call, and the ranking does not depend on effort.

**Root cause, newly identified and source-verified:** the `*Fib` arity-4 char engine violates
**Rabinovich Def 3.1 (PDF p.4)**, which requires the point types `α_j`, `β_j` to be *"quantifier
free formulas with **one variable**"*. Rabinovich's char formulas (`A_i`, `B_i`, **Prop 3.5, PDF
p.5**) characterize only those one-variable types; the witness points `x_0…x_n` are recovered by
**nesting Until/Since**, which *binds* them — they are **never named**. The repo already encoded
this cap type-level (`EAtomDom := ZoneSpec n × NormalForm sig k 1`, `NfEFold.lean:69-70`, whose
docstring cites exactly these pages and states *"There is NO slot for a joint `(n+1)`-ary
sub-evaluation"*). `charFib : NormalForm sig k 4 → Formula` is precisely that forbidden slot.

**The automorphism obstruction and the source's cap are the same fact.** A parameter-free formula
can define only automorphism-invariant sets; therefore it can characterize only anchor-free
(one-variable) types. Rabinovich's `≤`-one-variable cap is the syntactic shadow of the semantic
invariance. Two independent lines — the verified primary source and the compiled refutation —
converge on the same boundary. This is not a proof bug to be argued around; it is a design
invariant that task 376's arity-4 generalization broke.

---

## Q1 — The 7 exclusion obligations, verified against source

All seven `.mp` sites confirmed at exactly the stated lines, each inside an
`igFoldBitFib qnf <zone> σ = false` branch, each on a possibly-unmarked σ, each supplying only a
fixed-zone-constant witness (**not** `nf0_zoneSpec σ`):

| Line | Host | Zone | Witness supplied |
|------|------|------|------------------|
| 1932 | `hsegL_all` | `igZXW` | `hzXW u hxu huw` |
| 1946 | `hsegR_all` | `igZWT` | `hzWT u hwu hut` |
| 1968 | `hepL` | `igZPastX` | `hzPastX s hsx` |
| 1984 | `hepL` | `igZAtX` | `hzAtX` |
| 2009 | `hepR` | `igZAtT` | `hzAtT` |
| 2022 | `hepR` | `igZFutT` | `hzFutT s hts` |
| 2046 | `hptW` | `igZAtW` | `hzAtW` |

Each has the shape `(hz' <zone> σ).mpr ⟨pt, <zone-constant>, (hchar σ pt).mp hch⟩`. Confirmed.

**Addition to the census the delegation did not state.** The *same* host lemmas also use the
**`.mpr`** direction at **five** sites — 1964, 1980, 2005, 2018, 2042 — in their `| true =>`
branches, plus 2098/2107 in the arrangement step. So the `.mp` (exclusion) and `.mpr`
(realization) directions of the *same* `hchar σ pt` are consumed **inside the same proofs**. This
matters for Route B: you cannot drop the `.mp` direction from the seam's spec without stranding
seven sites, and you cannot keep the iff without the refutation. The pincer is tighter than
"7 exclusion sites" suggests.

**`hcharFib` is never discharged anywhere** (`grep` across `Theories/`: it occurs only as a
hypothesis binder at `EGA:574-578`, `IGGK:1778`, `KampPrior:1073-1077`, and as
`have hchar := hcharFib w hw` at `IGGK:1799`). The whole `*Fib` stack rests on a hypothesis that
is false.

---

## Q2/Q3 — Route B: does the literature offer an exclusion argument off the `.mp` transport?

### The stated form of Route B is impossible — and the reason is structural, not literary

Route B is specified as *"carrier definitions stay frozen; exclusion ARGUMENT changes"*. Read the
frozen carrier (`IGGK:1374-1378`):

```lean
def igSegLFib (charFib : NormalForm sig k 4 → Formula) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) :
    TemporalPred :=
  ⟨formula_conjList ((igAllSubs sig k).map (fun σ =>
    if b igZXW σ then Formula.top else (charFib σ).neg))⟩
```

`charFib` is an **arbitrary function parameter**. It has no definition to unfold and no properties
beyond those supplied as hypotheses. The exclusion goal `¬ temporal_truth u (charFib σ)` therefore
has **exactly one possible source of information: a spec on `charFib`**. There is no "argument" to
rework — the argument is already a single modus ponens off the only available hypothesis. Any
Route B necessarily *changes the seam's statement*, i.e. changes signatures at `EGA:574-581`,
`IGGK:1778`, `KampPrior:1073-1082`. That is not "argument-only", and the plan should not be
written as if it were.

Worse, every automorphism-stable respec I could construct **fails to discharge the sites**:

- **∃-anchored** (`truth(u, charFib σ) ↔ ∃ w₁, nf_eval[u,w₁,x,t] σ`) — automorphism-safe (compiled:
  `existAnchored_rhs_is_automorphism_invariant`), and it leaves the carrier's *type* untouched. But
  the exclusion needs `nf_eval` at the **specific** `w`, and `∃ w₁` delivers it at some other
  anchor. **Does not discharge.**
- **`.mp`-only** — satisfiable by the degenerate `charFib σ := ⊥`, but that strands the five `.mpr`
  realization sites.
- **Split by markedness** (realization for marked σ, exclusion for unmarked σ) — looks promising,
  and it is *not* immediately refuted; but `igFoldBitFib qnf zs σ = decide (qnf.2 σ = true ∧
  nf0_zoneSpec (atom_assgn σ) = zs)` (`IGGK:1349-1353`) makes "fold bit false" **weaker** than
  "unmarked": it also covers σ that *is* marked but sits in a different zone. For those, the segL
  exclusion demands that `charFib σ` be **false throughout `(x,w)` while true somewhere in
  `(w,t)`** — i.e. a parameter-free formula whose truth-set **respects the `w`-cut**. That is
  exactly what an anchor-fixing automorphism forbids. **Does not discharge.**

### What the literature actually says — and it is decisive

The delegation asked whether Burgess or GHR offer an exclusion/separation argument avoiding the
transport. The answer arrived from a different and much better source: **the repo's own primary,
Rabinovich, whose `.md` hazard I bypassed by reading the PDF directly.**

**Rabinovich 2014, Definition 3.1, p. 4** (verbatim from the PDF):

> ψ(z₀,…,z_m) := ∃x_n … ∃x₁∃x₀ [ (⋀ᵐ_{k=0} z_k = x_{i_k}) ∧ (x_n > x_{n-1} > … > x₁ > x₀) … ∧
> ⋀ⁿ_{j=0} α_j(x_j) … ∧ ⋀ⁿ_{j=1} [(∀y)^{<x_j}_{>x_{j-1}} β_j(y)] … ]
> "with a prefix of n+1 existential quantifiers and with all α_j, β_j **quantifier free formulas
> with one variable** over Σ"

**Rabinovich 2014, Proposition 3.5, p. 5** (verbatim) — the ∃⃗∀ → TL(Until,Since) translation:

> "Let A_i and B_i be temporal formulas equivalent to α_i and β_i (**A_i and B_i do not even use
> Until and Since modalities**). It is easy to see that ψ is equivalent to the conjunction of
> A_k ∧ (B_{k+1}Until(A_{k+1} ∧ (B_{k+2}Until⋯(A_{n-1} ∧ (B_n Until(A_n ∧ □B_{n+1}))))))
> and A_k ∧ (B_{k-1}Since(A_{k-1} ∧ (B_{k-2}Since(⋯A_1 ∧ (B_1 Since(A_0 ∧ ⃖□B_0))))))"

**Rabinovich 2014, Lemma 3.2(2), p. 4** (verbatim):

> "(2) *Every ∃⃗∀-formula is equivalent to a conjunction of ∃⃗∀-formulas with at most two free
> variables.*"

Read these together and the answer to Q2 is unambiguous:

1. Rabinovich's char formulas (`A_i`, `B_i`) characterize **one-variable** types only — and are so
   far from anchor-aware that they *"do not even use Until and Since modalities"*: they are pure
   boolean combinations of monadic predicates at a single point.
2. The anchors `x_0…x_n` are **existentially bound by the `∃x_n…∃x₀` prefix** and recovered in the
   temporal formula by **nesting Until/Since**, which bind them. **Rabinovich never names an
   anchor.** Specific points live in the *metatheory*, never in the object language.
3. Therefore there is **no `truth → nf_eval-at-a-specific-w` transport anywhere in the source**.
   The transport is not a step the repo transcribed from Rabinovich; it is an artifact of the
   arity-4 redesign.

**So the literature does not offer an alternative exclusion argument — it says the obligation
should never have existed.** That is a stronger and more useful answer than the one sought.

### Is the exclusion obligation a SEPARATION obligation in the GHR sense? — No

Separation (GHR) is an **object-language rewriting**: every formula is equivalent to a boolean
combination of pure-past / pure-present / pure-future formulas, evaluated at a single "now". It
never names or pins a point of the model. The repo's obligation is *"a parameter-free formula's
truth-set must equal a set defined using a fixed, un-named anchor `w`"* — a **definability**
claim about an anchor-relative set, not a rewriting claim. These are different kinds of statement,
so **the canonical separation machinery cannot discharge the repo's obligation.** (Confidence:
Medium — the `gabbay_*` conversions carry `provenance_fidelity: null` and I did not verify them
against the PDFs. This conclusion follows from the *shape* of separation as standardly stated and
does not depend on those files; it is also not load-bearing for the verdict, which rests on the
Rabinovich PDF and the compiled probe.)

### Route B's real cost

Because the seam statement must change, the honest scope is:

| Change | Declarations |
|--------|--------------|
| Seam signature (drop `hcharFibSoundP`; re-shape `hcharFib`) | `EGA:559-581` (`bracketEndChar_kvExtFib_correct_prior`), `IGGK:1769-1783` (`bracketEndChar_kvFib_step_complete`), `IGGK:2323`, `KampPrior:1073-1082` |
| Char layer back to arity-1 per Def 3.1/4.1 | `igSegLFib`/`igSegRFib`/`igEpLFib`/`igEpRFib`/`igPtWFib` (`IGGK:1356-1394`) re-typed `NormalForm sig k 1 → Formula`, applied to `nfk_projFresh σ` |
| Re-instated projection roundtrip | the `nfk_projFresh` / `nf_characteristic` / `nf_eval_unique` roundtrip that `igFoldBit_realize_iff` (`:563`) already performs |
| Re-verifies | the `*Fib` stack; `ZoneSeamCrossContextProbe` Block B (guarded soundness) is unaffected |

The arity-4 fiber was adopted (per `IGGK:1667-1673`) to **avoid** that projection roundtrip — the
de-folded fold bit "reads the WHOLE fiber σ" so the realization biconditional is proved directly,
with "NO `nfk_projFresh`/`nf_characteristic`/`nf_eval_unique` roundtrip". **That roundtrip is not
incidental overhead; it is the mechanism that keeps the char layer one-variable.** Removing it
dragged `w`-relative order bits into the char layer, where they are not expressible. The roundtrip
must come back.

---

## Q4 — Is `w`-indexing coherent? **No. It is futile, and it is a category error.**

This was the single most valuable question, and it has a compiled answer.

### The compiled refutation: `wIndexedSeam_refuted` (sorry-free, axiom-clean)

The key move is to make the char engine **a universally quantified parameter that is never
inspected**:

```lean
theorem anchorMove_refutes_any_charEngine
    … (charEngine : NormalForm sig (k + 1) 4 → Formula)
    (hiff : ∀ σ u, temporal_truth M atomMap u (charEngine σ) ↔
        nf_eval_nf M (k + 1) 4 (Fin.cons u (Fin.cons w0 (Fin.cons x (fun _ => t)))) σ) :
    False
```

Given an anchor-fixing automorphism `α` (fixes `x,t`, `α w0 = w'`, surjective) and a separating
point `v` with `w0 < v < w'`, **no** family `charEngine` can satisfy the seam at `w0`. Route A is
then a **one-line corollary**:

```lean
theorem wIndexedSeam_refuted … (charFibW : M.carrier → NormalForm sig (k + 1) 4 → Formula)
    (hiffW : ∀ w σ u, temporal_truth M atomMap u (charFibW w σ) ↔ nf_eval[u,w,x,t] σ) : False :=
  anchorMove_refutes_any_charEngine … (charFibW w0) (hiffW w0)
```

**The automorphism argument re-runs — and it does not even have to work for it.** The refutation
never transports a formula between renders (which is what `w`-indexing was designed to make
ill-typed). It fixes the **one** formula `charFibW w0 σ` emitted at `w0` and **moves the anchor
underneath it**. The obstruction lives on the `nf_eval` side, not the `charFib` side, so indexing
the engine cannot touch it. `charFibW` is arbitrary — this covers every possible implementation,
including ones built by classical choice with no orbit-invariance at all. `hα_truth` needs only
that `charFibW w0 σ` is *a formula*.

`wIndexedSeam_refuted_with_render_guard` confirms render-guarding does not help: only `w0` is ever
required to render; `w'` is never fed to the seam and `v` is not a render at all.

### The exposed diagnosis: `anchorMove_collapses_the_fiber`

The intermediate step, compiled separately, states what the seam actually asserts: the `w0`-fiber
and the `w'`-fiber of `nf_eval` **coincide at every point, for every σ** — i.e. *moving the
bracket witness `w` changes nothing semantically*. False as soon as σ records an order bit between
slot 0 (`u`) and slot 1 (`w`) — i.e. as soon as the arity is `≥ 2`. **The char engine cancels out
of this derivation entirely.**

### Why it is *also* a category error, independent of the refutation

`igSegLFib`, `igPtWFib`, `igEpLFib`, `igEpRFib` (`IGGK:1356-1394`) are **purely syntactic** defs
returning `TemporalPred` (a `Formula` wrapper). **There is no model `M` in scope at their
definition sites.** To index `charFib` by `w : M.carrier` you must thread a model into the syntax
layer — at which point `bracketEndChar_kvFib` is no longer formula-valued, and Kamp's theorem
(*every FO formula is equivalent to a **TL(Until,Since) formula***) has nothing to produce. The
only sound alternative is adding nominals to name points — which converts TM into a **hybrid
logic** and changes the theorem being proved.

So Route A is refuted three times over, at three independent levels:

1. **Semantically** — compiled: the automorphism moves the anchor under any formula.
2. **Type-theoretically** — a formula cannot depend on a model element without nominals.
3. **Against the source** — Rabinovich never names an anchor (Def 3.1 p.4; Prop 3.5 p.5); Until/Since bind them.

### Q5 — Blast radius (recorded for completeness; moot given the above)

Worth flagging that the delegation's Route A blast radius is **mis-scoped**: the named "live
consumer" `kampPrior_site_rungK_gate_match` (`KampPrior:941`) and the defeq bridges
`bracketEndChar_kv_succ_eq` (`IGGK:339-351`) and `bracketEndChar_kv_one_eq` (`CarrierKv:294-300`)
all take `charF : (j : Nat) → NormalForm sig j 1 → Formula` — **arity-1**. They are on the
*working* chain, not the `*Fib` chain. `w`-indexing them would damage working code to serve a
refuted design. The carrier trio is 4,881 lines (`Base` 2,076 / `CarrierK1V` 2,216 /
`CarrierKv` 589); `charFib` appears across 7 files. None of it should be spent on Route A.

---

## Finding that bears on Route C (sibling's scope — flagged, not pursued)

`seamPair_joint_refutation_int` (`SeamPairRefutationProbe.lean:145`, task 374 phase 1, verdict R —
**not** listed in this dispatch's context) already refutes the seam pair
`hcharFib` + `hcharFibSoundP` in a **concrete `(ℤ,<)` model** (`x=0 < w0=1 < t=2`, `w'=3`), with
**no automorphism, no homogeneity, and zero residual** — I re-verified it: axiom-clean, no
`sorryAx`. Its mechanism is that `hcharFibSoundP` (`EGA:579-581`) is `∀ w` **unguarded**, so σ must
realize at *every* anchor, forcing `w' = w0`.

**Implication the Route C agent should weigh:** restricting the model class to rigid/intended
models does **not** rescue the seam pair, because `(ℤ,<)` is rigid-enough *and already refuted with
no automorphism*. Rigidity addresses only the homogeneity-residual refutations (reports/02, /03,
and mine); it does nothing about the seam pair. Flagged and dropped per instructions.

---

## Reference Grounding (Tier 1)

| Source | Prop/Location | Lean Identifier | Type Signature / fact | Status |
|--------|---------------|-----------------|------------------------|--------|
| Rabinovich 2014 | Def 3.1, **PDF p.4** | — | `α_j, β_j` are *"quantifier free formulas with **one variable**"*; anchors `x_0…x_n` bound by `∃x_n…∃x₀` | **verified against PDF** (bypassed `.md` hazard) |
| Rabinovich 2014 | Prop 3.5, **PDF p.5** | — | char formulas `A_i`,`B_i` ≡ the one-variable `α_i`,`β_i`, *"do not even use Until and Since"*; anchors recovered by **nesting** Until/Since | **verified against PDF** |
| Rabinovich 2014 | Lemma 3.2(2), **PDF p.4** | — | *"Every ∃⃗∀-formula is equivalent to a conjunction of ∃⃗∀-formulas with at most two free variables."* | **verified against PDF** |
| Rabinovich 2014 | Def 4.1, PDF p.5 (via repo) | `EAtomDom` | `ZoneSpec n × NormalForm sig k 1` — *"There is NO slot for a joint `(n+1)`-ary sub-evaluation"* (`NfEFold.lean:64-70`) | Read-confirmed; docstring cites p.4/p.5 |
| Repo (working, discharged) | `IGGK:128-145` | `interiorGate_hck` | `temporal_truth M atomMap u (P.existF 0 χ) ↔ nf_eval_nf M k 1 (fun _ => u) χ` — **arity-1, anchor-free** | **proved, sorry-free** |
| Repo (working, discharged) | `PriorInterface.lean:41-45` | `ExistProviders.correct` | `truth(t, existF n sub) ↔ ∃ env, nf_eval_nf M k (n+1) (insertEnv env t) sub` — anchors **existentially bound** | Read-confirmed |
| Repo (semantic anchor layer) | `NfEFold.lean:58-60` | `zoneHolds` | `M`-and-`env`-taking `Prop`; free to mention anchors — the correct home for `w`-relative content | Read-confirmed |
| Repo (refuted seam) | `EGA:574-578`; `IGGK:1778` | `hcharFib` | `∀ w, render(w) → ∀ σ u, truth(u, charFib (k+1) σ) ↔ nf_eval[u,w,x,t] σ` | hypothesis; **never discharged**; refuted |
| Repo (refuted seam) | `EGA:579-581` | `hcharFibSoundP` | `∀ w τ x1, truth(x1, charFib (k+1) τ) → nf_eval[x1,w,x,t] τ` — `∀ w` **unguarded** | hypothesis; refuted in `(ℤ,<)` |
| Repo (frozen carrier) | `IGGK:1374-1394` | `igSegLFib`/`igPtWFib`/… | `(charFib : NormalForm sig k 4 → Formula) → … → TemporalPred` — **syntactic, no `M` in scope** | Read-confirmed |
| Prior art (task 374) | `SeamPairRefutationProbe.lean:47,145` | `seamPair_joint_refutation{,_int}` | seam pair → `False` in concrete `(ℤ,<)`, no automorphism | **compiled, axiom-clean** (re-verified) |
| **This report** | probe | `anchorMove_refutes_any_charEngine` | ANY `charEngine` + anchor-fixing `α` → `False` | **compiled sorry-free, axiom-clean** |
| **This report** | probe | `wIndexedSeam_refuted` | **Route A: `w`-indexed engine → `False`** | **compiled sorry-free, axiom-clean** |
| **This report** | probe | `wIndexedSeam_refuted_with_render_guard` | render-guarding does not rescue Route A | **compiled sorry-free, axiom-clean** |
| **This report** | probe | `anchorMove_collapses_the_fiber` | the seam ⟹ `w` is semantically inert | **compiled sorry-free, axiom-clean** |
| **This report** | probe | `existAnchored_rhs_is_automorphism_invariant` | ∃-anchored RHS **is** α-invariant — why the working shape is safe | **compiled sorry-free, axiom-clean** |

**Fidelity hazards honoured**: Rabinovich cited **by PDF page only**, never `md:NN` — and I read
the PDF rather than trusting the equation-dropping `.md`, which is why Def 3.1's one-variable
clause (dropped from the `.md`) was recoverable at all. `thomas_1997`
(`provenance_fidelity: no_source_pdf`) is **not cited for any claim** — see below. The `gabbay_*`
entries (`provenance_fidelity: null`) support only the separation remark, explicitly flagged
Medium and non-load-bearing.

**Sources consulted but NOT used, and why** (recorded so the omission is not mistaken for an
oversight): `burgess_1982_i` and `burgess_1984_sec04`/`_sec07` were designated PRIMARY for Route B,
and `thomas_1997` PRIMARY for Route A. Neither is cited. The reason is not that they were skipped
but that **better evidence displaced them**: the Route B question ("is there an exclusion argument
off the `.mp` transport?") and the Route A question ("is `w`-indexing coherent?") were both settled
from the *verified* primary (Rabinovich PDF pp.4-5) plus a compiled probe, which outrank a
corroborating secondary and — for `thomas_1997` — outrank a source with **no PDF to verify against
at all**. Citing `thomas_1997` for the automorphism-invariance principle would have been the
tempting move here; it is also exactly the move its `no_source_pdf` flag forbids, and it is
unnecessary because that principle is **compiled** in this report rather than cited. The Burgess
corroboration remains genuinely open and is recorded as a **gap**, not a finding: if a future
dispatch wants a second independent source for "Since/Until bind their witnesses rather than naming
them", Burgess 1982 is where to look. Nothing in this report's verdict depends on it.

---

## Adversarial Self-Verification

Attacking hardest the claims that a route **works**, and the claim that Route A **fails** (a false
refutation would wrongly close a viable design — but three designs have now died of false
optimism, so the bar is set to catch optimism first).

| Claim | Source/Counterexample |
|-------|------------------------|
| Route A (`w`-indexed engine) is refuted | `wIndexedSeam_refuted` — compiled `lake env lean` exit 0, `#print axioms` = `[propext, Classical.choice, Quot.sound]`, no `sorryAx`. `charFibW` universally quantified and never destructured |
| **The refutation does not prove too much** (hardest attack: if it also killed the working code, it would be wrong) | **It draws the line exactly at the repo's own working/broken boundary.** `interiorGate_hck` (`IGGK:128-145`) is a PROVED sorry-free theorem at **arity-1**; my proof needs σ to record an order bit between slot 0 and slot 1, which **requires arity ≥ 2**. It cannot touch `interiorGate_hck`, and it does kill exactly the arity-4 `hcharFib` that was never discharged. Independent confirmation from the repo's own docs (`IGGK:1674-1678`): *"unlike the folded arity-1 `interiorGate_hck`, [`hcharFib`] depends on the bracket witness `w`"* |
| The hypothesis set is **not vacuous** (a vacuous refutation proves nothing) | `α` = the `(ℚ,<)` order-automorphism fixing `x,t` and moving `w0↦w'` (Aut(ℚ,<) is 2-point-stabiliser-transitive on `(x,t)`); trivial valuation makes any order-automorphism preserve `interp`; `v ∈ (w0,w')` exists by density. This is the SAME non-vacuity pin reports/02 certified. Independently, `seamPair_joint_refutation_int` refutes the seam pair in a **concrete `(ℤ,<)`** with **no** automorphism — so the design is dead even if one doubts the `(ℚ,<)` leg entirely |
| `hα_truth` / `hα_nf` are hypotheses, not compiled | **Disclosed residual, unchanged and WEAKER than prior accepted work.** Identical to reports/02 `hchar_eq` and reports/03 `htransport`, both already accepted by the user. My refutation needs **one** iff where reports/02 needed **two** — strictly less assumption. It introduces **no new** assumption |
| Route A is a category error (not just futile) | `igSegLFib` (`IGGK:1374-1378`) returns `TemporalPred` with parameters `(charFib) (b)` only — **no `M` anywhere in scope**. Read-confirmed. Indexing by `w : M.carrier` is not type-correct without threading a model into the syntax layer |
| Rabinovich's char formulas are one-variable / anchors are bound | **Read from the PDF directly** (pp. 4-5), quoted verbatim above. Not from the `.md`, whose known defect (drops every displayed equation) would have hidden Def 3.1's quantifier prefix entirely. This is the one place the `.md` hazard would have produced a wrong answer, and it was avoided |
| The 7 `.mp` sites are as described | Read-confirmed at 1932/1946/1968/1984/2009/2022/2046, each with the fixed-zone-constant witness, each in a `= false` branch |
| **Correction to the delegation's census** | The same host lemmas also use `.mpr` at 1964/1980/2005/2018/2042 (+2098/2107). The delegation described only the 7 `.mp` sites; Route B must account for the 5 `.mpr` sites too or it strands them |
| **Correction to the delegation's Route A blast radius** | `KampPrior:941`, `IGGK:339-351`, `CarrierKv:294-300` all take `charF : … NormalForm sig j 1 → Formula` — **arity-1**, i.e. the *working* chain, not the `*Fib` chain. Grep-confirmed |
| Route B "carrier definitions stay frozen; exclusion ARGUMENT changes" is achievable | **REFUTED.** `charFib` is an arbitrary parameter; the only information about it is the seam. There is no argument to rework. Any Route B changes the seam statement — a signature change at `EGA:574-581`/`IGGK:1778`/`KampPrior:1073-1082`. The plan must not be written as argument-only |
| The ∃-anchored respec would save Route B | **REFUTED by me, against my own preferred direction.** `existAnchored_rhs_is_automorphism_invariant` shows it is automorphism-safe, but the exclusion needs `nf_eval` at the **specific** `w`, which `∃ w₁` does not deliver. It is safe but insufficient — the fix must go further, to the arity-1 char layer |
| Separation (GHR) cannot discharge the obligation | **Medium confidence, non-load-bearing.** `gabbay_*` is `provenance_fidelity: null`, unverified. The claim rests on the standard *shape* of separation (object-language rewriting, never pins a point) vs. the repo's obligation (definability of an anchor-relative set). The verdict does not depend on it |
| Anything attributed to `thomas_1997` | **Nothing is.** `provenance_fidelity: no_source_pdf` — no PDF exists to verify against. The automorphism-invariance-of-definable-sets principle I use is **textbook-standard**, and in this report it is not merely cited but **compiled** (`anchorMove_collapses_the_fiber`). Thomas is not load-bearing anywhere and I decline to cite it |

**Contradiction Log.**

1. **reports/03 Frozen-Constraint Assessment ("(A) … the only route that makes the char seam
   anchor-aware") vs. this audit (A is refuted and incoherent).** RESOLVED against reports/03
   (precedence: compiled probe > prior assessment). reports/03 correctly identified that the
   `w`-independence of `charFib` is the poison, and inferred that `w`-indexing is the cure. The
   inference does not hold: the refutation never uses cross-render *formula* transport (which
   `w`-indexing would block) — it moves the **anchor** under a single fixed formula. reports/03
   also described (A) as merely "largest blast radius", implying feasibility-at-a-price; it is
   **not feasible at any price**, because formulas cannot name model points.

2. **reports/03 ("no zero-frozen-edit additive seam exists") vs. this audit (agrees, but for a
   deeper reason).** NOT a contradiction — a strengthening. reports/03 located the fault at the
   frozen boundary. It is one level deeper: at the **arity of the char layer**, which the source
   caps at one variable (Def 3.1, p.4) and which the repo already enforces type-level in
   `EAtomDom` but bypasses in `*Fib`.

3. **This report's Route B verdict is two-sided and must not be read as one-sided.** "B is the
   principled fix" is a claim about *direction*, not about the delegation's *stated form* of B,
   which I refute. Anyone planning from this report must take the direction (restore the arity-1
   char / zone-carried ordering split) and discard the framing ("carriers stay frozen,
   argument-only"). Recorded explicitly because this is the most likely way the report gets
   misread.

**Residual (non-compiled) legs, disclosed:**
(a) `hα_truth`/`hα_nf` — the `(ℚ,<)` automorphism leg, identical to and weaker than reports/02's
and reports/03's accepted residual; and **fully bypassed** by `seamPair_joint_refutation_int`'s
`(ℤ,<)` instance for the seam-pair half of the finding.
(b) The claim that restoring the arity-1 char layer **suffices** to discharge the exclusions is
**argued, not compiled** — it is what `bracketEndChar_kv_step_complete` (`IGGK:693`) already does
at arity-1, sorry-free, which is strong evidence but not a proof that the `*Fib` zone
decomposition re-derives cleanly through `nfk_projFresh`. **This is the one thing a next dispatch
should compile before committing to the rework**, and it is the natural Phase 1 of any Route B plan.

---

## Recommendation for the plan

1. **Close Route A.** It is refuted (compiled), type-incoherent, and contrary to the source. Do not
   spend the carrier trio on it. Delete it from the live option set.
2. **Reframe Route B** from "keep carriers frozen, change the argument" (impossible) to **"restore
   Rabinovich's Def 3.1/4.1 split: arity-1 anchor-free char layer, all `w`-relative content in
   `zoneHolds`"**. This is the only design consistent with the verified source, with the compiled
   invariance results, and with the repo's own discharged machinery.
3. **Phase 1 of that plan should be a probe**, not a refactor: compile that the seven exclusion
   obligations discharge from an **arity-1** char seam via the `nfk_projFresh` roundtrip, on one
   zone (`igZXW`/`hsegL_all`) only. That is residual (b) above, and it is the last thing standing
   between this diagnosis and a committed rework.
4. **Tell the Route C agent** about `seamPair_joint_refutation_int`: rigidity does not rescue the
   seam pair, which dies in `(ℤ,<)` with no automorphism.

---

## References

- `specs/376_.../reports/06_routes-ab-probe.lean` — this session's artifact (5 theorems, sorry-free, axiom-clean)
- `specs/376_.../reports/03_existential-w-seam.md` / `02_split-seam-certification.md` — the prior refutations this strengthens
- `Theories/.../NfMultiAnchorBridge/SeamPairRefutationProbe.lean:47,145` — task 374's zero-residual `(ℤ,<)` seam-pair refutation
- `Theories/.../Kamp/NfEFold.lean:42-79` — `ZoneSpec`/`zoneHolds`/`EAtomDom`, citing Rabinovich Def 3.1 p.4 & Def 4.1 p.5
- `Theories/.../NfMultiAnchorBridge/InteriorGateGeneralK.lean:128-145` (`interiorGate_hck`, proved), `:693` (arity-1 `step_complete`), `:1349-1394` (`*Fib` carriers), `:1667-1678` (the design note admitting the arity-4 shift), `:1769-2110` (`step_complete`, the 7+5 sites)
- `Theories/.../NfMultiAnchorBridge/ExteriorGateAssembleK.lean:559-581` — `hcharFib` + `hcharFibSoundP`
- `Theories/.../NfMultiAnchorBridge/PriorInterface.lean:38-45` — `ExistProviders.correct` (∃-anchored)
- `/home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf` **pp. 4-5** — Def 3.1, Lemma 3.2(2), Prop 3.5
