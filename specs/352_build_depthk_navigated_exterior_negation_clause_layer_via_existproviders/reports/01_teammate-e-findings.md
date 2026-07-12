# Task 352 — Teammate E Findings (Literature faithfulness: Rabinovich 2014)

**Role**: Ground-truth fidelity read of Rabinovich (2014), "A Proof of Kamp's Theorem" (LMCS),
against the depth-k navigated exterior negation clause layer task 352 must build.
**Source**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`
(chunks 0009, 0013–0016, 0021–0023) + PDF pages 8–11 read directly (the display equations —
the `F_i` definitions in Cor 5.4 and the `A_i`/`B_i` definitions in Lemma 5.1 Case 3 — were
LOST in the markdown conversion; every quote below that cites "PDF p.N" was read from the PDF).
**Mode**: read-only; only write is this file. Cross-checked against PriorInterface.lean,
KampPrior.lean, ExteriorNegation.lean:1097–1490, ExteriorBracketK.lean, report 349/10, and
sibling findings A–D (headers + C's §"Does resolution (a) actually escape it" in full).

---

## Key Findings

1. **Lemma 7.8 VERDICT: resolution (a) holds; it does NOT collapse into (b).** The paper's
   negation closure at a rung consumes, across the rung boundary, ONLY formulas of the
   previous round's canonical expansion (= `existF`-class TL formulas). No rung-(k+1) bracket
   ever appears on the consumption side of its own negation. Teammate C's Medium-High claim
   is CONFIRMED and upgraded to High, **with one sharpening C did not state**: Lemma 5.1/7.8
   contains a genuine internal recursion — an induction on **bracket length n within the same
   rung** (the `A_i`/`B_i` decomposition, PDF p.10–11) — whose Lean analog is list recursion
   (already the landed `kvE2_futChain` pattern), not a depth recursion. "(a) vs (b)" is a
   depth-axis question and (a) wins; the length-axis recursion is real but intra-layer.

2. **The cross-rung interface is exactly two things**: (i) previous-round TL formulas used as
   bracket entries `α_i, β_i` (Def 4.1/7.7 canonical expansion atoms), and (ii) TL-combinator
   closure over them — the `Until`-folds `F_i` (Cor 5.4, PDF p.9) and the `K⁺`/`K⁻`
   applications (Lemma 5.3 case 2, Lemma 5.1 cases 1/3). Both are formula-level. The
   `ExistProviders` bundle (PriorInterface.lean:38–46) plus free `Formula` syntax supplies
   both; no new bundle field is needed (over discrete orders even `K⁺` is not needed — §risks).

3. **G6 ("no marginal bits as clause content") is paper-justified.** In Lemma 5.1's proof the
   content pin is always the full entry tuple (the `A_i`/`B_i` brackets and `F_i` folds carry
   every `α_j`, `β_j` of the bracket being negated); the only marginal-looking objects
   (`INF`, `K⁺`, the `r_0` locator) serve zone NAVIGATION, never content. The paper has no
   analog of keying a negation clause on an arity-1 projection.

4. **The frozen k=2 layer's `Formula.neg` shortcut is faithful-in-effect, and the reason is in
   the paper.** Rabinovich must rebuild the negation as a POSITIVE ∨∃∀ formula only because
   his target class (∨∃∀ FOMLO formulas) "is not closed under negation" (chunk 0022 line 3);
   TL formulas ARE negation-closed, and Def 7.7 admits any TL formula (including negated
   ones) as an expansion atom — "if A is a TL formula over E[Σ] predicates, then it is
   equivalent to a TL formula over Σ, and hence to an atomic formula in the canonical
   expansions" (chunk 0011:15). So `kvE2_extNegFut := (kvE2_futPos σ).neg`
   (ExteriorNegation.lean:1136–1140) discharges the paper's FORMULA-existence obligation
   trivially, and the entire mathematical content of Lemma 5.1/7.8 migrates into the
   `_sound`/`_complete` proofs — which is exactly where the k=2 layer put it.

---

## Def 7.5 & 7.7 faithful reading (quotes)

**Def 7.5** (chunk 0021:17, verbatim):

> "Definition 7.5 ((z0, z1)-∃∀ formula). Let z0 and z1 be two variables. A formula z0 > z1,
> z0 = z1 or of the form [α0, β1 . . . , βn−1, αn−1, βn, αn](z0, z1) is called a (z0, z1)-∃∀
> formula. A formula is (z0, z1)-∨∃∀ formula if it is equivalent to a disjunction of
> (z0, z1)-∃∀ formulas."

The entries `α_i, β_i` are, per Def 3.1 (chunk 0009:5–7), "quantifier free formulas with one
variable over Σ" — and at each round of the master recursion Σ is the CANONICAL EXPANSION
signature, so "quantifier free" means "Boolean combinations of previous-round TL predicates".
**What rung (k+1) consumes from rung k is therefore precisely: rung-k TL formulas as atoms.**
There is no clause anywhere in Def 7.5/3.1 letting a bracket appear as an entry of a bracket.

**Def 7.7** (chunk 0022:5, verbatim):

> "Definition 7.7 (The canonical TL(Until, K⁻) and TL(Since, K⁺) expansions). Let M be a Σ
> chain. We denote by E[Σ, TL(Until, K⁻)] the set of unary predicate names Σ ∪ {A | A is an
> TL(Until, K⁻) formula over Σ}. The canonical TL(Until, K⁻)-expansion of M is an expansion
> of M to an E[Σ, TL(Until, K⁻)]-chain, where each predicate's name A ... is interpreted as
> {a ∈ M | M, a |= A}."

Note the mission's phrase "Def 7.7 zones" conflates two paper objects: Def 7.7 is the
canonical expansion (above); the ZONE split is **Definition 7.13** (interior segments
`(z_i, z_{i+1})` conjoined with one unbounded exterior segment `(z_k, ∞)`; chunk 0023:25) plus
**Lemma 7.10** ("[α0, β1 ..., αn, βn+1](z0, ∞) over canonical TL(Until, K⁻)-expansions is
equivalent to a TL(Until, K⁻) formula. Proof. By a straightforward formalization as in the
proof of Proposition 3.5." — chunk 0023:15–17). The exterior zone's positive form is a plain
TL formula; only interior two-endpoint brackets need the ∨∃∀ apparatus.

**The depth recursion itself** is not in Section 7's definitions; it is the structural
induction of Prop 4.3 (chunk 0012:15): FOMLO negation is handled by "Proposition 4.2
(Closure under negation): The negation of ∃∀-formulas with at most two free variables is
equivalent over Dedekind complete chains to a disjunction of ∃∀-formulas" — over the
canonical expansion, i.e. after promoting the previous round's output to atoms. Section 7
re-runs this with Lemma 7.8 in place of Prop 4.2 and Lemma 7.14's induction ("by Lemmas 7.6,
7.8(2), 7.10 and a straightforward structural induction").

---

## Lemma 7.8 negation-closure adjudication — does (a) hold or collapse to (b)?

**(a) holds. The faithful construction closes negation using only previous-round formulas
(existF-class converters) plus an INTRA-rung induction on bracket length. It never invokes
the rung-(k+1) bracket recursively on the depth axis.**

**Lemma 7.8 statement + proof** (chunk 0022:9–15, verbatim):

> "Lemma 7.8. (1) ¬[α0, β1 ..., βn−1, αn−1, βn, αn](z0, z1) is equivalent over the canonical
> TL(Since, K⁺)-expansions of Dedekind complete chains to a (z0, z1)-∨∃∀-formula. (2) Dually
> ... over the canonical TL(Until, K⁻)-expansions ...
> Proof. Actually, our proof of Lemma 5.1, as it is, works for the canonical TL(Since, K⁺)-
> expansions of Dedekind complete chains, when '∃∀ formulas' are replaced by '(z0, z1)-∃∀
> formulas.'"

And the follow-up accounting of exactly what that proof uses (chunk 0023:3–7, verbatim):

> "Indeed, Lemma 5.3 uses only modality K⁺. ... (because K⁺ is equivalent to a TL(Until)
> formula). In the proof of Corollary 5.4(1) we used Lemma 5.3 and Until modality. ... In
> proof of Lemma 5.1 we use standard logical equivalences and Corollary 5.4(2)."

So the ENTIRE resource inventory of the negation closure is: **Lemma 5.3 + Until/Since
modality + K⁺ + standard equivalences**. Walking the actual proofs (PDF p.8–11):

1. **Cor 5.4 (PDF p.9)** defines `F_n := α_n`, `F_{i−1} := α_{i−1} ∧ (β_i Until F_i)` for
   i = 1..n, observes "there is z ∈ (z0, z1) such that [α0,...,αn](z0, z) iff F0(z0) and
   there is an increasing sequence x1 < ··· < xn in (z0, z1) such that F_i(x_i)", and
   concludes "¬F0(z0) ∨ On(F1, ..., Fn, z0, z1)" is the ∨∃∀ equivalent of the negation. The
   `F_i` are TL formulas over the rung's entry alphabet — **the literal existF converter
   shape** (PriorInterface.lean:35–36 already cites this: "Per-round provider threading per
   Cor 5.4 (the F_i are TL formulas)").

2. **Lemma 5.3 (PDF p.8)** builds `O_{n+1}` from `O_n` by recursion **on n, the number of
   predicates** — cases: "(1) (∀y)¬P1(y); (2) K⁺(P1)(z0) ∧ On(P2,...,Pn, z0, z1);
   (3) (∃r0)(INF(z0, r0, z1, P1) ∧ On(P2,...,Pn, r0, z1))" with
   `INF(z0,r0,z1,P1) := z0 < r0 < z1 ∧ (∀y)_{>z0}^{<r0} ¬P1(y) ∧ (P1(r0) ∨ K⁺(P1)(r0))`
   (eq. 5.2), justified by "K⁺(P1)(z0) is an atomic (and hence a ∨∃∀) formula in the
   canonical expansion". `r_0 = inf{...}` "exists by Dedekind completeness".

3. **Lemma 5.1 Case 3 (PDF p.10–11)** — the inner induction the mission's crux question is
   really about. It defines, for the bracket of length n+1 being negated:
   `A_i^−(z0,z) := [α0, β1, ..., β_i, α_i](z0, z)`,
   `A_i^+(z,z1) := [α_i, β_{i+1}, ..., β_{n+1}, α_{n+1}](z, z1)`, `A_i := A_i^− ∧ A_i^+`
   (i = 1..n), and `B_i^−(z0,z) := [α0, β1, ..., α_{i−1}, β_i, β_i](z0, z)`,
   `B_i^+(z,z1) := [β_i, β_i, α_i, β_{i+1} α_{i+1}, ..., β_{n+1}, α_{n+1}](z, z1)`,
   `B_i := B_i^− ∧ B_i^+` (i = 1..n+1), proves
   `[α0,...,α_{n+1}](z0,z1) ⟺ (∃z)_{>z0}^{<z1} (⋁ A_i ∨ ⋁ B_i)` (and the ∀-form), and then
   discharges "**By the inductive assumption (a): ¬A_i is equivalent to a ∨∃∀ formula for
   i = 1,...,n. (b): ¬B_i ... for i = 2,...,n. (c): ¬B_1^− and ¬B_{n+1}^+ ... by the
   induction basis.**" — i.e. negations of STRICTLY SHORTER brackets over the SAME entry
   alphabet, via Lemma 5.1's own length induction.

**Adjudication.** The recursion in the negation closure is indexed by bracket length n, with
the entry alphabet (the rung-k formulas) held fixed throughout. At no point does a
depth-(k+1) formula appear inside a bracket being negated, and at no point is the rung-(k+1)
"characteristic/carrier" construction invoked to close its own negation. Therefore:

- **Resolution (a) is the faithful reading**: `ExistProviders.existF` at depth k (arbitrary
  arity, per the bundle's `(n : Nat) → NormalForm sig k (n+1) → Formula`) is the complete
  cross-rung input. Teammate C's "converters suffice ... the recursion in 7.14 threads
  formulas, not brackets" is confirmed word-for-word against PDF p.8–11.
- **No collapse to (b)**: mutual recursion between the clause layer and the rung-(k+1)
  bracket is not in the paper. What IS in the paper — and what a naive "single converter
  application" reading of (a) would miss — is the **intra-rung length induction** (`O_n`,
  `A_i`/`B_i`). The Lean layer must implement this as list/length recursion over chain
  formulas built from `existF` images. The frozen k=2 layer already does exactly this
  (`kvE2_futChain` list recursion :1108–1118; `kvE2_futMinPick` list induction :1146;
  `kvE2_futChainBuild`/`Destruct` :1180/:1435), so generalizing to symbolic k changes the
  element type of the lists (depth-k profiles via `P.existF`), not the recursion shape.

---

## Paper→Lean construct map (5-column)

| Rabinovich construct | Paper location | Intended Lean form (352) | Already-landed analog | Notes |
|---|---|---|---|---|
| ∃∀-formula / bracket `[α0,β1,...,αn](z0,z1)`; entries quantifier-free over Σ | Def 3.1 (PDF p.4), Notation 5.2 (PDF p.8), Def 7.5 (chunk 0021:17) | depth-k positive local-existence form per exterior sub `σ : NormalForm sig (k+1) 4`, entries = `P.existF`-images of depth-k profiles | `kvE2_futPos` (ExteriorNegation.lean:1124–1132); determinacy core ExteriorBracketK.lean | Entries are rung-k FORMULAS, never rung-k brackets (Def 3.1) — G1-consistent; FORBIDDEN `nf_char3_deeper_split` not implicated |
| Canonical expansion E[Σ,TL]: every TL formula is an atom; idempotent | Def 4.1 (chunk 0011:5), Def 7.7 (chunk 0022:5), idempotence chunk 0011:15 | `P : ExistProviders sig atomMap k` — `existF` + UZ/SZ-conditional `correct` is the Lean rendering of "expansion atom with its defining ⊨-equivalence" | PriorInterface.lean:38–46; consumer pattern KampPrior.lean:216–223/:351 | Boolean/Until closure of atoms comes free from `Formula`; negated existF-images are legitimate "atoms" (idempotence quote) |
| `F_i` Until-fold: `F_n := α_n`, `F_{i−1} := α_{i−1} ∧ (β_i Until F_i)` | Cor 5.4 proof (PDF p.9) | depth-k `kvE_futChain`: D-guarded Until chain whose profile/guard formulas are `P.existF`-images | `kvE2_futChain` (ExteriorNegation.lean:1108–1118, docstring cites "Lemma 5.3 / Cor 5.4 O_n device") | The exact converter shape PriorInterface.lean:35–36 cites; generalization = element type swap `NormalForm sig 0 1 → (depth-k profile)` |
| `O_n` obstruction formula, recursion on n; cases ∀¬P1 / K⁺ / INF+recurse | Lemma 5.3 (PDF p.8, eq. 5.2) | list recursion inside the chain + admissibility-gated permutations disjunction | `kvE2_futPos` permutations disjunction (:1128–1131) | Over discrete orders `K⁺ ≡ False` (paper p.3: "K⁺(True) ... equivalent to False in the chains over (N, <)"), so O_n's case 2 vanishes and case 3's inf becomes a minimum — the landed min-pick convention is the faithful discrete specialization |
| `r_0 = inf{...}` via Dedekind completeness; `INF` formula (5.2)/(5.3) | Lemma 5.3 case 2, Lemma 5.1 case 3 (PDF p.8/p.10) | minimal-witness selection over the finite chain family | `kvE2_futMinPick` (ExteriorNegation.lean:1146–1149) | Finitary: min over finitely many list elements' witnesses — needs only linearity, no completeness axiom on the carrier; sound specialization, flag if a dense-order variant is ever targeted |
| Lemma 5.1 = Lemma 7.8 negation closure: Cases 1–3, `A_i`/`B_i` length induction | PDF p.9–11; Lemma 7.8 chunk 0022:9–15; resource inventory chunk 0023:3–7 | `kvE_extNegFut/Past := (pos σ).neg` + `_sound`/`_complete` pair at depth k; proofs by list-length induction over chains of existF-profiles | `kvE2_extNegFut` :1136, `_sound` :1243, `_complete` :1484; `ChainBuild` :1180 / `ChainDestruct` :1435 | `Formula.neg` discharges the paper's positive-form obligation trivially (TL is negation-closed; the paper needs positivity only because ∨∃∀-FOMLO is not — chunk 0022:3). ALL of Lemma 5.1's content lives in `_sound`/`_complete` |
| Cor 5.4(1)/(2): refute ∃z with one anchored endpoint; `¬F0(z0) ∨ O_n(F1..Fn)` split | PDF p.9 | per-side depth-k exterior bracket `_sound`/`_complete`: realizer refuted either at the anchor (fold fails: ¬F0) or by interval obstruction (O_n) | `kvE2_extBracketPast/Fut_sound/_complete` (ExteriorBracket.lean:432/456ff per report 10 C6) | This IS the `_sound`/`_complete` direction split the mission asks about: sound = no chain ⟹ no strictly-exterior realizer (ChainDestruct ≅ Cor 5.4's induction with the y1/y2 case split); complete = realizer ⟹ chain (Build ≅ the "trivial" ⇒) |
| Lemma 7.10: `[...](z0, ∞)` exterior-zone bracket is plainly TL | chunk 0023:13–17 | exterior ray/end forms as plain `Formula` (Prop 3.5-style formalization, no ∨∃∀ re-entry) | `kvE2_futEnd`/`kvE2_futRayForm` (:1097–1104, :1130) | The unbounded exterior zone is the EASY zone; positivity machinery only needed for two-endpoint interior brackets |
| Lemma 7.6 adjacency: `(∃z1)(ϕ1 ∧ ϕ2)` composes `(z0,z1)`- and `(z1,z2)`-brackets | chunk 0021:23 | conjunction of Past-bracket (anchor x) and Fut-bracket (anchor t) at the fixed anchor pair | `bracketEndChar_kvE2Ext_holds_iff` (ExteriorBracket.lean:674 per report 10 C8) | The double-anchor repair; unchanged by 352 |
| Prop 3.5: one-free-variable ∨∃∀ → TL formula | chunk 0010:11 (PDF p.5) | the master `charF` recursion supplying providers | `nf_succ_char_formula` KampPrior.lean:67/:81, `nf_nvar_exist_all_depths` :212 | Frozen, byte-identical (guard); rule-N1 citation split already recorded in PriorInterface docstring :27–30 |

---

## Fidelity risks & G6 assessment

**G6 ("no marginal bits as clause content") — ADOPT; paper-justified.** Every content-bearing
formula in Lemma 5.1's proof carries the FULL entry tuple of the bracket being negated: the
`F_i` folds consume every `α_j, β_j` from position i outward; the `A_i^±`/`B_i^±` brackets
are literally prefix/suffix sub-brackets of the full tuple. The marginal-looking devices —
`K⁺(¬β1)(z0)`, `INF^{¬β1}`, the `r_0` locator — appear only in `Cond_i` (case selectors) and
witness-location subformulas, i.e. **navigation**, and even these are keyed to a specific
entry (`β1`), not to a projection that identifies distinct subs. There is no paper analog of
pinning exclusion content on an arity-1 shadow `χ`; teammate C's "zone-navigation label vs
content pin" discipline is exactly the paper's own division of labor. G6 does NOT collapse
(a) into (b): the extra thing the paper demands beyond single converter applications is the
intra-rung LENGTH recursion (already the landed list pattern), not a depth recursion.

Remaining fidelity risks, ranked:

1. **(Low, deliberate) Discrete-order specialization.** The paper's Dedekind-completeness /
   `K⁺` machinery is load-bearing only over dense/continuous chains. The landed k=2 proofs
   replace `inf` with finite min-pick and never introduce a `K⁺`-style provider field. This
   is sound for the project's UZ/SZ Prior structures and should be recorded as a deliberate
   specialization (the paper's theorem covers a superclass). If the exterior-zone chains at
   depth k ever needed the infimum of an INFINITE definable set (not a finite family), the
   provider bundle would need a `K⁺`-analog — nothing in the k=2 skeleton suggests this, but
   it is the one place the generalized `_complete` proof could surprise.
2. **(Low) Permutations disjunction has no verbatim paper analog.** The paper's bracket fixes
   the entry order syntactically; `kvE2_futPos` disjoins over `permutations` of the
   gap-profile list because the sub's zone order is not syntactically pinned. Frozen and
   green at k=2 — keep the pattern, but a planner should cite it as an encoding choice
   (bounded: finite disjunction), not as Def 7.5 itself.
3. **(Low) `.neg` vs positive-form reconstruction.** Do NOT spend effort building a paper-
   style positive ∨∃∀ negation formula at depth k: it is unnecessary (TL negation-closure +
   Def 7.7 idempotence, quotes above) and would balloon the layer. The obligation that
   actually transfers from the paper is the SEMANTIC case analysis in `_sound`/`_complete`.
   Conversely, if any future consumer demands the negation clause re-enter a positive bracket
   class, that demand is satisfiable (Lemma 5.1 shows how) but is a separate task.
4. **(Guard check) G1–G5, frozen assets.** Everything above is additive: providers (7 frozen)
   and KampPrior.lean stay byte-identical; the layer consumes `P : ExistProviders sig atomMap k`
   exactly as PriorInterface exposes it; FORBIDDEN `nf_char3_deeper_split` is not implicated
   by any construct in the map (the paper route never splits a sub's deeper coordinates —
   G1's full-arity existF reads are the pin). UZ/SZ conditionality must thread through every
   `_sound`/`_complete` statement (the paper's counterpart: all equivalences are "over the
   canonical expansions", i.e. conditional on the expansion's defining property — which IS
   `ExistProviders.correct`).

---

## Confidence

- Lemma 7.8 verdict ((a) holds; length-not-depth recursion): **High** — adjudicated from the
  actual proofs on PDF p.8–11 including the display equations lost in the markdown, with the
  paper's own resource inventory (chunk 0023:3–7) as a cross-check.
- Paper→Lean map rows for landed k=2 objects: **High** (file:line verified this session);
  rows citing ExteriorBracket.lean interior lines ride report 10's verified citations
  (**Medium-High**, not re-opened here).
- Discrete-specialization risk assessment: **Medium** — I verified the k=2 proofs use only
  finite min-pick, but did not exhaustively audit every completeness-flavored step a depth-k
  `_complete` proof will need.
