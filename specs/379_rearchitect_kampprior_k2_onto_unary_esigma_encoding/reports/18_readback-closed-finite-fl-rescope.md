# Blocker Research: Finite-Fischer–Ladner Re-scope of `ReadbackClosed`

- **Task**: 379, Phase 13e-1 (blocker research feeding `/revise` → plan v19 decision)
- **Agent**: lean-research-hard-agent (H2+H3+H4+H5)
- **Reference tier**: Tier 1 (literature-backed, strict) — Rabinovich, *A Proof of Kamp's Theorem* (2014)
- **Binding**: NO Feferman–Vaught, NO novel mathematics, exact faithfulness to Rabinovich. Source = PDF pages + `chunk_00NN.md` only (companion `.md` is corrupt).
- **k≥2 anchor** (untouched): `nf_nvar_exist_all_depths` (`| _k + 2` arm). `EANegation.lean:1090/:1249` untouched.

## VERDICT (up front): **NO-GO**

The proposed pivot — re-scope `ReadbackClosed` to a *finite input-derived Fischer–Ladner family* and *"discharge with F = Fischer–Ladner closure, which is Rabinovich's OWN finite closure"* — **rests on a misattribution.** Rabinovich's E[Σ] alphabet (Def 4.1, p.5) is the set of **ALL** TL(Until,Since) formulas over Σ — **infinite**. There is **no finite Fischer–Ladner closure of the fixed input formula anywhere in Def 4.1 (p.5), Prop 4.3 (p.6), or Thm 4.4 (p.6).** Rabinovich's "closure" (Lemma 3.4, p.5) is *closure of the ∨∃∀ formula-class under logical operations*, not a finite subformula/Fischer–Ladner `Finset`. Discharging the re-scoped predicate with "F = finite FL closure" therefore requires **constructing a finite-alphabet joint fixpoint (formula-set ∧ alphabet) that Rabinovich explicitly avoids by going infinite** — a formalization structure absent from the source, whose very existence (termination) is not established by anything in the paper. That is inventing structure, contra the "exact faithfulness / no novel math" binding.

This is the **third** attempt on this obligation (358, 376 abandoned here). Per the task's own decision criterion — *"If Rabinovich does NOT have a finite FL closure at this point, that is a NO-GO — say so decisively"* — the fast decisive answer is **NO-GO**, and the surrounding architecture (plan v18's finite-`F`-indexed E[Σ] alphabet) should **escalate to the user** as an architecture decision, not proceed to a `/revise`.

---

## H3 Reference Grounding — 5-column lemma-mapping table (PDF-page-cited)

| Rabinovich PDF page | Repo construct | Obligation | Faithful? | Note |
|---|---|---|---|---|
| **Def 4.1, p.5** (chunk_0011): E[Σ] = Σ ∪ {A \| A a TL(U,S)-formula over Σ}; canonical expansion interprets *every* A ∈ E[Σ] | `sigE sig F` with fresh preds `esigmaPred A` for `A ∈ F` (`ESigmaExpansion.lean:63-71`) | Alphabet must index the readback atoms | **NO** | Rabinovich's E[Σ] is **infinite** (all TL formulas). Repo indexes the alphabet by a **finite `F`** — a departure. This departure *is* the source of `not_readbackClosed`. |
| **Lemma 3.4, p.5** (chunk_0010): "closure properties" — ∨∃∀ closed under ∨, ∧, ∃ (and, via Prop 4.2, ¬) | (used as the closure-under-operations facts, `VeeConj.lean`, `Prop35VeeLift.lean`) | Not a subformula closure | **N/A** | This is the "closure" the pivot mis-reads as "Fischer–Ladner." It is closure of a *formula class under connectives*, NOT a finite `Finset Formula`. |
| **Def 3.1, p.4** (chunk_0009): ∃∀-formula has `n+1` ordered points; `n` is per-formula | `ExistsForallFormula sig F 1` with unbounded `n : Nat` field | Quantify readback over ξ | **partial** | For a *fixed* ξ, `n` is fixed/finite. The type quantifies over ALL `n` — the unbounded direction the committed predicate mistakenly ranges over. |
| **Prop 4.3, p.6** (chunk_0012): structural induction ⇒ FO formula ≡ *finite disjunction* of ∃∀-formulas | (target: the finite input-derived ξ-family the pivot wants) | Finite family per fixed input | **partial (structure only)** | The finite top-level disjunction is real, but its ∃∀-atoms `αⱼ,βⱼ` range over the *infinite* E[Σ] (all TL preds). Finiteness is of the disjunction shape, NOT of the alphabet. |
| **Thm 4.4, p.6** (chunk_0012): φ ≡ ⋁ᵢ φᵢ (finite, Prop 4.3), each φᵢ →Prop 3.5→ TL formula | `translateProp35` (`Prop35Assembly.lean:145-151`) | Readback lands "in the alphabet" | **NO (as finite-F)** | In Rabinovich the readback lands in TL(U,S) over Σ = an atom of the (infinite) canonical expansion — always available. It needs no finite `F` membership. Requiring `translateProp35 ξ ∈ F` for finite `F` has no counterpart in Thm 4.4. |
| **chunk_0011, p.6** ("collapse note"): a TL formula over E[Σ]-preds ≡ a TL formula over Σ | (no repo analog; would be needed for well-foundedness) | Terminate the readback nesting | **NO (semantic only)** | Rabinovich's well-foundedness is a **semantic** equivalence (E[Σ]-atoms collapse to Σ), not a syntactic finite closure. Formalizing it as finite syntactic `F` is the missing, non-trivial construction. |

---

## Deliverable 1 — Faithfulness Verification (PDF-page-cited)

**Question posed**: does Rabinovich quantify the E[Σ] alphabet over a FIXED target formula's FINITE Fischer–Ladner closure (bounded n)?

**Answer: NO — decisively, machine-cited.**

1. **E[Σ] is infinite (Def 4.1, p.5 / chunk_0011).** Verbatim: *"We denote by E[Σ] the set of unary predicate names Σ ∪ {A | A is an TL(Until,Since)-formula over Σ}. The canonical TL(Until,Since)-expansion of M ... interprets each predicate name A ∈ E[Σ] as {a ∈ M | M,a ⊨ A}."* The index set is **all** TL formulas — unbounded. Reinforced at chunk_0010 (Lemma 3.4 footnote/text): the negation result holds *"in the expansion of the chains by **all** TL(Until,Since) definable predicates."* There is no fixed target formula and no finite closure in this definition.

2. **"Closure" in Rabinovich ≠ Fischer–Ladner (Lemma 3.4, p.5 / chunk_0010).** The only object named "closure" in this region is Lemma 3.4 *"(closure properties): The set of ∨∃∀ formulas is closed under disjunction, conjunction, and existential quantification."* That is closure of a **formula class under connectives**, proved from Lemma 3.2(1),(3). It constructs no `Finset`, bounds no `n`, and names no target formula. The pivot's phrase *"Rabinovich's OWN finite Fischer–Ladner closure"* has no referent in the paper.

3. **Prop 4.3 / Thm 4.4 (p.6 / chunk_0012) introduce no finite alphabet.** Prop 4.3 is a structural induction producing, for a first-order φ, a *finite disjunction* ⋁ᵢ φᵢ of ∃∀-formulas. Thm 4.4 translates each φᵢ by Prop 3.5. The finiteness here is of the **top-level disjunction for a fixed φ** — but the ∃∀-atoms `αⱼ, βⱼ` are quantifier-free formulas over E[Σ] = over the infinite set of TL predicates. Nothing bounds the alphabet, and nothing constructs a finite subformula closure. The succinctness discussion (chunk_0009, p.4) confirms the output is only bounded non-elementarily in |φ| — consistent with unbounded readback size, inconsistent with a small finite closure.

4. **The one thing that keeps Rabinovich well-founded is semantic, not syntactic (chunk_0011, p.6).** *"if A is a TL(Until,Since) formula over E[Σ] predicates, then it is equivalent to a TL(Until,Since) formula over Σ, and hence to an atomic formula in the canonical expansions."* This is a **semantic collapse** (E[Σ]-atoms are definable over Σ), which is exactly why Rabinovich can afford an infinite E[Σ] without regress. It is not a finite syntactic closure and does not license one.

**Conclusion**: The pivot's premise ("Rabinovich quantifies the E[Σ] alphabet over the fixed target formula's finite Fischer–Ladner set") is **false as an attribution to Def 4.1 / Prop 4.3 / Thm 4.4.** Building "F = finite FL closure" and claiming faithfulness is inventing structure. **NO-GO on faithfulness grounds.**

---

## Deliverable 2 — Consumer-Site Enumeration (the load-bearing question)

**Claim under test (from handoff)**: the four/five `*_of_closed` consumers only apply closure at the *finite, input-derived* ξ-family fed to `hCapture`/`capFn` at the ζ sites, so a bounded predicate is strong enough.

**Finding: the consumers are stated GENERICALLY (`∀ ξ` / `∀ A : Formula`), not over a finite family — and the finiteness the pivot needs is NOT visible at these interfaces.** Evidence from reading the sites:

- `efSat_negation_diagonal` (`EFSatNegationGeneral.lean:272-293`) takes `hCapture : ∀ A : Formula, ∃ S, ∀ y, intervalHolds N S y ↔ temporal_truth N atomMap y A` — capture over **all** formulas — and a single `ξ : ExistsForallFormula sig F 1` parameter. It applies capture at `(translateProp35 atomMap h_surj ξ).neg` (line 282).
- `efSat_negation_existence` (`:311-329`) — same shape at `(translateProp35 … (pinFirst ξ)).neg` (line 321).
- The uniform forms `efSat_negation_diagonal_uniform` / `efSat_negation_existence_uniform` (`ZetaUniformExtract.lean:121,152`) take `capFn : Formula → IntervalType sig F` (a *total* function on all formulas) and apply it at `(translateProp35 … ξ).neg` (lines 135,168).
- Bracket/endpoint consumers (`ZetaUniformExtract.lean:292,295,306-312`) apply `hCapFn` at `(vc.bracket.pointTypes i).formula`, `(vc.bracket.segmentTypes j).formula`, `vc.endpointLeft/Right.formula` — again via a total `hCapFn : ∀ A, …`.

**Where the ξ come from**: `efSat_negation_general` (`EFSatNegationGeneral.lean:395,398`) instantiates the leaves at `diagProject ψ k` and `existenceSentence ψ`; the uniform assembler (`ZetaUniformExtract.lean:385,388`) at `diagProject ψ k` / `existenceSentence ψ`. These are input-derived — for a *fixed* ψ, `diagProject ψ k` and `existenceSentence ψ` are specific ξ. **So the per-call ξ IS input-derived and, for a fixed input, finite.** This is the grain of truth in the pivot.

**But the load-bearing gap**: the *capture hypothesis itself* (`hCapture`/`capFn`, `∀ A : Formula`) is total, and the `*_of_closed` lemmas exist to convert the concrete `A ∈ F` capture (`esigmaCapture_canonExpand`, `ESigmaCapture.lean:207-219`) into that total capture. To do so **only for the finitely-many `A` actually fed** (`(translateProp35 ξ).neg` for the input ξ, plus the bracket/endpoint formulas), you must show each of *those finitely-many readbacks* is `∈ F`. That is exactly `translateProp35 ξ ∈ F` for the input ξ — and here the machine-checked obstruction bites regardless of finiteness of the family:

- Even a **single** escaping readback `translateProp35 ξ ∉ F` forces enlarging `F`, which **strictly grows the E[Σ] alphabet** (`esigma_alphabet_strict_mono`, `readback_closure_step_grows_alphabet`, `ZetaEngineClosure.lean:177,188` — machine-checked). The synthesized U/S chains `translateEF1`/`buildRight` emit are **not subformulas of the input** (`ZetaEngineClosure.lean:49`, doc), so they *do* escape any subformula-`F`.
- Bounding `n` (the pivot's "bounded n") does **not** help: `readback_closure_step_grows_alphabet` holds for *any* escaping readback irrespective of `n`.

**Conclusion for D2**: Bounding the quantifier to the finite input-derived family makes each *individual consumer* provable **iff** its specific readback is `∈ F`. It does **not** make a finite `F` *exist* that satisfies all of them simultaneously, because adding the (non-subformula) readbacks grows the alphabet and can spawn new required members. The finite-family re-scope **relocates** the obstruction from "unbounded `n`" (`not_readbackClosed`) to "does the input-derived readback-closure reach a finite joint fixpoint of formula-set ∧ alphabet" — which is **unproven, non-trivial, and has no Rabinovich counterpart** (he sidesteps it with infinite E[Σ]). Downstream is not *broken* by bounding, but bounding is **not sufficient** to discharge.

---

## Deliverable 3 — Concrete Interface Specification (for the record; see NO-GO caveat)

Were a `/revise` to proceed (it should not, per the verdict), the minimal faithful interface change is *not* "quantify over a finite family inside `ReadbackClosed`" but "delete the universal closure and thread per-ξ membership as a hypothesis." Concretely, **editing the committed probe `ZetaEngineClosure.lean` (flagged PRESERVED — this call-out is mandatory):**

1. **`ReadbackClosed` (`ZetaEngineClosure.lean:85-89`)** — *remove*. Replace its role by per-site membership hypotheses. There is no satisfiable finite-`F` predicate to salvage (this is what `not_readbackClosed` proves). Do **not** attempt a `def ReadbackClosed … := ∀ ξ ∈ 𝓕, …` for a finite `𝓕 : Finset (ExistsForallFormula sig F 1)` unless `𝓕` and `F` are produced by a *single joint construction* (see D4) — otherwise it is vacuously satisfiable only by circular definition.

2. **`translateProp35_mem_F_of_closed` (`:98`)** → `translateProp35_mem_F` taking `(hξ : translateProp35 atomMap h_surj ξ ∈ F)` and returning it (identity). The obligation moves to the caller.

3. **`translateProp35_neg_mem_F_of_closed` (`:109`)** → keep `hNegClosed : ∀ A ∈ F, A.neg ∈ F`, add `hξ : translateProp35 … ξ ∈ F`, conclude `(translateProp35 … ξ).neg ∈ F`.

4. **`bracket_pointType_formula_mem_F_of_closed` / `bracket_segmentType_…` (`:121,132`)** → take `hτ : (efPointTP atomMap h_surj τ).formula ∈ F` per `τ`.

5. **`endpoint_formula_mem_F_of_closed` (`:143`)** → take `hS : (efIntervalSetTP atomMap h_surj S).formula ∈ F` per `S`.

The consumers (`efSat_negation_diagonal` etc.) would then need matching `∈ F` hypotheses threaded from their callers (`efSat_negation_general`, the uniform assembler), ultimately from whoever fixes the input ψ and constructs `F`. **The whole difficulty then concentrates in D4: producing that `F`.** Since D4 shows `F` cannot be produced finitely and faithfully, this interface is a dead end — documented here only to make the dead end precise.

---

## Deliverable 4 — Constructibility of the Fischer–Ladner Closure in Lean

**Does the repo already have a finite subformula/FL closure `Finset Formula`?** Partially — and it is the *wrong* closure:

- `BXCanonical/Quasimodel/SubformulaClosure.lean`: `subformulas : Formula → Finset Formula` (`:30`), `SubformulaClosure (target) : Finset Formula` (`:59`, = `ghEnrichment (subformulas target)` ∪ its negations), with `target_mem`, decidable membership, finite by construction.
- `Decidability/FMP/*`: `subformulaClosure phi`, `ClosureMCSBundle phi`, `characteristicSet` — a full finite closure apparatus.
- `Bundle/CanonicalTaskRelation.lean:153`: `closure_F_bound (phi) : Nat`.

So **finite subformula-closure `Finset`s are constructible and well-supported.** BUT the ζ-readback formulas — the synthesized Until/Since chains emitted by `translateEF1`/`buildRight` (`ExistsForallNF.lean`, counted by `numUntl` in `ZetaReadbackClosure.lean`) — are **not subformulas of the input** (explicitly noted at `ZetaEngineClosure.lean:49`). A `SubformulaClosure`-style `Finset` therefore **does not contain the readbacks** the re-scoped predicate needs.

To contain them one must close under the **readback operation** `ξ ↦ translateProp35 ξ`. Machine-checked in `ZetaEngineClosure.lean`:
- `esigma_alphabet_strict_mono` (`:177`): `B ∉ F → F.card < (insert B F).card` ⇒ every added formula grows the fresh-predicate carrier.
- `readback_closure_step_grows_alphabet` (`:188`): an escaping readback step lands in a **strictly larger `sigE` alphabet**.

**Construction sketch and why it fails to terminate faithfully**: A joint fixpoint would iterate `F₀ = SubformulaClosure(input)`, `Fₖ₊₁ = Fₖ ∪ { translateProp35 ξ | ξ input-derived over sigE sig Fₖ }`. Each step that adds a non-subformula readback strictly enlarges `sigE sig Fₖ`, which enlarges the type `ExistsForallFormula sig Fₖ 1`, which yields new input-derived ξ (their `αⱼ,βⱼ` may name the freshly-added predicates), whose readbacks may again escape. There is **no decreasing measure**: `numUntl` grows without bound along `psiConst sig F m` (`le_numUntl_translateProp35`, machine-checked), and the alphabet grows monotonically. Rabinovich's termination is the *semantic* collapse "E[Σ]-atom ≡ Σ-atom" (chunk_0011, p.6), which is **not a syntactic finite closure** and gives no Lean well-founded recursion. **Constructibility: NOT established; the only candidate construction re-triggers the machine-checked alphabet growth. NO-GO on constructibility.**

---

## Deliverable 5 — GO / NO-GO Verdict, Sizing, and Escalation

**Verdict: NO-GO.** The finite-FL re-scope is **not faithful** (Rabinovich's E[Σ] is infinite; no finite FL closure exists at Def 4.1/Prop 4.3/Thm 4.4 — D1) and **not constructible** as a finite joint fixpoint (the only candidate re-triggers machine-checked alphabet growth — D4). Bounding the quantifier does not discharge the obligation; it relocates it to an unproven, non-Rabinovich fixpoint-existence claim (D2).

**Is plan v18 refuted?** The specific v18 mechanism — a **finite `F : Finset Formula` serving simultaneously as the E[Σ] alphabet index AND the readback target** — is refuted for the readback obligation: `not_readbackClosed` proves no finite `F` satisfies the committed predicate, and D1/D4 show the "finite FL closure" repair has no faithful, constructible form. The *faithful* alternative is **Rabinovich's own move: make the alphabet the infinite E[Σ] = all TL(U,S) formulas over Σ**, so readbacks are automatically atoms of the canonical expansion and need no `∈ F` membership. That is an **architecture change** (it removes the finiteness the completeness/decidability spine currently leans on via `sigE sig F` indexed by finite `F`) — precisely a **user architecture decision**, not a `/revise`.

**Recommended disposition**: **Escalate to the user.** Do **not** dispatch `/revise` for plan v19 on the finite-FL premise. Present two faithful architectural options for the user to choose:
- **(A) Infinite-alphabet E[Σ]** (Rabinovich-faithful): re-index `sigE` by the (infinite) set of TL formulas rather than finite `F`; assess spine/decidability impact. Large, cross-cutting.
- **(B) Semantic-collapse capture**: replace the syntactic `A ∈ F` capture (`esigmaCapture_canonExpand`) with a *semantic* capture that supplies `hCapture`/`capFn` for readback formulas directly (mirroring chunk_0011's "E[Σ]-atom ≡ Σ-atom over the canonical expansion"), decoupling capture from finite-`F` membership. Requires a truth-lemma-level bridge, not a `Finset` closure.

**Revised 13e-1 size estimate**: as a *research/escalation* outcome, 13e-1 is **complete** (this report). If the user selects (A) or (B), that is a **new multi-file phase (est. 400–1200+ lines across `ESigmaExpansion`, `ESigmaCapture`, `ZetaUniformExtract`, `EFSatNegationGeneral`, and the truth-lemma bridge)** — well beyond a single 13e-1 construction. The finite-FL `/revise` path is **~0 lines of faithful progress** (it cannot be discharged), which is why 358 and 376 abandoned here.

---

## Adversarial Self-Verification (H4)

I attempted to **refute the NO-GO** (i.e., find a way the pivot IS faithful+constructible) before endorsing it. The strongest GO-steelman and its rebuttal are logged.

### Claim Verification Table

| Claim | Source / Counterexample | Verification Method | Confidence |
|---|---|---|---|
| Rabinovich's E[Σ] is infinite (all TL formulas), not a finite FL closure | Def 4.1, p.5 / chunk_0011 verbatim: "Σ ∪ {A \| A is a TL(U,S)-formula over Σ}" | Direct PDF read (pp.4-7) + chunk_0011 cross-check | **High** |
| Rabinovich's only "closure" here is Lemma 3.4 closure-under-connectives, not FL | Lemma 3.4, p.5 / chunk_0010 verbatim | Direct PDF read + chunk_0010 | **High** |
| Prop 4.3/Thm 4.4 introduce no finite alphabet; finiteness is of the top-level disjunction only | p.6 / chunk_0012; atoms αⱼ,βⱼ over E[Σ] (Def 3.1, p.4/chunk_0009) | PDF read + chunk_0012 + chunk_0009 | **High** |
| The committed `ReadbackClosed` is unsatisfiable for finite F (unbounded `n`) | `not_readbackClosed`, `ZetaReadbackClosure.lean:178` | Machine-checked (committed green, axioms [propext, Classical.choice, Quot.sound]) | **High** |
| **Downstream ξ-family fed to consumers IS finite & input-derived** (the pivot's grain of truth) | `efSat_negation_general:395,398` / uniform `:385,388` instantiate at `diagProject ψ k`, `existenceSentence ψ` for fixed ψ | `lean` source read of call sites | **High** |
| …but finiteness of the ξ-family does NOT make a satisfying finite F exist | `esigma_alphabet_strict_mono`/`readback_closure_step_grows_alphabet:177,188`; readbacks are non-subformulas (`ZetaEngineClosure.lean:49`) | Machine-checked lemmas + source doc | **High** |
| Bounded `n` does not prevent alphabet growth | `readback_closure_step_grows_alphabet` holds for any escaping readback ∀`n` | Machine-checked (independent of `n`) | **High** |
| Repo has finite subformula-closure Finsets, but they exclude the readbacks | `SubformulaClosure.lean:59`; exclusion noted `ZetaEngineClosure.lean:49` | Source read of `SubformulaClosure` def | **High** |
| No terminating joint fixpoint (formula-set ∧ alphabet) is constructible faithfully | `numUntl` unbounded (`le_numUntl_translateProp35`) + monotone alphabet; Rabinovich's termination is semantic collapse (chunk_0011), not syntactic | Machine-checked measure + PDF read | **Medium-High** — "no construction exists" is a negative; it is not machine-proved that no clever finite F exists, only that the natural iteration provably diverges and Rabinovich supplies none |
| The faithful alternative is infinite-alphabet / semantic capture = architecture change | chunk_0011 "collapse note" is semantic; spine uses finite `sigE sig F` | Inference from Def 4.1 + repo architecture read | **Medium-High** |

### Contradiction Log

- **Apparent contradiction**: coordinator pointer called chunk_0012 "Closure / Fischer–Ladner", suggesting a finite FL closure exists there. **Resolution** (precedence: primary source text > pointer gloss): chunk_0012 read directly contains Prop 4.2/4.3/Thm 4.4 and the word "closure" only in the sense of Lemma 3.4 (class closure under connectives) and Prop 4.3's negation-closure argument. **No finite Fischer–Ladner subformula closure appears.** The pointer's "Fischer–Ladner" label is not borne out by the source; resolved in favor of the source. No UNRESOLVED contradiction.

### Recommendations modified after verification
- Initial hypothesis entertained: "finite-family re-scope is a mechanical interface fix → GO." **Refuted** and downgraded to NO-GO after D2/D4 showed the finite-family bound relocates rather than discharges the obstruction, and D1 showed the "F = FL closure" discharge is a misattribution.
- Strengthened the disposition from "revise" to "escalate to user," identifying the two faithful architecture options (infinite E[Σ]; semantic capture) so the user decision is actionable.

## References
- Rabinovich (2014), *A Proof of Kamp's Theorem*: Def 3.1 (p.4), Lemma 3.2/3.4 (p.5), Prop 3.5 (p.5), **Def 4.1 (p.5)**, Prop 4.2 (p.6), **Prop 4.3 (p.6)**, **Thm 4.4 (p.6)**; chunks 0009–0012 (and 0024 for the K⁻ future-fragment analog). Companion `.md` corrupt — not used.
- `ZetaReadbackClosure.lean` (`not_readbackClosed`, `numUntl`, `le_numUntl_translateProp35`).
- `ZetaEngineClosure.lean` (`ReadbackClosed`, five `*_of_closed`, `esigma_alphabet_strict_mono`, `readback_closure_step_grows_alphabet`).
- Consumers: `EFSatNegationGeneral.lean:272,311,395,398`; `ZetaUniformExtract.lean:121,152,292,295,306-312,385,388`.
- Existing closures: `BXCanonical/Quasimodel/SubformulaClosure.lean`; `Decidability/FMP/*`.
