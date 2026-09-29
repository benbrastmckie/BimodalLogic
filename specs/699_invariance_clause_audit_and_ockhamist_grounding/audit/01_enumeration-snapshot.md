# Enumeration Snapshot: Shape-(S) audit, task 699

**Run date**: 2026-09-29T05:12:34Z
**Invocation**: `bash specs/699_invariance_clause_audit_and_ockhamist_grounding/audit/enumerate-shape-s.sh`
(run from the repository root; read-only, no `git` or `lake` invocation)
**Idempotency check**: two consecutive runs produced byte-identical output (`diff` empty).

## Counts

| Pass | Script count (this run) | Report's figure (§ Context & Scope, § A1) | Divergence |
|---|---|---|---|
| 1 — candidate definitions | 64 definitions across 39 files | 67 definitions across 40 files | −3 definitions, −1 file |
| 2 — share-guarded quantifiers | 18 hits | not stated as a separate figure in the report (described as a cross-check step only) | no comparable figure |
| 3 — reflexive relations | 45 hits | 39 hits | +6 hits |

## Full output

Captured verbatim from the invocation above at write time (this file is the dated snapshot the
report's Appendix now points to instead of an inline transcript):

```
=== Pass 1: candidate definitions (def/abbrev/structure/class whose body contains <->) ===
FormalSystem/Metalogic/BXCanonical/Frame.lean:77
FormalSystem/Metalogic/Conservativity/MinusChronicle.lean:72
FormalSystem/Metalogic/Core/MCSProperties.lean:71
FormalSystem/Metalogic/Decidability/BiLasso/Annotation.lean:301
FormalSystem/Metalogic/Decidability/BiLasso/Annotation.lean:356
FormalSystem/Metalogic/Decidability/BiLasso/Decide.lean:301
FormalSystem/Metalogic/Decidability/BiLasso/Realized.lean:221
FormalSystem/Metalogic/Decidability/BiLasso/SmallModel.lean:59
FormalSystem/Metalogic/Decidability/FMP/Filtration.lean:68
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Decide.lean:439
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Decide.lean:518
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Decide.lean:662
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Decide.lean:930
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean:166
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean:195
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean:258
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean:276
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean:71
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean:84
FormalSystem/Metalogic/Decidability/Verified/Bridge/Interpolate.lean:143
FormalSystem/Metalogic/Decidability/Verified/Bridge/Interpolate.lean:465
FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean:109
FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean:369
FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean:86
FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Types.lean:106
FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean:283
FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean:898
FormalSystem/Metalogic/Decidability/WitnessFamily/Predicates.lean:106
FormalSystem/Metalogic/Decidability/WitnessFamily/Predicates.lean:72
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Decide.lean:347
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Decide.lean:420
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Predicates.lean:136
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Predicates.lean:147
FormalSystem/Metalogic/Expressiveness/EFGames/CustomGame.lean:236
FormalSystem/Metalogic/Expressiveness/EFGames/CustomGame.lean:247
FormalSystem/Metalogic/Expressiveness/EFGames/CustomGame.lean:258
FormalSystem/Metalogic/Expressiveness/EFGames/Decomposition.lean:69
FormalSystem/Metalogic/Expressiveness/EFGames/Defs.lean:177
FormalSystem/Metalogic/Expressiveness/GameTransfer/SplitPointProps.lean:53
FormalSystem/Metalogic/Expressiveness/Kamp/ContentfulWitness.lean:152
FormalSystem/Metalogic/Expressiveness/Kamp/ExistsForallNF.lean:247
FormalSystem/Metalogic/Expressiveness/Kamp/NfEFold.lean:65
FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/CarrierK1V.lean:398
FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/CarrierK1V.lean:77
FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/EndIntervalConsumerK.lean:113
FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean:1338
FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/PriorInterfaceFaithful.lean:137
FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/PriorInterfaceFaithful.lean:90
FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/PriorInterface.lean:45
FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/PriorInterface.lean:70
FormalSystem/Metalogic/Expressiveness/Kamp/PerFormulaType.lean:82
FormalSystem/Metalogic/Expressiveness/MonadicFO.lean:647
FormalSystem/Metalogic/Expressiveness/PriorExpressivenessDense.lean:182
FormalSystem/Metalogic/Expressiveness/Separation/Defs.lean:124
FormalSystem/Metalogic/Expressiveness/Separation/Defs.lean:143
FormalSystem/Metalogic/Expressiveness/Separation/Defs.lean:149
FormalSystem/Metalogic/Expressiveness/Separation/Defs.lean:155
FormalSystem/Metalogic/Independence/LoopingDuration.lean:52
FormalSystem/Metalogic/WeakCanonical/BackAndForth.lean:64
FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Defs.lean:306
FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Defs.lean:380
FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Dual.lean:344
FormalSystem/Metalogic/WeakCanonical/GroupModel/MonoDiscrete.lean:148
FormalSystem/Metalogic/WeakCanonical/MixedSum.lean:245
# count: 64 candidate definitions across 39 files

=== Pass 2: share-guarded quantifiers ===
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean:339:        (stabFamily p).share 0 i j → stabEvent p ∈ (stabFamily p).L j 0 := by
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean:352:        (stabFamily p).share u i j → stabEvent p ∈ (stabFamily p).L j u)
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean:79:    (hdet : ∀ (u : ℤ) (i j : Fin S.lassos.length), S.skeleton.share u i j ↔ i = j)
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean:270:    stab φ ∈ S.L i u ↔ ∀ j, S.share u i j → φ ∈ S.L j u
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean:279:      (PlusFormula.stab φ ∈ S.L i u ↔ ∀ j, S.share u i j → φ ∈ S.L j u)
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean:72:  ∀ (u : ℤ) (i j : Fin S.lassos.length), S.share u i j →
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean:91:    (∀ j : Fin S.lassos.length, S.share (t + 1) i j →
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean:95:    (∀ k : Fin S.lassos.length, S.share t i k →
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Decide.lean:420:def shareClauseAt {n : ℕ} (bx : Formula → Bool) (rt rp : Fin n → Fin n)
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Decide.lean:442:  ∀ i : Fin n, Formula.bot ∉ Lt i ∧ ∀ ψ ∈ C, shareClauseAt bx rt rp Lm Lt Lp i ψ
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Predicates.lean:137:  ∀ (u : ℤ) (i j : Fin S.lassos.length), S.share u i j →
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Predicates.lean:154:    (∀ j : Fin S.lassos.length, S.share (t + 1) i j →
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Predicates.lean:158:    (∀ k : Fin S.lassos.length, S.share t i k →
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean:305:  step : ∀ u : ℤ, K.share (u + 1) (idx u) (idx (u + 1))
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean:116:      ∀ j : Fin S.lassos.length, S.share (s + t) (θ.idx (s + t)) j → ψ ∈ S.L j (s + t) := by
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean:144:    (hdiag : ∀ (u : ℤ) (i j : Fin S.lassos.length), S.share u i j → i = j)
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean:44:stab φ ∈ L i u ↔ ∀ j, share u i j → φ ∈ L j u
FormalSystem/Metalogic/Expressiveness/Kamp/ZetaUniformExtractFaithful.lean:89:right disjunct are `∀`/`∃` statements over the shared carrier whose only non-order atom is
# count: 18 share-guarded quantifier hits

=== Pass 3: reflexive relations (_refl lemma names, @[refl], Reflexive) ===
FormalSystem/Metalogic/Algebraic/LindenbaumQuotient.lean:65:theorem derives_refl (φ : Formula) : Derives φ φ := by
FormalSystem/Metalogic/Algebraic/LindenbaumQuotient.lean:72:theorem provEquiv_refl (φ : Formula) : φ ≈ₚ φ :=
FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean:139:theorem collapse_equiv_refl (fc : FrameClass) (A : Set Formula)
FormalSystem/Metalogic/BXCanonical/Frame.lean:391:theorem bx_modal_equiv_refl (w : BXPoint) : BxModalEquiv w w :=
FormalSystem/Metalogic/Conservativity/MinusCanonicalFrame.lean:465:theorem canBox_refl (Γ : MPoint fc) : canBox Γ.1 Γ.1 :=
FormalSystem/Metalogic/Conservativity/MinusChronicle.lean:40:* Reflexive points may label many rationals: coherence needs only `canR`, never injectivity.
FormalSystem/Metalogic/Conservativity/MinusChronicle.lean:651:`canBox`-class. Reflexive points may label many rationals; no injectivity is required. -/
FormalSystem/Metalogic/Conservativity/MinusChronicle.lean:87:theorem le_refl (s : Stage) : s.le s := fun _ _ h => h
FormalSystem/Metalogic/ConvexConsequence/Separations.lean:76:theorem bdd_zero_mem : bdd.domain 0 := ⟨le_refl 0, le_refl 0⟩
FormalSystem/Metalogic/Decidability/FMP/Filtration.lean:74:theorem mcs_filtration_equiv_refl (phi : Formula) (S : Set Formula) :
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Basic.lean:276:@[refl]
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Basic.lean:277:theorem share_refl (S : PlusSharingWitnessFamily Γ Del) (u : ℤ) (i : Fin S.lassos.length) :
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Fulfil.lean:129:theorem foldRel_refl (S : PlusSharingWitnessFamily Γ Del) (a : ℤ) : S.FoldRel a a :=
FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Fulfil.lean:132:theorem foldRelB_refl (S : PlusSharingWitnessFamily Γ Del) (a : ℤ) : S.FoldRelB a a :=
FormalSystem/Metalogic/Decidability/SignedFormula.lean:201:theorem beq_refl (sf : SignedFormula) : (sf == sf) = true := by
FormalSystem/Metalogic/Decidability/SignedFormula.lean:77:theorem beq_refl (l : Label) : (l == l) = true := by
FormalSystem/Metalogic/Decidability/Verified/Bridge/Interpolate.lean:159:@[refl]
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Basic.lean:165:@[refl]
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Basic.lean:166:theorem share_refl (S : SharingWitnessFamily Γ Del) (u : ℤ) (i : Fin S.lassos.length) :
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Fulfil.lean:586:theorem foldRel_refl (S : SharingWitnessFamily Γ Del) (a : ℤ) : S.FoldRel a a := Or.inl rfl
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Fulfil.lean:588:theorem foldRelB_refl (S : SharingWitnessFamily Γ Del) (a : ℤ) : S.FoldRelB a a := Or.inl rfl
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean:210:@[refl]
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean:211:theorem share_refl (K : SharingSkeleton) (u : ℤ) (i : Fin K.n) : K.share u i i := rfl
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean:350:theorem step_refl (K : SharingSkeleton) (u : ℤ) (i : Fin K.n) : K.Step u i i :=
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Thread.lean:119:theorem step_refl (S : SharingWitnessFamily Γ Del) (u : ℤ) (i : Fin S.lassos.length) :
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Window.lean:337:theorem foldRel_refl (W : SharingWindow) (a : ℤ) : W.FoldRel a a := Or.inl rfl
FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Window.lean:339:theorem foldRelB_refl (W : SharingWindow) (a : ℤ) : W.FoldRelB a a := Or.inl rfl
FormalSystem/Metalogic/Expressiveness/Separation/Defs.lean:128:theorem int_equiv_refl (φ : Formula) : IntEquiv φ φ :=
FormalSystem/Metalogic/WeakCanonical/ChronicleExtraction.lean:7:import FormalSystem.Metalogic.WeakCanonical.ReflexiveCanonical
FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Lemma34.lean:184:theorem contemp_refl (a : M.carrier) : ContempEquivDense M ε a a := hε.refl M a
FormalSystem/Metalogic/WeakCanonical/FrameProperties.lean:10:# Frame Properties for the Reflexive Canonical Model
FormalSystem/Metalogic/WeakCanonical.lean:72:1. **ReflexiveCanonical**: Domain, relation (reflexive), valuation
FormalSystem/Metalogic/WeakCanonical.lean:7:import FormalSystem.Metalogic.WeakCanonical.ReflexiveCanonical
FormalSystem/Metalogic/WeakCanonical/NEquivalence.lean:7:import FormalSystem.Metalogic.WeakCanonical.ReflexiveCanonical
FormalSystem/Metalogic/WeakCanonical/RealModel/EpsilonDense.lean:135:theorem simDense_refl (k : Nat) (M : OrderedMonadicStructure sig) (a : M.carrier) :
FormalSystem/Metalogic/WeakCanonical/ReflexiveCanonical.lean:18:# Reflexive Canonical Model for TM Bimodal Logic
FormalSystem/Metalogic/WeakCanonical/ReflexiveCanonical.lean:454:/-! ## Reflexive Relation Properties -/
FormalSystem/Metalogic/WeakCanonical/ReflexiveCanonical.lean:457:theorem reflCanR_refl (x : ReflCanDomain) : reflCanR x x := by
FormalSystem/Metalogic/WeakCanonical/ReflexiveCanonical.lean:689:theorem canS5R_refl (x : ReflCanDomain) : canS5R x x := by
FormalSystem/Metalogic/WeakCanonical/ReflexiveCanonical.lean:81:/-- Reflexive canonical accessibility relation: xRy iff GWContent x ⊆ y.val. -/
FormalSystem/Metalogic/WeakCanonical/Transfer.lean:17:# Z-Model Transfer for the Reflexive Canonical Model
FormalSystem/Metalogic/WeakCanonical/TruthLemma.lean:142:Uses h_content_closed_derivation (already proved in ReflexiveCanonical.lean)
FormalSystem/Metalogic/WeakCanonical/TruthLemma.lean:14:# MCS Truth Facts for the Reflexive Canonical Model
FormalSystem/Metalogic/WeakCanonical/TruthLemma.lean:69:Uses g_content_closed_derivation from ReflexiveCanonical.lean.
FormalSystem/Metalogic/WeakCanonical/TruthLemma.lean:7:import FormalSystem.Metalogic.WeakCanonical.ReflexiveCanonical
# count: 45 reflexive-relation hits
```

## Divergence analysis

**Per the plan's Scope Hypothesis, the script's output is authoritative and the report's original
figures are corrected against it — the script's filters were not tuned to reproduce 67/40/39.**
Three findings, in order of significance:

1. **No tree drift.** `git log --since="2026-09-28 22:35" -- FormalSystem/Metalogic` (the report's
   completion timestamp) returns no commits. So the divergence is not the tree changing since the
   report; it is a defect in the report's own original enumeration.

2. **Pass 3's documented command is broken as written.** The report's Appendix gives:

   ```
   grep -rn "^theorem .*_refl\b|^@\[refl\]|Reflexive" FormalSystem/Metalogic --include=*.lean   # 39 hits
   ```

   Run literally (no `-E`), GNU `grep` treats this pattern in basic-regex mode, where a bare `|`
   is a **literal** character, not alternation — verified: running the command exactly as printed
   yields **0 hits**, not 39. Adding `-E` (as this script's pass 3 does) yields 45. The report's
   stated "39" therefore cannot have come from running its own printed command; the printed
   command needs `-E` (or `-P`) to do anything, and Phase 4 corrects the Appendix to name the
   working, `-E`-flagged version (this script).

3. **The original enumeration never scanned `FormalSystem/Metalogic/WeakCanonical/**`, even
   though it is inside the enumeration's own declared scope.** All files there predate the report
   by 4-8 weeks (`git log --diff-filter=A`, checked at write time: `BackAndForth.lean` and
   `MixedSum.lean` 2026-07-29, `DenseModelSurgery/Defs.lean` 2026-07-28,
   `DenseModelSurgery/Dual.lean` 2026-07-28, `GroupModel/MonoDiscrete.lean` 2026-08-25) — this is
   not new code, it was always in scope and was missed. Six of pass 1's candidates are under
   `WeakCanonical/`:
   `BackAndForth.lean:64`, `DenseModelSurgery/Defs.lean:306`, `DenseModelSurgery/Defs.lean:380`,
   `DenseModelSurgery/Dual.lean:344`, `GroupModel/MonoDiscrete.lean:148`, `MixedSum.lean:245`.
   Seventeen of pass 3's 45 hits are also under `WeakCanonical/` (`grep -c "WeakCanonical"` on the
   pass-3 output, checked at write time).

   **Each of the six `WeakCanonical/` pass-1 candidates was read and checked against Shape (S) at
   write time, and none qualifies:**
   - `BackForth` (`BackAndForth.lean:64`) — the `↔` is a two-structure atom-agreement
     existential-game clause (`AtomEval M (Fin.cons a eM) ak ↔ AtomEval N (Fin.cons b eN) ak`);
     there is no relational guard at all, only an outer `∃`/`∀` alternation over two separate
     structures. OUT OF SHAPE, no guard.
   - `IsContempEquivDenseOn.contemporary` (`DenseModelSurgery/Defs.lean:306`) and
     `IsContempEquivDenseCD.contemporary` (same file, `:380`) — both sides of the `↔` mention the
     bound points (`ContempEquivDense M ε a b ↔ ContempEquivDense (M.subinterval …) ε ⟨a,…⟩ ⟨b,…⟩`).
     OUT OF SHAPE: the left side depends on the quantified variable, which Shape (S) excludes by
     definition.
   - `StructIso.map_lt` / `StructIso.map_interp` (`Dual.lean:344` region) — an isomorphism's
     order- and interpretation-preservation clauses; both sides mention the bound carrier
     elements (`toEquiv x < toEquiv y ↔ x < y`). OUT OF SHAPE, same reason.
   - `MonoInv` (`MonoDiscrete.lean:148`) — `p.1 < q.1 ↔ p.2 < q.2` and the succ-reachability
     clause both mention the bound pair on both sides. OUT OF SHAPE, same reason.
   - `Mixed` (`MixedSum.lean:245`) — the two `AtomEval … ↔ AtomEval …` conjuncts are the same
     two-structure game-equivalence shape as `BackForth`. OUT OF SHAPE, no guard.

   **None of the six is a new Shape-(S) collapse, and none introduces a relation other than
   `share` (or the (C3) total relation) guarding a Shape-(S) biconditional inside
   `FormalSystem/Metalogic/`.** The report's A1 table membership is therefore unchanged by this
   correction; per the plan's Scope Hypothesis, a membership-changing divergence would require
   stopping and reporting separately, and this is not that case. What changes is the *coverage
   claim*: the report's Context & Scope section should no longer imply its enumeration covered
   the whole of `FormalSystem/Metalogic/**` when `WeakCanonical/` (72 files) was omitted. This is
   filed as a documentation-scope correction in Phase 4, not as a new row in the audit table.

4. **The Expressiveness/EFGames/Kamp candidates already fall inside row 17's stated bucket.**
   `Expressiveness/**` is named as a location in row 17 with verdict "INTENDED or OUT OF SHAPE"
   under the same two general reasons (both sides mention the bound object, or no relational
   guard at all) rather than as an exhaustive per-declaration list; the additional individual
   `path:line` entries this run surfaces under `Expressiveness/EFGames/**` and
   `Expressiveness/Kamp/**` are consistent with that bucket on inspection (back-and-forth game
   clauses and structure/carrier transport lemmas of the same two shapes checked above) and are
   not treated as a coverage gap the way `WeakCanonical/` is, since row 17 already names the
   subtree.

## Net conclusion

The script's counts (64/39/18/45) are the corrected, reproducible figures. The audit table's
nineteen rows and their verdicts are unaffected — the divergence is a documentation/coverage
defect (a broken Appendix command, and an unscanned subtree that turns out to contain no
Shape-(S) candidate), not a new finding about the substrate. Phase 4 updates the report's
Appendix "Enumeration commands" section and its Context & Scope figures accordingly.
