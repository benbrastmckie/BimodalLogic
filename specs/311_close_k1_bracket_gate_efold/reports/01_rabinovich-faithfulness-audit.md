# Research Report: Rabinovich-Faithfulness Audit of the k=1 Bracket-Gate Closure Plan

- **Task**: 311 - close_k1_bracket_gate_efold
- **Started**: 2026-07-06T00:00:00Z
- **Completed**: 2026-07-06T00:00:00Z
- **Effort**: ~2 hours (verification research; no code written)
- **Type**: lean4 / research (literature-fidelity verification)
- **Session**: sess_1783377034_1c2280
- **Dependencies**: 310 (COMPLETE), 309 (BLOCKED, parent)
- **Sources/Inputs**:
  - PRIMARY (ground truth): `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf` (pages 3-7 read directly) + `.md` summary (245 lines)
  - Plan under audit: `specs/311_close_k1_bracket_gate_efold/plans/01_k1-gate-closure-plan.md`
  - Prior art: `specs/310_.../reports/01_efold-encoding-research.md`, `specs/309_.../plans/03_offdiag-fi-chain-plan.md`, `specs/305_.../reports/14_faithfulness-audit.md` + `35_team-research.md`, `specs/303_.../reports/19_rabinovich-proof-extraction.md`
- **Artifacts**: `specs/311_close_k1_bracket_gate_efold/reports/01_rabinovich-faithfulness-audit.md`
- **Standards**: report-format.md, literature-fidelity-policy.md

## Executive Verdict

**FAITHFUL-WITH-CAVEATS.** The plan does **not** reinvent novel mathematics. Every one of the six
cited Rabinovich results genuinely exists in the 2014 paper, and — a strong fidelity signal — **all
six cited PDF page numbers are exactly correct** (Def 3.1 p.4, Lemma 3.2 p.4, Lemma 3.4 p.5,
Prop 3.5 p.5, Def 4.1 p.5, Prop 4.3 p.6, all verified against the actual PDF pages, not just the
summary). The three load-bearing moves for the "novel math" question — (a) that Rabinovich's
normal form has **no joint multi-point atom** (Def 3.1's α_j/β_j are one-variable quantifier-free
formulas), (b) that the free-variable/anchor count is capped at **≤2** (Lemma 3.2(2)), and (c) that
adding an existential witness under **∃-closure stays inside ∨∃∀ without raising the free-variable
count** (Lemma 3.4 + Lemma 3.2(2)/(3)) — are each **faithful transcriptions**, not inventions. The
critical insight the plan relies on is in fact the *opposite* of novel math: the "arity-4 residual"
that blocked the old encoding is a **Lean `nf_eval_nf` arity-growth artifact that has no counterpart
in Rabinovich's proof** (Rabinovich's depth is TL-nesting over quantifier-free α/β, never arity
growth). The fold *removes* a Lean-side deviation and *restores* fidelity to Def 4.1's monadic
E[Σ] atoms. The caveats are two citation-precision slips (claims 4 and 6 below), neither of which
introduces new mathematics — they attribute a mechanism to the wrong (but adjacent) numbered
result. No claim is UNSUPPORTED.

## Context & Scope

The user directive: "Check the Rabinovich and other prior art to confirm that the plan is faithful
to the literature to avoid reinventing novel mathematics." This is an adversarial verification of
the plan's "Source-to-Implementation Mapping (Tier 1, Rabinovich 2014)" table (plan lines 76-85),
six numbered-result claims, plus three named red flags. No Lean code was written or edited; the
deliverable is this report.

Ground-truth anchors from the actual PDF (pages 3-7):
- **Def 3.1 (p.4)**: an ∃∀-formula is `∃x_n…∃x_0 [ (∧ z_k=x_{i_k}) ∧ (x_n>…>x_0) ∧ ∧_j α_j(x_j) ∧
  ∧_j (∀y)^{<x_j}_{>x_{j-1}} β_j(y) ∧ (∀y)_{>x_n}β_{n+1} ∧ (∀y)^{<x_0}β_0 ]`, with **α_j, β_j
  quantifier-free with ONE variable**, and `m+1` free variables `z_0…z_m`, `n+1` existential
  witnesses. Witnesses meet the free variables (env) only through the ordering/equality conjuncts.
- **Lemma 3.2 (p.4)**: (1) conj of ∃∀ ≡ disj of ∃∀; **(2) every ∃∀ ≡ conjunction of ∃∀ with at most
  two free variables**; (3) `∃xφ` of an ∃∀ is an ∃∀.
- **Lemma 3.4 (p.5)**: the ∨∃∀ set is closed under disjunction, conjunction, and **existential
  quantification** (proof: Lemma 3.2(1),(3) + distributivity of ∃ over ∨).
- **Prop 3.5 (p.5)**: every ∨∃∀-formula **with ONE free variable** ≡ a TL(Until,Since) formula; the
  proof folds the ∃ witnesses into nested `A_k ∧ (B_{k+1} Until (A_{k+1} ∧ …))` / dual `Since`.
- **Def 4.1 (p.5)**: `E[Σ]` = `Σ ∪ {A | A is a TL(Until,Since)-formula over Σ}`, a set of **unary
  (monadic) predicate names**; each `A` interpreted as `{a ∈ M | M,a ⊨ A}`. The p.6 note: TL over
  E[Σ] ≡ TL over Σ ≡ atomic in the expansion (the iterated-fold license).
- **Prop 4.3 (p.6)**: every first-order formula ≡ a disjunction of ∃∀-formulas over Dedekind
  complete chains; structural induction (atomic / disjunction / negation via Prop 4.2 + Lemma 3.2(2)
  / **∃-quantifier via Lemma 3.4**).

## Findings

### Six-row verification table

| # | Rabinovich result (plan claim) | Claimed page | Actually found? (where) | What it actually says | Verdict |
|---|--------------------------------|--------------|-------------------------|------------------------|---------|
| 1 | Def 4.1 (E[Σ] monadic-atom fold) | p.5 | **YES — Def 4.1, p.5 (verbatim)** | `E[Σ] = Σ ∪ {A | A a TL-formula over Σ}`, a set of **unary** predicate names, each interpreted as `{a | M,a⊨A}`. The p.6 note licenses iterated folds. | **FAITHFUL** |
| 2 | Lemma 3.2(2) (≤2 free vars, type-level cap) | p.4 | **YES — Lemma 3.2(2), p.4** | "Every ∃∀-formula is equivalent to a conjunction of ∃∀-formulas with **at most two free variables**." | **FAITHFUL** |
| 3 | Def 3.1 (∃∀ ordering conjuncts; witness meets env only via order) | p.4 | **YES — Def 3.1, p.4** | Normal form with ordering constraints; **α_j, β_j quantifier-free with ONE variable**. No joint multi-point atom exists. | **FAITHFUL** |
| 4 | Prop 3.5 (∃x_i ⇒ Until/Since bracket at FIXED endpoints z_0,z_1) | p.5 | **YES — Prop 3.5, p.5** | Every ∨∃∀ with **ONE free variable** ≡ TL; ∃ witnesses fold into nested Until/Since anchored at the single free var `z_k`. | **PARTIAL** |
| 5 | Lemma 3.4 (∃-closure absorbs the zone witness as a bracket witness) | p.5 | **YES — Lemma 3.4, p.5** | ∨∃∀ closed under **existential quantification** (via Lemma 3.2(1),(3)); Lemma 3.2(2) re-caps free vars ≤2. | **FAITHFUL** |
| 6 | Prop 4.3 (innermost fold / iteration reading of the reduced residual) | p.6 | **YES — Prop 4.3, p.6** | Every FO formula ≡ disjunction of ∃∀ (structural induction); ∃-case via Lemma 3.4, negation via Prop 4.2. | **PARTIAL** |

**Note on page numbers**: every cited page is correct. This is itself a strong finding — a plan
inventing math would typically show page/numbering drift. There is none.

### Per-claim detail

- **Claim 1 (Def 4.1) — FAITHFUL.** Def 4.1 is real, on p.5, and reads exactly as the 310 report
  quotes it. Rabinovich's E[Σ] atoms *are* monadic (unary predicate names) by construction, so
  "monadic-atom fold" is a faithful name. The one engineering substitution: the Lean atom is
  `NormalForm sig k 1` (a depth-k **arity-1** normal form) rather than a literal TL formula. The 310
  report confronts this explicitly (its decision D5, and the note that the atom's TL-realizability is
  supplied separately by `nf_succ_char_formula(_correct)`). That substitution preserves the essential
  property Def 4.1 requires — the atom is a *unary* predicate over a single point — so the fidelity
  holds; it is a representation choice, documented, not an invention.

- **Claim 2 (Lemma 3.2(2)) — FAITHFUL.** The ≤2-free-variable bound is not incidental to Rabinovich;
  it is the pillar of the entire negation argument (Prop 4.2 is *stated* for ≤2 free variables, and
  Prop 4.3's negation case invokes Lemma 3.2(2) to get there — verified p.6). Encoding it as a
  standing invariant of the carrier type (`EAtomDom`, endpoints `{x,t}`) is an implementation
  strategy, but it faithfully mirrors the fact that after normalization every object the proof
  handles has exactly the two endpoints `z_0,z_1`. The phrase "type-level cap" is a Lean encoding
  gloss, not Rabinovich's wording, but it does not overreach the lemma's content.

- **Claim 3 (Def 3.1) — FAITHFUL, and this is the single strongest piece of evidence against the
  "novel math" worry.** Def 3.1's α_j and β_j are **one-variable** quantifier-free formulas; the only
  coupling between an existential witness `x_i` and a free variable/endpoint is through the ordering
  and equality conjuncts. There is **no joint atomic predicate over multiple points** anywhere in the
  normal form. Therefore the claim that "a witness meets the env only via order" is a direct reading
  of Def 3.1, and the corollary — that the Lean "arity-4 joint object" `[x_1,w,x,t]` has **no
  Rabinovich counterpart** — is correct. The fold's dissolution of that object is fidelity-restoring.

- **Claim 4 (Prop 3.5) — PARTIAL (citation-precision, not novel math).** Prop 3.5 as printed is about
  a formula with **ONE** free variable (`z_0 = z_k`), producing nested Until/Since anchored at that
  single free var. The plan's gloss "bracket at FIXED endpoints z_0,z_1" (two endpoints) conflates
  Prop 3.5's one-free-variable translation with the **Section 5 / Prop 4.2 two-endpoint bracket**
  `[α_0,…,α_n](z_0,z_1)` (p.7) plus Lemma 3.2(2). The *mechanism* the plan needs — ∃ witnesses fold
  into Until/Since brackets and never become free anchors — is genuinely Prop 3.5. The "two fixed
  endpoints" framing belongs to Lemma 3.2(2) + §5. No new mathematics; the citation should read
  "Prop 3.5 (one-free-var translation) + Lemma 3.2(2) (≤2 endpoints) + §5 bracket notation."

- **Claim 5 (Lemma 3.4) — FAITHFUL, and it underwrites the plan's most load-bearing move (R1).**
  Lemma 3.4 states closure of ∨∃∀ under existential quantification; its proof routes through Lemma
  3.2(3) (`∃xφ` is again ∃∀ — the new witness enters the existential prefix) and Lemma 3.2(2) (which
  re-caps the free variables at ≤2). So "add an existential witness, stay in ∨∃∀, keep ≤2 free
  variables" is precisely Lemma 3.4 + Lemma 3.2. The plan's paraphrase "∃-closure absorbs the zone
  witness as a bracket witness" is a faithful operational reading: the absorbed witness joins the
  existential prefix (a *bracket* witness), not the free-variable set (an *anchor*). The math is
  licensed.

- **Claim 6 (Prop 4.3) — PARTIAL (attribution, not novel math).** Prop 4.3 is real (p.6) and is the
  master structural-induction theorem reducing any FO formula to ∨∃∀. But the specific "innermost
  fold / iteration reading" the plan attaches to `nf_quant_layer_fold_k1_gate` is more precisely the
  **Def 4.1 p.6 note** (TL over E[Σ] ≡ TL over Σ, iterated inside-out) than Prop 4.3 itself. Prop
  4.3's genuine role is to license *treating the residual as a ∨∃∀ object over E[Σ] atoms* (it works
  in the E[Σ] expansion and its ∃-case is Lemma 3.4). So the citation is grounded but imprecise:
  the "iteration" is Def 4.1(p.6); the "residual is ∨∃∀" is Prop 4.3. Note the codebase historically
  did **not** implement Prop 4.3 as literal structural induction (305 report 14 line 49: "Prop 4.3
  … NOT IMPLEMENTED via Rabinovich — Replaced by NF-depth induction"); the fold restores the local
  ∨∃∀/E[Σ] reading rather than transcribing Prop 4.3's induction. No new mathematics is introduced;
  the label should be split between Prop 4.3 and the Def 4.1 p.6 note.

### Red-Flag Adjudications

- **Red Flag A — "Is the fold Rabinovich's Def 4.1 mechanism, or an invention borrowing the name?"**
  **Adjudication: it is Def 4.1's mechanism; the invention was the thing it removes.** Rabinovich's
  normal form is monadic by construction (Def 3.1 α/β one-variable; Def 4.1 E[Σ] unary predicates).
  The arity-4 object `[x_1,w,x,t]` arises only from the Lean `nf_eval_nf` encoding, which grows env
  arity `n→n+1` at each depth descent — a growth that, per the 310 report's decision D1 and the 305
  faithfulness audit (report 14: "The arity tower … is a direct consequence of replacing Rabinovich's
  structural formula induction … Rabinovich avoids it entirely through Lemma 3.2(2)"), has **no
  counterpart in the paper**. The fold's "monadic reduction of a multi-variable quantifier layer" is
  therefore a *return* to Rabinovich's actual normal form, not a bespoke re-encoding. Verdict:
  faithful.

- **Red Flag B — "Fixed-endpoint bracket, witness-count grows under ∃-closure but anchor-count stays
  ≤2 — real Rabinovich distinction or convenient invention?"** **Adjudication: a real Rabinovich
  distinction, and it is the most important confirmation.** In Def 3.1 the counts are *structurally
  separate*: `n+1` existential witnesses `x_0…x_n` (unbounded `n`) versus `m+1` free variables
  `z_0…z_m` capped at ≤2 by Lemma 3.2(2). Prop 3.5 folds the witnesses into Until/Since nesting;
  Lemma 3.4/3.2(3) add witnesses under ∃ while Lemma 3.2(2) holds the free-var count at ≤2. So
  "witness count may grow, anchor count stays ≤2" is verbatim the Def-3.1/Lemma-3.2 arithmetic. 303
  report 19 reads the F_i chain the same way ("the Until modality in F_{i-1} produces the witness
  x_i"), and 305 report 14 line 114 fixes `{z_0,z_1} = {x,t}`. Not a convenient invention. Verdict:
  faithful — this is the crux and it is grounded.

- **Red Flag C — "R1 mitigation (absorb a SECOND interior witness inside a single BracketFormula 1
  via bracketBuildLeft/Right + existsBounded_right) — licensed by Lemma 3.4, or exceeding the
  literature?"** **Adjudication: the mathematics is licensed by Lemma 3.4; the residual risk is Lean
  representability, not fidelity, and the plan handles it correctly.** Rabinovich freely permits
  `n+1` witnesses in one ∃∀ formula, so a second interior witness is mathematically unremarkable
  (Lemma 3.4 ∃-closure + Lemma 3.2(3)). The only open question is whether the *fixed-shape Lean type*
  `VecEA2 1` (with its specific interval slots) can host that witness — a representability question,
  not a mathematical one. The plan flags R1 Medium and mandates escalation-before-shape-change
  ("do not silently switch to `VVecEA2`/`VecEA2 2`"). That is the right posture: it does not quietly
  exceed the literature, and it does not assume the Lean shape trivially absorbs the math. Verdict:
  faithful as to math; representational risk appropriately fenced.

### Prior-Art Consistency

311's reading of Rabinovich is **consistent with 303, 305, 309, and 310** — indeed it inherits a
repeatedly-established finding rather than proposing anything new:

- **310** (`reports/01`, §1.5, D1, D5): reads Def 4.1 identically (E[Σ] = unary predicates; atom =
  `NormalForm sig k 1`; arity growth is a Lean artifact absent from the paper). Same page citations.
  311 consumes 310's assets by name; no divergence.
- **309** (`plans/03`, lines 41-94, 127-153): G6 fixed-endpoint bracket, `w` a bracket witness, ≤2
  anchor cap; maps Def 3.1 p.4, Lemma 3.2(2) p.4, Prop 3.5 p.5 — **identical page numbers to 311**.
  The Corrected Anchor-Cap and G2/G4 (no third free anchor) are the same constraints 311 restates.
- **305** (`reports/14` faithfulness-audit, `35` team-research): explicitly names the "arity tower"
  as a **deviation** from Rabinovich caused by replacing Prop 4.3 structural induction with NF-depth
  induction, and states Rabinovich avoids it "entirely through Lemma 3.2(2)" (line 54) with
  `{z_0,z_1}={x,t}` (line 114). This is exactly the diagnosis 310/311 act on. One nuance worth
  surfacing: 305 line 49 records that Prop 4.3 was **not** implemented as literal Rabinovich
  structural induction — consistent with my PARTIAL verdict on claim 6.
- **303** (`reports/19`): Lemma 3.2(2) ≤2 free vars (line 59), Prop 4.2/4.3 structural induction,
  and the F_i chain `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` with "the Until modality … produces the
  witness x_i" (line 319) — the same witness-folding reading 311 uses.

No inconsistency detected. 311 does not diverge from the established repo reading; it applies it.

## Decisions

- The plan is cleared as literature-faithful for implementation. No claim requires re-grounding to
  avoid novel mathematics.
- The two PARTIAL rows (claims 4 and 6) are citation-precision issues to be corrected in
  doc-comments, not blockers.

## Recommendations

Priority order (all are refinements; none blocks implementation):

1. **(Low, doc-comment) Fix the claim-4 citation.** In `bracketEndChar_k1`'s doc-comment and the
   plan's mapping table, attribute the two-fixed-endpoint bracket to **Lemma 3.2(2) (≤2 free vars,
   p.4) + §5 bracket notation (p.7)**, and reserve **Prop 3.5 (p.5)** for the one-free-variable
   ∃-witness→Until/Since folding *mechanism*. Prevents a future auditor reading Prop 3.5 (a
   one-free-var result) as if it directly delivered a two-endpoint bracket.

2. **(Low, doc-comment) Split the claim-6 citation.** For `nf_quant_layer_fold_k1_gate`, cite the
   **Def 4.1 p.6 note** (TL over E[Σ] ≡ TL over Σ, iterated) for the "innermost fold / iteration"
   reading, and **Prop 4.3 (p.6)** only for "the residual is ∨∃∀ over E[Σ] atoms." Note in the
   comment that the codebase realizes Prop 4.3's content locally via the fold, not via literal
   structural induction (per 305 report 14).

3. **(Medium, keep as-is) Preserve the R1 escalation fence.** The plan's instruction to escalate
   before switching the carrier codomain is correct and literature-consistent — the ≤2-anchor cap is
   the Rabinovich invariant (Lemma 3.2(2)); growing witness count is fine, growing anchor count is
   not. Do not relax this during implementation. If a single `VecEA2 1` genuinely cannot host the
   second interior witness, that is a Lean-representability escalation, not a license to add a third
   anchor.

4. **(Informational) Strongest evidence to cite in the implementation summary.** Def 3.1's
   one-variable α_j/β_j (no joint multi-point atom) is the definitive rebuttal to the "novel math"
   worry: the arity-4 residual is provably a Lean artifact, and the fold restores fidelity. Lead with
   this in the R2 = GO doc-comment.

There is **no UNSUPPORTED claim**, so no "safe literature-faithful alternative" needs to be
specified — the plan is already the faithful path.

## Risks & Mitigations

| Risk | Assessment |
|------|------------|
| Plan reinvents novel mathematics | **Not observed.** All six results exist; the fold restores fidelity rather than inventing. |
| Citation imprecision misleads a future auditor | Low; addressed by recommendations 1-2 (doc-comment fixes). |
| R1 representability (single `VecEA2 1` cannot host 2nd witness) | Real but Lean-side, not fidelity-side; plan fences it with mandatory escalation. |

## Appendix

- PDF pages read directly: 3 (semantics, Thm 2.1), 4 (Def 3.1, Lemma 3.2, Def 3.3), 5 (Lemma 3.4,
  Prop 3.5, Def 4.1), 6 (p.6 fold note, Prop 4.2, Prop 4.3, Thm 4.4), 7 (§5 setup, Lemma 5.1).
- Def 4.1 verbatim (p.5): "We denote by E[Σ] the set of unary predicate names Σ ∪ {A | A is a
  TL(Until,Since)-formula over Σ}. The canonical … expansion of M … where each predicate name
  A ∈ E[Σ] is interpreted as {a ∈ M | M,a ⊨ A}."
- Cross-referenced repo artifacts: 310/01 (D1,D5,§1.5), 309/03 (G1-G6, Corrected Anchor-Cap),
  305/14 (arity-tower deviation), 305/35, 303/19 (F_i chain).
