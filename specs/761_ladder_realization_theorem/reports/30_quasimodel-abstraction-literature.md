# Research Report: Task #761

**Task**: 761 - ladder_realization_theorem
**Started**: 2026-11-16T14:23:51-08:00
**Completed**: 2026-11-16T14:29:10-08:00
**Effort**: one literature-verification round (read-only)
**Dependencies**: `reports/29_row-link-route-viability.md` §Q4 (the claims under test)
**Sources/Inputs**:
- Hodkinson, Wolter, Zakharyaschev, "Decidable fragments of first-order temporal logics", APAL 106 (2000) 85-134 — local corpus, `~/Projects/Literature/sources/hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl/` (author-preprint text; conversion unverified, angle brackets dropped). **The prompt's premise that this paper is absent from the local index is wrong: it is present.**
- Etessami, Wilke, "An Until Hierarchy and Other Applications of an Ehrenfeucht-Fraïssé Game for Temporal Logic", Information and Computation 160 (2000) 88-108 — full published text fetched from `https://lclem.github.io/formal_verification_2025-2026/assets/pdf/etessami-wilke.pdf`, converted with `pdftotext`.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean` (`Zrel` l.207, `FwdJump`/`BwdJump` l.612-629, `LnkRow` l.642, `RowFrag` l.1116, `truth_iff_of_lnkRow` l.1135).
- `.claude/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` §8; `specs/state.json` task record; `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` l.78-88, 282-290.
- Hodkinson & Reynolds, Handbook ch. 11 (local) — searched, **zero** occurrences of "quasimodel", "Ehrenfeucht", "Etessami"; it is not a source for either question.
**Artifacts**: `specs/761_ladder_realization_theorem/reports/30_quasimodel-abstraction-literature.md`
**Standards**: report-format.md, subagent-return.md
**Task Type**: logic (literature verification for a lean4 task)

**Marking convention.** Every assertion carries **[SOURCED]** (citation and where obtained), **[INFERRED]** (from a sourced fact, inference stated) or **[UNSOURCED]**. Extent of reading is stated in the Appendix; absence claims are bounded by it.

## Executive Summary

- **Claim 2 of report 29 is half right, and the wrong half matters.** HWZ's quasistate is NOT a merely sound abstraction: a state candidate is realizable only if its type set is **exactly** the set of types realized in a structure (Definition 7, an equality), and Theorem 14 (⇐) builds a model in which the types realized at `w` are exactly `T_w`. What HWZ never requires is that the quasistate be a function of any coarser coordinate: the state function is an arbitrary map from time points to realizable state candidates (Definition 10). "Sound and existentially realizable" correctly describes the **runs** (Definition 12, second bullet), not the quasistates. [SOURCED]
- **Claim 3 survives in a corrected form.** HWZ does contain a fibre-type equation — "types realized at `w` = `f(w)`", both containments — but it is keyed by the quasistate itself and holds **by construction** in a model built from the quasimodel. Nothing in HWZ asserts, for a pre-given model, that its quasistates are computed from a finite quotient coordinate. Regularity (`f₁ ∗ f₂^ω`, Theorem 24) is proved for a quasimodel **obtained by surgery**, not for the given one. [SOURCED for the facts; INFERRED for the absence, within the sections read]
- **Theorem 14 is not what the task record's phrase suggests.** It is an iff for satisfiability of monodic first-order temporal sentences over a flow `F`; its ⇐ direction constructs a model (domain = runs × `κ` copies). It does not realize a quasimodel inside a fixed model, and the paper has no `□`/`⊡` and no task-frame semantics. [SOURCED]
- **Claim 1 is half refuted.** `LnkRow`'s jump clause is the Etessami-Wilke U-move in relational (back-and-forth) form, with four named differences; calling it "the" EW game is a supportable analogy, not an identity. But **the attribution "exponential thresholds are the normal form in that literature" is contradicted by the paper**: EW's Duplicator invariants are **linear** in the remaining rounds (threshold `k − k'`; staircase height `k+1` against U-depth `k`, `2k+1` with Since). The only exponential in EW is first-order quantifier depth `O(log k)` versus Until depth — the opposite direction. [SOURCED]
- **No threshold normal form for jumps was found.** EW states none, and omits the invariant for the Since-and-Until case altogether ("We omit the details"). The doubling report 29 compiled (`dblC`) is a fact about this project's `Zrel`/`⊡` setting, not something the game literature predicts. [SOURCED for EW; UNSOURCED beyond it]
- **Direct answer:** the evidence supports **keying the certificate by quasistates** (exact type sets, `⊡` internal) — that is literally HWZ's object. It does **not** support the stated rationale ("only soundness is needed"), and it gives **no** support to an existential-realization leg stated inside the fixed `ladderModel`: the literature's ⇐ builds the model from the certificate.

## Context & Scope

Report 29 §Q4 made three literature claims from memory. This round reads the two primary sources and the project's `LnkRow` definition, and answers Q1-Q4 of the dispatch. Out of scope and untouched: report 29's Lean refutations, any `.lean` file, any plan or record. No `.orchestrator-handoff.json` is written.

Identity of "HWZ 2000": confirmed as I. Hodkinson, F. Wolter, M. Zakharyaschev, "Decidable fragments of first-order temporal logics", Annals of Pure and Applied Logic 106 (2000) 85-134, doi 10.1016/S0168-0072(00)00018-X. [SOURCED: title block of the local preprint, chunk_0001]

## Findings

### Q1 — what the quasimodel abstraction must satisfy

The conditions, as the source states them (HWZ §3; local chunks 0019-0023):

1. **Type** (Def. 5): a boolean-saturated subset of `sub_x φ`. [SOURCED]
2. **State candidate** (Def. 6): "a set of types for φ that agree on `sub_0 φ`" together with indexed types for the constants. [SOURCED] — the sentence-level (0-free-variable) formulas are constant across the set; this is the slot the project's `⊡`-internal-to-the-cell clause would occupy. [INFERRED: analogy between the first-order quantifier over the domain and `⊡` over histories; the project's own note says "Correspondence, not identity", `ztime-no-finite-carrier-fmp.md` §8]
3. **Realizable state candidate** (Def. 7): a structure `D` realizes `⟨T, T^con⟩` if "`T = {t^D(a) : a ∈ D}`" and `T^con = {⟨t^D(c^D), c⟩ : c ∈ con φ}`. **This is an equality, not an inclusion.** Lemma 8 restates it as satisfiability of `α_C = ⋀_{t∈T} ∃x t(x) ∧ ∀x ⋁_{t∈T} t(x) ∧ ⋀ t(c)` — every listed type occurs **and** nothing else occurs. [SOURCED]
4. **State function** (Def. 10): "a map `f` associating with each `w ∈ W` a realizable state candidate". No further constraint: `f` is not required to factor through anything. [SOURCED]
5. **Run** (Def. 11): `r(w) ∈ T_w` for all `w`, with the Until and Since clauses holding along `r` as biconditionals. [SOURCED]
6. **Quasimodel** (Def. 12): `⟨f, R⟩` such that (i) each constant's type sequence is a run in `R`, and (ii) "for every `w ∈ W` and every `t ∈ T_w`, there exists a run `r ∈ R` such that `r(w) = t`." [SOURCED]
7. **Theorem 14**: "A `TL_1`-sentence φ is satisfiable in a model based on `F = ⟨W, <⟩` iff it is satisfied in a quasimodel for φ over `F`." [SOURCED]

Which strength does the construction need?

- **Per-type: existential.** Condition 6(ii) asks for *some* run through each type. Nothing asks that all sequences through a type be runs, nor that a run be determined by its value at a point. This is the "existentially realizable" half of report 29's claim, and it is correct. [SOURCED: Def. 12]
- **Per-quasistate: exact, in both directions of Theorem 14.** In (⇒) the quasistate is *defined* as `T_w = {t_a : a ∈ D}`, the exact set of types at `w`. In (⇐) the model is built on `D = {⟨r, ξ⟩ : r ∈ Ω_f, ξ < κ}` and the proof displays that the number of domain elements with `r(w) = t` is "`κ`, if `t ∈ T_w`, `0`, otherwise", then takes `I(w)` "realizing `f(w)`" via Lemma 9. So the constructed model realizes at `w` exactly the types of `f(w)`. [SOURCED: proof of Theorem 14, chunks 0022-0023] The exactness is used: the induction step for `∀x ψ` goes through the structure `I(w)` realizing the state candidate, which is only correct if no unlisted type occurs. [INFERRED from Def. 7 + Lemma 8's `∀x ⋁ t(x)` conjunct]
- **Across time points: no invariant coarser than the quasistate is ever required.** Surgery (Lemma 17) has the hypothesis "`f(n) = f(m)` for some `n < m`" — equality of the full quasistates — and concludes that `f^{≤n} ∗ f^{>m}` with the glued runs `{r₁^{≤n} ∗ r₂^{>m} : r₁(n) = r₂(m)}` is a quasimodel. No numeric hypothesis, no coordinate. [SOURCED: Lemma 17 and its proof, chunks 0027-0028]
- **And equal quasistates are themselves not always enough.** For finite domains the paper says "a somewhat subtler deleting technique is required" and replaces `f(i) = f(j)` by the finer `i ∼ⁿ_R j` (same quasistate **and** the same set of (type at `n`, type at `i`) run-pairs), Lemma 30/32. So even in the source, "same abstract state ⇒ interchangeable" is a fact that has to be re-earned per construction, at the granularity the construction needs. [SOURCED: chunks 0037-0038]

**Verdict on report 29's claim 2** ("needs only a sound, existentially realizable abstraction, never a complete invariant"):
- "existentially realizable" — correct for runs. [SOURCED]
- "only … sound" — **wrong as stated** for the per-state datum: the quasistate is exact (Def. 7). [SOURCED]
- "never a complete invariant" — correct in the sense that matters to the task: no coordinate coarser than the quasistate is asserted to determine it; the quasistate is the key, and it is chosen, not derived. [SOURCED: Def. 10; INFERRED as an absence over the sections read]

### Q2 — is there a fibre-equation counterpart?

- **Yes, keyed by the time point / quasistate, and trivially so.** "Set of types realized at `w` = `T_w`" holds by definition in (⇒) and by construction in (⇐). That is an exact two-containment equation. [SOURCED: as Q1]
- **No, keyed by a quotient coordinate of a given model.** The paper never proves or uses a statement of the form "in model `M`, the quasistate at `w` equals `F(π(w))` for a finite-valued `π`". [INFERRED: absence, over §§3-6 read in full and the remainder grepped]
- **What the construction uses instead** to reach a finite presentation: (a) Theorem 15 — existence of a quasimodel is one monadic second-order sentence `σ_φ` over the flow, discharged by Büchi/Rabin, covering `⟨ℕ,<⟩`, `⟨ℤ,<⟩`, `⟨ℚ,<⟩`; (b) Lemmas 17, 19, 21, 23 and Theorem 24 — every quasimodel **contains a subquasimodel** from which an ultimately periodic `f₁ ∗ f₂^ω` with bounded `|f₁|`, `|f₂|` satisfying three local conditions is obtained, and conversely any such pair of sequences **is** a quasimodel. [SOURCED: chunks 0024-0025, 0027-0033]
- In (b) the periodic state function does factor through a finite coordinate (position modulo the period), but for the **selected** quasimodel, by construction. The given model's quasimodel is cut down by deletion; its own positions are not classified. [SOURCED: Lemma 19 "contains a subquasimodel", Theorem 24's proof]

**Verdict on claim 3** ("the filed fibre equation over `κ` has no counterpart"): correct if read as "no equation computing the cells of a pre-given model from a quotient coordinate". Incorrect if read as "the literature has no exact cell equation" — it has one, by construction. [INFERRED from the two bullets above]

### Q3 — is `LnkRow` the Etessami-Wilke game?

**The project's definition** [SOURCED: `LadderStepFrag.lean` l.612-651]. `FwdJump R t t'`: every `s > t` is answered by some `s' > t'` with `R s s'`, such that every `r'` with `t' < r' < s'` is answered by some `r` with `t < r < s` and `R r r'`. `LnkRow a b g g' t t'` := `Zrel a b (g t) (g' t')`, and if `b = b₀+1` the forward jump condition in both directions at `LnkRow a b₀`, and if `a = a₀+1` the backward one in both directions at `LnkRow a₀ b`. `truth_iff_of_lnkRow` (l.1135): row-linked positions agree on every `RowFrag` formula (atoms, `⊥`, `→`, `untl`, `snce`; **no `box`, no `stab`**) with `dBack ψ ≤ a`, `dFwd ψ ≤ b` — one direction only (link ⇒ agreement).

**EW's U-move** [SOURCED: EW §3, p. 91-92]. From configuration `(i₀, i₁)`: Player I picks a word `w_δ` and a position `i'_δ` with `i_δ ≤ i'_δ < |w_δ|`; Player II answers `i'_{1−δ}` with `i_{1−δ} ≤ i'_{1−δ}`, "such that if `i_δ = i'_δ` then `i_{1−δ} = i'_{1−δ}`"; then Player I either (a) sets the configuration to `(i'₀, i'₁)`, or (b) picks `i''_{1−δ}` with `i_{1−δ} ≤ i''_{1−δ} < i'_{1−δ}` and Player II answers `i''_δ` with `i_δ ≤ i''_δ < i'_δ`, the configuration becoming `(i''₀, i''₁)`. Theorem 3.1: Player II wins the `k`-round game on `(v,i)`, `(w,j)` **iff** they agree on all formulas of operator depth `k`. Theorem 3.3 separates `k` U-moves from `r` residual (`○`, `◇`) moves. The past version "with both past and future moves [has] a total of `k` uses of S- and U-moves".

**Comparison** [INFERRED: side-by-side reading of the two definitions]:

| | EW 2000 | `LnkRow` |
|---|---|---|
| Shape of the until move | pick witness, answer, then accept or challenge an intermediate point on the other side | identical two-step shape (`FwdJump`), in both directions |
| Presentation | a game; "Player II has a winning strategy" | the relation of winning positions, by recursion on the budget |
| Until semantics | reflexive: witness `≥ i`, intermediate points in `[i, i')` | strict: witness `> t`, intermediate points in `(t, s)` open |
| Other moves | `○` and `◇` moves as separate resources | none (strict until subsumes them) |
| Budget | one counter `k` for U (and S) moves together | two counters: `a` backward, `b` forward |
| Base relation | agreement on atomic propositions (`≡₀`) at every configuration | `Zrel a b` — same object state **plus** budget-dependent thresholds on countdown, register and gap |
| Structures | finite and ω-words over a finite alphabet | ℤ-indexed ladder paths |
| Adequacy | iff (Theorem 3.1) | one direction (`truth_iff_of_lnkRow`), `⊡`/`□`-free fragment only |

- EW say "it is easy to modify the moves in the game in order to capture variants of the temporal operators" (after Remark 3.4), which covers the strict/reflexive difference in spirit but is not a theorem about the strict variant. [SOURCED]
- **Verdict:** the jump clause of `LnkRow` is the EW U-move, strict variant, in back-and-forth form with a split budget. The one substantive departure is the **base relation**: EW's game only ever demands atomic agreement at a configuration, whereas `LnkRow` demands `Zrel` at the remaining budget. `LnkRow` is therefore **at least as fine as** the strict-until EW equivalence at the corresponding budget, and the extra strength was put there to serve the `⊡` lift, which EW's game does not model at all. "Is the EW game" overstates; "is the EW until/since move with a stronger base relation" is supported. [INFERRED]

**Thresholds — the concrete question.**

- EW's Duplicator invariant for the future-only hierarchy (Claim 4.3): after `k'` U-moves and `r'` residual moves, `PD(i) = PD(j)`; `TD(i) = TD(j)` or `TD(i) = TD(j)+1`; and in the latter case `TD(i) ≥ k − k'`, with `PD(i) ≥ r − r' + 1` at equality. **The threshold drops by one per move: it is linear in the remaining rounds.** The separating words differ by one stair in a staircase of height `k+1`; Theorem 4.1: `FAIR_{k+1}` is expressible with U-depth `k` and not with `k−1`. [SOURCED: EW p. 94-97]
- With Since: Theorem 4.4, `STAIR_{2k+1}` expressible with `{U,S}`-depth `k`, not `k−1` — still linear, `2k+1`. The invariant is described in one sentence ("the minimum of topdistance and bottomdistance … not below the current threshold (depending on the round we are on)") and then: "**We omit the details.**" [SOURCED: EW p. 97-98] So the paper does not print a since-and-until threshold invariant that could be transcribed.
- The only exponential relation in the paper runs the other way: `STAIR_k` has a first-order definition of quantifier depth `O(log k)` (Proposition 5.1), "thus, there are properties whose expression requires exponentially more Until depth than first-order quantifier depth". [SOURCED: EW Introduction and §5] Doubling thresholds are the signature of the **first-order** EF game on linear orders; the LTL game was introduced precisely because its counting power is linear in Until depth. [INFERRED from Proposition 5.1 with Theorem 4.1]
- **Therefore report 29's sentence "a game-based route … has exponential thresholds as its NORMAL form" is not supported by Etessami-Wilke and is contradicted by its main theorem.** [SOURCED]
- **No threshold normal form for jumps exists in EW**, exponential or otherwise: its bounds are for one specific word family, not a general closure recurrence. [SOURCED: scope of Lemma 4.2/4.5] One web search for a general until/since EF threshold result on ℤ-indexed counter structures returned EW itself, MTL games (Pandya-Shah, arXiv 1102.5638) and lecture notes; none was read, none is cited for a bound. [UNSOURCED beyond EW]
- **Reconciliation with report 29's compiled doubling** (not re-litigated): the `dblC` family and the recurrence `N(a,b) ≥ 2N(a−1,b)+2` are stated by report 29 as arising where a relation "must hold again at the matched pair (which the `⊡` lift requires)". EW has no `⊡` and no state relation beyond atoms, so its linear bounds neither confirm nor contradict that recurrence. The doubling is a property of `Zrel`-with-`⊡`, i.e. of the project's strengthened base relation, and the literature cannot be cited for it in either direction. [INFERRED]

### Q4 — is the filed statement over-strong relative to the result chased?

Filed statement [SOURCED: `specs/state.json`, task 761]: `cellAt (ladderModel …) φ (t, ⟨(q,c,n),h⟩) z = {T | ∃ S, typeOfCl S = T ∧ (q, S, κ(c,n)) ∈ Dmax}` — the cell of a **fixed** model at an arbitrary ladder state equals the fibre of a certified set over the finite coordinate `(q, κ(c,n))`.

- **The literature does not require this.** HWZ's decidability results (Theorems 15, 24) need: satisfiable ⇒ a quasimodel exists (read off, exact per time point); a quasimodel exists ⇒ satisfiable (model **constructed**); and existence of a quasimodel is finitely checkable. At no point is a pre-given model's quasistate shown to be a function of a finite quotient of its state. [SOURCED for what is used; INFERRED for the absence]
- **The literature does not forbid it.** Nothing in HWZ says such a factorization fails; the paper has no fixed infinite-width model with counters to factor. The refutation of the filed clip is the project's own compiled result, not a literature fact. [INFERRED]
- **The literature's ⇐ is not the ⇐ report 29's rank 3 describes.** Rank 3 proposes "soundness plus existential realization" with the model fixed as `ladderModel`. HWZ's ⇐ realizes a quasimodel in a model whose domain is manufactured from the runs (`runs × κ`, with `κ ≥ ℵ₀` so that every type has full multiplicity, Lemma 9). Existential realization of certificate runs inside a pre-existing model is a statement HWZ does not make. Report 29 itself flags that leg as "Not costable from here"; this round adds that it is also **not literature-backed**. [SOURCED for HWZ's construction; INFERRED for the mismatch]
- **A parallel worth recording.** HWZ's ⇐ needs infinitely many copies of each run for arbitrary domains, and the finite-domain case needs strictly more (finitary quasimodels, Lemma 27, the finer `∼ⁿ_R`). The task record's WIDTH fact (a model built on a `Fintype` has finite width and is incomplete) is the same phenomenon. [SOURCED for HWZ §6; INFERRED for the parallel]
- **Scope caveat that bounds every transfer above.** HWZ treats monodic first-order temporal logic over linear flows. It has no `□`, no `⊡`, no task frames; the project's own context file says the logic "is not a product" and titles the HWZ table "Correspondence, not identity". The role of `⊡` is played, by analogy only, by the first-order quantifier. Any claim that a quasistate-keyed certificate "follows the cited literature" is an analogy at the level of proof architecture, not an instance of a published theorem. [SOURCED: `ztime-no-finite-carrier-fmp.md` §8, §10]

**On the task record's citation.** "the HWZ 2000 Theorem 14 ⇐ direction for this semantics" names no published result: Theorem 14 is about `TL_1`, not this semantics. As a pointer to a proof *shape* (build the model from the certificate, exact quasistate per point, runs existential) it is accurate. `KTypeSummaryAxiomTest.lean` uses it in that sense, and says both that the construction "is requirement (S), landed in `RaySummary/Realize.lean` for `box`/`stab`-free φ at ONE seam" (l.83-84) and that "Theorem 14 ⇐ — a model from a colouring — is absent from this tree" (l.289); those two sentences should be read together as "landed in a corner, absent in general". [SOURCED: the test file; INFERRED reading]

### Mathlib Theorems

Gate resolved to perform (task type lean4, tools registered). `lean_leansearch` "Ehrenfeucht-Fraïssé game back-and-forth equivalence of structures" returned only first-order model theory (`FirstOrder.Language.ElementarilyEquivalent`, `PartialEquiv`); nothing for temporal until/since games or quasimodels. `lean_local_search LnkRow` confirmed the eleven local declarations (source-text search; symbol index errored). No Mathlib result bears on this round. [SOURCED: tool output]

### Context File Review

`.claude/context/project/logic/README.md` and `domain/ztime-no-finite-carrier-fmp.md` §8-§11. The latter already carries a Definition-by-Definition HWZ table that this round's reading confirms (Defs 5-12, Lemmas 17, 21, 23, Theorems 14, 24). It does **not** record the two points this round adds: Def. 7 is an equality, and Theorem 14 ⇐ builds its model.

### External Resources

- Etessami & Wilke 2000, full text (see Sources). LICS 1996 conference version exists ("An Until Hierarchy for Temporal Logic", pp. 108-117) [SOURCED: search result metadata only; not read].
- GKWZ 2003 ch. 11 and §13.2 (local) restate the quasimodel method (Lemma 11.22; Theorem 13.6 for PTL × S5) [SOURCED: grep hits and the project context file only; **not read this round**, so no claim here rests on it].

## Decisions

- Treated the local HWZ extract as primary despite the dispatch saying it was absent; verified its identity from its own title block.
- Did not read GKWZ §13.2 (PTL × S5 quasimodels), which is the closest published object to an S5-like box over a linear flow. Flagged below as the one unread source that could change the Q4 answer.
- Did not attempt to derive a jump-closed threshold; the round is literature-only.
- Marked the strict-until / split-budget correspondence INFERRED rather than SOURCED: EW prove their theorem for the reflexive variant with a single counter.

## Recommendations

1. **Correct report 29 §Q4 before anyone acts on it** (owner: orchestrator / next reviser). Three edits of substance: (i) quasistates are exact, not merely sound — cite HWZ Def. 7 and Lemma 8; (ii) the model in Theorem 14 ⇐ is constructed, not given; (iii) delete "exponential thresholds as its NORMAL form" as a literature attribution — EW's thresholds are linear; keep the doubling as the project's own compiled finding.
2. **Take the statement question to the user with the corrected framing.** The choice is not "complete invariant vs. sound abstraction". It is: (A) keep the cell equation on the fixed `ladderModel` over a finite coordinate — no literature precedent, refuted at the filed clip; (B) HWZ-shaped: certificate keyed by exact quasistates, model **built from** the certificate, plus the read-off direction — literature-shaped by analogy, and exactly what the tree's own test file calls "absent from this tree"; (C) report 29's rank 3 as written (existential realization inside fixed `ladderModel`) — neither refuted nor literature-backed, uncosted.
3. **Before choosing (B), read GKWZ 2003 §13.2 / Theorem 13.6 and ch. 11 §11.3-11.4 in the local corpus** for how the S5 dimension is carried in a quasistate. One bounded reading round; it is the nearest published analogue to `⊡` and was not read here.
4. **Do not open a threshold-hunting round on the strength of the game literature.** It supplies no jump-closure recurrence. If rank 4 of report 29 is taken, it is first-principles work and should be labelled so.
5. Optional context-file amendment (owner: whoever next edits the source store, not `.claude/` directly): add the two missing facts to `ztime-no-finite-carrier-fmp.md` §8.

**Direct answer to the dispatch question — does the evidence support re-stating the task around a quasistate-keyed certificate?**
Qualified yes on the *keying*, no on the *rationale*, and silent on the *model*. Keying by quasistates (exact sets of types, the box-like clause internal to the set, runs existential) is precisely HWZ's Definitions 6-12 [SOURCED]. But HWZ gets its ⇐ by constructing the model, and it has no `⊡`; so the evidence supports re-stating toward a **certificate ⇒ constructed model** theorem of HWZ shape, and does **not** support a restatement that keeps `ladderModel` fixed and weakens the equation to a two-containment "soundness + existential realization" pair — that variant has no source. The sources are sufficient to say this much and not sufficient to say the HWZ shape transfers to this semantics; that transfer is the open risk, and GKWZ §13.2 is where to look next.

## Risks & Mitigations

- **Conversion fidelity.** The HWZ extract drops angle brackets and scrambles the `σ_φ` display. Mitigation: every quotation above is from prose or from definitions whose meaning survives; the `σ_φ` formula is described, not quoted. The Def. 7 equality was cross-checked against Lemma 8's `α_C` and the cardinality display in Theorem 14's proof.
- **Absence claims.** "HWZ never requires a coarser invariant" is bounded by the sections read (Appendix). §7 (the composition method over `⟨ℝ,<⟩`) uses "characters" as finite descriptions of pre-quasimodels and notes "there can be more than one prequasimodel with a given character" (chunk 0050, seen by grep) — consistent with, and mildly supporting, the existential reading, but not read in full.
- **EW's Since case is not written out.** The linear `2k+1` bound is a stated theorem; its invariant is omitted by the authors. Anyone wanting a since-and-until threshold shape cannot get it from this paper.
- **Analogy risk.** All Q4 conclusions transfer from first-order temporal logic to this logic by analogy. Mitigation: recommendation 3.

## Appendix

**Extent of reading.**
- HWZ 2000 (88 chunks): read in full — chunks 0001, 0017-0025 (§2.2, §3, §4 through Theorem 15's proof), 0027-0034 (§5 entire: Lemma 17 through Theorem 24; §6 opening), 0037-0038 (Def. 28, Theorem 29, Lemmas 30-32). Grepped only — the rest, including §7 and §8.
- Etessami-Wilke 2000 (21 pp.): read in full — §1, §3 (game, Theorem 3.1 statement and opening, Theorem 3.3, Remark 3.4), §4 through Lemma 4.5 and its discussion, §5. Skimmed by grep — §6 (automata characterizations).
- Project: `LadderStepFrag.lean` l.18-30, 201-221, 560-760, 1116-1150; report 29 l.60-125.

**Locators.**
- HWZ Def. 5 chunk 0019; Def. 6-7, Lemmas 8-9 chunk 0020; Def. 10-11 chunk 0021; Def. 12, Remark 13, Theorem 14 statement and (⇒) chunk 0022; Theorem 14 (⇐) chunk 0023; `σ_φ`, Theorem 15 chunks 0024-0025; Lemma 17 chunks 0027-0028; Lemma 19 chunk 0028; Def. 20, Lemma 21 chunks 0030-0031; Def. 22, Lemma 23 chunks 0031-0032; Theorem 24 chunk 0033; Def. 28, Theorem 29, Lemma 30 chunk 0037; Lemmas 31-32 chunk 0038.
- EW: game definition pp. 91-92; Theorem 3.1 p. 92; Theorem 3.3 pp. 93-94; Theorem 4.1, Lemma 4.2, Claim 4.3 pp. 94-97; Theorem 4.4, Lemma 4.5 pp. 97-98; Proposition 5.1 pp. 99-100.

**Search queries.**
- WebSearch: `Etessami Wilke "An until hierarchy and other applications of an Ehrenfeucht-Fraïssé game for temporal logic" Information and Computation 2000`
- WebSearch: `Ehrenfeucht-Fraïssé game until since temporal logic integers counters threshold Duplicator strategy exponential in nesting depth`
- Local: index scan of `~/Projects/Literature/index.json` for hodkinson/wolter/zakharyaschev/etessami/wilke/quasimodel; grep of the HWZ, GKWZ and Handbook ch. 11 directories.
- Mathlib: one `lean_leansearch`, one `lean_local_search` (see Findings).

**Web sources.**
- https://lclem.github.io/formal_verification_2025-2026/assets/pdf/etessami-wilke.pdf (full text used)
- https://www.research.ed.ac.uk/en/publications/an-until-hierarchy-and-other-applications-of-an-ehrenfeucht-fra%C3%AFs/ and https://lics.siglog.org/1996/EtessamiWilke-AnUntilHierarchyfor.html (bibliographic metadata only)
- https://arxiv.org/pdf/1102.5638.pdf (surfaced, not read)
