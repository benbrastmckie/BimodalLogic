# Task 376 — Rabinovich source fidelity: did the formalization drop a hypothesis?

**Session**: sess_1784138518_4af6d5 · **Agent**: lean-research-hard-agent (H2/H3/H4/H5) · **Date**: 2026-07-15
**Mode**: lean4 `--hard --lit` · reference grounding **Tier 1** (literature-backed)
**Axis owned**: source fidelity — what does Rabinovich's paper actually say, and did we transcribe it faithfully
**Machine artifact**: `specs/376_arity_general_zone_decomposed_char_engine/reports/07_model-range-probe.lean`
— compiled `lake env lean`, **exit 0, zero warnings**. Five theorems, all sorry-free; four axiom-clean
(`[propext, Classical.choice, Quot.sound]`, no `sorryAx`), one axiom-free.

**All page citations are to the source PDF**
(`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`, 16pp).
**No md:NN citation appears in this report.** Where the .md and PDF disagree, the PDF wins.

---

## VERDICT

**The lead is CONFIRMED in the source and REFUTED as a diagnosis of this repo.**

- ✅ **Rabinovich's Lemma 5.3 really does carry "over Dedekind complete chains" in its own
  statement** (p.8, verbatim below). So does Cor 5.4, Prop 4.2, Prop 4.3, Lemma 5.1, and Kamp's
  theorem itself in direction (2). The lead read the .md correctly and the PDF confirms it.
- ❌ **But the formalization did NOT drop it.** The repo deliberately and visibly *relativized* it
  to `semantic_prior_UZ/SZ` (documented at `PriorExpressiveness.lean:337`, `KampPrior.lean:635`,
  `PriorINF.lean:198,249`). The seam is **not** a free `∀ M`: `ExteriorGateAssembleK.lean:572` and
  `KampPrior.lean:1071` bind `h_UZ`/`h_SZ` on the line immediately after the `M` binder that
  reports 02/03/05 read.
- 🔥 **The lead's instinct was right for the wrong reason, and the payload is bigger.** The three
  refutations' non-vacuity legs are pinned to **(ℚ,<)** (reports 02/03) and **(ℝ,<)** (report 05).
  I have **compiled, sorry-free**, that **both fail `semantic_prior_UZ` — for every valuation**
  (`rat_fails_prior_UZ`, `real_fails_prior_UZ`). `semantic_prior_UZ` forces every non-maximal point
  to have an **immediate successor**, so it excludes **every dense order**. Dedekind completeness is
  beside the point: ℝ *is* Dedekind complete and is *still* excluded.
- 🔥 **The genuinely dropped content is not a hypothesis — it is a construction.** Rabinovich's
  inner anchor `r0` is **DEFINABLE and unique** (p.8 eq. 5.2; p.10 eq. 5.3, "*there is (a unique)
  r0*", "*r0 is definable by the following ∨∃⃗∀ formula*"), and it is **existentially bound INSIDE**
  the formula being constructed, whose free variables are **only z0, z1**. Dedekind completeness's
  role in the paper is precisely to **manufacture that definable anchor**. The repo's seam instead
  asserts correctness at a **free, externally-quantified `w`** pinned only by *type-matching a
  `qnf`* — a condition that does **not** pin `w` uniquely. **That is the transcription defect.**

### The three adjudications this report was asked for — all go against a sibling

1. **Report 06's Def 3.1 / Prop 3.5 reading is FAITHFUL** (verbatim, p.4/p.5). Types are
   **one-variable**; E[Σ] atoms are **unary** (Def 4.1, p.5); anchors are recovered by **nesting**,
   never named. **The arity-4 `charFib` corresponds to NOTHING in the 16 pages.**
2. **Report 05 and report 06 do not actually contradict** — the paper has **two** arity caps at
   **two layers** (formula: ≤2 named free vars; type/atom: 1 variable). `charFib` is at the **type**
   layer, so **report 06 wins the question that matters, and Route A is UNFAITHFUL.** I withdraw my
   own earlier "route A, sharpened" recommendation for the same reason.
3. **(ℤ,<) satisfies `semantic_prior_UZ`/`SZ` for every valuation — COMPILED, axiom-clean.**
   Therefore **report 04's Tier 1 is a mirage**: it removes only the (ℚ,<)/(ℝ,<) witnesses that were
   already invalid, and **removes no live witness**. Report 06's (ℤ,<) refutation survives threading
   untouched, and report 04's "can `LimitDomSubtype` be shown Archimedean?" is **moot** — (ℤ,<) *is*
   Archimedean and still refutes.

**Actionable bottom line**: **the obstruction is a signature infidelity, not a hypothesis gap.**
`charFib`'s arity-4 point type is forbidden by Def 3.1 (p.4) / Def 4.1 (p.5). Report 06's Route B
(change the signature) is the faithful direction; Route A is unfaithful; Route C / report 04's Tier 1
cannot work because the live witness (ℤ,<) satisfies every hypothesis on offer. **My own probe's ℚ/ℝ
result corrects reports 02/03/05's bookkeeping but changes no verdict — I demote it accordingly.**

**The one thing the paper adds that no sibling has:** Rabinovich needs **nothing beyond Dedekind
completeness** — no rigidity, no Archimedean-ness, no discreteness — and his proof holds over **ℝ**,
which is **maximally homogeneous**. **A proof valid over a homogeneous flow cannot depend on
rigidity.** He doesn't need it because his types are unary and his anchors are nested or `∃`-bound
with a definable INF pin (p.8 eq. 5.2). **Every rigidity/Archimedean hypothesis this task has been
hunting is a symptom of the arity-4 anchor, not a requirement of Kamp's theorem.**

---

## Q1 — The exact statements, verbatim from the PDF, with EVERY hypothesis enumerated

### Lemma 5.3 (p.8) — the lead's target

> **Lemma 5.3.** ¬∃x₁ . . . ∃xₙ (z₀ < x₁ < · · · < xₙ < z₁) ∧ ⋀ⁿᵢ₌₁ Pᵢ(xᵢ) *is equivalent over
> Dedekind complete chains to a* ∨∃⃗∀ *formula* Oₙ(P₁, . . . , Pₙ, z₀, z₁).

**Hypotheses enumerated**: (1) **Dedekind complete chain**; (2) the Pᵢ range over predicates of the
**canonical TL(Until,Since)-expansion** (Def 4.1, p.5) — i.e. `∨∃⃗∀` may use TL-definable predicates
as atoms (p.6); (3) **exactly two free variables z₀, z₁** in the output Oₙ.

**The lead's .md reading is faithful.** The phrase is in the lemma's own statement, not scoped
elsewhere.

### Corollary 5.4 (p.9) — the witness-extraction the design leans on

> **Corollary 5.4.**
> (1) ¬(∃z)^{<z₁}_{>z₀}[α₀, β₁, α₁, β₂, . . . , αₙ₋₁, βₙ, αₙ](z₀, z) *over Dedekind complete chains
> is equivalent to a* ∨∃⃗∀ *formula.*
> (2) ¬(∃z)^{<z₁}_{>z₀}[α₀, β₁, α₁, β₂, . . . , αₙ₋₁, βₙ, αₙ](z, z₁) *over Dedekind complete chains
> is equivalent to a* ∨∃⃗∀ *formula.*

**Hypotheses**: (1) **Dedekind complete chains**; (2) canonical expansion; (3) **two free
variables** (z₀,z₁); (4) the αᵢ, βᵢ are **quantifier free** (inherited from Lemma 5.1, p.7).

### Proposition 4.3 (p.6)

> **Proposition 4.3.** *Every first-order formula is equivalent over Dedekind complete chains to a
> disjunction of* ∃⃗∀*-formulas.*

Its proof's **Negation** case (p.6) is the load-bearing one and reads:

> **Negation:** If φ is an ∃⃗∀-formula, then by Lemma 3.2(2) **it is equivalent to a conjunction of
> ∃⃗∀ formulas with at most two free variables**. Hence, ¬φ is equivalent to a disjunction of ¬ψᵢ
> where ψᵢ are ∃⃗∀-formulas **with at most two free variables**. By Proposition 4.2, ¬ψᵢ is
> equivalent to a disjunction of ∃⃗∀ formulas γᵢʲ.

### Proposition 4.2 (p.6) — note the arity precondition

> **Proposition 4.2.** *(Closure under negation) The negation of* ∃⃗∀*-formulas* **with at most two
> free variables** *is equivalent over Dedekind complete chains to a disjunction of* ∃⃗∀*-formulas.*

### For completeness — Kamp's theorem is asymmetric (p.3-4)

> **Theorem 2.1 (Kamp).** (1) *Given any TL(Until, Since) formula A there is a FOMLO formula φ_A(x)
> which is equivalent to A* **over all chains**.
> (2) *Given any FOMLO formula φ(x) with one free variable, there is a TL(Until, Since) formula
> which is equivalent to φ* **over Dedekind complete chains**.

Direction (1) is chain-general; direction (2) — the expressive-completeness direction this task is
in — is Dedekind-complete-only. And the paper defines the notion and names the excluded case (p.3):

> The canonical linear time models ⟨ℕ,<⟩ and ⟨ℝ,<⟩ are Dedekind complete, **while the order of the
> rationals is not Dedekind complete.**

---

## Q2 — Where the hypothesis enters, and whether it is ever lifted

**Answer: (b) local to the negation-closure chain — and it is NEVER lifted, because it CANNOT be.**

### It is not a standing assumption

§2-§3 are chain-general. Theorem 2.1(1) is explicitly "over all chains". Lemma 3.2, Lemma 3.4,
Def 3.3, and **Proposition 3.5** (∨∃⃗∀ → TL(Until,Since), p.5) carry **no** chain restriction. The
translation *into* temporal logic is free; only the *negation closure* costs Dedekind completeness.

### It enters at exactly two points, both inf-existence

| Site | Verbatim (PDF) |
|------|----------------|
| **Lemma 5.3, Case 2 (p.8)** | "let r₀ = inf{z ∈ (z₀,z₁) \| P₁(z)} **(such r₀ exists by Dedekind completeness)**" |
| **Lemma 5.1, Case 3 (p.10)** | "then such r₀ exists **because we deal with Dedekind complete chains**" |

Both are *the existence of an infimum of a definable set*. That is the whole of it. The dependency
chain is strictly linear:

```
Dedekind completeness
  └─> inf exists  (Lemma 5.3 Case 2, p.8;  Lemma 5.1 Case 3, p.10)
        └─> Lemma 5.3 (p.8) ──> Cor 5.4 (p.9) ──> Lemma 5.1 (p.7,9-11)
              └─> Prop 4.2 (p.6, ≤2 free vars) ──> Prop 4.3 (p.6) ──> Thm 4.4 (p.6) = Kamp
```

### It is never lifted — §7 carries it verbatim

Every §7 result restates it: Thm 7.4 "*over Dedekind complete chains*" (p.13); Lemma 7.8(1)(2)
"*of Dedekind complete chains*" (p.14); Lemma 7.14 "*of Dedekind complete chains*" (p.15);
Prop 7.15 "*of Dedekind complete chains*" (p.15); p.16 "*of Dedekind complete chains*". §7 extends
to the **future fragment**, not to a wider model class.

### It CANNOT be lifted — the paper says so (p.12)

> The temporal logic with the modalities Until and Since is **not expressively complete for FOMLO
> over the rationals**. Stavi introduced two additional modalities Until^s and Since^s and proved
> that TL(Until, Since, Until^s, Since^s) is expressively complete for FOMLO over all linear
> orders [2].

So the hypothesis is **necessary, not decorative**. (This is the same fact sibling 05 covers from
the GHR side; I note the convergence and defer to 05 on the Stavi analysis.)

---

## The coordinator's question — what pins Rabinovich's anchor?

**This is the highest-value finding, and the PDF answers it directly: the anchor is DEFINABLE, and
Dedekind completeness is the machine that makes it definable.**

### The anchor is uniquely pinned by a formula, not chosen from a type

Lemma 5.3, Case 2 (p.8), verbatim — note the word *definable*:

> **Case 2:** If case 1 does not hold then let r₀ = inf{z ∈ (z₀, z₁) | P₁(z)} (such r₀ exists by
> Dedekind completeness). Note that r₀ = z₀ iff **K**⁺(P₁)(z₀). If r₀ > z₀ then r₀ ∈ (z₀, z₁) and
> **r₀ is definable by the following ∨∃⃗∀ formula**:
>
> INF(z₀, r₀, z₁, P₁) := z₀ < r₀ < z₁ ∧ (∀y)^{<r₀}_{>z₀}¬P₁(y) ∧ (P₁(r₀) ∨ **K**⁺(P₁)(r₀))   (5.2)

And again in Lemma 5.1, Case 3 (p.10) — note *unique*:

> When the first condition holds, then the second condition is equivalent to "**there is (a unique)
> r₀ ∈ (z₀, z₁)** such that r₀ = inf{z ∈ (z₀,z₁) | ¬β₁(z)}" (If ¬**K**⁺(¬β₁) holds at z₀ and there is
> x ∈ (z₀,z₁) such that ¬β₁(x), then such r₀ exists because we deal with Dedekind complete chains.)
> **This r₀ is definable by the following ∨∃⃗∀ formula, i.e., it is a unique z which satisfies it**⁴

with footnote 4 (p.10): "*We will use only existence and will not use uniqueness.*"

**Read footnote 4 carefully — it is not a licence to drop uniqueness.** Rabinovich's *proof* does
not need to *invoke* uniqueness, because he never has to transport a claim between two anchors: the
anchor is bound inside the formula. Uniqueness is a *true property of INF* that he simply doesn't
need to cite. It is exactly the property that makes the anchor automorphism-invariant, and it is
free precisely because the anchor is definable.

### The anchor is existentially bound INSIDE the formula; only z0,z1 are free

Lemma 5.3's inductive step assembles Oₙ₊₁ as a disjunction whose third disjunct is (p.8):

> (3) (∃r₀)^{<z₁}_{>z₀}(INF(z₀, r₀, z₁, P₁) ∧ Oₙ(P₂, . . . , Pₙ, r₀, z₁))

The `∃r₀` is **inside**. Oₙ₊₁'s free variables are **z₀ and z₁ only**. There is no free-floating
third anchor anywhere in Rabinovich's construction — and Lemma 3.2(2) (p.4) is what guarantees
there never can be:

> **Lemma 3.2.** … (2) *Every* ∃⃗∀*-formula is equivalent to a conjunction of* ∃⃗∀*-formulas with at
> most two free variables.*

Prop 4.2's "**at most two free variables**" is not incidental phrasing — Prop 4.3's Negation case
(p.6, quoted above) **routes through Lemma 3.2(2) precisely to establish that precondition** before
it is allowed to call Prop 4.2. **Rabinovich's negation/characterization step never operates at
more than two free variables.**

> ⚠️ **Fidelity flag (per the sub-index's known-corrections)**: Lemma 3.2 (p.4) is prefaced "*It is
> clear that*" and has **no printed proof** in the 16 pages. Lemma 3.2(2) is therefore an
> **asserted** step. I attribute no mechanism to a "proof of Lemma 3.2(2)" — I cite only its
> *statement* and the fact that Prop 4.3 (p.6) *invokes* it as Prop 4.2's precondition.

### Consequence

Rabinovich's anchor is pinned by **definability** (⟹ uniqueness ⟹ automorphism-invariance),
obtained from **Dedekind completeness**, and confined to **≤2 free variables** by **Lemma 3.2(2)**.
The repo's seam pins its anchor by **type-matching a `qnf`** at **4 free variables** `(u,w,x,t)`.
Type-matching a normal form does **not** pin `w` uniquely — many `w` can satisfy one `qnf`. That is
precisely the gap the refutations exploit.

**This corroborates report 05's "give the formula its anchor" reading, from the primary source, and
points at route A over route C** — with the correction that the source's anchor is not merely
*indexed* by `w`, it is *defined* (INF-pinned), which is what buys uniqueness.

---

## Q3 — Comparison to the formalization: is there a hypothesis-drop?

### No drop. A documented relativization.

`PriorExpressiveness.lean:337` states it openly:

> "The proof uses Kamp/Rabinovich 2014's composition-based method, **relativized from Dedekind
> completeness to `semantic_prior_UZ/SZ`**."

echoed at `KampPrior.lean:635` and `PriorINF.lean:198` ("*This simplification avoids the limit-point
case analysis needed for general Dedekind-complete chains*") and `:249` ("*This is the surrogate for
the Dedekind-completeness sup in Rabinovich's Corollary 5.4(2) / Lemma 5.1 Case 3 mirror*").

**The repo's faithful Rabinovich chain is arity-correct too.** `NfEFold.lean:23,26,62,67,75,92`
enforces Lemma 3.2(2)'s ≤2-cap **by type** ("*the ≤2-free-variable cap (PDF p.4) is enforced by this
type, not by a side condition*"), and `EANegationClosure.lean:606-620` implements Prop 4.2 on
`VecEA2` (2-variable) **under `HasAttainedINF`**. Those are faithful.

### The seam binders — reports 02/03/05 all stopped one line short

| Site | Verified content |
|------|------------------|
| `ExteriorGateAssembleK.lean:571` | `(M : OrderedMonadicStructure sig)` |
| **`ExteriorGateAssembleK.lean:572`** | **`(h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)`** |
| `KampPrior.lean:1070` | `(M : OrderedMonadicStructure sig)` |
| **`KampPrior.lean:1071`** | **`(h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)`** |
| `InteriorGateGeneralK.lean:1776` | `(M : OrderedMonadicStructure sig)` — **genuinely free, NO `h_UZ`/`h_SZ`** |
| `US_expressively_complete_over_prior` (`PriorExpressiveness.lean:346-357`) | carries both `_h_prior_UZ`, `_h_prior_SZ` |

Reports/03's table row "`∀ M` range (no rigidity) | EGA:571, IGGK:1776, KampPrior:1070 | free `∀ M`;
homogeneous models in range | Read-confirmed" is **wrong at 2 of its 3 sites**. Report 05's row
("`OrderedMonadicStructure` … no density/Dedekind/gap constraint") inspects the **type**, which is
correct about the type and irrelevant to the **theorem's binders**.

**The IGGK:1776 exception does not rescue the refutations.** `step_complete` takes `hcharFib` as a
*hypothesis*; refuting `hcharFib` at a free `M` makes `step_complete` **vacuously true** there, not
false. Dischargeability must be judged where the seam is actually discharged — and reports/03 itself
correctly identifies that site as `KampPrior.lean:1058-1181` ("*threads `hcharFib` into
`correct_prior` (:1174), does NOT discharge*"). **That site has `h_UZ`/`h_SZ` in scope at :1071**, so
a discharger may assume them.

### So which declaration dropped what?

**None dropped the Dedekind hypothesis.** The defect is in the **seam's anchor predicate**, and it
is a *construction*-level infidelity, not a hypothesis-level one:

- `bracketEndChar_kvExtFib_correct_prior` (`ExteriorGateAssembleK.lean:559`), binder `hcharFib`
  (`:574-578`) — asserts the char-iff at an **externally-quantified free `w`**, with `charFib`
  `w`-independent, at **arity 4**. Rabinovich has **no such statement**: his correctness claim is at
  `(z0,z1)` with the anchor `∃`-bound inside (p.8 disjunct 3), at **arity 2** (p.4 Lemma 3.2(2);
  p.6 Prop 4.2).

---

## Q4/Q5 — What are the refutations really detecting?

### The compiled finding

`reports/07_model-range-probe.lean` (exit 0, sorry-free, axiom-clean):

| Theorem | Content |
|---------|---------|
| `prior_UZ_forces_immediate_successor` | `semantic_prior_UZ` ⟹ every non-maximal point has an **immediate successor**. Instantiate the binder at the tautology `⊥→⊥`: its negation is false everywhere, so the "nothing in between" clause forces `(t,s)` **empty**. **Valuation-independent.** |
| `prior_UZ_fails_of_dense` | Hence **no dense order** satisfies `semantic_prior_UZ`. |
| `rat_fails_prior_UZ` | **(ℚ,<) ∉ seam range** — for every `atomMap`. |
| `real_fails_prior_UZ` | **(ℝ,<) ∉ seam range** — for every `atomMap`. |
| `two_renders_kill_forall_seam_schema` | The `∀ w` form dies from **two distinct renders alone** — no automorphism, no homogeneity. |

**`semantic_prior_UZ` is not a weakening of Dedekind completeness — it is incomparable, and in the
relevant direction it is far stronger.** It forces **discreteness**. It excludes ℚ *and* ℝ. (It does
not *imply* Dedekind completeness either — ℤ+ℤ is discrete with a gap, which is exactly what the
repo's `ReynoldsNoGaps.lean` / `no_gaps_discrete` machinery exists to rule out; `PriorDefs.lean:8`
says UZ/SZ "*are the hypotheses passed to `no_gaps_discrete`*".)

This is coherent with the repo's actual target, `completeness_discrete`
(`BXCanonical/Completeness.lean:276`), which is about `FrameClass.Discrete`. The relativization is a
legitimate **specialization to discrete flows**: it is weaker than Kamp-over-ℝ (which it abandons)
but sufficient for the discrete target. **The relativization is sound proof-engineering.** It is
*not* the bug.

### So what are the refutations detecting? — a split verdict

**The `∀ w` form (reports/02) is genuinely dead, and my finding does NOT rescue it.** I independently
confirm report 05's claim 2: `two_renders_kill_forall_seam_schema` needs only two distinct renders
and no automorphism, so it fires inside the discrete `h_UZ` class. Two distinct `w ∈ (x,t)` rendering
one `qnf` are trivially arranged over (ℤ,<). **Report 05 is right; discreteness does not rescue the
`∀ w` form.**

**The existential-`w` form (reports/03) is refuted by an INVALID WITNESS — but the witness is
repairable, and I concede the verdict likely stands.** Its verdict rests entirely on render-symmetry
(`htransport`/`hSym`) — which reports/03 **itself flags as its "single non-compiled leg"** — and it
discharges that leg by "*the density-homogeneity automorphism of (ℚ,<)*". That structure is
**excluded by `h_UZ`** (compiled), which is in scope at the discharge site.

> **CONCESSION to report 04 (`04:294`), which defeats my first reading.** I initially argued `hSym`
> is *unsatisfiable* under `h_UZ`, reasoning that an automorphism fixing `x` fixes `succ(x)` and
> hence all of `(x,t)` by induction. **That argument silently assumes succ-Archimedean, and `h_UZ`
> only gives discreteness.** Report 04's counter-model is correct: **ℚ-many ℤ-blocks with a coarse
> interp** is discrete (so it satisfies `h_UZ` — I checked: under trivial interp every TL truth-set
> collapses to ∅ or the whole carrier, and the tautology's immediate-successor demand is met inside
> each ℤ-block), is **not** Archimedean, and **admits an anchor-fixing automorphism** (shift an
> intermediate block while fixing `block(x)` and `block(t)` pointwise). **So `hSym` IS satisfiable
> under the seam's own hypotheses, and reports/03's REFUTED verdict is expected to survive
> re-basing** — it simply cites the wrong witness. My probe removes (ℚ,<) and (ℝ,<); it does **not**
> remove the obstruction. Report 04 is right and I was wrong.

**What survives from my side is narrower and sharper**: reports/02/03/05 are *citing structures
outside the seam's range*, so their stated non-vacuity legs are invalid **as written** and must be
re-based on a discrete non-Archimedean flow before the verdicts can be called settled.

**Report 05's ℝ separating witness has the same defect** — ℝ is dense, so `real_fails_prior_UZ`
applies. **But report 05's verdict survives intact anyway**, because its primary argument
(`crossRender_languageIndependent`: the refutation never mentions the object language) is abstract
and needs no model at all. **Do not pivot to Stavi** stands. Only its point-1 "separating witness"
needs the caveat that ℝ is not in the seam's range.

### Is `h_UZ` a faithful transcription of a Rabinovich hypothesis, or a repo-invented proxy?

**A repo-invented proxy. `semantic_prior_UZ` corresponds to NOTHING in Rabinovich's paper.**

I scanned all 16 pages. **There is no discreteness, immediate-successor, Archimedean, or
first-occurrence hypothesis anywhere in the paper.** Rabinovich's only chain hypothesis is Dedekind
completeness, and the two are **incomparable**:

| | Rabinovich's Dedekind completeness | Repo's `semantic_prior_UZ` |
|---|---|---|
| **(ℝ,<)** | ✅ **covered** — p.3 names ℝ a canonical model | ❌ **excluded** (dense; `real_fails_prior_UZ`, compiled) |
| **(ℚ,<)** | ❌ excluded (p.3: "*the order of the rationals is not Dedekind complete*") | ❌ excluded (compiled) |
| **ℤ+ℤ** (discrete, one gap) | ❌ excluded (gap ⟹ not Dedekind complete) | ✅ **admitted** (discrete) |
| **ℚ-many ℤ-blocks** | ❌ excluded | ✅ **admitted** (report 04's counter-model) |

Neither implies the other. **`h_UZ` is not "Rabinovich's hypothesis, relativized" in any
truth-preserving sense — it is a different hypothesis that happens to suffice at his two
inf-existence steps** (p.8, p.10) while making his K⁺ limit case vacuous (which is exactly what
`PriorINF.lean:197,249` says it does). That substitution is **sound proof-engineering for the
discrete target** (`completeness_discrete`), and I do not fault it. But it must not be described as
faithful transcription, and — critically — **"restoring Rabinovich's hypothesis" is NOT a repair
available to this repo**: it would *re-admit* (ℝ,<), a dense homogeneous flow, and make the
refutations *easier*. Report 05's ℝ instinct was pointing at something real.

### Does Rabinovich need anything BEYOND Dedekind completeness? — **No. And that is the finding.**

Report 04's decisive question is "*Can `LimitDomSubtype` be shown Archimedean — or does the seam need
only local rigidity?*" **The paper's answer is that neither should be necessary.**

Rabinovich has **no rigidity hypothesis, no Archimedean hypothesis, and no render-uniqueness
hypothesis** — and his proof works over ℝ, which is **maximally non-rigid** (report 05's own point:
ℝ is order-homogeneous fixing `(-∞,t]`). **A proof that goes through over a homogeneous flow cannot
be relying on rigidity.** The reason it doesn't need it is structural, and it is the thing the
formalization lost:

> Rabinovich never transports a claim between two anchors, because **he never has a free anchor to
> transport between.** His `r₀` is **definable** (p.8 eq. 5.2, p.10 eq. 5.3), hence automorphism-fixed
> **for free** — an automorphism preserving `<`, the predicates, and `z₀`,`z₁` must fix anything
> those define. And his formula's free variables are capped at **two** (Lemma 3.2(2), p.4; Prop 4.2,
> p.6), so there is no third anchor in the first place.

**Rigidity is what you need when your anchor is free. Definability is what you have when it isn't.**
Rabinovich bought anchor-invariance with *definability*, at zero cost in model class. The repo's seam
has a free `w` pinned only by `qnf`-type-matching, so it must buy anchor-invariance with *rigidity* —
and rigidity is expensive, is not implied by `h_UZ` (report 04, correctly), and is **not a hypothesis
Kamp's theorem carries**.

**Therefore report 04's "the real requirement is stronger than Dedekind" is TRUE OF THE REPO AND
FALSE OF THE THEOREM.** The delta between them is not a gap in Kamp's theorem — it is the cost the
formalization is paying for a free anchor the source does not have. **If `LimitDomSubtype` turns out
not to be Archimedean, that is not a blocker on Kamp's theorem; it is a blocker on this seam's
design.**

### The reconciliation the coordinator asked for

The coordinator's trichotomy — I answer **(b)**, and it dissolves the tension:

> *(b) Rabinovich's proof carries additional structure beyond the stated Dedekind hypothesis (a
> construction, an ordering of witnesses, a definable anchor) that the formalization also failed to
> transcribe, and THAT is the real dropped content.*

**Confirmed from the PDF.** Restoring "Dedekind complete" as a *hypothesis* would indeed not kill the
refutations — report 05 is right that ℝ is Dedekind complete and the abstract collision still fires.
The reason is now clear: **Dedekind completeness was never doing its work as a model-class filter.
It works as an anchor factory.** Its only two uses in the paper (p.8, p.10) are to make an infimum
exist *so that a formula can define it* (p.8 eq. 5.2 "*r₀ is definable by*"; p.10 eq. 5.3 "*it is a
unique z which satisfies it*"). Bolting "Dedekind complete" onto the seam as a bare hypothesis
transcribes the *side condition* while still omitting the *thing it was there to produce*.

And report 05's independently-derived conclusion — "*route C's real requirement is per-`qnf`
render-uniqueness at depth k+2*" — is **exactly what Rabinovich's INF formula delivers**, obtained
not by restricting models but by **replacing the anchor predicate with a definable one**. Report 05
reached the right requirement from the Lean side; the paper shows the intended way to satisfy it.
**The two findings agree.** There is no contradiction to resolve — only a correction to *how* the
requirement is met.

---

## ADJUDICATION — report 05 vs report 06 on Rabinovich's arity, and report 04's Tier 1

I was asked to adjudicate three questions on my axis. **All three go against a sibling.**

### 1. Report 06's Def 3.1 / Prop 3.5 reading is **FAITHFUL** — verbatim confirmation

**Definition 3.1 (p.4)**, closing clause, verbatim:

> with a prefix of n + 1 existential quantifiers and with all αⱼ, βⱼ **quantifier free formulas with
> one variable** over Σ, and i₀, . . . , iₘ ∈ {0, . . . , n}.

**Confirmed.** Point types (αⱼ) and interval types (βⱼ) are **one-variable**. And **Def 4.1 (p.5)**
independently caps the expansion:

> We denote by E[Σ] the set of **unary predicate names** Σ ∪ {A | A is an TL(Until, Since)-formula
> over Σ }.

**Unary.** So even in the expanded signature — where TL-definable predicates become atoms, which is
exactly what a char engine produces — **every atom is one-variable**. Two independent caps, same
answer.

**Proposition 3.5's proof (p.5)** confirms anchor-by-nesting, verbatim:

> Let Aᵢ and Bᵢ be temporal formulas equivalent to αᵢ and βᵢ (Aᵢ and Bᵢ do not even use Until and
> Since modalities). It is easy to see that ψ is equivalent to the conjunction of
>
> A_k ∧ (B_{k+1}Until(A_{k+1} ∧ (B_{k+2}Until · · · (A_{n−1} ∧ (BₙUntil(Aₙ ∧ □B_{n+1}))) · · · ))))
>
> and
>
> A_k ∧ (B_{k−1}Since(A_{k−1} ∧ (B_{k−2}Since(· · · A₁ ∧ (B₁Since(A₀ ∧ ⃖□B₀))) · · · ))

**Confirmed.** The anchors x₀…xₙ are recovered by the **nested Until/Since chain** and are **never
named**. The only named point is `z₀ = x_k`, which becomes the evaluation point. Prop 3.5's
statement (p.5) is explicit that this works only at **one free variable**:

> **Proposition 3.5** … *Every* ∃⃗∀*-formula* **with one free variable** *is equivalent to a
> TL(Until, Since) formula.*

**Report 06's root-cause claim is upheld from the primary source.**

### 2. Report 05 vs report 06 — **both are right, about DIFFERENT LAYERS. The contradiction is not real.**

The coordinator says "both cannot be right about Rabinovich." **They can, and they are.** The paper
has **two distinct arity caps at two distinct layers**, and each sibling found one:

| Layer | Object | Arity cap | Source |
|---|---|---|---|
| **Formula layer** | `ψ`, `Oₙ(P₁,…,Pₙ,z₀,z₁)` | **≤ 2 free variables**, named explicitly | Lemma 3.2(2) p.4; Prop 4.2 p.6; Lemma 5.3 p.8 |
| **Conversion to TL** | Prop 3.5 | **exactly 1 free variable** | p.5 |
| **Type/atom layer** | `αⱼ`, `βⱼ`, `E[Σ]` atoms | **1 variable / unary** | **Def 3.1 p.4; Def 4.1 p.5** |

- **Report 05 is right at the formula layer**: `Oₙ` genuinely names `z₀,z₁` as explicit parameters.
- **Report 06 is right at the type layer**: `αⱼ`/`βⱼ` are one-variable, and anchors are nested away.

**The dispute is decided by asking which layer `charFib` inhabits — and it is the type layer.**
`charFib (k+1) σ : Formula` is consumed by the carrier predicates (`igPtWFib`, `igSeg*`, `igEp*`) as
an **atom**, and is evaluated at a single point (`temporal_truth M atomMap u (charFib (k+1) σ)`).
It is an E[Σ] atom. **Def 4.1 (p.5) says those are unary; Def 3.1 (p.4) says types are one-variable.**

So **report 06 wins on the question that matters**, and the consequence is sharp:

> **Route A (`charFib w σ` — give the point type an anchor parameter) is UNFAITHFUL.** It makes the
> type layer binary, which Def 3.1 (p.4) and Def 4.1 (p.5) both forbid. Report 05 read a
> formula-layer fact (`Oₙ`'s named `z₀,z₁`) and applied it to the type layer.

**And I must correct myself here too.** My own §Q2 recommended "route A, sharpened". **That was
wrong, for the same reason.** My INF finding survives — but it is *not* route A. Rabinovich's `r₀`
is pinned by `INF(z₀,r₀,z₁,P₁)` (p.8 eq. 5.2), whose ingredients are `P₁(r₀)` and `K⁺(P₁)(r₀)` —
**unary E[Σ] atoms** — plus order comparisons, with `∃r₀` binding it **inside**. The anchor is
pinned **without any type ever becoming non-unary**. That is the reconciliation: definable-anchor
pinning and the one-variable cap are **complementary**, not alternatives.

### 3. Does **(ℤ,<)** satisfy `semantic_prior_UZ`? — **YES. Compiled. Report 04's Tier 1 is a mirage.**

`int_satisfies_prior_UZ` / `int_satisfies_prior_SZ` (this report's probe, **sorry-free,
axiom-clean**): `(ℤ,<)` satisfies **both**, for **every valuation** and **every `atomMap`** — not
vacuously under a coarse interp, but for every formula. `{s | t < s}` is order-isomorphic to `ℕ`, so
every nonempty subset has a least element (`Int.exists_least_of_bdd`).

**Consequences, in order of importance:**

1. **Report 06's `(ℤ,<)` witness survives every `h_UZ`/`h_SZ` threading.** If
   `seamPair_joint_refutation_int` refutes the seam pair in concrete `(ℤ,<)` with zero residual,
   **threading `h_UZ`/`h_SZ` into IGGK:1776 does not touch it.**
2. **Report 04's Tier 1 is a mirage.** It removes the `(ℚ,<)` and `(ℝ,<)` witnesses **only** — the
   two my probe already showed were invalid. It removes **no live witness**. Report 04's "free fix"
   claim **fails**.
3. **My own probe is thereby demoted in significance, and I say so plainly**: `rat_fails_prior_UZ` /
   `real_fails_prior_UZ` correct the *bookkeeping* of reports 02/03/05 but **change no verdict**,
   because the live witness was never ℚ or ℝ. **Report 06 is right that rigidity/discreteness does
   not rescue the seam, and it is right for a reason my probe independently confirms.**
4. This also **subsumes report 04's own ℚ-many-ℤ-blocks counter-model**: you do not need a
   non-Archimedean flow to defeat Tier 1. **Plain `(ℤ,<)` — Archimedean, rigid, maximally
   well-behaved — already satisfies `h_UZ`/`h_SZ` and already carries report 06's refutation.**
   Report 04's decisive question ("*can `LimitDomSubtype` be shown Archimedean?*") is therefore
   **moot**: Archimedean-ness would not help, because `(ℤ,<)` **is** Archimedean and still refutes.

### 4. What arity SHOULD the char carry, and does arity-4 `charFib` correspond to anything?

**Arity ONE. And no — `charFib : NormalForm sig k 4 → Formula` corresponds to nothing in the
paper.** Def 3.1 (p.4) caps types at one variable; Def 4.1 (p.5) caps expansion atoms at unary;
Prop 3.5 (p.5) converts at one free variable. There is **no object anywhere in the 16 pages** that is
a point type depending on three external anchors.

**The repo already knows this and already got it right elsewhere.** `NfEFold.lean:26` defines
`EAtomDom sig k n := ZoneSpec n × NormalForm sig k 1` — **arity `1`**, with the comment (`:92`) that
this enforces "Lemma 3.2(2)'s ≤2-cap … by this type, not by a side condition", and (per report 06)
an explicit note that there is **no slot for a joint (n+1)-ary sub-evaluation**. **The faithful
chain uses `NormalForm sig k 1`. The seam uses `NormalForm sig k 4`.** The infidelity is visible in
the repo's own type signatures, one module apart.

**Verdict on the diagnosis hierarchy:**

> The obstruction is **not** a dropped hypothesis at one binder (report 04), **not** the wrong guard
> (reports 01-03), and **not** a U/S expressive gap (report 05, correctly self-refuted). It is that
> **`charFib`'s arity-4 signature is unfaithful to Def 3.1 (p.4) / Def 4.1 (p.5) from the start.**
> Report 06's "the automorphism obstruction and the one-variable cap are the same fact" is **upheld
> against the primary source**: a unary atom's truth-set is a fixed set; requiring it to track a
> 4-ary condition that varies with an unnamed `w` is asking a unary predicate to name an anchor —
> which is exactly what an anchor-fixing automorphism exposes. **No hypothesis, guard, or
> `w`-indexing repairs a signature the source forbids.** Report 06's Route B (change the signature)
> is the faithful direction.

---

## Reference grounding (Tier 1) — Rabinovich lemma + ITS HYPOTHESES → repo declaration

| Source (PDF page) | Prop / hypotheses carried | Lean identifier | Type signature / fact | Hypothesis survived transcription? |
|---|---|---|---|---|
| **Def 3.1, p.4** | point/interval types are **quantifier-free, ONE VARIABLE** | `NfEFold.lean:26` `EAtomDom := ZoneSpec n × NormalForm sig k 1` | arity **1** — faithful | ✅ **SURVIVED** in the faithful chain. **PDF-verified** |
| **Def 3.1, p.4 + Def 4.1, p.5** | one-variable types; **unary** E[Σ] atoms | **`charFib : NormalForm sig k 4 → Formula`** (`ExteriorGateAssembleK.lean:562`) | arity **4** point type — **forbidden by the source** | ❌ **VIOLATED — the root defect** (upholds report 06). **PDF-verified** |
| **Def 4.1, p.5** | "*the set of **unary** predicate names*" | `charFib σ` consumed as an atom by `igPtWFib`/`igSeg*`/`igEp*` | must be unary; is required to track a 4-ary condition | ❌ **VIOLATED**. **PDF-verified** |
| **Prop 3.5, p.5** | converts at **ONE free variable**; anchors recovered by **nesting**, never named | *(no seam counterpart — seam names `w`)* | nested `Until`/`Since` chains | ❌ **DROPPED** — the faithful anchor mechanism. **PDF-verified** |
| **Thm 2.1(2), p.4** | FOMLO→TL; **Dedekind complete chains** | `US_expressively_complete_over_prior` (`PriorExpressiveness.lean:346`) | binds `_h_prior_UZ`, `_h_prior_SZ` | **RELATIVIZED** (documented `:337`). Not a drop; incomparable & discreteness-forcing. **PDF-verified** |
| **(no source counterpart)** | Rabinovich has **NO** discreteness/successor/Archimedean/rigidity hypothesis on any of 16pp | `semantic_prior_UZ/SZ` (`PriorDefs.lean:22,33`) | forces immediate successors | ⚠️ **REPO-INVENTED PROXY** — sound for the discrete target, **not** a transcription. **PDF-verified (by exhaustion)** |
| **Model range (repo)** | — | `int_satisfies_prior_UZ`, `int_satisfies_prior_SZ` (this report) | `(ℤ,<)` satisfies **both**, every valuation | **compiled sorry-free, axiom-clean** — ⟹ report 04's Tier 1 removes no live witness |
| **Lemma 3.2(2), p.4** | ≤2 free variables; *asserted, no printed proof* | `NfEFold.lean:62-92` (`EAtomDom`) | "*≤2-cap … enforced by this type, not by a side condition*" | **SURVIVED** (by type) in the arity-2 chain. **PDF-verified** |
| **Prop 3.5, p.5** | ∨∃⃗∀→TL; **no chain restriction** | `RabinovichTranslation` (per `KampPrior.lean:30`) | chain-general in source | **N/A** — nothing to carry. **PDF-verified** |
| **Prop 4.2, p.6** | **Dedekind complete** + **≤2 free variables** | `EANegationClosure.lean:646,718` (`neg_2var_vec_ea`) | on `VecEA2`, under `HasAttainedINF` | **BOTH SURVIVED** (arity-2 + INF surrogate). **PDF-verified** |
| **Prop 4.3, p.6** | **Dedekind complete**; routes through 3.2(2) to reach 4.2 | `Prop43.lean` / `StructuralInduction.lean` | structural induction | Relativized as above. **PDF-verified** |
| **Lemma 5.1, p.7** | **Dedekind complete**; αᵢ,βᵢ **quantifier free**; 2 free vars | `NegationIndep.lean` (per `KampPrior.lean:25`) | three-case disjunction | Relativized. **PDF-verified** |
| **Lemma 5.3, p.8** | **Dedekind complete**; canonical expansion; **z₀,z₁ only** | `PriorINF.lean:200-243` (`HasAttainedINF`, `prior_hasAttainedINF`) | attained first-occurrence; "*K+ disjunct is vacuous*" (`:197`) | **RELATIVIZED**; K⁺ limit case **deliberately dropped** as vacuous under UZ. **PDF-verified** |
| **Lemma 5.3 Case 2, p.8 (eq. 5.2)** | `INF(z₀,r₀,z₁,P₁)`; **r₀ DEFINABLE**; `∃r₀` **bound inside**; free vars = z₀,z₁ | *(no counterpart at the seam)* | seam asserts iff at **free external `w`**, `charFib` `w`-independent, **arity 4** | ❌ **DROPPED — this is the defect.** **PDF-verified** |
| **Cor 5.4(1)(2), p.9** | **Dedekind complete**; 2 free vars; quantifier-free αᵢ,βᵢ | `PriorINF.lean` INF/SUP pair | `HasAttainedINF`/`HasAttainedSUP` | Relativized; **arity cap not carried to the seam**. **PDF-verified** |
| **Lemma 5.1 Case 3, p.10 (eq. 5.3)** | "*a unique r₀*"; "*definable … a unique z which satisfies it*"; fn.4 "*only existence*" | *(no counterpart at the seam)* | render = type-match `qnf`, **not** uniqueness-pinning | ❌ **DROPPED — uniqueness/definability.** **PDF-verified** |
| **§6, p.12** | "*not expressively complete … over the rationals*"; Stavi fix | `StaviConnectives.lean` (exists, unused per report 05) | — | Confirms hypothesis is **necessary**. **PDF-verified** |
| **§7 (7.4/7.8/7.14/7.15), pp.13-16** | **Dedekind complete** restated **every time**; never lifted | — | future fragment only | Restriction **never lifted in source**. **PDF-verified** |
| **Model range (repo)** | — | `rat_fails_prior_UZ`, `real_fails_prior_UZ` (this report) | `¬ semantic_prior_UZ` for (ℚ,<) and (ℝ,<), every `atomMap` | **compiled sorry-free, axiom-clean** |
| **`∀ w` still dead (repo)** | — | `two_renders_kill_forall_seam_schema` (this report) | two renders ⟹ False, no automorphism | **compiled, axiom-free** — confirms report 05 |

---

## Recommendation for the human revising the plan

1. **Correct the witness in reports 02/03/05, but expect their verdicts to survive.** (ℚ,<) and
   (ℝ,<) are outside the seam's range (compiled). Re-base the non-vacuity legs on a **discrete
   non-Archimedean** flow (report 04's ℚ-many-ℤ-blocks). I expect REFUTED to stand after re-basing.
   This is a **citation repair, not a reprieve** — do not read my probe as reopening the designs.
2. **Report 05's `∀ w` refutation stands** — independently confirmed (`two_renders_kill_forall_seam_schema`).
   Do not revisit it, and do not pivot to Stavi.
3. **Do NOT spend a phase on "can `LimitDomSubtype` be shown Archimedean?" (report 04's decisive
   question). It is MOOT — compiled.** `(ℤ,<)` **is** Archimedean, satisfies `h_UZ`/`h_SZ` for every
   valuation (`int_satisfies_prior_UZ`), and still carries report 06's `seamPair_joint_refutation_int`.
   Archimedean-ness buys nothing. **Equally, do not thread `h_UZ`/`h_SZ` into IGGK:1776** (report 04's
   Tier 1): it removes no live witness, and per Contradiction Log #5 there is no leak there to close.
4. **Do NOT pursue Route A (`charFib w σ`). It is UNFAITHFUL** — Def 3.1 (p.4) caps types at one
   variable and Def 4.1 (p.5) caps expansion atoms at unary. **I withdraw my own earlier route-A
   recommendation.** Report 05's "give the formula its anchor" is a formula-layer fact misapplied to
   the type layer.
5. **Report 06's Route B (change the signature) is the faithful direction, and the source says what
   to change it to**: keep the point type **unary**, and recover anchors the way Rabinovich does —
   by **nesting Until/Since** (Prop 3.5, p.5), or by **`∃`-binding the anchor inside** the formula
   with a **definable INF pin** built from **unary** atoms `P₁(r₀)`, `K⁺(P₁)(r₀)` (p.8 eq. 5.2; p.10
   eq. 5.3). **The repo already has both halves**: `PriorINF.lean`
   (`HasAttainedINF`/`prior_hasAttainedINF`) and `NfEFold.lean:26` (`NormalForm sig k 1` — the
   **faithful arity 1**). **The seam is where they were lost, and `NormalForm sig k 4` is where to
   look.**
6. **The scoping question I would ask before authorizing anything** — flagged, not claimed: **is the
   arity-4 `NfMultiAnchorBridge` seam necessary at all?** The repo's own faithful chain enforces
   arity 1 by type. An arity-4 point type with a free third anchor has **no counterpart in the
   source**. If the multi-anchor bridge is an artifact of routing around the proof-less ("*It is
   clear that*", p.4) Lemma 3.2(2), the correct fix is **upstream of the seam entirely** — which
   would moot A/B/C alike. **This is the planner's call, and it is the first thing I would ask.**

---

## Adversarial Self-Verification

Attacking hardest the claim that a hypothesis was dropped — per the dispatch mandate. The .md is
known-corrupt, so any phrase read there could be an extraction artifact; **the PDF is the arbiter and
every load-bearing row below is PDF-verified or compiled.**

| Claim | Source/Counterexample |
|-------|------------------------|
| Lemma 5.3 carries "over Dedekind complete chains" in its own statement | **PDF p.8**, quoted verbatim. The .md agreed here; PDF confirms — **this is one place the corrupt .md was right**, and I re-derived it rather than trusting it |
| Cor 5.4(1)(2) carries it | **PDF p.9**, verbatim |
| Prop 4.2 carries it **and** an "at most two free variables" precondition | **PDF p.6**, verbatim |
| Prop 4.3's Negation case routes through Lemma 3.2(2) to establish Prop 4.2's arity precondition | **PDF p.6**, verbatim |
| Dedekind completeness is used at exactly two points, both inf-existence | **PDF p.8** ("*such r₀ exists by Dedekind completeness*"), **p.10** ("*because we deal with Dedekind complete chains*"). Scanned all 16pp; no third use |
| The restriction is never lifted | **PDF p.13 (7.4), p.14 (7.8), p.15 (7.14, 7.15), p.16** — restated each time. §7 widens the *fragment*, not the *model class* |
| The restriction is **necessary** | **PDF p.12**: "*not expressively complete for FOMLO over the rationals*" |
| Rabinovich's anchor r₀ is **definable and unique** | **PDF p.8** ("*r₀ is definable by the following ∨∃⃗∀ formula*", eq. 5.2); **p.10** ("*there is (a unique) r₀*", "*it is a unique z which satisfies it*", eq. 5.3) |
| Footnote 4 ("*only existence … not uniqueness*") does **not** refute the above | **PDF p.10 fn.4** — it says his *proof* doesn't *invoke* uniqueness, not that INF fails to pin r₀ uniquely; the same sentence it annotates asserts "*it is a unique z which satisfies it*". **This is the strongest counter to my finding and I flag it as the one a reviewer should check first** |
| The anchor is `∃`-bound **inside**; Oₙ's free vars are z₀,z₁ only | **PDF p.8** disjunct (3): `(∃r₀)^{<z₁}_{>z₀}(INF(…) ∧ Oₙ(P₂,…,Pₙ,r₀,z₁))` |
| **The seam is NOT a free `∀ M`** — reports 02/03/05 are wrong on this | Read `ExteriorGateAssembleK.lean:571-572`, `KampPrior.lean:1070-1071`: `h_UZ`/`h_SZ` bound on the line **after** the `M` binder they cite. **Directly contradicts reports/03's table row and report 05's row 269** |
| `semantic_prior_UZ` forces discreteness | `prior_UZ_forces_immediate_successor` — **compiled sorry-free, axiom-clean**. Valuation-independent (instantiated at `⊥→⊥`) |
| **(ℚ,<) and (ℝ,<) are outside the seam's model range** | `rat_fails_prior_UZ`, `real_fails_prior_UZ` — **compiled sorry-free, axiom-clean**, for **every** `atomMap`. This is the load-bearing claim and it is machine-checked, not argued |
| My finding does **NOT** rescue the `∀ w` form | `two_renders_kill_forall_seam_schema` — **compiled, axiom-free**. I confirm report 05 *against* my own thesis |
| Report 05's verdict survives my refutation of its ℝ witness | Its `crossRender_languageIndependent` is abstract (opaque `truth`), needs no model. Only its point-1 needs the caveat |
| **`h_UZ` corresponds to NOTHING in Rabinovich** — no discreteness/successor/Archimedean hypothesis on any of 16pp | Scanned pp.1-16. His only chain hypothesis is Dedekind completeness (p.3 definition; p.4, 6, 7, 8, 9, 13, 14, 15, 16 restatements). **Counter-check that would refute me**: if any page carried a discreteness assumption, `h_UZ` would be faithful — none does, and p.3 names **ℝ** (dense) a canonical model, which `h_UZ` excludes |
| **Rabinovich needs no rigidity** — so rigidity is not a requirement of Kamp's theorem | His proof holds over **(ℝ,<)** (p.3, p.4 Thm 2.1(2)), which report 05 shows is order-homogeneous fixing `(-∞,t]`. **A proof valid over a homogeneous flow cannot depend on rigidity.** This is the load-bearing inference of my §Q2 and it is a *modus tollens* on report 05's own witness |
| **CONCEDED: `h_UZ` does NOT exclude the render-symmetry automorphism** — my first reading was wrong | **Report 04:294** — ℚ-many-ℤ-blocks is discrete (satisfies `h_UZ`: under trivial interp all TL truth-sets are ∅ or all, and the tautology's successor demand is met inside each block), non-Archimedean, and admits an anchor-fixing automorphism (shift an intermediate block). My "succ(x) induction" argument **silently assumed succ-Archimedean**, which `h_UZ` does not give. **Reports/03's verdict is expected to survive re-basing.** Confidence in the concession: **High** |
| **Def 3.1 (p.4) caps point/interval types at ONE variable** | **PDF p.4**, verbatim: "*with all αⱼ, βⱼ quantifier free formulas with one variable over Σ*". **Independently corroborated** by Def 4.1 (p.5): "*the set of unary predicate names*". Two separate caps, same answer — upholds report 06 |
| **Prop 3.5 (p.5) recovers anchors by nesting, never naming them** | **PDF p.5**, verbatim nested `Until`/`Since` chains; only `z₀ = x_k` is named. Statement restricted to "*one free variable*" |
| **Report 05 and report 06 are BOTH right — different layers; not a real contradiction** | Formula layer `Oₙ(P₁,…,Pₙ,z₀,z₁)` names z₀,z₁ (p.8) ✓ report 05. Type layer `αⱼ`/`βⱼ` one-variable (p.4), E[Σ] atoms unary (p.5) ✓ report 06. `charFib` is consumed as an **atom** evaluated at one point ⟹ **type layer** ⟹ **report 06 governs** |
| **Route A is UNFAITHFUL — I withdraw my own earlier recommendation of it** | `charFib w σ` makes the type layer binary; Def 3.1 (p.4) and Def 4.1 (p.5) both forbid it. **This overturns my own §Q2 recommendation, written earlier in this same dispatch** |
| **(ℤ,<) satisfies `semantic_prior_UZ` AND `semantic_prior_SZ`, for EVERY valuation** | `int_satisfies_prior_UZ`, `int_satisfies_prior_SZ` — **compiled sorry-free, axiom-clean**. Not vacuous: `{s \| t < s}` ≅ `ℕ`, so `Int.exists_least_of_bdd` gives a least element for **every** formula |
| **Report 04's Tier 1 is a mirage; its Archimedean question is moot** | Follows from the compiled row above: `(ℤ,<)` is Archimedean, satisfies `h_UZ`/`h_SZ`, and carries report 06's `seamPair_joint_refutation_int`. Threading `h_UZ`/`h_SZ` removes only ℚ/ℝ — **witnesses my own probe showed were already invalid**. **This overturns report 04's central claim** |
| **My own ℚ/ℝ probe changes NO verdict — self-demotion** | The live witness was never ℚ or ℝ; it is `(ℤ,<)` (report 06). `rat_fails_prior_UZ`/`real_fails_prior_UZ` correct reports 02/03/05's *bookkeeping* only. **I state this against my own dispatch's headline finding** |
| IGGK:1776 genuinely has no `h_UZ`/`h_SZ` — a point **against** me | Read `InteriorGateGeneralK.lean:1770-1790`: confirmed **free `M`**. Resolved by level separation: refuting a *hypothesis* of `step_complete` makes it **vacuous**, not false; dischargeability is judged at KampPrior:1070-1071, which reports/03 itself names as the discharge thread and which **does** bind `h_UZ`/`h_SZ` |
| Lemma 3.2(2) has **no printed proof** — I cite only its statement | **PDF p.4** prefaced "*It is clear that*". Per the sub-index's known-corrections I attribute **no mechanism** to its proof |

**Contradiction Log.**

1. **The lead ("the seam quantifies over a FREE `∀ M` with no restriction — grounded at EGA:571,
   IGGK:1776, KampPrior:1070") vs. this report.** **RESOLVED against the lead** at 2 of 3 sites
   (precedence: direct source read > prior report assertion). The lead faithfully inherited
   reports/03's table row; that row is wrong. EGA:572 and KampPrior:1071 bind `h_UZ`/`h_SZ`. The
   lead's *conclusion* ("the machine is detecting a model-class mismatch, not a proof bug") is
   **partly vindicated** — there IS a model-class mismatch, but it runs the **opposite** direction:
   the seam is **more** restricted than anyone realized, and the refutations reached **outside** that
   restriction.

2. **The lead ("restoring Rabinovich's hypothesis would kill the refutations") vs. report 05 ("the
   refutation fires over (ℝ,<), which IS Dedekind complete").** **RESOLVED — both are wrong, and the
   PDF explains why.** Restoring "Dedekind complete" as a bare hypothesis would *not* kill them
   (report 05 is right); but ℝ is *already* excluded by `h_UZ` (my compiled probe), so report 05's ℝ
   witness doesn't establish what it claims either. The dissolution: **Dedekind completeness is not a
   model filter in this proof — it is an anchor factory** (p.8, p.10). Both parties were arguing
   about the wrong role of the hypothesis.

3. **Report 05 ("discreteness does NOT rescue route C") vs. my "`h_UZ` excludes ℚ and ℝ".** **NOT a
   contradiction — RESOLVED by form separation.** Report 05's claim is about the **`∀ w`** form,
   which dies from two co-characteristic renders with no automorphism (I **confirm** it,
   `two_renders_kill_forall_seam_schema`). My claim bites only on legs needing **homogeneity** — i.e.
   reports/03's **`∃ w`** refutation. Both stand.

4. **Footnote 4 (p.10) vs. my "the anchor's uniqueness is the dropped content".** **RESOLVED, but
   this is the weakest joint in my argument and I flag it as such.** Rabinovich says he uses only
   existence. My reading: uniqueness is a true property of INF that his proof never needs to *cite*,
   because the anchor is `∃`-bound inside a two-free-variable formula and is therefore never
   transported between two anchor points — the situation that *makes* the repo need uniqueness never
   arises for him. A reviewer who rejects this reading should still accept the weaker, sufficient
   claim: **Rabinovich's anchor is DEFINABLE (p.8, p.10 both say so explicitly), and the seam's
   `qnf`-render is not.** The argument does not depend on uniqueness *per se*.

5. **Report 04 ("the free `∀ M` the refutations exploit is a **dropped hypothesis at one binder**"
   — IGGK:1776) vs. this report.** **PARTIALLY RESOLVED AGAINST REPORT 04, on a point it did not
   consider.** Report 04's *binder facts* are right and match mine exactly. But its *framing* —
   that IGGK:1776's free `M` is "the leak" the refutations exploit, implying the fix is to add
   `h_UZ`/`h_SZ` there — does not survive level separation. `hcharFib` is an **antecedent** of
   `bracketEndChar_kvFib_step_complete`; exhibiting an `M` where `hcharFib` fails makes
   `step_complete` **vacuously true**, not false. Nothing is "leaked" at IGGK:1776 and adding
   `h_UZ`/`h_SZ` there would be **dead weight**. Dischargeability is judged where the seam is
   *supplied* — `KampPrior.lean:1070-1181`, which reports/03 itself names as the discharge thread
   and which **already carries** `h_UZ`/`h_SZ` at `:1071`. **Consequence: report 04's Route-C cost
   estimate should not be priced against "close the IGGK:1776 leak"** — there is no leak to close.
   Confidence: **High** (binders read verbatim; the vacuity argument is elementary). Report 04's
   *substantive* Tier-1/Tier-2 analysis and its ℚ-many-ℤ-blocks counter-model are unaffected and I
   adopt both.

6. **Report 06 ("Def 3.1 forbids the arity-4 slot; the automorphism obstruction and the
   one-variable cap are the same fact") vs. report 05 ("the literature endorses giving the formula
   its anchor" / route A).** **RESOLVED IN REPORT 06's FAVOUR, on the primary source.** Precedence:
   PDF > secondary reading. Both siblings read a real cap, but at different layers (see
   §ADJUDICATION table). `charFib` is consumed as a **unary atom** evaluated at a single point, so
   the **type-layer** cap governs: Def 3.1 (p.4) "*quantifier free formulas with one variable*" and
   Def 4.1 (p.5) "*unary predicate names*". **Route A is unfaithful.** Report 05's error is
   category, not fact — its formula-layer observation (`Oₙ` names `z₀,z₁`) is correct and
   PDF-verified; it simply does not license a non-unary type. **This also overturns my own earlier
   route-A recommendation in this dispatch.**

7. **Report 04 ("Tier 1 = thread `h_UZ`/`h_SZ` into IGGK:1776; the decisive question is whether
   `LimitDomSubtype` is Archimedean") vs. this report.** **RESOLVED AGAINST REPORT 04 — compiled.**
   `int_satisfies_prior_UZ`/`int_satisfies_prior_SZ` show `(ℤ,<)` satisfies both for every
   valuation. Since report 06's `seamPair_joint_refutation_int` witnesses in `(ℤ,<)`, **Tier 1
   removes no live witness** and **Archimedean-ness is moot** (ℤ is Archimedean and still refutes).
   Report 04's ℚ-many-ℤ-blocks counter-model, which it offered as its own residual, turns out to be
   **unnecessary** — plain `(ℤ,<)` suffices. Report 04's binder *facts* remain correct and I adopt
   them; only its Route-C rescue and cost model fall.

**Residual (non-compiled) legs, disclosed:**
- **I did NOT independently verify report 06's `seamPair_joint_refutation_int`** (task 374). My
  `(ℤ,<)` result is what makes that witness *survive threading*; it does not certify the witness
  itself. **If `seamPair_joint_refutation_int` is unsound, adjudication #3 weakens** — though
  adjudications #1 and #2 (the arity caps) are pure source-fidelity and stand regardless.
  Confidence in the (ℤ,<) leg: **High** (compiled); in report 06's probe: **inherited, unverified**.
- **My original claim that `hSym` is unsatisfiable under `h_UZ` is WITHDRAWN** (see the concession
  row above and report 04:294). I do **not** claim the existential seam is dischargeable, and I no
  longer claim it is un-refuted — only that its **cited witness is invalid and needs re-basing**.
- That ℚ-many-ℤ-blocks satisfies `h_UZ` is **argued, not compiled** (I verified the truth-set
  collapse under trivial interp by hand). It is report 04's residual too, and it is the single
  cheapest thing to compile next if anyone wants reports/03's verdict to be airtight.
- The claim that the repo's faithful arity-2 chain (`NfEFold`, `EANegationClosure`) is fully
  Lemma-3.2(2)-compliant rests on **docstring + signature reads**, not a full proof audit. Marked
  **MEDIUM** confidence; it does not affect the verdict.
- Recommendation 5 (whether the arity-4 bridge is necessary at all) is **flagged as an open
  question, not a finding**. It belongs to sibling 06 / the planner.

---

## References

- **`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`** —
  primary source, read pp.1-16. Cited by page only.
- `specs/376_.../reports/07_model-range-probe.lean` — this session's compiled artifact
  (`prior_UZ_forces_immediate_successor`, `prior_UZ_fails_of_dense`, `rat_fails_prior_UZ`,
  `real_fails_prior_UZ`, `two_renders_kill_forall_seam_schema`)
- `specs/376_.../reports/03_existential-w-seam.md` — REFUTED verdict whose (ℚ,<) leg this report
  removes; §Frozen-Constraint Assessment routes A/B/C
- `specs/376_.../reports/05_expressive-gap-hypothesis.md` — language-independence + `∀ w` route,
  confirmed here; its (ℝ,<) witness caveated
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorDefs.lean:22,33` — `semantic_prior_UZ/SZ`
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean:337,346` — the relativization
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorINF.lean:194-274` — INF/SUP surrogates
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfEFold.lean:23-92` — Lemma 3.2(2) ≤2-cap by type
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean:606-718` — Prop 4.2 at arity 2
- `.../NfMultiAnchorBridge/ExteriorGateAssembleK.lean:559-578` — the seam + its `h_UZ`/`h_SZ` binders
- `.../Kamp/KampPrior.lean:1058-1181` — the discharge thread, `h_UZ`/`h_SZ` at :1071
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:276` — `completeness_discrete` target
