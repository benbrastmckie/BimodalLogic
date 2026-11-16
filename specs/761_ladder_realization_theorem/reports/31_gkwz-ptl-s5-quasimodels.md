# Research Report: Task #761

**Task**: 761 - ladder_realization_theorem
**Started**: 2026-11-16T14:30:43-08:00
**Completed**: 2026-11-16T14:36:03-08:00
**Effort**: one bounded literature round (read-only)
**Dependencies**: `reports/30_quasimodel-abstraction-literature.md` (the gap this round closes); `reports/29_row-link-route-viability.md` (not re-litigated)
**Sources/Inputs**:
- Gabbay, Kurucz, Wolter, Zakharyaschev, *Many-Dimensional Modal Logics: Theory and Applications* (2003) — local corpus `~/Projects/Literature/sources/gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics/` (758 chunks, OCR-derived; modal glyphs and the run-order symbol are garbled, see Risks). Cross-checked against a `pdftotext` pass over the staging PDF named in the corpus `metadata.json` (same OCR layer, so a check on chunking, not on glyphs).
- Project: `FormalSystem/Metalogic/Decidability/RaySummary/AnchorLayer.lean` (`cellAt`, l.132), `CounterQuotient.lean` (`certStabK`, `certBoxK`, `certAdmK`, `Dmax`, `dmax_maximal`, l.1215-1262), `LadderModel.lean` (`ladderModel`, l.225), `PlusLanguage/PlusTruth.lean` (`stab_state_only`, l.338); `specs/state.json` task record; `.claude/context/project/logic/domain/ztime-no-finite-carrier-fmp.md` §7, §8, §10.
- No web source was needed or used.
**Artifacts**: `specs/761_ladder_realization_theorem/reports/31_gkwz-ptl-s5-quasimodels.md`
**Standards**: report-format.md, subagent-return.md
**Task Type**: logic (literature round for a lean4 task)

**Marking convention.** Every assertion carries **[SOURCED]** (work, theorem/section, printed page where the extract shows one, corpus chunk), **[INFERRED]** (from a sourced fact, inference stated) or **[UNSOURCED]**. Extent of reading is in the Appendix; absence claims are bounded by it.

## Executive Summary

- **§13.2 does not contain what report 30 expected, in one specific respect.** Theorem 13.6's proof is written out **only for L = K** (quasistates are finite intransitive *trees* of types). The S5 case is dispatched in one sentence: "For L = KD45_n and L = S5_n, the reader should have no difficulties with repeating the proof above by appropriately modifying quasimodels similar to what was done in the proofs of Theorems 6.49 and 6.67." There is no S5-specific definition or lemma in §13.2. The S5 quasimodel that sentence points at is defined in §5.2 (S5 × S5, Theorem 5.22 / Lemma 5.24) and reused by sketch in §6.5 (Theorems 6.44 and 6.61). This round read those. [SOURCED]
- **Q2: the exact/existential split is the same as HWZ's; the S5 dimension changes how exactness is *stated*, not whether it holds.** Quasistate = a set `T` of types closed under an internal biconditional `(qm1)`; read-off direction *defines* `q(x) = {t(x,y) | y ∈ W₂}` (an equality); converse direction builds a model on `W × R` in which the types at `w` are exactly `q(w)`; runs are existential (`(qm3)`: every type in `q(w)` lies on *some* run). Two differences from HWZ: no external realizability hypothesis (Def. 7 collapses to the syntactic `(qm1)`), and no multiplicity cardinal (domain = runs, not runs × κ). [SOURCED]
- **Q3: the modal clause is `(qm1)`, a saturation condition internal to the cluster — and the project's `certStabK` is that clause, verbatim up to duality, relativised to a fibre.** GKWZ: `◇ψ ∈ t ⇔ ∃ t' ∈ T, ψ ∈ t'`. Project: `⊡ψ ∈ x ⇔ ∀ y ∈ R, y.1 = x.1 → y.2.2 = x.2.2 → ψ ∈ y`. Same shape; the difference is *which set plays T*: in GKWZ the cluster is the whole time slice (one cluster per time point); in the project it is the fibre of `R` over `(q, κ)` (many clusters per time point). There is no per-state bit in GKWZ beyond the consequence that `◇ψ` is constant across a cluster. [SOURCED for both clauses; INFERRED for the comparison]
- **Q4: the converse constructs its model, in every variant read** (S5 × S5: `W₁ × R` with universal relations; K × K and §13.2: `𝔉 × (R, ◁)`; monodic: runs × κ). The only place a **pre-given** model is quotiented is the filtration proof of Theorem 5.27 / Lemma 6.47, where a point is keyed by `(Σ(x), {Σ(z) | x R_v z})` — its type together with its cluster's type set, i.e. by the quasistate itself, never by a coarser coordinate — and that route yields the fmp, which the temporal products provably lack (Theorem 5.32). [SOURCED]
- **Q5: the filed shape is UNSUPPORTED, not contradicted — and it decomposes.** Three of its four ingredients have exact published counterparts (cell = quasistate read-off; `⊡` clause = `(qm1)`; `Dmax` = the maximal satisfying set obtained by elimination). The fourth — that the cell of a **pre-given** infinite model at a state equals the fibre of the *maximum* certified set over a **fixed finite quotient coordinate** — has none. The published facts about a maximal set are a one-sided containment for given objects plus realizability by a constructed one. [SOURCED for the published side; INFERRED for the mapping]
- **A premise of the dispatch needs correcting.** "PTL × S5 is this project's actual setting" is not what the project's own context file says ("this logic is not a product", §10), and the Lean semantics confirms it: `⊡` is keyed by world state, at any two times (`stab_state_only`), giving many clusters per time. GKWZ's own taxonomy puts that outside §13.2 (products = "know the time, do not forget, do not learn") and nearer §13.1 (synchronous systems), which goes through the *monodic first-order* quasimodel — i.e. back to the HWZ-shaped object report 30 already read. [SOURCED for each side; INFERRED for the placement]

## Context & Scope

Report 30 read HWZ 2000 and Etessami-Wilke and named GKWZ §13.2 / Theorem 13.6 as the unread source that could change its Q4 answer. This round reads it and everything it defers to. Out of scope and untouched: report 29's Lean refutations, report 30's HWZ findings, every `.lean` file, plan and record. No `.orchestrator-handoff.json` is written.

## Findings

### Q1 — Theorem 13.6 and the definitions under it

**Setting of §13.2** (printed pp. 565-571; chunks 0587-0594). §13.2 is titled "Agents who know the time and neither forget nor learn". Its opening observation: such a temporal epistemic structure "is isomorphic to the product of the frames (T, <) and (R, S₁, …, S_n)". `KN` is the class of these structures. Theorem 13.4: `ELog(KN_{L,C}) = Log(C × Fr L)`. Theorem 13.5 specialises to named products (`Log{(F,<)} × L` for F ∈ {ℕ, ℚ}; `K4.3 × L`, `Lin × L`, `Lin_SU × L` for all strict linear orders). [SOURCED: chunks 0587-0589]

**Theorem 13.6** (p. 568; chunks 0589-0590): "Suppose that L ∈ {K_n, T_n, KD45_n, S5_n} and C is one of the following classes of strict linear orders: (1) {⟨ℕ,<⟩}, … any first-order definable class of strict linear orders—for example, the class of all strict linear orders. Then ELog_SU(KN_{L,C}) is decidable." [SOURCED] Items (2)-(4) of the list are lost in both the corpus extract and the PDF text layer. The proof speaks of "the first four statements" and "statement (5)" and sends (5) to "the corresponding part of the proof of Theorem 11.21", whose list is ℕ, ℤ, ℚ, finite strict linear orders, first-order definable classes; so (2)-(4) are very probably ⟨ℤ,<⟩, ⟨ℚ,<⟩, finite orders. [INFERRED from the proof's own cross-reference; the three items themselves are not legible]

It is a **decidability** theorem. The satisfiability iff underneath it is Lemma 13.7. [SOURCED]

**The proof as written is for L = K.** "We prove this result first for L = K. Let us begin with a straightforward modification of the notion of a quasimodel used in the proof of decidability of K × K (Theorem 6.1)." Definitions, as stated (chunks 0591-0592):

1. **Type**: "any Boolean-saturated subset of sub φ". [SOURCED]
2. **Quasistate**: "a pair q = ((T, <), t), where (T, <) is a finite intransitive tree of depth ≤ md(φ) and t is a labeling function associating with each x ∈ T a type t(x) for φ such that conditions (qm1) and (qm1′) from the proof of Theorem 6.1 hold." Isomorphic quasistates are identified. [SOURCED] From Theorem 6.1 (pp. 273-274; chunk 0298): **(qm1) saturation** — for all `x ∈ T` and `◇ψ ∈ sub φ`, `◇ψ ∈ t(x)` iff `∃y ∈ T (x < y ∧ ψ ∈ t(y))`; **(qm1′) smallness** — distinct immediate successors of a node generate non-isomorphic labelled subtrees. [SOURCED]
3. **Basic structure of depth m**: `(𝔉, q)`, `q` "a function associating with each w ∈ W a quasistate" of depth `m`. No further constraint on `q`. [SOURCED]
4. **k-run**: "a function r giving for each w ∈ W a point r(w) ∈ T_w of co-depth k". **Coherent and saturated**: the Until and Since clauses hold along `r` as biconditionals (`ψ₁Uψ₂ ∈ t_w(r(w))` iff there is `v > w` with `ψ₂ ∈ t_v(r(v))` and `ψ₁ ∈ t_u(r(u))` for all `u ∈ (w,v)`; dually for S). [SOURCED]
5. **Quasimodel** `Q = (𝔉, q, R, ◁)`: `R` a set of coherent and saturated runs, `◁` a binary relation on `R`, with **(eqm2)** `∃w₀ ∈ W, φ ∈ t_{w₀}(r₀(w₀))`, `r₀ ∈ R₀`; **(eqm3)** if `r ◁ r′` then `r(w) <_w r′(w)` for all `w`; **(eqm4)** for all `k < m`, `r ∈ R_k`, `w`, `x ∈ T_w`: if `r(w) <_w x` then there is `r′ ∈ R_{k+1}` with `r′(w) = x` and `r ◁ r′`. [SOURCED; the `◁` glyph is rendered "<" in the extract and is read from Theorem 6.1's parallel text]
6. **Lemma 13.7**: "An ML_SU ⊗ ML-formula φ is satisfiable in a product frame 𝔉 × 𝔊 iff there is a quasimodel for φ based on 𝔉." Proof: "can be proved in the same way as Lemma 6.2". [SOURCED]
7. **MSO step**: unary predicates `P_q` (one per quasistate) and `R^k_ψ`; the sentence `qm^m_φ` existentially quantifies the `P_q`, whose first line "says that the sets P_q ⊆ W form a partition of W"; Lemma 13.8: `𝔉 ⊨ qm^m_φ` for some `m ≤ md(φ)` iff a quasimodel based on `𝔉` exists; then Theorem 1.28. [SOURCED: chunks 0592-0593]

**The S5 case.** One sentence (p. 571; chunk 0594), quoted in the Executive Summary. Nothing else in §13.2 concerns S5. [SOURCED]

- A numbering note: in the local copy the CPDL × S5 *quasimodel* sketch is **Theorem 6.44** and "Theorem 6.49" is the filtration fmp theorem for the same logic; the book elsewhere also calls "the block-technique used in the proof of decidability of CPDL × S5" Theorem 6.49 (chunk 0563). So the cross-reference is an internal numbering slip in the book, and the intended target is the quasimodel proof at 6.44. [INFERRED from the two cross-references agreeing with each other and disagreeing with the numbered statements; verified in the PDF text layer]
- Theorem 6.67 is `CPDL × S5_m` (multi-agent), whose quasistates are again trees, with two alternating relations (chunks 0357-0359). It is the multi-agent case and is not the single-box analogue. [SOURCED]

**The single-S5 quasimodel that sentence imports** (§5.2, pp. 236-239, chunks 0265-0268; restated for a linear first component in Theorem 6.61's sketch, pp. 323-325, chunks 0351-0352):

- **Quasistate**: "a set T of distinct types for φ which is ◇-saturated, i.e., **(qm1)** ∀t ∈ T ∀◇ψ ∈ sub φ (◇ψ ∈ t ↔ ∃t′ ∈ T ψ ∈ t′). It follows that if ◇ψ ∈ t, for some type t in T, then ◇ψ ∈ t′ for all other types t′ in T. Note that we can consider a quasistate as a 'cluster of types'". [SOURCED] Theorem 6.61: "the S5 component makes it possible to define quasistates for φ as just ◇-saturated subsets of types for φ". [SOURCED]
- **Basic structure** `(W, q)`: `q` any function from `W` to quasistates ("a multiset of type-clusters"). [SOURCED]
- **Run**: "a function r from W to the set of types for φ such that ∀w ∈ W r(w) ∈ q(w) … a 'choice-function'". Coherent and saturated per the first-dimension operators. [SOURCED]
- **Quasimodel** `(W, q, R)`: **(qm2)** φ belongs to a type in some `q(w)`; **(qm3)** "for every w ∈ W and every t ∈ q(w), there is an r ∈ R such that r(w) = t". "Besides, no ordering of the runs is needed" (Theorem 6.44's sketch). [SOURCED]
- **Lemma 5.24**: φ is satisfiable in a universal product S5 × S5-frame iff there is an S5 × S5-quasimodel for φ. [SOURCED]

So the per-state datum for the S5 product is a **set of types**, subject to exactly one condition, `(qm1)`. [SOURCED]

### Q2 — is the exact/existential split kept?

**Yes, on both counts, in every variant read.**

- **Quasistates exact, read-off direction.** Lemma 5.24 (⇒): "with every x ∈ W₁ we associate the quasistate ('vertical type-cluster') q(x) = {t(x,y) | y ∈ W₂}", and "R = {r_y | y ∈ W₂}. Then clearly (W₁, q, R) is a quasimodel for φ." An equality by definition. [SOURCED: chunk 0266]
- **Quasistates exact, construction direction.** Lemma 5.24 (⇐) takes the product of the universal frames on `W₁` and on `R`, valuation `𝔙(p) = {⟨x,r⟩ | p ∈ r(x)}`, and proves `(𝔐, ⟨x,r⟩) ⊨ ψ iff ψ ∈ r(x)`. [SOURCED: chunk 0268] Hence the types realised on the slice at `x` are `{r(x) | r ∈ R}`; this is `⊆ q(x)` by the definition of a run and `⊇ q(x)` by (qm3), so it equals `q(x)`. [INFERRED: two-line consequence of the run definition, (qm3) and the displayed truth lemma] The exactness is used: the `◇` step of the truth lemma reads "⇒ … [by (qm1)]" one way and "[by (qm1)] … [by (qm3)]" the other. [SOURCED]
- **Runs existential.** (qm3) asks for some run through each type; nothing asks that every choice function be a run or that a run be determined by a value. The finitisation proof makes the point itself: after cutting down, "𝔖 is not necessarily big enough to satisfy (qm3)", and the fix is to *manufacture* runs by splicing (`r_{v,t} + s`). [SOURCED: chunk 0269]
- **State function arbitrary.** `q` is "a function from W into the set of quasistates"; in §13.2's MSO sentence the `P_q` are existentially quantified and only required to partition `W`. No factorisation of `q` through a coordinate is stated or used. [SOURCED: chunks 0265, 0593] Chapter 11's splice lemma (Lemma 11.27) has HWZ's hypothesis unchanged — "q(n) = q(m) for some n < m" — equality of whole quasistates. [SOURCED: chunk 0497]

**What the S5 dimension does change** relative to HWZ:

1. **Exactness becomes internal.** HWZ's Def. 7 requires a structure realising exactly `T`; in the S5 product there is no realizability hypothesis at all — any `(qm1)`-saturated set is a quasistate. The `∀x ⋁ t(x)` conjunct of HWZ's Lemma 8 has become the `⇒` half of (qm1). [SOURCED for both definitions; INFERRED for the identification]
2. **No multiplicity cardinal.** The constructed second coordinate is `R` itself, not `runs × κ`. HWZ's `κ` is a number of copies needed because first-order structures count; S5 does not. [SOURCED: chunk 0268 against report 30's Theorem 14 reading; INFERRED for the reason] **Note for readers of the task record:** HWZ's `κ` (a cardinal of copies) and the project's `κ(c,n)` (a counter-class coordinate) are unrelated objects that happen to share a letter. [INFERRED]
3. **For K the "exact" datum is a bisimulation quotient, not a set of points.** Lemma 6.2 (⇒): the slice at `w` is first quotiented by a depth-indexed back-and-forth equivalence `∼_w` and then unravelled to a tree, because "the obvious choice of T_w = Δ … does not work, because Δ can be infinite". [SOURCED: chunks 0300-0301] Not relevant to S5, recorded because §13.2's written proof is this one.

**Consequence for the filed fibre equation.** An exact set equation "types realised at a point's cluster = the certified cluster" **does** have a published product-logic counterpart; it is not an invention. What it is keyed by is the point's own quasistate, assigned by an unconstrained state function. [SOURCED for the equation; INFERRED for "counterpart"]

### Q3 — the S5 dimension's own clause

- **It is (qm1) and nothing else**: a biconditional *inside* the per-state datum. No bit attached to the state, no separate component. The only bit-like fact is the stated corollary that `◇ψ` has the same membership in every type of a cluster. [SOURCED: chunk 0265]
- **The project's filed clause** [SOURCED: `CounterQuotient.lean` l.1222-1226]:
  `certStabK`: `∀ x ∈ R, ∀ ψ, isStab ψ → (ψ ∈ x.2.1 ↔ ∀ y ∈ R, y.1 = x.1 → y.2.2 = x.2.2 → argOf ψ ∈ y.2.1)`.
  And `certBoxK` (l.1230-1233): `ψ ∈ x.2.1 ↔ ∀ y ∈ R, argOf ψ ∈ y.2.1`.
- **Comparison.** [INFERRED: side-by-side reading]

| | GKWZ S5-product quasistate | Project certificate |
|---|---|---|
| Clause | `◇ψ ∈ t ⇔ ∃t′ ∈ T, ψ ∈ t′` | `⊡ψ ∈ x ⇔ ∀y ∈ fibre(x), ψ ∈ y` (the box dual of the same clause) |
| The set quantified over | the quasistate `T = q(w)` — the whole slice at time point `w` | the fibre of `R` over `(q, κ)` |
| Clusters per time point | one | many (one per world state: `stab_state_only`) |
| Key of the cluster | the time point `w`, via an arbitrary map `q` | the pair `(q, κ)`, a fixed quotient of the ladder state |
| Slice-wide box | none separate (the S5 box *is* slice-wide) | `certBoxK`: one global bit — the fibre over everything |
| Read-off of a model | `q(x) = {t(x,y) \| y ∈ W₂}` | `cellAt M φ w z = {T \| ∃σ, σ.state z = w ∧ tpOf M φ σ z = T}` (`AnchorLayer.lean` l.132) |

- **So `certStabK` is a faithful transcription of (qm1), and `cellAt` is a faithful transcription of the quasistate read-off.** The project's `stab` *letters* are the closure formulas `⊡ψ` inside a type, which is how GKWZ carries `◇ψ` too — there is no extra "bit" on either side. [INFERRED]
- **The one structural difference is the indexing**, and it is not cosmetic. In a product the S5 cluster at a point is the entire time slice, so a quasistate is a per-time datum. In the project `⊡` quantifies over histories through the same *world state*, so the cluster is a per-state datum and a time slice contains many. That is precisely the feature that makes the structure not a product. GKWZ's chapter 13 draws the same line: products are the structures for agents who "know the time, do not forget and do not learn simultaneously" (§13.2 opening); structures where the epistemic relation only respects time are `SYNC` (§13.1), "the disjoint union of the n-frames ({t} × R, R₁ᵗ, …)" — many clusters per time. [SOURCED: chunks 0587, 0581-0582; INFERRED for the project's placement on the `SYNC` side of that line]
- **How §13.1 carries the many-clusters case** (read because it is the structurally nearer one): by translating to monodic first-order temporal logic and applying Theorem 11.21. The state candidate is "just a set of types"; it is "LC-realizable iff there is an n-frame for L and a model such that for every t ∈ T, there exists w with (𝔐,w) ⊨ ⋀t" **and** "for every w ∈ W, there exists t ∈ T such that (𝔐,w) ⊨ ⋀t". Both bullets: exact again, now as an external realizability condition, and the cluster partition is *not* recorded in the quasistate — it lives inside the realising model. Condition (b) is met by "the disjoint union of κ isomorphic copies". [SOURCED: chunks 0584-0585]
- **§13.1 is not the project's setting either.** Theorem 13.3: over homogeneous flows (ℤ, ℚ, ℝ) the synchronous logic "coincides with the fusion" — no interaction between time and the box. [SOURCED: chunk 0586] The project's `⊡` does interact (it is state-only *across times*, and histories are the step paths of a frame, not an arbitrary set of functions). So neither section's theorem applies; both supply shapes only. [SOURCED for `stab_state_only` and the context file §7 S1/S3; INFERRED for the non-applicability]

### Q4 — constructed model or certified pre-given model?

- **Constructed, without exception in what was read.** S5 × S5 (Lemma 5.24 ⇐): product of universal frames on `W₁` and `R`. K × K (Lemma 6.2 ⇐): "Take the product frame 𝔉 × (R, ◁) and define a valuation … 𝔙(p) = {(w,r) | p ∈ t_w(r(w))}". §13.2 (Lemma 13.7): "in the same way as Lemma 6.2". Monodic (Lemma 11.22 ⇐): `D = {⟨r,ξ⟩ | r ∈ R, ξ < κ}`. In each, a point of the built model is a (time point, run) pair and its type is the run's value — the cell equation holds by construction. [SOURCED: chunks 0266-0268, 0299-0300, 0592, 0489]
- **Remark 5.23 makes the reading explicit**: "the quasimodel Q = (W, q, R) can be regarded as an abstract model for S5 × S5 satisfying φ. The set of points in this model is U = {r(w) | w ∈ W, r ∈ R} … An important property of this abstract model is that it can be reconstructed into a product model". The certificate is itself read as a model; nothing is certified *about* another one. [SOURCED: chunk 0266]
- **The read-off direction does take a pre-given model, and gives an exact equation for it** — `q(x) = {t(x,y) | y ∈ W₂}` — but as a *definition* of `q` from the model, per point. It does not assert that `q` is a function of any coordinate of `x` fixed in advance. [SOURCED: chunk 0266; INFERRED for the absence, within the sections read]
- **One genuine pre-given-model quotient exists: filtration** (Theorem 5.27, pp. 241-243, chunk 0271; Lemma 6.47, chunk 0346). `x ∼ y iff Σ(x) = Σ(y) and {Σ(z) | x R_v z} = {Σ(z) | y R_v z}`; "each world [x] in 𝔐∼ is uniquely determined by the pair (Σ(x), {Σ(z) | x R_v z})". This is stated for commutator (not necessarily product) frames, i.e. many clusters per horizontal position — the project's geometry. Two limits on its use: (i) the key is the point's type together with its cluster's exact type set — the quasistate again, computed from the model, not a coordinate chosen beforehand; (ii) its output is a *finite model*, and it is proved only for `L × S5` with L among K_n, T_n, D_n, K4_n, S4_n, KD45_n, S5_n. For temporal first components the book records "none of the logics K4.3 × S5, Log{(ℕ,<)} × S5, Log{(ℚ,<)} × S5 have the product fmp" (Theorem 5.32) and leaves the abstract fmp open (Question 6.62). The project's own finite-width refutation is the same wall. [SOURCED: chunks 0271, 0346, 0353; INFERRED for the parallel with the project's WIDTH fact]
- **A published counterpart to `Dmax`.** The 2EXPTIME procedure for `Lin × S5` (Theorem 6.61) and the 3EXPTIME one for `CPDL × S5` (after Lemma 6.46) both compute a **maximal** set by elimination: "Eliminate iteratively those blocks … Obviously, the set 𝔎 of remaining blocks forms a satisfying set for φ if it contains a block satisfying (qm2). Conversely, if there exists a satisfying set S of blocks for φ, then 𝔎 ⊇ S and 𝔎 is a satisfying set for φ itself." [SOURCED: chunks 0345, 0353] The project's `Dmax` is the union of all `certAdmK`-certified sets, with `dmax_maximal` the analogue of "𝔎 ⊇ S". [SOURCED: `CounterQuotient.lean` l.1248-1262; INFERRED for the analogy] What the book proves about the maximal set is: (a) every satisfying set — in particular what any model yields on read-off — lies **inside** it; (b) it is itself satisfying, hence realised by a quasimodel **assembled from it** (block lemma). It never proves that a given model realises *all* of the maximal set over any point. [SOURCED for (a), (b); INFERRED for the absence]

**Does the product-logic version differ from HWZ on this point? No.** The distinction report 30 called load-bearing holds unchanged. [INFERRED from the four bullets above]

### Q5 — the filed shape against the published construction

Filed [SOURCED: `specs/state.json`]: `cellAt (ladderModel …) φ (t, ⟨(q,c,n),h⟩) z = {T | ∃ S, typeOfCl S = T ∧ (q, S, κ(c,n)) ∈ Dmax}`.

Ingredient by ingredient:

| Ingredient of the filed equation | Published counterpart | Status |
|---|---|---|
| Left side: exact set of types at a cluster | quasistate read-off `q(x) = {t(x,y)}` (Lemma 5.24 ⇒) | **supported** [SOURCED] |
| `⊡` clause inside the certificate (`certStabK`) | (qm1) | **supported**, modulo cluster indexing [SOURCED/INFERRED] |
| `Dmax` as a maximum certified set | maximal satisfying set by elimination (Thm 6.61, Lemma 6.46 ff.) | **supported** [SOURCED/INFERRED] |
| `⊆` half: every realised type lies in `Dmax`'s fibre | "𝔎 ⊇ S" applied to the read-off | **supported in shape**, provided the read-off of `ladderModel` is itself a certified set over the same key [INFERRED] |
| `⊇` half for a **pre-given** model: every element of the maximum set over the key is realised at *this* state of *this* model | none; the book's ⊇ is realisation by a model built from the set | **unsupported** [INFERRED: absence over sections read] |
| Key = a **fixed finite quotient** `(q, κ(c,n))` of an infinite state space, with the valuation blind to `(c,n)` | none; `q` is an arbitrary map, quotient keys are the quasistate itself (filtration) | **unsupported** [INFERRED] |

- **Not contradicted.** Nothing in GKWZ says a model cannot have cells that factor through a finite coordinate; the constructed models trivially do when the chosen state function does (e.g. the periodic `q₁ ∗ q₂^ω` of §11.4). The refutations of particular clips are the project's own compiled results. [SOURCED for the periodic form only as far as Lemma 11.28's statement (chunk 0497) and one grep-seen line of chunk 0495 — §11.4 was not read in full; INFERRED for the rest]
- **A different, supported statement shape — two halves, as in every quasimodel lemma read:**
  1. **Read-off (soundness), model given.** For the given model, the family of cells, keyed by the state itself (or by any key the cells are *proved* to factor through), together with the histories as runs, satisfies the certificate conditions; hence it lies inside the maximum certified set. This is Lemma 5.24 (⇒) plus "𝔎 ⊇ S". It yields `⊆` only. [SOURCED shape; INFERRED transfer]
  2. **Construction (completeness), certificate given.** From a certified set build a model whose points carry the certificate's key, so that the cell equation is the truth lemma plus (qm3). This is Lemma 5.24 (⇐). The model is an *output*. [SOURCED shape; INFERRED transfer]
  The filed equation fuses the two by asking a model fixed in advance to be the output of step 2 for the *maximum* set. That is consistent with the literature only if `ladderModel` is shown to be (or is redefined as) the model step 2 builds — in GKWZ's terms, if its states are literally the keys of the state function. With states `(q,c,n)` and a quotient `κ` on top, that identity is the open content, and no source supplies it. [INFERRED] `ladderModel`'s own docstring already says of its frame "has no literature counterpart". [SOURCED: `LadderModel.lean` l.215-224]
- **Does §13.2 change report 30's Q4 answer?** No. It confirms it for the product setting and adds two things report 30 could not have: the `⊡` clause and `Dmax` both have real published counterparts (report 30 had only an analogy through the first-order quantifier), and the published maximal-set statements are one-sided for given objects. [INFERRED]

### Mathlib Theorems

Gate resolved to perform (lean4-routed task, tools registered). One `lean_leansearch`, "product of Kripke frames, modal logic S5 quasimodel", returned only order-theoretic `Order.Frame` instances (`Prod.instFrame`, `Pi.instFrame`, coframe variants) — nothing on modal products or quasimodels. No Mathlib result bears on this round. [SOURCED: tool output]

### Context File Review

`ztime-no-finite-carrier-fmp.md` §8 says "§13.2's Theorem 13.6 gives the MSO route for PTL × S5". That is accurate as a pointer but overstates what is on the page: the route is written for K and the S5 case is left to the reader. §10 of the same file ("this logic is not a product … GKWZ's product quasimodels presuppose commutativity and Church-Rosser, which the stability modal lacks") is consistent with this round and conflicts with the dispatch's premise. [SOURCED]

### External Resources

None consulted. The corpus copy contained every section needed.

## Decisions

- Read past §13.2 into §5.2, §6.1, §6.5, §6.6, §5.3, §11.3 and §13.1, because §13.2 defers its S5 content entirely; reporting on §13.2 alone would have been a non-answer.
- Treated "Theorems 6.49 and 6.67" as pointing at the CPDL × S5 quasimodel proof (numbered 6.44 in the copy) and the S5_m proof; recorded the mismatch rather than silently resolving it.
- Read §13.1 although not requested, on finding that the project's `⊡` sits on the non-product side of the book's own taxonomy.
- Did not cost or attempt any restated theorem; did not open any `.lean` file beyond reading four definitions.
- Marked every project/literature identification INFERRED: no source mentions this semantics.

## Recommendations

1. **Record that `certStabK`, `cellAt` and `Dmax` are literature-shaped** — (qm1), the quasistate read-off, and the maximal satisfying set — with the GKWZ locators in the Appendix. This replaces report 30's weaker "analogy via the quantifier". (Owner: next reviser.)
2. **Take the statement question to the user as a split, not a weakening.** The published shape is two lemmas with the model on opposite sides: read-off (given model ⇒ certified, hence `⊆ Dmax`) and construction (certified set ⇒ model whose cells are its fibres). The filed single equation is their fusion at a fixed model and a fixed quotient key; only the fusion is unsourced.
3. **If the fixed-model equation is kept, name its two unsourced obligations explicitly**: (i) the read-off of `ladderModel` factors through `(q, κ)`; (ii) `ladderModel` realises the *whole* maximum set over each key. Neither can cite GKWZ or HWZ.
4. **Correct the context file's §8 sentence** to say Theorem 13.6 is proved for K with S5 left to the reader, and point at §5.2 / Theorem 6.61 for the single-S5 quasimodel. (Source store, not `.claude/` directly.)
5. **Stop describing the setting as PTL × S5** in task prose; the project's own note and `stab_state_only` both say otherwise.
6. Optional, one bounded round: GKWZ §3.4 and Halpern-Vardi's "intermediate" constraint classes (Table 13.1), which the book says its machinery does *not* cover — the place a state-keyed, non-synchronous box would have to live. Not read here; no claim rests on it.

**Direct answer to Q5.** The filed shape — a fibre equation over a fixed finite coordinate certifying a pre-given `ladderModel` — is **unsupported** by the published product-logic construction, and **not contradicted** by it. Its clauses are the published ones; its *architecture* is not: GKWZ, like HWZ, proves an exact cell equation only (a) by defining the quasistate from a given model, point by point, or (b) by constructing the model from the quasimodel, and its statements about a *maximal* certified set are a containment for given objects and realisation by a built one. The supported statement shape is that pair — read-off and construction — not their fusion.

**What would falsify this answer.** (1) A passage in GKWZ (or its cited sources) proving, for a model given in advance, that its quasistates are a function of a finite quotient of its points *and* exhaust a maximal certified set — most plausibly inside the unread block proofs (Theorem 6.40, Lemmas 6.45/6.46 in full) or §11.4's elementary analysis; this round did not find one in the sections listed in the Appendix. (2) A different intended target for "Theorems 6.49 and 6.67" than the one inferred here, carrying an S5 quasistate that is not a (qm1)-saturated set of types. (3) Glyph-level misreading of (qm1) from the OCR — mitigated by the proof of Lemma 5.24, which uses (qm1) and (qm3) exactly as read, but a printed-page check of p. 236 would settle it. (4) On the project side: a proof that `ladderModel` is isomorphic to the model the construction half builds from `Dmax`; that would turn "unsupported" into "supported by construction", and is the one route by which the filed equation becomes literature-shaped.

## Risks & Mitigations

- **OCR fidelity.** Both the corpus chunks and the PDF text layer render `◇`, `□`, `◁`, set braces and some labels unreliably ("(qml)", "(am2)", "(eqm?2)", "&" or "S" or "O" for a diamond). Mitigation: each clause quoted was cross-read against the proof step that uses it (which operator's induction step cites it); where a symbol was reconstructed the bullet says so. No printed page was inspected visually.
- **Deferred proofs.** §13.2's S5 case, Lemma 13.7, Theorems 6.44 and 6.61 are sketches or "left to the reader". The definitions quoted are stated in the book; that they compose into a PTL × S5 quasimodel lemma is the book's claim, not a written proof.
- **Absence claims** are bounded by the Appendix. Unread and relevant: Theorem 6.40's full block proof, Lemma 6.46's proof, §11.4 beyond Lemmas 11.27-11.29's statements, §3.4.
- **Transfer risk.** Every project/literature identification is by shape. The logic is not a product and is not a synchronous fusion; no theorem in the book applies to it.

## Appendix

**Extent of reading (GKWZ 2003, local corpus).** Read in full: chunks 0263-0269 (§5.2: quasimodel method, Theorem 5.22, Remark 5.23, Lemma 5.24, finitisation, Theorem 5.25); 0270-0271 (Theorem 5.27 statement and proof to (f2)); 0298-0301 (Theorem 6.1 definitions, Lemma 6.2 both directions); 0343-0348 (§6.5 opening, Theorem 6.44, Lemmas 6.45-6.48, Theorem 6.49); 0351-0353 (Theorems 6.60, 6.61 and sketch, Question 6.62); 0357-0360 (Theorems 6.64, 6.67 definitions); 0487-0489 (Theorem 11.21, quasimodel definition, Lemma 11.22); 0497 (Lemmas 11.27, 11.28 statement); 0580-0595 (chapter 13 introduction, §13.1, §13.2 entire). Partially: 0193 (Theorem 3.29). Grepped only: the rest.

**Locators.** Theorem 13.6 p. 568, chunks 0589-0590; its proof pp. 568-571, chunks 0591-0594; Lemma 13.7 p. 569, chunk 0592; Lemma 13.8 p. 570, chunk 0593; S5 sentence p. 571, chunk 0594. S5 × S5 quasistate, (qm1)-(qm3) pp. 236-237, chunk 0265; Remark 5.23 and Lemma 5.24 pp. 237-239, chunks 0266-0268; Theorem 5.27 pp. 241-243, chunks 0270-0271. Theorem 6.1 / Lemma 6.2 pp. 272-276, chunks 0297-0301. Theorem 6.44 pp. 318-319, chunk 0344; elimination procedure p. 319, chunk 0345; Lemma 6.47 p. 320, chunk 0346; Theorem 6.61 pp. 323-325, chunks 0351-0353; Theorem 6.67 pp. 330-332, chunks 0357-0359. Lemma 11.22 pp. 475-477, chunks 0488-0489; Lemma 11.27 chunk 0497. §13.1 pp. 559-565, chunks 0581-0587; Theorem 13.3 chunk 0586.

Page numbers are read from the running heads embedded in the extract and are approximate to within a page at section boundaries.

**Searches.** Local grep over the GKWZ directory for "quasimodel", "Theorem 13.6", "PTL x S5", the cross-referenced theorem numbers and the (qm*) labels; `pdftotext -layout` of the staging PDF for numbering checks; one `lean_leansearch`. No web search.
