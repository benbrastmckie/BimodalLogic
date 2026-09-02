# Territory A: Soundness & Validity — Findings

Scope: `FormalSystem/Metalogic/{Soundness,BaseLanguageSoundness}.lean`,
`FormalSystem/Metalogic/SoundnessLemmas{,.lean}/*`,
`FormalSystem/Semantics/{Validity,FrameClassValidity,BLValidity,BLSchemaValidity,Truth,BLTruth}.lean`
— 7,381 lines, ~290 declarations. Context read: `.claude/rules/lean4.md`,
`FormalSystem/Metalogic.lean`, `FormalSystem/Semantics/{FrameProperty,TaskFrame}.lean`,
`FormalSystem/ProofSystem/Axioms.lean`, `FormalSystem/Metalogic/StrongCompleteness.lean`
(for the ×4 map). No files were modified; no builds were run.

---

## 1. Architecture assessment

**The load-bearing structure is excellent and recently won.** The `FrameClass`-indexing collapse
is the right architecture and it is genuinely done at the *definition* layer:

- `ProofSystem.FrameClass.Sat` (`Semantics/FrameClassValidity.lean:112`) is the single place where
  a proof-side tag acquires a frame class. Its antitonicity (`FrameClass.Sat.anti`,
  `FrameClassValidity.lean:131`) is proved once, and *every* semantic monotonicity bridge in the
  tree is a corollary — `ValidIn.mono` (`Validity.lean:466`), `BLValidIn.mono`
  (`BLValidity.lean:151`), and the four `valid_implies_valid*` lemmas
  (`Validity.lean:846,852,860,867`) are all one-liners over `ValidOnFrames.mono`
  (`Validity.lean:453`). That is a real, high-quality abstraction.
- `soundness_in` (`Soundness.lean:1438`) writes the seven-constructor `DerivationTree` induction
  exactly once, at an arbitrary `fc`. `axiom_validIn_min` (`Soundness.lean:1277`) states each
  axiom's validity at *its own* `minFrameClass`, and `ValidIn.mono` lifts. `soundness`,
  `soundness_dense`, `soundness_discrete`, `soundness_dedekind` are genuine one-line instances
  (`Soundness.lean:1529,1582,1619,1668`). Four hand-written 45-arm dispatchers were collapsed
  into one. `bl_soundness_in` (`BaseLanguageSoundness.lean:204`) does the same on the BL side.
- The `ValidOnFrames P` / `ValidIn fc` two-layer split is correctly motivated: `ValidDedekind`
  (`Validity.lean:711`) is `ValidOnFrames TaskFrame.IsComplete`, a class no `FrameClass`
  constructor denotes, and it still lands inside the collapse. This is the right call and the
  docstring's justification (`Validity.lean:305-322`) is sound.
- `SoundnessLemmas/Separability.lean` is the best-engineered file in the territory:
  `sep_order` (`:270`) extracts the *order-theoretic core* of Reynolds §7 lemma 10 as a statement
  about an abstract `P : Set D`, and `sep_order_mirror` (`:324`) obtains the past-directed dual by
  instantiating that core at `Dᵒᵈ` rather than hand-mirroring ~130 lines. This is the pattern the
  rest of the territory should be measured against.

**The main structural smell is that the collapse stopped at the definition layer and was never
followed by a cleanup pass.** Three concrete symptoms, in order of cost:

1. **The superseded machinery was left in place, not deleted.** `SoundnessLemmas/DenseValidity.lean`
   contains **615 of its 1,297 lines (47%) of transitively unreachable code** — including a
   298-line 45-arm dispatcher `axiom_locally_valid` whose only occurrence in the entire tree is
   its own declaration (finding A-01). Its own section docstrings admit the supersession
   (`DenseValidity.lean:215-217`) without removing the code.
2. **Two 45-arm swap dispatchers survive, 321 of their lines byte-identical**, and the Dense one is
   invoked for exactly **2** of its 45 arms (finding A-02).
3. **The truth layer is missing the derived-Boolean unfolding lemmas that the BL layer already
   has**, which is the single root cause of the largest category of ugly proof in the territory:
   four private copies of `and_of_not_imp_not`, three separate re-provings of `truth_and_iff`,
   85 `by_contra`s, and comment lines that read
   `Goal: (((D₁→F)→D₂)→F) → D₃. For D₁: intro h; exfalso; apply h; intro h2; exfalso; apply h2`
   (`Soundness.lean:779`) (finding A-03).

A fourth, subtler smell: `TaskFrame.IsDense` is a `def` rather than an `abbrev`
(`Semantics/FrameProperty.lean:71`), which hides `DenselyOrdered` from instance search. That one
keyword is the stated reason for a family of **47 binder-shape adapter lemmas** spread across four
modules (finding A-04).

Documentation is unusually thorough and, where it is about *mathematics*, unusually good — the
`ValidDedekind`-vs-`ValidIn .Dedekind` trap and the Reynolds fidelity note (`Soundness.lean:1160-
1188`) are model entries. But a significant share of the prose narrates the *edit history* rather
than the artifact ("Before this lemma each was written out by hand", "Formerly a strategic sorry",
"Earlier revisions of this docstring…"), some of it is now factually stale (finding A-10), and
three files cite a `specs/NNN_…` task path that violates the repository's own
`no-task-references-in-deliverables` rule (finding A-11).

---

## 2. Frame-class duplication map (Q1)

`Sat` (`Semantics/FrameClassValidity.lean:112`) states each class's frame condition in **exactly one
place** — `.Base ↦ True`, `.Dense ↦ IsDense`, `.Discrete ↦ IsSuccArchDiscrete`,
`.Dedekind ↦ IsDedekind` — and `FrameProperty.lean:71,118,142,172` states each predicate once.
**On the binder-set question the answer is: yes, one place, and this is correct and complete.**

| Family | Indexed form (single source) | Base | Dense | Discrete | Dedekind | Verdict |
|---|---|---|---|---|---|---|
| Empty-context validity | `ValidIn` `Validity.lean:337` (over `ValidOnFrames` `:326`) | `valid` `:377` | `ValidDense` `:534` | `ValidDiscrete` `:608` | `ValidDedekindDense` `:765` | **Already one-line abbreviations.** Keep — they are the citable names. Plus `ValidDedekind` `:711`, genuinely different (`IsComplete`, no tag denotes it). |
| Validity ↔ indexed | — | `valid_iff_validIn_base` `:810` | `validDense_iff_…` `:815` | `validDiscrete_iff_…` `:824` | `validDedekindDense_iff_…` `:830` | All four now `Iff.rfl`. Cheap; keep as drift alarms. |
| `valid ⟹` class | `ValidIn.mono` `:466` | — | `:846` | `:852` | `:867` (+ `:860` for `ValidDedekind`) | **Already one-line instances.** Keep. |
| Binder adapters (validity) | `ValidIn.of_forall_total`/`.apply_total` `:494,:501` | `valid.of_forall_total`/`.apply`/`.of_not` `:388,396,405` | `ValidDense.of_forall`/`.apply`/`.of_not` `:545,552,561` | `ValidDiscrete.*` `:618,628,636` | `ValidDedekindDense.*` `:770,779,787` (+`ValidDedekind.*` `:716,725`) | **Redundant given A-04.** 17 lemmas whose sole purpose is to re-expose `Sat fc F` as instances. |
| Finite-context consequence | `SemanticConsequenceIn` `Validity.lean:92` (over `ConsequenceOnFrames` `:82`) | `SemanticConsequence` `:120` | `SemanticConsequenceDense` `StrongCompleteness.lean:734` | `…Discrete` `:873` | `…DedekindDense` `:206` | **Already indexed.** Good. |
| Binder adapters (consequence) | *none* | `.of_forall`/`.apply` `Validity.lean:140,147` | `StrongCompleteness.lean:739,747` | `:880,891` | `:211,220` | 8 more adapters, same root cause (A-04). |
| Semantic deduction thm | *none* | `semantic_deduction_base` `:632` | `_dense` `:762` | `_discrete` `:907` | `_dedekind_dense` `:256` | **Redundant.** Four structurally identical 10-line proofs; one generic replaces all (A-05). |
| Soundness (context) | `soundness_in` `Soundness.lean:1438` | `soundness` `:1529` | `soundness_dense` `:1582` | `soundness_discrete` `:1619` | `soundness_dedekind` `:1668` | **Already one-line instances.** Keep. |
| Soundness (validity) | `soundness_validIn` `:1468` | — | `soundness_dense_valid` `:1561` | `soundness_discrete_valid` `:1608` | `soundness_dedekind_valid` `:1649` | One-liners; `_dense_valid`/`_dedekind_valid` have **0** in-tree consumers. |
| Axiom validity | `axiom_validIn` `:1357` / `axiom_validIn_min` `:1277` | `axiom_valid` `:1494` | `axiom_dense_valid` `:1501` | `axiom_discrete_valid` `:1509` | `axiom_dedekind_valid` `:1640` | **Already one-line instances.** Keep. |
| Axiom **swap** validity | `axiom_swap_validIn` `:1362` / `_min` `:1326` | `axiom_swap_valid_general` `FrameClassVariants.lean:46` (348 L) | `axiom_swap_valid` `DenseValidity.lean:297` (416 L) | — | — | **The one place the collapse did not reach.** 321 identical lines; Dense form used for 2 of 45 arms (A-02). |
| Local validity (`IsValid`) | — | — | `axiom_locally_valid` `DenseValidity.lean:970` (298 L) | — | — | **DEAD.** Zero references anywhere (A-01). |
| Set consequence | `SetConsequenceOnFrames`/`SetSemanticConsequenceOn` | `SetSemanticConsequenceBase.*` | `…Dense.*` | `…Discrete.*` | `…DedekindDense.*` | 8 more adapters (`SetConsequence.lean`), same root cause. |
| BL validity | `BLValidIn` `BLValidity.lean:107` (over `BLValidOnFrames` `:102`) | `BLValid` `:123` | `BLValidDense` `:202` | `BLValidDiscrete` `:227` (+ `BLValidDiscreteSucc` `:264`) | `BLValidDedekindDense` `:288` | **A whole-module clone of the above.** Genuinely different only in `BLValidDiscreteSucc`, and in the *absence* of `BLValidDedekind` (A-07). |
| BL binder adapters | `BLValidIn.of_forall_total`/`.apply_total` `:181,189` | `:128,135` | `:206,213` | `:232,242` | `:291,300` | 12 more adapters. |
| BL soundness | `bl_soundness_in` `BaseLanguageSoundness.lean:204` | `:229` | `:242` | `:255` | `:276` | Already one-line instances; **plus** `bl_soundness_discrete_succ` `:405`, genuinely different (drops the Archimedean binders), correctly flagged. |

**Answers.**
- *Which per-class copies are redundant?* The four `semantic_deduction_*`; the 45 arms of
  `axiom_swap_valid` beyond `density`/`dense_indicator`; the entire `axiom_locally_valid` block;
  and, conditionally on A-04, all 45 binder adapters (17 validity + 8 consequence + 8 set +
  12 BL).
- *Which are genuinely different?* `ValidDedekind` (bare `IsComplete`; correctly excluded from
  `ValidIn`); `ValidDedekindDense` carrying density in its binder (the refutability argument at
  `Validity.lean:672-690` is correct and load-bearing); `BLValidDiscreteSucc` and
  `bl_soundness_discrete_succ` (Archimedean-free, provably not a composition).
- *Binder set stated once?* **Yes** — `FrameClass.Sat` + `FrameProperty.lean`. This is the part of
  the refactor that landed cleanly.

---

## 3. Findings

### A-01. 615 of 1,297 lines in `DenseValidity.lean` are transitively unreachable
- **Severity**: High
- **Category**: organization
- **Anchors**: `FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean:98-169`
  (`swap_axiom_t4_valid`, `swap_axiom_ta_valid`, `swap_axiom_tl_valid`), `:228-279`
  (`mp_preserves_swap_valid`, `modal_k_preserves_swap_valid`, `temporal_k_preserves_swap_valid`,
  `weakening_preserves_swap_valid`), `:717-874` (the eleven `axiom_*_valid` local-validity
  lemmas), `:960-969` (`axiom_density_valid`), `:970-1267` (`axiom_locally_valid`, **298 lines**),
  `:1268-1297` (`mp_preserves_valid`, `necessitation_preserves_local_valid`,
  `temporal_necessitation_preserves_local_valid`); `SoundnessLemmas/Core.lean:56`
  (`valid_at_triple`), `:67-105` (`truth_at_swap_swap`, 39 lines).
- **Description**: Each of these 26 declarations occurs exactly once in the whole tree — at its own
  `theorem` line. Verified by `grep -rho '\b<name>\b' --include=*.lean FormalSystem/ | wc -l`
  returning 1 for every leaf, and by transitive closure for the eleven `axiom_*_valid` helpers
  (their only consumer is `axiom_locally_valid`, which is itself dead) and for
  `axiom_modal_future_valid` (consumed only at `:1181`, inside `axiom_locally_valid`). Nothing in
  `Tests/` or `docs/` references them. Four survivors of that block — `axiom_temp_linearity_valid`
  `:875`, `axiom_temp_linearity_past_valid` `:907`, `axiom_F_until_equiv_valid` `:940`,
  `axiom_P_since_equiv_valid` `:950` — *are* live, consumed by `FrameClassVariants.lean:310-316`.
  The file's own section docstring at `:215-217` says the rule-preservation lemmas "were the
  ingredients of this file's own swap-validity recursion, which `Metalogic/Soundness.lean`'s
  `derivable_valid_and_swap_validIn` superseded and replaced" — the supersession was noted but the
  code was not removed.
- **Impact**: Half of a 1,300-line file is maintenance surface that no theorem depends on. It costs
  build time on every `lake build`, it makes `axiom_locally_valid` look like a live 45-arm proof
  obligation to any reader auditing axiom coverage, and it is the single largest reason
  `SoundnessLemmas/` looks like an unorganized dumping ground. For publication this is the most
  visible defect in the territory: a reviewer opening the largest file in the soundness layer sees
  a 298-line dispatcher that proves nothing.
- **Recommendation**: Delete the eight ranges above. Move the four live `axiom_*_valid` survivors
  and `axiom_swap_valid`'s two live arms into `FrameClassVariants.lean` (see A-02), and delete
  `DenseValidity.lean` outright — nothing that remains justifies a separate module. `Core.lean`
  then holds only `IsValid`, which A-08 proposes retiring too. Guard against regression with a
  small `scripts/` dead-declaration check, or by making the surviving helpers `private`.
- **Effort**: S (deletion is mechanical; one build to confirm)
- **Depends on**: — (do this first; it shrinks A-02's surface)

### A-02. Two 45-arm swap dispatchers, 321 identical lines, one used for 2 arms
- **Severity**: High
- **Category**: duplication
- **Anchors**: `SoundnessLemmas/DenseValidity.lean:297` `axiom_swap_valid` (416 lines,
  `[DenselyOrdered ↑D]`, `h_fc : h.minFrameClass ≤ FrameClass.Dense`);
  `SoundnessLemmas/FrameClassVariants.lean:46` `axiom_swap_valid_general` (348 lines, no order
  instances, `h_fc : … ≤ FrameClass.Base`). Call sites: `Soundness.lean:1333` (general),
  `Soundness.lean:1337` (`density` arm), `Soundness.lean:1341` (`dense_indicator` arm).
- **Description**: `comm -12` on the two sorted bodies returns **321 common lines**; `diff` returns
  159 differing lines. The two differ only in the frame hypothesis. `axiom_swap_validIn_min`
  (`Soundness.lean:1326`) already performs the `by_cases hbase : ax.minFrameClass ≤ FrameClass.Base`
  split that makes the general form cover the twelve-plus Base axioms, and then reaches into
  `axiom_swap_valid` for **only two** constructors — `density` and `dense_indicator`. The other 43
  arms of the 416-line Dense dispatcher are unreachable through any live path.
- **Impact**: The largest single duplication in the territory. Every future axiom constructor must
  be added to both dispatchers or the build breaks in two places for one reason; and a reader
  auditing "is every axiom's swap proved?" has to read 764 lines to learn that the answer lives in
  one 348-line proof plus two three-line lemmas.
- **Recommendation**: Delete `axiom_swap_valid` and replace its two live arms with two standalone
  lemmas beside the other dense validity lemmas in `Soundness.lean`:
  ```lean
  theorem density_swap_valid (φ : Formula) :
      ValidDense ((φ.allFuture.allFuture.imp φ.allFuture).swapTemporal)
  theorem dense_indicator_swap_valid :
      ValidDense ((Formula.untl Formula.bot Formula.top).neg.swapTemporal)
  ```
  matching the existing convention set by `sep_swap_valid` (`Soundness.lean:1217`). Then
  `axiom_swap_validIn_min`'s `.Dense` arms become `exact density_swap_valid a0` and
  `exact dense_indicator_swap_valid`, and `SoundnessLemmas` keeps exactly **one** 45-arm swap
  dispatcher, in `FrameClassVariants.lean`. Net: −416 lines, one dispatcher.
- **Effort**: S
- **Depends on**: A-01

### A-03. `Truth.lean` has no derived-Boolean unfolding lemmas; `BLTruth.lean` has all of them
- **Severity**: High
- **Category**: abstraction / tactic-automation
- **Anchors**: present in BL — `Semantics/BLTruth.lean:137` `neg_iff`, `:141` `top_true`, `:144`
  `and_iff`, `:150` `or_iff`, `:163` `diamond_iff`, `:171` `somePast_iff`, `:179` `someFuture_iff`,
  `:191` `always_iff`, all `@[simp]`. Absent in `Semantics/Truth.lean` (`Truth` namespace ends at
  `:343` with only `bot_false`, `imp_iff`, two atom lemmas, `box_iff`, and four `@[simp]` temporal
  lemmas). Consequences: `Semantics/Correspondence/DurationFrames.lean:294-299` — its own docstring
  reads *"`Truth.lean` supplies unfolding lemmas for the four tense operators but none for
  `Formula.and` or `Formula.always`"* — plus two further re-provings at
  `Metalogic/DedekindNonCompactness.lean:158` (`truth_and_iff'`, whose docstring explicitly says
  "the local copy is kept deliberately") and `Metalogic/Independence/CoNotPriorU.lean:180`
  (`truth_and_iff`). Four private copies of the classical conjunction extractor:
  `Soundness.lean:153`, `SoundnessLemmas/CoValidity.lean:61`, `SoundnessLemmas/DenseValidity.lean:826`,
  `Metalogic/Decidability/Verified/Decidable.lean:2563` (`and_of_not_imp_not'`).
- **Description**: `Formula.and φ ψ` is `(φ.imp ψ.neg).neg` (`Syntax/Formula.lean:449`) and
  `Formula.or` is `φ.neg.imp ψ` (`:454`). Without unfolding lemmas every proof that touches a
  conjunctive or disjunctive axiom must open the double-negation encoding by hand. Measured in
  the territory: 30 `simp only [… Formula.and | Formula.or …]` invocations, 85 `by_contra`s,
  18 `Classical.byContradiction`s, 222 `simp only [… TruthAt …]`. The worst offenders are the
  linearity axioms — `linear_until_valid` (`Soundness.lean:715`, 36 lines) and
  `linear_since_valid` (`:752`, 38 lines) — whose proof comments are literally instructions for
  navigating the encoding:
  `-- Goal: (((D₁→F)→D₂)→F) → D₃. For D₁: intro h; exfalso; apply h; intro h2; exfalso; apply h2`
  (`Soundness.lean:779`), and whose scripts are chains of
  `intro h_outer; exfalso; apply h_outer; intro h_inner; exfalso; apply h_inner`.
  `temp_linearity_valid` (`:347`), `temp_linearity_past_valid` (`:386`), `enrichment_until_valid`
  (`:610`), `enrichment_since_valid` (`:632`), `absorb_until_valid` (`:673`),
  `absorb_since_valid` (`:692`), `discreteness_forward_valid` (`:472`), `temp_l_valid` (`:293`)
  and the two Prior gap lemmas all pay the same tax. `BLTruth` shows what the same proofs look
  like with the lemmas present: `df_valid_of_isLeast_pos` (`BLSchemaValidity.lean:56`) opens its
  three-conjunct antecedent with a single `simp only [BLTruth.imp_iff, BLTruth.and_iff, …]` and
  `rintro ⟨⟨hHφ, hφ⟩, -⟩`.
- **Impact**: This is the single highest-leverage defect in the territory. It is the direct cause of
  four duplicated private helpers, three duplicated `truth_and_iff`s, and the least readable
  proofs in the tree. For publication it is worse than a maintenance cost: the linearity and
  enrichment proofs no longer *look like* the mathematics they encode, so a referee cannot check
  them against Burgess/Xu without first decoding the negation gymnastics.
- **Recommendation**: Add to the `Truth` namespace in `Semantics/Truth.lean`, mirroring `BLTruth`
  one-for-one:
  ```lean
  @[simp] theorem neg_iff   (φ : Formula) : TruthAt M τ t φ.neg ↔ ¬ TruthAt M τ t φ := Iff.rfl
  @[simp] theorem top_true  : TruthAt M τ t Formula.top := id
  @[simp] theorem and_iff   (φ ψ : Formula) : TruthAt M τ t (φ.and ψ) ↔ (TruthAt M τ t φ ∧ TruthAt M τ t ψ)
  @[simp] theorem or_iff    (φ ψ : Formula) : TruthAt M τ t (φ.or ψ)  ↔ (TruthAt M τ t φ ∨ TruthAt M τ t ψ)
  @[simp] theorem diamond_iff (φ : Formula) : TruthAt M τ t φ.diamond ↔ ∃ σ, σ.IsTotal ∧ TruthAt M σ t φ
  @[simp] theorem always_iff  (φ : Formula) : TruthAt M τ t φ.always ↔
      (∀ s, s < t → TruthAt M τ s φ) ∧ TruthAt M τ t φ ∧ (∀ s, t < s → TruthAt M τ s φ)
  @[simp] theorem kPlus_iff  (φ : Formula) : TruthAt M τ t φ.kPlus  ↔ ¬ ∃ s, t < s ∧ ∀ r, t < r → r < s → ¬ TruthAt M τ r φ
  @[simp] theorem kMinus_iff (φ : Formula) : …
  ```
  Then delete all four `and_of_not_imp_not` copies, `DurationFrames.truth_and_iff`,
  `DedekindNonCompactness.truth_and_iff'`, `CoNotPriorU.truth_and_iff`, and
  `CoValidity.always_elim` (`:73`, which becomes `always_iff.mp`). Expected saving in the
  territory alone: **~200-250 lines**, concentrated in the eight proofs named above, plus a
  qualitative gain — `linear_until_valid` becomes a `rcases lt_trichotomy` with three
  `exact ⟨s, _, ⟨_, _⟩, _⟩` arms.
- **Effort**: M (the lemmas are trivial; the payoff is in rewriting ~10 proofs, one at a time,
  each independently verifiable)
- **Depends on**: —

### A-04. `TaskFrame.IsDense` is a `def`, forcing 47 binder-shape adapter lemmas
- **Severity**: High
- **Category**: api-ergonomics / abstraction
- **Anchors**: `Semantics/FrameProperty.lean:71` `def TaskFrame.IsDense (F) : Prop :=
  DenselyOrdered F.Duration`; `:118` `def TaskFrame.IsSuccArchDiscrete` (a bare `∃`); `:142`
  `IsComplete`; `:172` `IsDedekind := F.IsDense ∧ F.IsComplete`. The stated justification is at
  `Semantics/Validity.lean:536-543`: *"`Sat .Dense F` is `TaskFrame.IsDense F`, whose head symbol
  is `TaskFrame.IsDense` rather than `DenselyOrdered`, so a hypothesis of that type is invisible
  to typeclass resolution and every downstream `exists_between` would fail."* The 47 adapters:
  `Validity.lean:140,147,388,396,405,481,488,494,501,514,545,552,561,618,628,636,716,725,770,779,787`;
  `BLValidity.lean:128,135,166,174,181,189,206,213,232,242,291,300`;
  `StrongCompleteness.lean:211,220,739,747,880,891`; `SetConsequence.lean` (×8).
- **Description**: The entire `.of_forall` / `.apply` / `.of_not` family exists for one reason: to
  convert a `Sat fc F` hypothesis back into the shape typeclass resolution can consume. That is a
  three-line fix at the definition site, not a 47-lemma API. `IsDense` needs only `abbrev` (or
  `@[reducible] def`) for `DenselyOrdered` to be found by instance search through it.
  `IsSuccArchDiscrete`, being an existential over data-carrying classes, needs to become a
  `structure` with `instance`-tagged projections so that `obtain ⟨so, po, hsa, hpa⟩ := hF` puts
  the four instances in scope directly instead of requiring positional `@`-application (a
  fragility the docstrings themselves warn about at `Validity.lean:820-824`:
  *"never with `haveI`: routing them through the instance cache would break definitional
  equality"*).
- **Impact**: 47 declarations plus ~250 lines of docstring exist to route around one keyword. Every
  new class-restricted notion (as `BLValidDiscreteSucc` already shows) tempts an author into
  adding three more. The public API a paper would cite is buried in adapter noise: `Validity.lean`
  has 60 declarations, of which 21 are adapters.
- **Recommendation**: Two steps.
  1. `abbrev TaskFrame.IsDense (F : TaskFrame) : Prop := DenselyOrdered F.Duration`, and
     ```lean
     structure TaskFrame.IsSuccArchDiscrete (F : TaskFrame) : Prop where
       [succ : SuccOrder F.Duration] [pred : PredOrder F.Duration]
       [succArch : IsSuccArchimedean F.Duration] [predArch : IsPredArchimedean F.Duration]
     ```
     (a `Prop`-valued structure keeps `Sat` in `Prop`; the projections are still `instance`s.)
  2. Add **one** tactic, in a new `Semantics/SatTactic.lean` or beside `Sat`:
     ```lean
     /-- Discharge a `fc.Sat F` hypothesis into the instance cache, uniformly in `fc`. -/
     macro "sat_intro " h:ident : tactic =>
       `(tactic| first | clear $h | (obtain ⟨_, _⟩ := $h) | (obtain ⟨_,_,_,_⟩ := $h) | skip)
     ```
     A goal site then reads `refine ValidIn.of_forall_total ?_; intro F hF M τ hτ t; sat_intro hF`
     with no per-class adapter at all. Delete the 45 class-specific adapters (keep the two generic
     `ValidIn.of_forall_total`/`.apply_total` and their BL twins).
- **Effort**: M (mechanical but wide — ~27 downstream consumer files per `FrameClassValidity.lean:75`;
  do it as one commit with the build as the oracle)
- **Depends on**: —

### A-05. Four structurally identical `semantic_deduction_*` proofs
- **Severity**: Medium
- **Category**: duplication
- **Anchors**: `Metalogic/StrongCompleteness.lean:256` `semantic_deduction_dedekind_dense`, `:632`
  `_base`, `:762` `_dense`, `:907` `_discrete`.
- **Description**: All four are the identical 10-line script — `constructor`, then each direction
  is `refine <Valid*>.of_forall ?_; intro F …; exact (truthAt_foldr_imp M τ t Γ φ).mpr (h.apply F … )`.
  The only variation is which adapter pair is named and how many `_`s the `intro` takes. The
  underlying content, `truthAt_foldr_imp` (`:238`), is already frame-condition-free and generic,
  and both sides of each biconditional are already `ValidIn fc` / `SemanticConsequenceIn fc` by
  definition.
- **Impact**: Four proofs to keep in step for one theorem; four docstrings restating the same
  observation. Low severity only because each copy is short.
- **Recommendation**: One generic theorem plus four `rfl`-instances:
  ```lean
  theorem semantic_deduction_in {fc : FrameClass} (Γ : Context) (φ : Formula) :
      SemanticConsequenceIn fc Γ φ ↔ ValidIn fc (Γ.foldr Formula.imp φ) := by
    constructor
    · intro h; exact ValidIn.of_forall_total fun F hF M τ hτ t =>
        (truthAt_foldr_imp M τ t Γ φ).mpr (h F hF M τ hτ t)
    · intro h F hF M τ hτ t hall =>
        (truthAt_foldr_imp M τ t Γ φ).mp (h.apply_total F hF M τ hτ t) hall
  theorem semantic_deduction_base     := semantic_deduction_in (fc := .Base)
  theorem semantic_deduction_dense    := semantic_deduction_in (fc := .Dense)   -- etc.
  ```
  Note this becomes trivial once A-04 lands, because the adapters it currently routes through
  disappear.
- **Effort**: S
- **Depends on**: A-04 (easier after, but not blocked by it)

### A-06. The discrete Prior/Z1 past-duals are hand-mirrored, though the `Dᵒᵈ` recipe already exists in the same directory
- **Severity**: Medium
- **Category**: math-insight / duplication
- **Anchors**: `SoundnessLemmas/FrameClassVariants.lean:400` `prior_UZ_is_valid` (~40 L) vs `:440`
  `prior_SZ_is_valid` (~40 L); `:479` `z1_is_valid` (~59 L) vs `:541` `z1_past_is_valid` (~49 L).
  The recipe not used: `SoundnessLemmas/Separability.lean:270` `sep_order` (abstract
  `P : Set D`, no formulas) and `:324` `sep_order_mirror` (*"obtained by instantiating the forward
  core at `Dᵒᵈ` rather than hand-dualising its ~130-line body"*).
- **Description**: `prior_SZ_is_valid` is `prior_UZ_is_valid` with `Order.succ ↦ Order.pred`,
  `Monotone ↦ Antitone`, `exists_succ_iterate ↦ exists_pred_iterate`,
  `lt_of_lt_of_le ↦ lt_of_le_of_lt`, `IsMax ↦ IsMin`, and the inequalities reversed. `z1_past_is_valid`
  stands in the same relation to `z1_is_valid`, including the identical
  `Nat.strong_induction_on`-over-`n₀ - k` backward-induction scaffold. `Soundness.lean:1210-1213`
  records the decision explicitly — *"(The Prior pair took the opposite route because its
  dualised body is only ~25 lines.)"* — but that estimate applies to the *Dedekind* Prior pair
  (`prior_U_gap_valid`/`prior_S_gap_valid`, 35 lines each), not to this discrete pair, where the
  duplicated body is ~90 lines.
  The deeper observation: none of these four proofs is about formulas. Each treats
  `fun s => TruthAt M τ s φ` as an opaque `P : D → Prop` and argues purely about the successor
  chain. So the `sep_order` treatment applies verbatim.
- **Impact**: ~90 duplicated lines of the most intricate proof scripts in the territory
  (`Nat.find` minimality plus strong induction on a distance), maintained twice. Mathematically it
  obscures the fact that Prior-UZ/SZ and Z1/Z1-past are *one* order-theoretic lemma each about a
  successor-Archimedean linear order, not four temporal-logic facts.
- **Recommendation**: Extract two `P`-parameterized cores into `SoundnessLemmas/Separability.lean`
  (or a new `SoundnessLemmas/DiscreteOrder.lean`), then obtain each dual at `Dᵒᵈ`:
  ```lean
  /-- Nearest witness on a successor-Archimedean order. -/
  theorem exists_nearest_succ {D} [LinearOrder D] [SuccOrder D] [IsSuccArchimedean D]
      (P : D → Prop) (t s : D) (hts : t < s) (hs : P s) :
      ∃ u, t < u ∧ P u ∧ ∀ r, t < r → r < u → ¬ P r
  /-- Backward induction along a successor chain. -/
  theorem forall_gt_of_succ_step {D} [LinearOrder D] [SuccOrder D] [IsSuccArchimedean D]
      (P : D → Prop) (t : D) (hstep : ∀ u, t < u → (∀ r, u < r → P r) → P u)
      (s₀ : D) (hts₀ : t < s₀) (hs₀ : ∀ r, s₀ < r → P r) : ∀ s, t < s → P s
  ```
  `prior_SZ_is_valid` and `z1_past_is_valid` then become `refine … (D := Dᵒᵈ) …` in the style of
  `sep_order_mirror:324-352`, at ~15 lines each. Net: −90 lines and two reusable order lemmas.
- **Effort**: M
- **Depends on**: —

### A-07. `BLValidity.lean` is a structural clone of `Validity.lean` despite the `truthAt_tr` bridge
- **Severity**: Medium
- **Category**: duplication
- **Anchors**: the parallel pairs — `BLValidity.lean:96` `TaskFrame.BLValidOn` ∥
  `Validity.lean:254` `TaskFrame.ValidOn`; `:102` `BLValidOnFrames` ∥ `:326` `ValidOnFrames`;
  `:107` `BLValidIn` ∥ `:337` `ValidIn`; `:123/:202/:227/:288` ∥ `:377/:534/:608/:765`;
  `:141` `BLValidOnFrames.mono` ∥ `:453` `ValidOnFrames.mono`; `:147` `BLValidIn.mono` ∥ `:466`
  `ValidIn.mono`; twelve adapters ∥ seventeen adapters; `BLValidity.blValid_implies_*`
  `:326,330,334` ∥ `Validity.valid_implies_*` `:846,852,867`; `:340`
  `blValid_iff_empty_consequence` ∥ `:886` `valid_iff_empty_consequence`. The bridge that already
  exists: `Metalogic/BaseLanguageSoundness.lean:110` `truthAt_tr`, `:147` `blValid_iff_valid_tr`,
  `:167` `blValidDiscrete_iff_validDiscrete_tr`. Also duplicated *mathematics*:
  `Semantics/BLSchemaValidity.lean:56` `df_valid_of_isLeast_pos` / `:88` `df_valid_of_succOrder`
  re-prove `Soundness.lean:473` `discreteness_forward_valid`, and `:104`
  `dn_valid_of_denselyOrdered` re-proves `Soundness.lean:457` `density_valid`, in the other
  language.
- **Description**: The module docstring is explicit that the mirroring is intentional —
  *"Each predicate here is a **binder-for-binder mirror** of its counterpart… Nothing changes but
  `Formula ↦ BLFormula` and `TruthAt ↦ BLTruthAt`"* (`BLValidity.lean:19-24`) — and the design
  reason (`BLTruth` is a native recursion, not `TruthAt ∘ tr`) is genuinely good and should be
  kept. But once `truthAt_tr` is proved, only *two* things need to be BL-native: the definitions
  (so the statements are about BL) and one transfer theorem per predicate. Every *lemma* about the
  BL predicates — monotonicity, the three inclusion lemmas, `blValid_iff_empty_consequence` — can
  be a corollary of its BL⁺ twin across `truthAt_tr`, rather than a re-proof.
- **Impact**: ~30 declarations and 352 lines that must be edited in lockstep with `Validity.lean`
  forever. The `BLValidDedekind` omission is correctly documented in three places precisely
  because the mirror is *not* exact, which is the maintenance risk made visible.
- **Recommendation**: Keep the definitions (`BLValidOn`, `BLValidOnFrames`, `BLValidIn`, and the
  four class predicates) — they carry the "BL means BL" claim. Promote one generic transfer
  theorem to `BaseLanguageSoundness.lean` and derive the lemma layer from it:
  ```lean
  theorem blValidIn_iff_validIn_tr (fc : FrameClass) (φ : BLFormula) :
      BLValidIn fc φ ↔ ValidIn fc (tr φ)
  ```
  Then `BLValidIn.mono`, `BLValidOnFrames.mono`, the three `blValid_implies_*` and
  `blValid_iff_empty_consequence` all become `simp [blValidIn_iff_validIn_tr]`-style corollaries,
  and `blValid_iff_valid_tr` / `blValidDiscrete_iff_validDiscrete_tr` become its `.Base` and
  `.Discrete` instances rather than two hand-written two-branch proofs. Similarly,
  `BLSchemaValidity`'s `dn_valid_of_denselyOrdered` becomes `density_valid` transported. The
  BL-native `example`s at `BaseLanguageSoundness.lean:489-503` already discharge the
  "`BLTruthAt` is not `TruthAt ∘ tr`" obligation; the transfer theorem does not weaken them.
- **Effort**: M
- **Depends on**: A-04 (the adapters vanish either way)

### A-08. `SoundnessLemmas.IsValid` is a second, monomorphic validity notion
- **Severity**: Medium
- **Category**: abstraction / api-ergonomics
- **Anchors**: `SoundnessLemmas/Core.lean:42` `def IsValid (D : TemporalOrder) (φ : Formula)`.
  Live consumers after A-01: `FrameClassVariants.lean:48,402,442,481,543` and
  `Metalogic/Decidability/Verified/Decidable.lean:2413`. The bridging shims at every call site:
  `Soundness.lean:913,921,928` (`prior_UZ_valid`, `prior_SZ_valid`, `z1_valid`) and `:1326-1356`
  (`axiom_swap_validIn_min`), each of the form
  `refine ValidDiscrete.of_forall ?_; intro F _ _ _ _ M τ h; exact SoundnessLemmas.X (D := F.Duration) … F.toFibre M τ h t`.
- **Description**: `IsValid D φ` is `ValidIn .Base φ` restricted to one temporal type, introduced
  (per its docstring, `Core.lean:26-31`) "to avoid circular dependency with Validity.lean" and
  "to avoid universe level mismatch errors". Both reasons have expired: `SoundnessLemmas/CoValidity.lean:9`
  and `Separability.lean` already import `Semantics.Validity` and use `ValidDedekindDense`
  directly, and `valid`/`ValidIn` are already `Type`-monomorphic by design
  (`Validity.lean:370-373`). The cost is a `.toFibre` + explicit-`(D := F.Duration)` shim at every
  boundary crossing.
- **Impact**: Two parallel validity vocabularies in one directory, with the reader having to know
  that `IsValid D` and `ValidIn .Base` are the same notion and that `F.toFibre` is the coercion.
  The docstring's stated justification is stale, which makes it actively misleading.
- **Recommendation**: Have `FrameClassVariants.lean` import `Semantics.Validity` (as its sibling
  `CoValidity.lean` already does) and restate its five theorems at `ValidIn`/`ValidDiscrete`
  directly. The three `Soundness.lean` shims at `:913-935` then collapse to
  `exact SoundnessLemmas.prior_UZ_is_valid φ` etc., and `axiom_swap_validIn_min`'s discrete arms
  lose their `ValidDiscrete.of_forall` wrappers. Delete `IsValid` and `Core.lean` entirely (its
  only other contents, `valid_at_triple` and `truth_at_swap_swap`, are dead per A-01). Keep the
  `Decidable.lean:2413` landing lemma, retargeted.
- **Effort**: M
- **Depends on**: A-01

### A-09. `exists_isGLB_of_lub` duplicated, with a docstring that explains the duplication instead of removing it
- **Severity**: Low
- **Category**: duplication
- **Anchors**: `Metalogic/Soundness.lean:1000` (private) and
  `SoundnessLemmas/Separability.lean:48` (private). The latter's docstring reads: *"Deliberate
  duplicate of the identically-named helper in `Metalogic/Soundness.lean`: that copy is `private`
  and so unreachable from this module, and it must stay where it is because `prior_S_gap_valid`
  uses it."*
- **Description**: The stated obstruction is self-inflicted and the import direction already
  permits the fix: `Soundness.lean:11` imports `SoundnessLemmas.Separability`. Dropping `private`
  from the `Separability.lean` copy and deleting the `Soundness.lean` one is a two-line change.
- **Impact**: Small, but it is a five-line lemma with a five-line apology attached, and the pattern
  ("keep the copy, explain why") recurs — see the identical construction at
  `DedekindNonCompactness.lean:154-157` in A-03.
- **Recommendation**: Un-`private` `Separability.exists_isGLB_of_lub`, delete the `Soundness.lean`
  copy. If the concern is namespace hygiene, `protected` or a `SoundnessLemmas.Order` sub-namespace
  serves.
- **Effort**: S
- **Depends on**: —

### A-10. Stale documentation claims contradicted by the code they describe
- **Severity**: Medium
- **Category**: documentation
- **Anchors**:
  - `Soundness.lean:76` and `SoundnessLemmas/Core.lean:40`: *"`TruthAt`'s remaining set argument is
    inert and is supplied as `Set.univ`."* `TruthAt` (`Truth.lean:163`) takes no set argument;
    `Truth.lean:130-135` says so explicitly (*"The designated-carrier argument … has been deleted
    outright"*). Two files assert the opposite.
  - `Semantics/Truth.lean:74-75`: *"moved to `Metalogic/SoundnessLemmas.lean`… See
    SoundnessLemmas.lean for details on the module hierarchy restructuring."* That is now a
    five-file directory with a bare aggregator (`SoundnessLemmas.lean`), which carries no such
    detail. Same stale link at `Soundness.lean:140`.
  - `SoundnessLemmas/FrameClassVariants.lean:32-35`: *"This resolves the 3 `temporal_duality`
    sorries in Soundness.lean: `soundness` (general, line ~877), `soundness_discrete_valid`
    (line ~1094), `soundness_discrete` (line ~1151)."* No sorries exist; all three line numbers are
    wrong (actual: 1568, 1646, 1652).
  - `Metalogic.lean` module-structure block: `SoundnessLemmas/  3 files`. Actual: five `.lean`
    files (`Core`, `CoValidity`, `DenseValidity`, `FrameClassVariants`, `Separability`).
  - `SoundnessLemmas.lean:19-25` lists four contents and omits `Separability.lean`; the aggregator
    also does not import it, so `import FormalSystem.Metalogic.SoundnessLemmas` does not give you
    the directory.
  - `Validity.lean:933-936`: *"The hypothesis now carries `[Nontrivial D]`, matching both
    `satisfiable` and the binder list of `SemanticConsequence`."* `SemanticConsequence`
    (`:120`) is now an abbreviation over `SemanticConsequenceIn .Base` and has no binder list.
  - `SoundnessLemmas/DenseValidity.lean:14-16`: *"…and that derivability implies both local
    validity and swap validity"* — that recursion was removed (see `:215-217`).
  - `Automation/AesopRules.lean:35-39` (adjacent, but a claim about this territory's results):
    *"The following axioms are excluded pending soundness proofs: TL (temp_l)… MF (modal_future):
    soundness incomplete."* Both are proved: `Soundness.lean:297` `temp_l_valid`, `:322`
    `modal_future_valid`.
- **Description**: Eight verifiable mismatches between prose and code, all in load-bearing module
  docstrings. Several are of the "the docstring describes a previous revision" kind, which is the
  predictable residue of a large refactor.
- **Impact**: For a publication-grade artifact these are the highest-visibility defects after the
  dead code: a referee checking the `Set.univ` claim against `TruthAt`'s signature finds them
  disagreeing, and the `Metalogic.lean` file-count claim is the tree's own advertised invariant
  (the docstring even says *"run `scripts/check-module-invariants.sh` to re-derive them"*).
- **Recommendation**: Fix each; add `Separability` to the aggregator's imports and its contents
  list; correct the `Metalogic.lean` count and re-run `check-module-invariants.sh`. Standing rule
  for the tree: docstrings state what *is*, never what *was* — retire the "Formerly a strategic
  sorry" / "Before this lemma each was written out by hand" / "Earlier revisions of this
  docstring…" register into commit messages (see A-18).
- **Effort**: S
- **Depends on**: A-01 (some of these vanish with the dead code)

### A-11. Task-management references leak into deliverable source files
- **Severity**: Medium
- **Category**: documentation
- **Anchors**: `Semantics/BLSchemaValidity.lean:40-41` (a `## References` entry naming a
  `specs/NNN_…/reports/01_….md` path), `:15` (*"report §4.1 Lemmas B and C, plus §6.1's
  past-dual obligation"*); `Semantics/BLValidity.lean:260` (*"The single prerequisite CEF was
  missing (report §6.1)"*); `Metalogic/BaseLanguageSoundness.lean:310` (*"The single missing
  prerequisite for CEF (report §6.1)"*).
- **Description**: The repository's own `.claude/rules/no-task-references-in-deliverables.md`
  states the rule applies to *"the entire repository EXCEPT `specs/**`"* and requires citing
  "durable anchors instead: a filename, a section heading, a decision-record name, or a verified
  fact". A `specs/` report path is not durable — the rule notes task numbers are renumbered — and
  "§4.1 Lemmas B and C" is unresolvable to any reader who does not have that ephemeral artifact.
  The names "Lemma B", "Lemma C" are also used *in the docstrings themselves* (`:44`, `:99`) as if
  they were the lemmas' identities.
- **Impact**: A published artifact whose docstrings cite an internal, deleted-on-archive planning
  document. It also loses the actual mathematical content: "Lemma B" tells the reader nothing,
  whereas "the least-positive-element form of DF validity" does.
- **Recommendation**: Replace each with a durable anchor — the paper anchor (`def:TMplus-f`,
  `def:frame-properties`) or the in-tree declaration (`Semantics/LexCarrier.lean`,
  `Metalogic/Z1Countermodel.lean`) that motivates it — and rename the "Lemma B / Lemma C"
  headings to describe the statements. `BLSchemaValidity.lean:40-41` should simply be deleted
  from the References block.
- **Effort**: S
- **Depends on**: —

### A-12. `time_shift_preserves_truth`: 236 lines, four near-identical arithmetic blocks
- **Severity**: Medium
- **Category**: proof-elegance
- **Anchors**: `Semantics/Truth.lean:450` `time_shift_preserves_truth`; the four blocks are the
  `untl` case (`:516-602`) and the `snce` case (`:603-664`), each with two mirror-image directions. Supporting: `:379` `truth_double_shift_cancel` (~55 L, itself six
  near-identical constructor arms), `:355` `truth_history_eq`.
- **Description**: Each of the four blocks re-derives the same three facts about the shift
  `Δ := y - x`: the witness transport (`s ↦ s + Δ` / `s ↦ s - Δ`), the guard-interval transport,
  and the `timeShift σ (r - (r - Δ)) = timeShift σ Δ` congruence. The `calc` chains
  (four of them, inside `:516-664`) are the same three-step
  `add_comm`/`add_sub_cancel_left` reasoning written four times. The `box` case additionally
  builds an ad-hoc cancellation argument (`:485-514`) that `truth_double_shift_cancel` already
  provides.
- **Impact**: The longest proof in `Semantics/`, and it is the *foundational* transport lemma — it
  is what `modal_future_valid` and `Truth.box_const` rest on. Its length hides the fact that the
  content is a single bijection `D ≃ D` and a `TruthAt`-congruence along it.
- **Recommendation**: Extract the two transport facts once, then all four blocks become
  three-liners:
  ```lean
  private theorem shift_lt_iff (Δ a b : F.Duration) : a + Δ < b + Δ ↔ a < b
  private theorem shift_cancel (σ : WorldHistory F) (Δ r : F.Duration) :
      WorldHistory.timeShift σ ((r + Δ) - r) = WorldHistory.timeShift σ Δ
  ```
  Better still, state the general shape once and get `snce` free from `untl` by the `Dᵒᵈ`
  instantiation recipe of A-06 — the two clauses of `TruthAt` (`Truth.lean:169-173`) are literal
  order-duals. Expected: 236 → ~90 lines.
- **Effort**: M
- **Depends on**: —

### A-13. No `truth_simp` set and no validity-introduction tactic, despite in-tree tactic infrastructure
- **Severity**: Medium
- **Category**: tactic-automation
- **Anchors**: 222 occurrences of `simp only [… TruthAt …]` and 47 of
  `refine valid.of_forall_total ?_` across the territory (measured by grep over the 13 files);
  40 of the latter are followed by the literal line `intro F M τ _h_mem t`. `@[simp]` coverage:
  6 of 13 `Truth`-namespace lemmas, 8 of 13 `BLTruth` — and the two files tag *disjoint* halves
  (`Truth.lean` tags the derived tense operators `:249,266,283,301`; `BLTruth.lean` tags the
  derived Booleans `:137-196` but leaves the primitive `past_iff`/`future_iff`/`box_iff`/`imp_iff`
  untagged). Existing infrastructure the territory does not use:
  `FormalSystem/Automation/Normalization.lean:178-220` (`modalNorm`, `propNorm`, `temporalNorm`,
  `modalNormAll`), `Automation/Tactics/Helpers.lean:109` (`apply_axiom`),
  `Metalogic/WeakCanonical/EFGameTactics.lean:44` (`simp_game_tuple`).
- **Description**: Every one of the ~47 base-class validity lemmas in `Soundness.lean` opens with
  the same three lines. There is no `Truth`-side simp set, so each proof hand-picks its unfolding
  list, and the lists drift (`simp only [TruthAt, Truth.future_iff]` vs
  `simp only [Formula.and, Formula.neg, TruthAt]` vs
  `simp only [TruthAt, Formula.and, Formula.neg, Formula.someFuture, Formula.top]`).
- **Impact**: ~90 lines of pure boilerplate in `Soundness.lean` alone, and — more importantly — no
  single place to change when a truth clause changes. The project clearly has the appetite and the
  skill for tactic authoring (six macros elsewhere); the soundness layer just never got one.
- **Recommendation**: Two small additions in `Semantics/Truth.lean`:
  ```lean
  /-- Canonical unfolding set for `TruthAt`: the six clauses plus every derived-operator
      characterization. -/
  register_simp_attr truth_simp
  -- tag: TruthAt equations, imp_iff, box_iff, past_iff, future_iff, some_*_iff,
  --      and the A-03 additions neg_iff/and_iff/or_iff/top_true/always_iff/diamond_iff
  ```
  and, beside the adapters,
  ```lean
  /-- Open a `valid`/`ValidIn`/`ValidDense`/… goal into its `(F, M, τ, hτ, t)` binder shape. -/
  macro "validity_intro" : tactic =>
    `(tactic| (refine ValidIn.of_forall_total ?_; intro F hF M τ hτ t; sat_intro hF))
  ```
  (`sat_intro` from A-04). Then every base validity lemma opens `validity_intro; simp [truth_simp]`.
  Also settle the `@[simp]` asymmetry: tag the same *kinds* of lemma in both namespaces, and say
  which in the module docstring.
- **Effort**: M
- **Depends on**: A-03, A-04

### A-14. Two induction idioms for one recursion, with duplicated termination scaffolding
- **Severity**: Medium
- **Category**: proof-elegance
- **Anchors**: `Soundness.lean:1436` `soundness_in` uses `induction d generalizing τ t`;
  `Soundness.lean:1366` `derivable_valid_and_swap_validIn` uses `match d with … termination_by
  d.height` + a bespoke `decreasing_by` (`:1430-1435`). The `weakening` arm's scaffold —
  `h_eq`, `h_height_eq`, `h_term`, then `exact … (h_eq ▸ d')` (`:1422-1429`) — is reproduced
  verbatim, modulo `BaseLanguage.` prefixes, at
  `BaseLanguageSoundness.lean:382-393`.
- **Description**: The two theorems recurse over the same inductive family for the same reason;
  one uses the equation compiler with a manual height measure, the other the structural
  `induction` tactic. The height-based `weakening` scaffold is fragile (it depends on `omega`
  picking `h_term` out of the local context of the `decreasing_by` goal) and now exists in two
  files.
- **Impact**: A reader auditing "does the soundness induction cover all seven constructors?" — which
  the docstrings go to some length to assert (`Soundness.lean:83-105`, `:1579-1581`) — must check
  two differently-shaped proofs. The duplicated scaffold is a latent breakage: a change to
  `DerivationTree.height` needs a matching edit in both trees.
- **Recommendation**: Extract the `weakening`-at-empty-context normalization as a shared lemma so
  the arm becomes a one-liner in both files:
  ```lean
  theorem DerivationTree.ofWeakeningNil {fc Γ' φ} (d : DerivationTree fc Γ' φ)
      (h_sub : Γ' ⊆ []) : DerivationTree fc [] φ
  ```
  with the height fact proved once beside it. Consider unifying the two recursions into a single
  `derivable_valid_and_swap_validIn`, with `soundness_in` derived from it plus the context
  argument — the `soundness_in` docstring (`:83-105`) already describes them as one induction.
- **Effort**: M
- **Depends on**: —

### A-15. Five competing naming conventions for "axiom X is valid"
- **Severity**: Medium
- **Category**: naming
- **Anchors**: `Soundness.lean:158` `prop_k_valid`, `:319` `modal_future_valid` (bare `X_valid`,
  at `valid`/`ValidDense`/`ValidDiscrete`); `DenseValidity.lean:717` `axiom_prop_k_valid`
  (`axiom_X_valid`, at `IsValid`); `FrameClassVariants.lean:400` `prior_UZ_is_valid`
  (`X_is_valid`, at `IsValid`); `DenseValidity.lean:50` `swap_axiom_mt_valid`
  (`swap_axiom_X_valid`); `Soundness.lean:1217` `sep_swap_valid` (`X_swap_valid`);
  `BLSchemaValidity.lean:56` `df_valid_of_isLeast_pos` (`X_valid_of_hypothesis`);
  `SoundnessLemmas/CoValidity.lean:102` `co_valid`. Also `Soundness.lean:1494` `axiom_valid` vs
  `:1357` `axiom_validIn`; `Validity.lean:377` `valid` (lowercase) vs `:337` `ValidIn`,
  `:534` `ValidDense` (uppercase).
- **Description**: Seven distinct spellings for one concept, correlating loosely with which file
  and which validity notion, but not reliably: `sep_swap_valid` and `swap_axiom_mt_valid` are the
  same kind of theorem with the affix on opposite sides. The `valid` / `ValidIn` case split is
  Mathlib-inconsistent — `valid` is a `Prop`-valued definition and should be `Valid` (Mathlib
  reserves lowercase for `Prop`-valued *predicates on data* only when they are not the primary
  notion; here `valid` is the primary notion and its siblings are all capitalized).
- **Impact**: The main obstacle to citing this development from a paper. A reader wanting "the
  theorem that MF is valid" has three plausible names to try. `axiom_valid` vs `axiom_validIn`
  is actively confusing since the former is a one-line instance of the latter.
- **Recommendation**: One convention, applied at the rename: **`<axiom>_valid`** for the unswapped
  form and **`<axiom>_swap_valid`** for the swapped form, at whatever validity predicate the class
  requires — matching the majority of `Soundness.lean` and `sep_swap_valid`. Rename the nine
  `swap_axiom_*` and the four `*_is_valid` accordingly (most of the former die with A-01 anyway).
  Rename `valid` → `Valid` with a deprecated alias, or document the exception prominently.
  Consider `Valid` / `Valid.dense` / `Valid.discrete` / `Valid.dedekindDense` as dot-namespaced
  siblings so the family is discoverable from one prefix.
- **Effort**: M (mechanical rename; `valid` has ~200 occurrences)
- **Depends on**: A-01, A-02 (rename after deletion, not before)

### A-16. `ValidDedekind` is not `ValidIn .Dedekind` — a trap defended by three docstrings rather than by a name
- **Severity**: Medium
- **Category**: naming
- **Anchors**: `Validity.lean:711` `def ValidDedekind := ValidOnFrames TaskFrame.IsComplete`
  vs `:765` `def ValidDedekindDense := ValidIn .Dedekind`. Warnings at `Validity.lean:638-648`
  (*"**Read this first: `ValidDedekind` is NOT `ValidIn .Dedekind`.**"*), `:672-690`,
  `:748-758`, `FrameClassValidity.lean:45-52`, `Soundness.lean:966-980`, `:1654-1667`,
  `BLValidity.lean:26-45`, `BaseLanguageSoundness.lean:46-54`, `FrameProperty.lean:129-172`.
- **Description**: Nine separate prose warnings across six files that two similarly-named
  predicates denote different frame classes and that using the wrong one yields a *refutable*
  theorem. The underlying mathematics is correct and the reasoning (`ℤ` is Dedekind-complete and
  refutes `density`) is right. But the defense is entirely documentary. `FrameProperty.lean:169`
  even records that the naming deviates from the paper (paper: "Complete"; tree: "Dedekind") for
  an unrelated reason.
- **Impact**: Nine copies of a warning is nine chances to be edited out of step, and it is the kind
  of thing a referee will notice. The predicate that "sounds like" the soundness target is the one
  that would make soundness false.
- **Recommendation**: Make the names carry the distinction so the prose can shrink to one sentence
  each. `ValidDedekind` denotes the bare Complete class, which the paper calls Complete and which
  no `FrameClass` tag names — call it `ValidComplete` (matching `TaskFrame.IsComplete`, which it
  is literally `ValidOnFrames` of). Then rename `ValidDedekindDense` → `ValidDedekind`, so the
  invariant becomes uniform: `ValidX = ValidIn .X` for every tag, with `ValidComplete` visibly
  outside the family. Eight of the nine warnings collapse to a cross-reference on
  `ValidComplete`. Same on the BL side (`BLValidDedekindDense` → `BLValidDedekind`), where the
  "there is deliberately no `BLValidDedekind`" paragraph (`BLValidity.lean:26-45`) then has
  nothing left to warn about.
- **Effort**: M
- **Depends on**: A-15 (do as one rename pass)

### A-17. `Truth.box_const` states the right insight but is not used where it applies
- **Severity**: Low
- **Category**: math-insight
- **Anchors**: `Semantics/Truth.lean:733` `box_const` (*"A boxed formula's truth value is a
  constant of the model: it depends on neither the history nor the time"*), `:746`
  `box_time_const`. Not used by: `Soundness.lean:902` `discrete_box_necessity_valid`
  (`U(⊤,⊥) → □U(⊤,⊥)`), which reproves the history-independence half inline; `:167`
  `modal_4_valid`; `:186` `modal_5_collapse_valid`; `Soundness.lean:1366`
  (`derivable_valid_and_swap_validIn`'s `necessitation` arm).
- **Description**: `box_const` is the sharpest observation in the truth layer and its docstring
  (`:717-732`) explains exactly why the box case of a finite-model truth lemma is routine. But the
  S5 collapse lemmas that would most benefit re-derive the fact from the clause each time.
  `discrete_box_necessity_valid` in particular is the statement *"`U(⊤,⊥)` is history-independent"*,
  a special case of a general fact worth stating: a formula containing no atom is a model
  constant.
- **Impact**: Small in lines; moderate in what the development *shows*. The general lemma —
  "atom-free formulas have history-independent truth" — is the reason the four uniformity axioms
  (`Soundness.lean:825,844,863,882,902`) are valid at all, and stating it would turn five separate
  translation-invariance arguments into one.
- **Recommendation**: State the general fact once:
  ```lean
  /-- A formula with no atoms has the same truth value at every history. -/
  theorem truthAt_atomFree_history_indep (h : φ.atomFree) (M) (τ σ : WorldHistory F) (t) :
      TruthAt M τ t φ ↔ TruthAt M σ t φ
  ```
  and derive `discrete_box_necessity_valid` from it. Pair it with the translation-invariance
  observation the four uniformity lemmas share (`Soundness.lean:813-818`: *"the group's
  translation invariance ensures that gaps are uniform across all time points"*) as
  ```lean
  theorem truthAt_gap_shift (M τ) (t Δ : F.Duration) :
      TruthAt M τ t gapFormula ↔ TruthAt M τ (t + Δ) gapFormula
  ```
  which would collapse `discrete_symm_fwd_valid` `:825` / `_bwd` `:844` / `discrete_propagate_fwd` `:863` / `_bwd` `:882`
  (four ~15-line proofs with the same three `calc` steps) into four two-liners.
- **Effort**: M
- **Depends on**: —

### A-18. Docstrings narrate edit history and design deliberation rather than the artifact
- **Severity**: Medium
- **Category**: documentation
- **Anchors**: `Validity.lean:445-452` (*"Before this lemma each was written out by hand against
  its own inlined binder list"*), `:995-1006` (*"**Formerly a strategic sorry; discharged by the
  validity-layer binder delta.** Before that delta, `valid` bound its history as `τ ∈ Omega`…"*),
  `Truth.lean:29-33` (*"Earlier revisions of this docstring described the paper's convention as
  reflexive… both descriptions were stale and have been corrected"*), `:161-166`,
  `Soundness.lean:24-30` (*"earlier revisions of this module cited `app:valid` at 'line 1984'…
  The citation and its line number were both bogus"*), `:96-101`,
  `Validity.lean:686-696`, `FrameClassValidity.lean:56-60`, `:62-77`.
  Volume: `Validity.lean` is 1,015 lines for 60 declarations; `FrameClassValidity.lean` is 140
  lines for 2 declarations (~100 of them prose).
- **Description**: A substantial share of the prose is written for the maintainer of the *previous*
  revision — recording what changed, what was wrong before, and which alternatives were rejected.
  Some of it is genuinely load-bearing (the `ValidDedekind` refutability argument, the Reynolds
  §7 fidelity deviation at `Soundness.lean:1137-1149`, the Decision-A atom-clause divergence at
  `Truth.lean:136-141`) and should stay. Much of it — "before this lemma", "formerly a sorry",
  "earlier revisions of this docstring" — has no reader in the finished artifact and is exactly
  the class of prose that goes stale (see A-10, where six of eight stale claims are of this kind).
- **Impact**: Signal-to-noise. `doc-gen4` will publish all of it. A referee reading
  `FrameClassValidity.lean` gets ~100 lines of module prose, including a paragraph on a rejected
  refactoring ("Relocating `inductive FrameClass` into a shared low-level module would remove the
  seam entirely, but…"), before reaching two five-line definitions.
- **Recommendation**: Adopt a three-register split and apply it once across the territory:
  **(a) doc-comments** state what the declaration means, its paper anchor, and any trap a caller
  can fall into — present tense, no history; **(b) a `docs/design/` note** (or the module README)
  carries rejected alternatives, layering rationale, and the "why not X" arguments —
  `FrameClassValidity.lean:56-77` and `Validity.lean:305-322` belong there; **(c) commit
  messages** carry "formerly a sorry", "before this delta", "earlier revisions said". Concretely:
  `Metalogic/SoundnessLemmas/README.md` already exists and is the natural home for (b).
  Target roughly halving prose in `Validity.lean` and `FrameClassValidity.lean` without losing a
  single mathematical claim.
- **Effort**: L (judgment-heavy; do it file by file, and only after A-01/A-02 delete the code
  whose docstrings would otherwise be rewritten)
- **Depends on**: A-01, A-02, A-10

### A-19. Declared-but-unconsumed public API in `Validity.lean`
- **Severity**: Low
- **Category**: api-ergonomics
- **Anchors**: zero in-tree consumers (grep for the bare name returns only the declaration):
  `Validity.lean:184` `SatisfiableAbs`, `:901` `consequence_monotone`, `:911` `valid_consequence`,
  `:918` `consequence_of_member`, `:969` `valid_of_valid_all_future`, `:982`
  `valid_of_valid_all_past`, `:1007` `valid_of_valid_box`, `Soundness.lean:947`
  `necessitation_preserves_valid`, `:959` `temporal_necessitation_preserves_valid`,
  `:1561` `soundness_dense_valid`, `:1649` `soundness_dedekind_valid`.
- **Description**: Eleven declarations with no consumer. Unlike A-01's dead code these are
  *deliberate* API surface — `Soundness.lean:938-943` says so of the two necessitation lemmas
  (*"kept as the free-standing semantic facts they state"*) — and the `soundness_*_valid` pair are
  reasonable citable names. But `valid_of_valid_all_future` / `_all_past` carry a note that they
  were "Relocated from the deleted `BXCanonical/CanonicalEmbedding.lean`" (`:958-961`), i.e. they
  are orphans of a deletion, and `SatisfiableAbs` sits beside two other satisfiability notions
  whose docstrings both open "**No paper anchor**".
- **Impact**: Unexercised statements are unverified statements in the weak sense that a signature
  drift would not be caught by any downstream use. Modest.
- **Recommendation**: Keep the ones a paper would cite (`soundness_*_valid`, the two necessitation
  lemmas, `consequence_monotone`) and add a short `example` or `#check` block exercising each, so
  a signature change breaks something. Delete `SatisfiableAbs` and the two `valid_of_valid_all_*`
  orphans unless a downstream consumer is planned; if kept, say in the docstring who they are for.
- **Effort**: S
- **Depends on**: —

---

## 4. Proposed core utilities, ranked

1. **`Truth`-namespace derived-operator lemmas + `truth_simp` attribute** — *discharges A-03,
   enables A-13.*
   Home: `FormalSystem/Semantics/Truth.lean`, `namespace Truth`, immediately after
   `strong_trigger_iff` (`:334`).
   ```lean
   @[simp, truth_simp] theorem neg_iff  (φ : Formula)   : TruthAt M τ t φ.neg ↔ ¬ TruthAt M τ t φ
   @[simp, truth_simp] theorem top_true                 : TruthAt M τ t Formula.top
   @[simp, truth_simp] theorem and_iff  (φ ψ : Formula) : TruthAt M τ t (φ.and ψ) ↔ (TruthAt M τ t φ ∧ TruthAt M τ t ψ)
   @[simp, truth_simp] theorem or_iff   (φ ψ : Formula) : TruthAt M τ t (φ.or ψ)  ↔ (TruthAt M τ t φ ∨ TruthAt M τ t ψ)
   @[simp, truth_simp] theorem diamond_iff (φ : Formula): TruthAt M τ t φ.diamond ↔ ∃ σ, σ.IsTotal ∧ TruthAt M σ t φ
   @[simp, truth_simp] theorem always_iff  (φ : Formula): TruthAt M τ t φ.always  ↔ …
   @[simp, truth_simp] theorem kPlus_iff / kMinus_iff
   ```
   Exact mirrors of `BLTruth.lean:137-196`, which are already proved and can be transcribed.
   Deletes: 4 × `and_of_not_imp_not`, 3 × `truth_and_iff`, `CoValidity.always_elim`.
   Highest leverage in the territory; do it first.

2. **`abbrev TaskFrame.IsDense` + `structure TaskFrame.IsSuccArchDiscrete` + a `sat_intro` tactic**
   — *discharges A-04, enables A-05, A-07, A-13.*
   Home: `FormalSystem/Semantics/FrameProperty.lean:71,118` (definitions);
   `FormalSystem/Semantics/FrameClassValidity.lean` (tactic, beside `Sat`).
   ```lean
   abbrev TaskFrame.IsDense (F : TaskFrame) : Prop := DenselyOrdered F.Duration
   structure TaskFrame.IsSuccArchDiscrete (F : TaskFrame) : Prop where
     [succ : SuccOrder F.Duration] [pred : PredOrder F.Duration]
     [succArch : IsSuccArchimedean F.Duration] [predArch : IsPredArchimedean F.Duration]
   macro "sat_intro " h:ident : tactic => …   -- destructure `fc.Sat F` into the instance cache
   ```
   Retires **45** of the 47 binder-shape adapters across `Validity.lean`, `BLValidity.lean`,
   `StrongCompleteness.lean`, `SetConsequence.lean`.

3. **`validity_intro` tactic** — *discharges A-13's boilerplate half.*
   Home: `FormalSystem/Semantics/Validity.lean`, beside the generic adapters.
   ```lean
   macro "validity_intro" : tactic =>
     `(tactic| (refine ValidIn.of_forall_total ?_; intro F hF M τ hτ t; sat_intro hF))
   ```
   Every base-class validity lemma in `Soundness.lean` opens `validity_intro` instead of a
   three-line preamble. ~90 lines, and one place to change when the binder shape moves.
   Follows the tree's existing macro convention (`Automation/Normalization.lean:178`).

4. **Order-dual cores for the discrete axioms** — *discharges A-06, and A-12's `snce` half.*
   Home: a new `FormalSystem/Metalogic/SoundnessLemmas/DiscreteOrder.lean`, beside
   `Separability.lean` whose `sep_order`/`sep_order_mirror` pair is the model.
   ```lean
   theorem exists_nearest_succ {D} [LinearOrder D] [SuccOrder D] [IsSuccArchimedean D]
       (P : D → Prop) {t s : D} (hts : t < s) (hs : P s) :
       ∃ u, t < u ∧ P u ∧ ∀ r, t < r → r < u → ¬ P r
   theorem forall_gt_of_succ_step {D} [LinearOrder D] [SuccOrder D] [IsSuccArchimedean D]
       (P : D → Prop) (t : D) (hstep : ∀ u, t < u → (∀ r, u < r → P r) → P u)
       {s₀ : D} (hts₀ : t < s₀) (hs₀ : ∀ r, s₀ < r → P r) : ∀ s, t < s → P s
   ```
   `prior_SZ_is_valid` and `z1_past_is_valid` become `Dᵒᵈ` instantiations (~15 lines each,
   down from ~90 combined). Also states the actual mathematics: these are two facts about
   successor-Archimedean linear orders, not four about temporal logic.

5. **`blValidIn_iff_validIn_tr`, the one BL transfer theorem** — *discharges A-07's lemma layer.*
   Home: `FormalSystem/Metalogic/BaseLanguageSoundness.lean`, replacing `blValid_iff_valid_tr`
   (`:147`) and `blValidDiscrete_iff_validDiscrete_tr` (`:167`) as their generalization.
   ```lean
   theorem blValidIn_iff_validIn_tr (fc : FrameClass) (φ : BLFormula) :
       BLValidIn fc φ ↔ ValidIn fc (tr φ)
   ```
   `BLValidIn.mono`, `BLValidOnFrames.mono`, the three `blValid_implies_*` and
   `blValid_iff_empty_consequence` become corollaries rather than re-proofs; the two existing
   `_iff_valid_tr` theorems become its instances. Keeps `BLTruthAt` native (the native `example`s
   at `BaseLanguageSoundness.lean:489-503` are untouched).

6. **`semantic_deduction_in`** — *discharges A-05.*
   Home: `FormalSystem/Metalogic/StrongCompleteness.lean`, replacing the four copies.
   ```lean
   theorem semantic_deduction_in {fc : FrameClass} (Γ : Context) (φ : Formula) :
       SemanticConsequenceIn fc Γ φ ↔ ValidIn fc (Γ.foldr Formula.imp φ)
   ```
   Four 10-line proofs → one 6-line proof and four one-line instances.

7. **`truthAt_atomFree_history_indep` + `truthAt_gap_shift`** — *discharges A-17.*
   Home: `FormalSystem/Semantics/Truth.lean`, beside `box_const` (`:733`).
   Collapses the four uniformity-axiom proofs (`Soundness.lean:825-912`, ~60 lines of repeated
   `calc` arithmetic) and `discrete_box_necessity_valid` into short applications, and states the
   reason those axioms are valid rather than re-deriving it four times.

8. **`DerivationTree.ofWeakeningNil`** — *discharges A-14.*
   Home: `FormalSystem/ProofSystem/Derivation.lean`, with a BL twin in
   `FormalSystem/BaseLanguage/Derivation.lean`.
   ```lean
   def DerivationTree.ofWeakeningNil {fc Γ' φ} (d : DerivationTree fc Γ' φ) (h : Γ' ⊆ []) :
       DerivationTree fc [] φ
   theorem DerivationTree.ofWeakeningNil_height_lt … -- the `decreasing_by` fact, proved once
   ```
   Removes the duplicated `h_eq`/`h_height_eq`/`h_term` scaffold from
   `Soundness.lean:1422-1429` and `BaseLanguageSoundness.lean:382-393`.

---

## 5. Metrics

**Size and shape**

| File | Lines | Decls | Notes |
|---|---:|---:|---|
| `Metalogic/Soundness.lean` | 1,741 | 62 | ~47 base validity lemmas + the indexed family |
| `Metalogic/SoundnessLemmas/DenseValidity.lean` | 1,296 | 39 | **615 lines (47%) unreachable** |
| `Semantics/Validity.lean` | 1,015 | 60 | 21 of 60 are binder adapters; ~40% prose |
| `Semantics/Truth.lean` | 752 | 18 | 1 proof is 236 lines (31% of the file) |
| `Metalogic/SoundnessLemmas/FrameClassVariants.lean` | 591 | 5 | 348-line dispatcher + 4 discrete lemmas |
| `Metalogic/BaseLanguageSoundness.lean` | 506 | 20 | incl. 3 `example` spot checks |
| `Metalogic/SoundnessLemmas/Separability.lean` | 352 | 7 | best-engineered file in the territory |
| `Semantics/BLValidity.lean` | 352 | 24 | ~all mirrors of `Validity.lean` |
| `Semantics/BLTruth.lean` | 199 | 14 | 8 `@[simp]` — the model for A-03 |
| `Semantics/BLSchemaValidity.lean` | 155 | 5 | 3 cite an ephemeral `specs/` report |
| `Semantics/FrameClassValidity.lean` | 140 | 2 | ~100 lines prose / 2 declarations |
| `Metalogic/SoundnessLemmas/CoValidity.lean` | 141 | 3 | private `and_of_not_imp_not` copy #2 |
| `Metalogic/SoundnessLemmas/Core.lean` | 107 | 3 | 2 of 3 declarations dead |
| `Metalogic/SoundnessLemmas.lean` | 34 | 0 | aggregator; **omits `Separability`** |
| **Total** | **7,381** | **~290** | |

**Longest declarations** (proof body, docstrings excluded)

| Lines | Declaration | Why long |
|---:|---|---|
| 416 | `DenseValidity.lean:297` `axiom_swap_valid` | 45 arms; **43 unreachable** (A-02) |
| 348 | `FrameClassVariants.lean:46` `axiom_swap_valid_general` | 45 arms; 321 lines shared with the above |
| 298 | `DenseValidity.lean:970` `axiom_locally_valid` | 45 arms; **entirely dead** (A-01) |
| 236 | `Truth.lean:450` `time_shift_preserves_truth` | 4 near-identical shift-arithmetic blocks (A-12) |
| 82 | `Separability.lean:176` `nested_core` | genuine: Baire-style nested-interval construction |
| 70 | `Soundness.lean:1366` `derivable_valid_and_swap_validIn` | 7 constructors × 2 (valid + swap) (A-14) |
| ~60 | `FrameClassVariants.lean:479` `z1_is_valid` | strong induction on `n₀ - k` (A-06) |
| ~55 | `Truth.lean:379` `truth_double_shift_cancel` | 6 constructor arms, 4 identical (A-12) |
| ~55 | `Soundness.lean:1217` `sep_swap_valid` | genuine; correctly reuses `sep_order_mirror` |
| ~54 | `BaseLanguageSoundness.lean:348` `bl_derivable_valid_and_swap_valid_discreteSucc` | 7 constructors; scaffold duplicated from `Soundness.lean` (A-14) |
| ~49 | `FrameClassVariants.lean:541` `z1_past_is_valid` | hand-mirror of `z1_is_valid` (A-06) |
| ~47 | `Soundness.lean:1277` `axiom_validIn_min` | 45 one-line arms — the *good* dispatcher |
| ~46 | `Soundness.lean:1150` `sep_valid` | genuine; Reynolds §7 |
| ~40 each | `FrameClassVariants.lean:400,440` `prior_UZ/SZ_is_valid` | order duals of each other (A-06) |
| ~38, ~36 | `Soundness.lean:752,715` `linear_since/until_valid` | negation-encoding gymnastics (A-03) |

**`@[simp]` coverage**

| Namespace | Tagged | Total | Tagged | Untagged |
|---|---:|---:|---|---|
| `Semantics.Truth` (`Truth.lean`) | 6 | 13 | derived *tense* ops: `some_future_iff` `:249`, `some_past_iff` `:266`, `future_iff` `:283`, `past_iff` `:301`, `strong_release_iff`, `strong_trigger_iff` | primitives `bot_false`/`imp_iff`/`box_iff`/atom ×2; `box_const`/`box_time_const`; **all derived Booleans missing entirely** |
| `Semantics.BLTruth` (`BLTruth.lean`) | 8 | 13 | derived *Booleans + existentials*: `neg_iff`, `top_true`, `and_iff`, `or_iff`, `diamond_iff`, `somePast_iff`, `someFuture_iff`, `always_iff` | primitives `bot_false`/`imp_iff`/`box_iff`/`past_iff`/`future_iff` |

The two namespaces tag **disjoint halves** of the same conceptual set. There is no `truth_simp`
attribute, no simp set, and no tactic in the semantics layer, though the project ships six macros
elsewhere (`Automation/Normalization.lean`, `Automation/Tactics/Helpers.lean`,
`WeakCanonical/EFGameTactics.lean`).

**Boilerplate counts across the 13 territory files**

| Pattern | Count |
|---|---:|
| `simp only [… TruthAt …]` | 222 |
| `intro F M τ …` | 182 |
| `by_contra` | 85 |
| `refine valid.of_forall_total ?_` | 47 |
| `intro F M τ _h_mem t` (immediately after the above) | 40 |
| `simp only [… Formula.and \| Formula.or …]` | 30 |
| `rcases lt_trichotomy` | 29 |
| `Classical.byContradiction` | 18 |
| `@[simp]` | 19 |
| `unfold` | 5 |

**Duplication measurements**

- `axiom_swap_valid` vs `axiom_swap_valid_general`: **321 identical lines** (`comm -12` on sorted
  bodies), 159 differing (`diff`).
- Binder-shape adapters (`.of_forall` / `.apply` / `.of_not` / `.of_forall_total` /
  `.apply_total`): **47** across `Validity.lean` (21), `BLValidity.lean` (12),
  `StrongCompleteness.lean` (6), `SetConsequence.lean` (8).
- `and_of_not_imp_not` (identical statement, 3 distinct proofs): **4** copies.
- `truth_and_iff` (identical statement): **3** copies, two with docstrings justifying the copy.
- `exists_isGLB_of_lub`: **2** copies, one with a docstring justifying the copy.
- Dead declarations (occurrence count 1 in the whole tree): **26**, totalling **~654 lines**
  (615 in `DenseValidity.lean`, ~39 in `Core.lean`).
- Declared-but-unconsumed public API: **11** further declarations.

**Verification hygiene** — no `sorry` occurs anywhere in the territory; `Metalogic.lean`'s
axiom-profile ledger (`propext`, `Classical.choice`, `Quot.sound` only) is consistent with the
proofs read. No correctness defect was found: every finding above is maintainability, ergonomics,
or documentation. `lake build` was not run (already verified green by the orchestrator).
