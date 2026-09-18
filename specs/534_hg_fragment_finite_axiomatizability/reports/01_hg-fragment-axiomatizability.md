# Research Report: Task #534

**Task**: 534 - H/G-fragment finite axiomatizability (TMFrag per frame class)
**Started**: 2026-09-18T19:19:57Z
**Completed**: 2026-09-18T20:05:00Z
**Effort**: ~4-6 implementation phases for the machine-checkable part (see Recommendations)
**Dependencies**: None (builds on the landed `Metalogic/Conservativity/` tree)
**Sources/Inputs**: - Codebase (`Metalogic/Conservativity/*`, `Syntax/MinusLanguage/*`, `Semantics/MinusLanguage/*`), Literature corpus (burgess_1984 PDF §2.5-2.8; venema_2001 §"Axiomatics" Thm 3.3), lean-lsp MCP (local search only; no build per user focus)
**Artifacts**: - specs/534_hg_fragment_finite_axiomatizability/reports/01_hg-fragment-axiomatizability.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The verdict is positive at all four classes, not negative.** Each fragment `TMFrag fc` is
  **finitely** axiomatizable over TM⁻ in the H/G language. The argument uses classical
  completeness theorems for linear tense logic plus three short lemmas stated below:
  | Class | `TMFrag fc` = | Extra schemas Σ_fc |
  |---|---|---|
  | `.Base` | TM⁻ + (Sp) | `{Sp}` = `{□DF φ ∨ □DN ψ}`, which is the (DD) schema |
  | `.Dense` | TM⁻_d | ∅ (TM⁻_d is already complete) |
  | `.ZTime` | TM⁻_z + Z1 | `{Z1}`, with its mirror supplied by TR |
  | `.RTime` | TM⁻_r | ∅ (TM⁻_r is already complete) |
- **The paper's negative footnote is not supportable and should not be un-commented as
  drafted.** The claim that the Past/Future language admits no complete finite axiomatization of
  the fragment is false, assuming the classical results cited below. The reworded footnote should
  say two things. First, TM⁻ by itself is incomplete at `.Base` and `.ZTime`. Second, adding the
  split schema (DD) at `.Base`, or the finite-interval schema Z1 at ℤ, gives a complete system.
- **Why it works.** Because of MF, TR and S5, the box `□` acts as the *universal modality* on a
  task model. As a result, H/G+□ validity over a class reduces to validity of pure H/G formulas
  on the single order D. That validity is exactly what Burgess and Venema axiomatize.
- **Machine-checkable now, with no completeness `sorry`:**
  - soundness, `TM⁻ + Σ_fc ⊆ TMFrag fc`, at all four classes;
  - the (DD) mirror and mixed forms;
  - `CO ⊢ A7` (Burgess's completeness axiom);
  - *conditional* completeness theorems, taking the classical linear-order completeness as a
    hypothesis.
- **Not cheaply machine-checkable:** unconditional completeness. It needs a maximal-consistent-set
  and chronicle/bulldozing layer over `MinusFormula`, which does not exist yet. This is the same
  gap `TMCompletenessReduction.lean` already names.

## Context & Scope

The object is `TMFrag fc φ := ⊢[fc] tr φ` (`Metalogic/Conservativity/Fragment.lean`). It equals
`MinusValidIn fc` at every class (`tmFrag_iff_minusValidIn`). The Lean classes are `.Base`,
`.Dense`, `.ZTime` and `.RTime`. The task text calls the last two "Discrete" and "Dedekind", but
in the Lean tree `.ZTime` is exactly the order ℤ (SuccOrder + PredOrder + Archimedean), and
`.RTime` is dense plus Dedekind-complete, i.e. ℝ. A `TemporalOrder` is a nontrivial totally
ordered abelian group (`Semantics/TemporalOrder.lean:83`).

The user's constraint was respected: no `lake build` or `lean_build` was run. Inspection was
read-only, plus `lean_local_search`.

## Findings

### Codebase Patterns

- `MinusTruthAt` (`Semantics/MinusLanguage/MinusTruth.lean:103`): `□` quantifies over all world
  histories at the same time. Histories are total on `D`.
- `chainSat` / `chainBundle_truth_lemma` / `not_minusValidIn_of_not_chainSat`
  (`Metalogic/Conservativity/ChainBundleTruth.lean:105,137,196`) do two things:
  - They realise any disjoint union of `D`-lines with arbitrary valuations, with **`□` universal
    over all points**, as a task model over `multiFamTaskFrameGen D FamIdx` at any `fc` that the
    frame satisfies.
  - This is exactly the "bundle" semantics the reduction below needs. It is generic in `D`, and
    `ℚ ×ₗ ℤ` already carries the instances (`Semantics/LexCarrier.lean`, used by
    `Z1Countermodel.lean`).
- `duration_dense_or_least_pos` (`Semantics/DurationClassification.lean:342`) is the Hölder
  dichotomy: every temporal order is dense or has a least positive element.
- `df_valid_of_isLeast_pos` and `dn_valid_of_denselyOrdered`
  (`Semantics/MinusLanguage/MinusSchemaValidity.lean:66,119`) give DF and DN validity on each half
  of that dichotomy.
- `minusValid_sp` and `sp_translate` (`SpWitness.lean`) prove the Base soundness of (Sp).
  `z1_translate` (`Backward.lean:202`) proves the ZTime soundness of Z1.
  `spDerivableDense` / `spDerivableRTime` (`DenseObstructionTransfer.lean:122`) show (Sp) is
  already a theorem at the dense classes.
- `tr_reflectTime` (`Syntax/MinusLanguage/Translation.lean:150`) says `tr` commutes with TR. That
  is what makes `TMFrag` closed under TR.
- **No deduction theorem exists on the L⁻ side** (grep: zero hits under `Syntax/MinusLanguage`).
  All L⁻ propositional reasoning in the tree is routed through the TM side
  (`AxiomDischarge.lean`).

### External Resources (literature, verified against the corpus text)

TM⁻'s temporal part consists of TK, T4, TC, TL and TS, with their mirrors via TR. That is
Burgess's L₂ (A0-A2, where A2a is TL's paper form) plus A4a,b (seriality).

- **Burgess 1984, "Basic Tense Logic", §2.5** (PDF p.106). L₂ + A4a,b + A5a (Fp→FFp, the dual of
  DN) "is complete for the class of dense total orders without maximum or minimum … the tense logic
  of the rationals". This is exactly TM⁻_d's temporal part.
- **Burgess 1984 §2.6** (pp.107-108). Adding A6a,b (`p∧Hp→FHp` and its mirror) "is complete for
  the class of total orders in which every element has an immediate successor and an immediate
  predecessor". With TS present, DF is equivalent to A6a, and TR gives A6b.
  - Same page: Burgess [1979] axiomatizes the tense logic of *homogeneous* orders by adding the
    **unboxed** disjunction `(Fp→FFp) ∨ [(q∧Hq→FHq) ∧ (q∧Gq→PGq)]`. This is the one-line
    ancestor of (Sp)/(DD). The box in (Sp) is exactly what the single-D bimodal setting adds, as
    the `SpWitness.lean` docstring already observes.
- **Burgess 1984 §2.7** (pp.109-110). L₂ + A4a,b + A5a + A7a,b is complete for continuous orders,
  and "any formula consistent with this theory is satisfiable … in the reals. Thus [it] is the
  tense logic of real time." Here A7a is `Fp ∧ FG¬p → F(HFp ∧ G¬p)`.
- **Venema 2001, "Temporal Logic", Thm 3.3** (corpus `venema_2001/sec02_validity-and-definability.md`).
  Lin.Z = Lin + P⊤ + F⊤ + A8 is sound and complete for ℤ. Here A8 is
  `G(Gq→q)→(FGq→Gq)` together with its H-mirror, and **this is exactly Z1 plus its TR mirror**.
  - Venema 2001 is a survey. The primary sources are Segerberg 1970 and Goldblatt's *Logics of
    Time and Computation*, neither of which is in the corpus. Treat this as survey-grade.

### The three bridging lemmas (proof sketches; all routine)

**Lemma U (□ is universal; reduction to pure tense logic).**
- TM⁻ proves `□χ → □□χ ∧ G□χ ∧ H□χ`, using S5, then MF, MT, and TR. It also proves
  `¬□χ → G¬□χ ∧ H¬□χ`, using M5 and the same route.
- So every □-subformula has a globally constant truth value. By replacement under a global
  hypothesis, every L⁻ formula is TM⁻-equivalent to a Boolean combination of □-free formulas and
  formulas `□α` with α □-free.
- Suppose `¬φ` is TM⁻_X-consistent. Then some `ψ ∧ □α ∧ ◇β₁ ∧ … ∧ ◇βₖ` is consistent. Hence each
  of `△α ∧ ψ` and `△α ∧ βⱼ` is consistent in the pure tense system L_X, since
  `□α → □△α` and L_X ⊆ TM⁻_X.
- By classical completeness, each of these is satisfied on a copy of D_X. Each such copy satisfies
  α everywhere, because in a linear order `△ = H ∧ id ∧ G` covers the whole line.
- The disjoint union of these copies is a `chainSat` model refuting φ. It is realised as a task
  model by `not_minusValidIn_of_not_chainSat`.
- Consequence: **TM⁻_X is complete for D_X-bundles iff its tense part is complete for D_X.**
  This is Goranko-Passy's universal-modality transfer, in the special case where MF+TR make □
  universal.

**Lemma I (intersection by boxed disjunction).**
- Let A₁ and A₂ be schema sets, each closed under TR up to TM⁻-derivability. Then
  `(TM⁻+A₁) ∩ (TM⁻+A₂) = TM⁻ + {□δ ∨ □ζ : δ ∈ A₁, ζ ∈ A₂}`.
- Proof: by the global deduction theorem `TM⁻+A ⊢ χ ⟺ TM⁻ ⊢ □⋀Δ → χ` for finite Δ ⊆ inst(A). This
  holds because MN, G-nec and TR all preserve the form `□⋀Δ → ·`, using Lemma U's facts. Then
  distribute `□⋀Δ₁ ∨ □⋀Δ₂` into pairwise disjunctions.
- For Base, take A₁ = {DF, DF^r} and A₂ = {DN}.
  - TR(Sp) gives `□DF^r ∨ □DN^r`.
  - `TM⁻ ⊢ □DN^r(q') → □DN(q)` for a suitable q'. The mirror of the following argument works:
    `Pp ∧ HH¬p → P(Fq ∧ ¬FFq)` with `q := HH¬p ∧ Pp` is valid on every transitive frame, hence a
    theorem of L₂.
  - So (Sp) with its TR closure yields all needed pairs.

**Lemma Q (discrete orders collapse onto ℚ ×ₗ ℤ).**
- Take any H/G formula satisfied at a point of a discrete unbounded order (X,<,P̄). Take a
  countable recursively saturated elementary extension (Barwise-Schlipf).
- Its order is I'×ℤ, where I' is countable, dense and unbounded, because the recursive types
  `{s^n(a) < x < p^n(b)}` and `{x > s^n(a)}` are realised. So I' ≅ ℚ.
- H/G truth is first-order via the standard translation, so it is preserved.
- Hence Burgess §2.6 completeness lands in ℚ ×ₗ ℤ. ℚ ×ₗ ℤ is a discrete *group*, so it lies in
  `.Base`.

**Lemma C (CO ⊢ A7).**
- The instance `CO(Fp)` implies A7a over L₂.
- Semantic argument, valid on every linear order. Assume `Fp ∧ FG¬p` at t, so `HFp` holds at t and
  `GFp` fails at t. CO then gives a point w with `HFp ∧ G¬HFp`.
  - If `Fp` held at w, some v > w would have p, while `¬HFp` at v forces `PG¬p` at v, a
    contradiction. So `G¬p` holds at w.
  - Linearity forces w > t.
- By Burgess's L₂ completeness this is an L₂-theorem. TR gives A7b. So TM⁻_r ⊇ Burgess's L_ℝ.

### Assembly per class

- **.Dense**: Lemma U + Burgess §2.5, with ℚ ∈ `.Dense`. So TMFrag_Dense = TM⁻_d.
- **.RTime**: Lemma U + Lemma C + Burgess §2.7, where `.RTime` frames are exactly ℝ. So
  TMFrag_RTime = TM⁻_r. The Doets/SEP obstruction recorded in `TMCompletenessReduction.lean` is
  specific to that *route*. It is not an obstruction for H/G, because Burgess's gap-filling lemma
  needs only A7.
- **.ZTime**: Lemma U + Venema Thm 3.3. So TMFrag_ZTime = TM⁻_z + Z1. DF becomes derivable from
  Z1, so it is redundant.
- **.Base**:
  - Hölder gives `MinusValidIn .Base = Log(dense-group bundles) ∩ Log(discrete-group bundles)`.
  - The dense side is TM⁻+DN, by the Dense row.
  - The discrete side is TM⁻+DF+DF^r, by Lemma U + Burgess §2.6 + Lemma Q, with soundness from
    `df_valid_of_isLeast_pos` and its mirror.
  - Lemma I then gives TMFrag_Base = TM⁻ + (Sp).
  - This also settles the Halldén analysis's two open conditions (TM⁻_f and TM⁻_d axiomatize their
    classes) positively.

### Recommendations

A sorry-free path exists for everything below. The plan should cover:

1. **`TMMinusExt fc Σ`**: a theorems-only Hilbert inductive over `MinusFormula` with rules axiom,
   Σ-axiom, MP, MN, G-nec and TR. Prove `tmMinusExt_le_tmFrag : (∀ ψ ∈ Σ, TMFrag fc ψ) →
   TMMinusExt fc Σ φ → TMFrag fc φ` by structural induction through `translate`, TM MP/MN/TN/TR
   and `tr_reflectTime`. Corollaries:
   - `Sp`-soundness at `.Base`, via `sp_translate`;
   - Z1-soundness at `.ZTime`, via `z1_translate`.
   This is the requested soundness half.
2. **Conditional completeness, stated with explicit hypotheses and never asserted.** For example,
   `TMFrag_ZTime ⊆ TM⁻_z+Z1`, given the hypothesis that the pure tense part is complete for ℤ.
   This may be cheaper phrased semantically: via `chainSat` and Lemma U's normal form. Lemma U and
   Lemma I need an L⁻ propositional layer (identity, deduction theorem, replacement) that does not
   exist yet. Budget a phase for it, mirroring `Metalogic/Core/DeductionTheorem.lean`.
3. **Small derivations**: `□DN^r → □DN`, the mixed (Sp) forms, and `CO(Fp) → A7a`. These are
   provable either directly or via `translate` + TM, but only for the *fragment*. Direct TM⁻
   derivations are preferable because they bear on TM⁻_r's completeness.
4. **Docs**: update the `TMCompletenessReduction.lean` four-row table. `.Dense` and `.RTime` become
   "complete by classical theorem (Burgess 1984 §2.5/§2.7 + universal-modality reduction), not
   machine-checked". Record Σ_Base and Σ_ZTime.
5. **Paper**: report back that the negative footnote must be reworded to the positive statement.
   Suggested content: "TM⁻ is incomplete; TM⁻ + (DD) and TM⁻_z + Z1 are complete for all task
   frames and ℤ-time respectively, and TM⁻_d, TM⁻_r are already complete."

## Decisions

- The classes are treated as the Lean tags (`.ZTime` = ℤ, `.RTime` = ℝ), not as generic
  "discrete" or "Dedekind" classes.
- No unconditional completeness theorem is proposed for Lean in this round. Completeness is
  recorded as classical-literature-backed, and conditional forms are offered.
- The verdict does not depend on anything unformalized beyond Burgess 1984 §2.5-2.7, Venema 2001
  Thm 3.3 (survey citation of Segerberg's ℤ result), and standard model theory (Barwise-Schlipf)
  for Lemma Q.

## Risks & Mitigations

- **Lemma Q is my own argument, not quoted from a source.** Mitigation: it is only needed for the
  `.Base` discrete side. An alternative is Burgess [1979] on homogeneous orders, which is not in
  the corpus. Worth `/literature` acquisition: Burgess 1979 "Logic and time" (JSL 44), and
  Goldblatt LTC (the ℤ axiomatization).
- **The ℤ citation is survey-grade (Venema 2001).** Verify against Segerberg 1970 or Goldblatt
  before the paper cites it.
- **Lemma U's normal form interacts with TR and G-nec inside the global deduction theorem.** The
  proof is routine but must be checked carefully when formalized.
- **The repo's own docs currently say ".Dense open, .RTime obstruction named".** This report
  supersedes that status only at the level of classical proof, not machine-checking. The docs
  must keep that distinction explicit.

## Tactic Survey Results

- Not applicable (no tactic survey performed; no build permitted this round).

## Context Extension Recommendations

- **Topic**: □ as universal modality in TM⁻ task semantics
- **Gap**: no context file explains the MF+TR+S5 universality and the resulting reduction of
  H/G+□ questions to pure linear tense logic
- **Recommendation**: add a short note under `.claude/context/project/logic/` (via the
  agent-system source store) citing Burgess 1984 §2 and Goranko-Passy 1992

## Appendix

- Corpus reads:
  - `~/Projects/Literature/sources/burgess_1984/Burgess_1984_Basic_Tense_Logic.pdf` (pdftotext,
    axioms list p.~101, §2.5-2.8 pp.106-112);
  - `venema_2001/sec02_validity-and-definability.md` (correspondence table, Thm 3.3).
- Code reads: `Fragment.lean`, `TMCompletenessReduction.lean`, `SpWitness.lean`,
  `ChainBundleTruth.lean`, `Syntax/MinusLanguage/{Axioms,Derivation}.lean`,
  `Semantics/MinusLanguage/{MinusTruth,MinusValidity}.lean`, `Semantics/TemporalOrder.lean`.
- The PossibleWorlds `possible_worlds.tex` was not located under `~/Projects`, so the footnote text
  was not quoted.
