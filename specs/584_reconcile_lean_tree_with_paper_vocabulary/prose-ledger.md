# Prose site ledger: TD -> TR, rule-sense "temporal duality" -> "time reflection"

Scope: every bare `TD` and `temporal[ -]dualit*` hit outside specs/, .lake, .git, .claude, agent-system, Boneyard and the record.

Totals: 215 hit lines; 187 renamed (rule sense); 28 kept.

## `FormalSystem/Automation/ContrastiveGeneratorMain.lean`
- L16: rule — renamed — `operator weakening, subformula deletion, depth reduction, temporal duality) and`
- L82: rule — renamed — `/-- Apply temporal duality via reflectTime. -/`
- L511: rule — renamed — `8. Temporal duality: if the formula contains temporal operators`
- L648: rule — renamed — `For invalid formulas: tries temporal duality (reflectTime) to find`
- L662: rule — renamed — `-- For invalid formulas, try temporal duality`

## `FormalSystem/Automation/DataExport.lean`
- L305: rule — renamed — `/-- Number of temporal duality applications. -/`

## `FormalSystem/Automation/DatasetGeneratorMain.lean`
- L23: rule — renamed — `- 'AugmentationInfo': Tracks whether a record was produced via temporal duality`

## `FormalSystem/Automation/FormulaEnumerator.lean`
- L991: KEEP — lemma (swap preserves validity) — `Note: Temporal duality preserves validity, so valid formulas produce valid duals.`

## `FormalSystem/Automation/ForwardProofGenerator.lean`
- L19: rule — renamed — `(modus ponens, necessitation, temporal necessitation, temporal duality) to`
- L293: rule — renamed — `/-- Apply temporal duality to every formula in the pool. -/`

## `FormalSystem/Automation/ProofSearch/Core.lean`
- L1053: rule — renamed — `- boxToPast: '□φ → Hφ' -- boxToFuture + temporal duality`

## `FormalSystem/Metalogic.lean`
- L60: rule — renamed — `('plus_soundness_validIn'), TD discharged semantically by the companion recursion with the`

## `FormalSystem/Metalogic/Algebraic/FlowFrame.lean`
- L603: rule — renamed — `/-- Past analog of TF axiom: '□φ → H(□φ)', derived via temporal duality. -/`

## `FormalSystem/Metalogic/Algebraic/InteriorOperators.lean`
- L77: rule — renamed — `Uses 'pastMono' from Perpetuity (derived via temporal duality).`

## `FormalSystem/Metalogic/Algebraic/LindenbaumQuotient.lean`
- L175: rule — renamed — `This uses 'pastMono' from Perpetuity which derives it via temporal duality.`
- L313: rule — renamed — `## Temporal Duality (sigma)`
- L315: rule — renamed — `We lift the 'reflectTime' operation to the quotient, establishing temporal duality`
- L341: rule — renamed — `Lifted temporal duality (sigma) on the Lindenbaum algebra.`
- L344: rule — renamed — `implementing the temporal duality principle.`

## `FormalSystem/Metalogic/Bundle/README.md`
- L41: rule — renamed — `## Temporal Duality Discipline`

## `FormalSystem/Metalogic/Bundle/TemporalCoherence.lean`
- L38: rule — renamed — `3. By temporal duality: F(neg phi) in fam.mcs t`
- L57: rule — renamed — `## Temporal Duality Infrastructure`
- L155: rule — renamed — `3. By temporal duality: F(neg phi) in fam.mcs t`

## `FormalSystem/Metalogic/Conservativity.lean`
- L165: rule — renamed — `'Semantics.truth_swap' discharging the temporal-duality rule). The countermodel is the disjoint`

## `FormalSystem/Metalogic/Conservativity/Backward.lean`
- L64: rule — renamed — `- 'time_reflection' — the load-bearing case. TM⁻'s **TD** concludes '⊢ swapMinus φ' while L's`

## `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean`
- L420: rule — renamed — `(and its swap) proof-theoretically, by composing 'minus_soundness_valid' with the 'TD' rule itself`
- L439: rule — renamed — `composed with the 'TD' proof rule — from the three that are not, without enumerating the twelve`

## `FormalSystem/Metalogic/Conservativity/Plus.lean`
- L30: rule — renamed — `| 'Conservativity/Plus/PlusSoundness.lean' | 'plus_derivable_valid_and_swap_validIn', 'plus_soundness_validIn', 'plus_soundness_in', the fou`

## `FormalSystem/Metalogic/Conservativity/Plus/Atomization.lean`
- L31: rule — renamed — `'atomize_reflectTime' (atomization commutes with temporal duality up to swapping the encoding,`
- L80: rule — renamed — `/-- The encoding conjugated by temporal duality on the '⊡'-formula side: 'e.swap.ι (inr χ) =`
- L124: rule — renamed — `/-- Atomization commutes with temporal duality, up to conjugating the encoding: the fresh atom`

## `FormalSystem/Metalogic/Conservativity/Plus/PlusSoundness.lean`
- L20: rule — renamed — `**TD is discharged semantically, never proof-theoretically.** Mapping derivations to mirrored`
- L22: rule — renamed — `future halves and obtains the past halves by TD); the companion recursion needs only`

## `FormalSystem/Metalogic/Conservativity/Plus/README.md`
- L43: rule — renamed — `- 'plus_soundness_validIn' — soundness of TM⁺ at every frame class, with TD discharged`

## `FormalSystem/Metalogic/Conservativity/Star.lean`
- L27: rule — renamed — `| 'Conservativity/Star/StarSoundness.lean' | 'star_derivable_valid_and_swap_validIn', 'star_soundness_validIn', the four rows, 'star_not_der`

## `FormalSystem/Metalogic/Conservativity/Star/README.md`
- L42: rule — renamed — `- 'star_soundness_validIn' — soundness of TM⋆ at every frame class, TD discharged semantically.`

## `FormalSystem/Metalogic/Conservativity/Star/StarSoundness.lean`
- L32: rule — renamed — `substitution-closed ('PlusAxiom.atom_stab'), and TD is discharged semantically through`
- L54: rule — renamed — `soundness · star-language · store-recall · temporal-duality`

## `FormalSystem/Metalogic/Core/DeductionTheorem.lean`
- L39: rule — renamed — `- Modal/temporal K rules and temporal duality do not apply with non-empty contexts`
- L315: rule — renamed — `- Temporal duality: Cannot occur (requires empty context)`

## `FormalSystem/Metalogic/Core/MCSProperties.lean`
- L281: rule — renamed — `Derived by applying temporal duality to the temp_4 axiom (Gφ → GGφ).`
- L285: rule — renamed — `-- By temporal duality from: Gψ → GGψ where ψ = reflectTime φ`
- L291: rule — renamed — `-- Step 2: Apply temporal duality to get: H(swap ψ) → HH(swap ψ)`

## `FormalSystem/Metalogic/Deterministic/Collapse.lean`
- L92: rule — renamed — `the system — the past half of every temporal principle is obtained by temporal duality, exactly as`
- L257: rule — renamed — `'Gφ''s derivation gives 'Hφ''s by temporal duality — which is already inside the axioms here, so`

## `FormalSystem/Metalogic/Deterministic/Erasure.lean`
- L26: rule — renamed — `- 'erasePlus_reflectTime' — erasure commutes with temporal duality ('⊡' is fixed by it)`
- L86: rule — renamed — `/-- Erasure commutes with temporal duality: 'reflectTime' fixes '⊡' on the L⁺ side and the six`

## `FormalSystem/Metalogic/Deterministic/Soundness.lean`
- L30: rule — renamed — `'time_reflection' case exchanges the two components. TD is discharged **semantically**, never by`

## `FormalSystem/Metalogic/Deterministic/System.lean`
- L123: rule — renamed — `/-- Temporal duality: from '⊢ φ', conclude '⊢ reflectTime φ'. Theorems only. -/`

## `FormalSystem/Metalogic/Independence/CoNotPriorU.lean`
- L490: rule — renamed — `/-- Temporal duality. -/`
- L519: rule — renamed — `whole 'CO' schema, modus ponens, modal and temporal necessitation, and temporal duality. Unlike`

## `FormalSystem/Metalogic/Independence/NaiveSystem.lean`
- L130: rule — renamed — `/-- Temporal duality in the naive system. -/`

## `FormalSystem/Metalogic/Soundness.lean`
- L67: rule — renamed — `separate 'Axiom' constructor — it is reached by temporal duality, so its validity rides on`
- L71: KEEP — lemma (temporal duality soundness) — `- Derivation-indexed induction for temporal duality soundness`

## `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean`
- L30: KEEP — lemma (temporal-duality soundness) — `Validity of swapped axioms, which is what lets temporal-duality soundness run by derivation`

## `FormalSystem/Metalogic/WeakCanonical/Separation/README.md`
- L17: rule — renamed — `| 'Duality.lean' | 342 | Temporal duality (G/H, F/P, U/S) in the separation context |`

## `FormalSystem/ProofSystem/Axioms.lean`
- L408: rule — renamed — `-- temporal necessitation, and temporal duality) are both sorry-free. The witness is the`

## `FormalSystem/ProofSystem/Derivable.lean`
- L171: rule — renamed — `Temporal duality: If '|-![fc] p' then '|-![fc] reflectTime p' (Prop-valued).`

## `FormalSystem/ProofSystem/Derivation.lean`
- L58: rule — renamed — `- Temporal duality only applies to theorems (empty context)`
- L149: rule — renamed — `Temporal duality rule: Swapping past and future in theorems.`
- L322: rule — renamed — `Temporal duality increases height by exactly 1.`

## `FormalSystem/ProofSystem/LinearityDerivedFacts.lean`
- L57: rule — renamed — `## Past Linearity via Temporal Duality`
- L61: rule — renamed — `is derivable from 'temp_linearity' via the temporal duality rule (reflectTime).`

## `FormalSystem/README.md`
- L123: rule — renamed — `- **Temporal Duality**: From '⊢ φ', derive '⊢ swap(φ)' (swap H/G, P/F)`

## `FormalSystem/Semantics/MinusLanguage/MinusFrame.lean`
- L65: rule — renamed — `## Converse closure and TD`
- L69: rule — renamed — `'truth_swap' is what discharges the temporal-duality *rule* 'DerivationTree.time_reflection' in`
- L123: rule — renamed — `('MinusFrame.swap'); that closure discharges the temporal-duality rule.`
- L167: rule — renamed — `temporal-duality rule sound on the class, via 'truth_swap'.`
- L296: rule — renamed — `one lemma is what makes the temporal-duality rule sound on the native class, replacing the`

## `FormalSystem/Semantics/PlusLanguage/PlusPasting.lean`
- L32: rule — renamed — `together with the two **past mirrors** that temporal duality needs ('reflectTime' exchanges`
- L41: rule — renamed — `mirrors are derived (the mirrors by TD). The purity restrictions are **necessary**: the`

## `FormalSystem/Semantics/Truth.lean`
- L131: KEEP — lemma (temporal-duality bridge theorems) — `The bridge theorems connecting the proof system to semantics — the temporal-duality`

## `FormalSystem/Syntax/Formula.lean`
- L23: rule — renamed — `- 'Formula.reflectTime': Temporal duality transformation`
- L602: rule — renamed — `This transformation is used in the temporal duality inference rule (TD),`
- L621: rule — renamed — `This is essential for the temporal duality rule to be well-behaved.`

## `FormalSystem/Syntax/MinusLanguage/Axioms.lean`
- L15: rule — renamed — `and the rules MP, MN, TD. This module carries the **axiom** half of that list; MP, MN and TD are`
- L72: rule — renamed — `| 'TD' | 'MinusLanguage.DerivationTree.time_reflection' | Rule. |`
- L146: rule — renamed — `* JPL paper '\S sub:Logic' — the TM axiomatization (MP/MN/MK/MT/M5/MF/TD/TK/T4/TS/TC/TL) that TM⁻ transposes`
- L162: rule — renamed — `MP, MN and TD are **rules**, not axioms; they are constructors of`

## `FormalSystem/Syntax/MinusLanguage/Derivation.lean`
- L24: rule — renamed — `6. 'time_reflection' — **TD**, empty context only, via **'swapMinus'**`
- L27: rule — renamed — `**TD uses 'swapMinus', not 'reflectTime'.** 'reflectTime' acts on L's 'untl'/'snce'; the L⁻`
- L33: rule — renamed — `rule** — its rules are exactly MP, MN and TD. Including 'temporal_necessitation' here therefore`
- L54: rule — renamed — `* JPL paper '\S sub:Logic' — the rules MP, MN, TD that TM⁻ inherits`
- L85: rule — renamed — `/-- **TD**: from '⊢ φ', conclude '⊢ φ⟨P|F⟩', i.e. '⊢ swapMinus φ'. Theorems only. -/`
- L169: rule — renamed — `TM⁻'s rule set is MP, MN, TD. 'temporal_necessitation' is carried as an eighth-slot primitive`

## `FormalSystem/Syntax/MinusLanguage/Formula.lean`
- L31: rule — renamed — `- 'MinusFormula.swapMinus': the past/future interchange used by TM⁻'s **TD** rule`
- L137: rule — renamed — `This is the L⁻-side analogue of 'Formula.reflectTime' and is what TM⁻'s **TD** rule`
- L157: rule — renamed — `'Formula.reflect_time_some_future', and friends. They are '@[simp]' so that the TD case of`

## `FormalSystem/Syntax/MinusLanguage/Translation.lean`
- L27: rule — renamed — `which the TD case of 'FormalSystem.Metalogic.Conservativity.translate' does not typecheck`
- L133: rule — renamed — `/-! ### The commutation lemma for TM⁻'s TD rule -/`
- L139: rule — renamed — `TM⁻'s **TD** rule concludes '⊢ swapMinus φ' from '⊢ φ'; L's 'DerivationTree.time_reflection'`
- L140: rule — renamed — `concludes '⊢ reflectTime ψ' from '⊢ ψ'. Without this equation the TD case of`

## `FormalSystem/Syntax/PlusLanguage/Axioms.lean`
- L53: rule — renamed — `SS '(α⁺ S ⟐φ⁻) → ⟐(α⁺ S φ⁻)') are obtained by the temporal-duality rule, since 'reflectTime'`

## `FormalSystem/Syntax/PlusLanguage/Derivation.lean`
- L88: rule — renamed — `/-- Temporal duality: from '⊢ φ', conclude '⊢ reflectTime φ'. Theorems only. -/`

## `FormalSystem/Syntax/PlusLanguage/Formula.lean`
- L51: rule — renamed — `- 'PlusFormula.reflectTime': the past/future interchange for the TD rule ('stab ↦ stab')`
- L199: rule — renamed — `/-! ### Temporal duality -/`
- L413: rule — renamed — `/-- 'ofFormula' commutes with temporal duality, which is what the 'time_reflection' case of the`

## `FormalSystem/Syntax/PlusLanguage/Substitution.lean`
- L127: rule — renamed — `**Substitution and temporal duality commute after shifting the substitution.**`

## `FormalSystem/Syntax/StarLanguage/Derivation.lean`
- L97: rule — renamed — `/-- Temporal duality: from '⊢ φ', conclude '⊢ reflectTime φ'. Theorems only. -/`

## `FormalSystem/Syntax/StarLanguage/Formula.lean`
- L46: rule — renamed — `- 'StarFormula.reflectTime': the past/future interchange for the TD rule`
- L216: rule — renamed — `/-! ### Temporal duality`
- L373: rule — renamed — `/-- 'ofPlus' commutes with temporal duality — the pin the 'time_reflection' case of the`

## `FormalSystem/Theorems/DedekindDerived.lean`
- L357: rule — renamed — `'Theorems.pastNecessitation' — temporal duality.`
- L370: rule — renamed — `modal and temporal necessitation, and temporal duality`

## `FormalSystem/Theorems/GeneralizedNecessitation.lean`
- L33: rule — renamed — `- 'pastNecessitation': If '⊢ φ', then '⊢ Hφ' (derived via temporal duality)`
- L34: rule — renamed — `- 'pastKDist': '⊢ H(A → B) → (HA → HB)' (derived via temporal duality)`
- L89: rule — renamed — `This is derived via temporal duality:`
- L107: rule — renamed — `Past K distribution axiom (derived via temporal duality).`
- L111: rule — renamed — `This is the past analog of 'temp_k_dist', derived by applying temporal duality`
- L120: rule — renamed — `-- Apply temporal duality`

## `FormalSystem/Theorems/Perpetuity.lean`
- L41: KEEP — operator duality — `- 'bridge1': '¬□△φ → ◇▽¬φ' (modal/temporal duality)`

## `FormalSystem/Theorems/Perpetuity/Helpers.lean`
- L48: rule — renamed — `- □φ → Hφ (past): via temporal duality on MF`
- L72: rule — renamed — `Proof via temporal duality:`
- L75: rule — renamed — `3. By temporal duality: '⊢ swap(□(swap φ) → G(swap φ))'`
- L78: rule — renamed — `This clever use of temporal duality avoids needing a separate "modal-past" axiom.`

## `FormalSystem/Theorems/Perpetuity/MonotonicityDuality.lean`
- L14: KEEP — operator duality — `This module contains bridge lemmas connecting modal and temporal duality,`
- L25: KEEP — operator duality — `- 'temporalDualityNeg': '▽¬φ → ¬△φ' (temporal duality forward)`
- L26: KEEP — operator duality — `- 'temporalDualityNegRev': '¬△φ → ▽¬φ' (temporal duality reverse)`
- L61: KEEP — operator duality — `## Modal and Temporal Duality Lemmas`
- L168: rule — renamed — `Derived via temporal duality from future monotonicity.`
- L309: KEEP — operator duality — `Temporal duality (forward): '▽¬φ → ¬△φ'.`
- L407: KEEP — operator duality — `Temporal duality (reverse): '¬△φ → ▽¬φ'.`
- L496: KEEP — operator duality — `Connects negated box-always to diamond-sometimes-neg using modal and temporal duality.`
- L594: rule — renamed — `- Past component: temporal duality + past K distribution`
- L614: rule — renamed — `- 'boxToPast': '⊢ □φ → Hφ' (temporal duality on MF)`
- L616: rule — renamed — `- 'boxToBoxPast': '⊢ □φ → □Hφ' (temporal duality on MF)`
- L623: rule — renamed — `- 'boxDiamondToPastBoxDiamond': Temporal duality for '□◇φ'`
- L628: rule — renamed — `- 'pastMono': Past monotonicity '⊢ (A → B) → (HA → HB)' (via temporal duality on futureMono)`
- L653: KEEP — operator duality — `3. Document modal-temporal duality relationships more precisely`

## `FormalSystem/Theorems/Perpetuity/Principles.lean`
- L70: rule — renamed — `1. '□φ → Hφ' (past): via temporal duality on MF (see 'boxToPast')`
- L333: rule — renamed — `Derived via temporal duality on MF, analogous to 'boxToPast'.`
- L435: rule — renamed — `1. '□φ → □Hφ' (via temporal duality on MF, see 'boxToBoxPast')`
- L580: rule — renamed — `Helper lemma: Apply temporal duality to get past component.`
- L582: rule — renamed — `From TF on '□◇φ', derive 'H□◇φ' via temporal duality.`
- L590: rule — renamed — `-- Apply temporal duality`
- L657: rule — renamed — `This is the past analog of future K distribution, derived via temporal duality.`
- L662: rule — renamed — `**Derivation**: This follows from 'futureKDist' applied with temporal duality.`
- L670: rule — renamed — `-- Apply temporal duality`
- L687: rule — renamed — `3. TF under 'time_reflection' (TD): '□◇φ → H□◇φ'`
- L703: rule — renamed — `-- Then apply TF and TD to □◇φ to get temporal components`
- L711: rule — renamed — `-- We can derive: □◇φ → H□◇φ from TD (temporal duality on TF)`
- L717: rule — renamed — `-- Apply temporal duality`
- L802: rule — renamed — `- Past component: temporal duality + past K distribution`

## `FormalSystem/Theorems/Perpetuity/README.md`
- L39: KEEP — operator duality — `- Modal/temporal duality: 'modalDualityNeg', 'modalDualityNegRev', 'temporalDualityNeg',`

## `FormalSystem/Theorems/TemporalDerived.lean`
- L42: KEEP — operator duality (F/G, P/H via double negation) — `### Category C: Temporal Duality and Contraposition (4: 2 computable, 2 noncomputable)`
- L265: rule — renamed — `'⊢ H(φ → ψ) → (H(φ) → H(ψ))': H-distribution. Derived via temporal duality from G-distribution.`
- L280: rule — renamed — `'⊢ H(φ) → H(H(φ))': H-transitivity. Derived via temporal duality from G-transitivity.`
- L285: rule — renamed — `-- Derive by applying temporal duality to G-transitivity of reflectTime φ`
- L514: KEEP — operator duality (F/G, P/H via double negation) — `## Category C3-C4: Temporal Duality Lemmas (2 computable theorems)`

## `README.md`
- L175: KEEP — other: mermaid `graph TD` — `graph TD`
- L256: rule — renamed — `| Soundness | 'minus_soundness_*' (TM⁻) | 'plus_soundness_validIn' (TM⁺), TD discharged semantically |`

## `Tests/BimodalTest/Integration/COVERAGE.md`
- L23: KEEP — lemma (temporal duality soundness) — `| Temporal duality soundness | ✓ | TemporalIntegrationTest.lean | Tests 12-13 |`

## `Tests/BimodalTest/Integration/ProofSystemSemanticsTest.lean`
- L25: KEEP — lemma (temporal duality soundness) — `6. Temporal duality soundness (swap preservation)`
- L265: KEEP — lemma (temporal duality is sound) — `Test 21: Temporal duality is sound.`

## `Tests/BimodalTest/Integration/TemporalIntegrationTest.lean`
- L26: rule — renamed — `6. Temporal duality integration`
- L37: rule — renamed — `- Temporal duality`
- L386: rule — renamed — `-- Temporal Duality Integration`
- L392: rule — renamed — `Test 12: Temporal duality rule.`
- L403: rule — renamed — `-- Apply temporal duality`
- L414: rule — renamed — `Test 13: Temporal duality with complex formula.`
- L416: rule — renamed — `Apply temporal duality to formula with mixed operators.`
- L425: rule — renamed — `-- Apply temporal duality`

## `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean`
- L202: rule — renamed — `/-- Temporal duality on Modal-Future -/`
- L225: KEEP — other: benchmark output label string — `let r3 ← runBenchmark "Temporal duality" (fun _ => mkTimeReflection)`

## `Tests/BimodalTest/ProofSystem/DerivationTest.lean`
- L24: rule — renamed — `- Temporal duality rule`
- L159: rule — renamed — `-- Temporal Duality Rule Tests`
- L162: rule — renamed — `-- Test: Temporal duality on Modal T`
- L166: rule — renamed — `-- Test: Temporal duality swaps allPast/allFuture`

## `Tests/BimodalTest/Syntax/FormulaTest.lean`
- L22: rule — renamed — `- Temporal duality (reflectTime)`

## `Tests/BimodalTest/Syntax/LanguageDerivationTest.lean`
- L96: rule — renamed — `/-- Temporal duality applies to a register formula: the dual of forward rigidity is backward`

## `Tests/BimodalTest/Theorems/PerpetuityTest.lean`
- L288: KEEP — operator duality (modal/temporal duality lemmas) — `## Modal and Temporal Duality Lemma Tests`

## `docs/development/CONTRIBUTING.md`
- L166: KEEP — other: example branch name — `- 'feature/temporal-duality-tactic'`

## `docs/development/DIRECTORY_README_STANDARD.md`
- L430: rule — renamed — `- **Rules.lean**: Inference rules (MP, MK, TK, TD)`

## `docs/development/METAPROGRAMMING_GUIDE.md`
- L30: rule — renamed — `MF, TF) and inference rules (MP, MK, TK, TD)`

## `docs/project-info/performance-targets.md`
- L48: KEEP — other: benchmark output label — `| Temporal duality | ~150ns | 1 | 2x time |`
- L60: KEEP — other: benchmark output label — `'Temporal duality' is now applied to the Modal-Future axiom. The file is not imported by the`

## `docs/reference/API_REFERENCE.md`
- L81: rule — renamed — `Swap temporal operators (past ↔ future) in a formula. Used in the temporal duality inference rule (TD).`

## `docs/reference/axiom-reference.md`
- L234: KEEP — operator duality (triangle defined via untl) — `('FormalSystem/Theorems/Perpetuity/') are derived from it, not postulated. Temporal duality`

## `docs/user-guide/architecture.md`
- L53: rule — renamed — `-- Temporal duality: swap allPast and allFuture operators`
- L201: rule — renamed — `(h : DerivationTree [] φ) : DerivationTree [] (reflectTime φ)               -- TD: If '⊢ φ' then '⊢ φ_{⟨H|G⟩}'`
- L1273: rule — renamed — `-- Example: Derive P1 (□φ → always φ) using MF, MT, TD`
- L1286: rule — renamed — `-- Step 4: By TD, get □φ → Hφ`
- L1288: rule — renamed — `sorry -- Apply temporal duality to h3`

## `docs/user-guide/examples.md`
- L279: rule — renamed — `-- Requires proving from MF, TF, MT, and temporal duality`
- L335: rule — renamed — `-- 4. By TD (temporal duality), '□P → Past P'`
- L423: rule — renamed — `### Temporal Duality Example`
- L426: rule — renamed — `/-- Temporal duality: swapping allPast and allFuture preserves provability -/`
- L433: rule — renamed — `-- By TD applied to T4`

## `docs/user-guide/tactic-development.md`
- L536: rule — renamed — `sorry  -- Prove using temporal duality and T4`
- L552: rule — renamed — `sorry  -- Prove using temporal duality of MF/TF`

## `docs/user-guide/troubleshooting.md`
- L186: rule — renamed — `**Error**: Temporal duality requires empty context.`

## `latex/subfiles/01-Syntax.tex`
- L95: rule — renamed — `\subsection{Temporal Duality}`

## `latex/subfiles/03-ProofTheory.tex`
- L134: rule — renamed — `\begin{definition}[Temporal Duality]`
- L157: rule — renamed — `Temporal Duality & \texttt{DerivationTree.temporal\_duality} & Empty only \\`

## `latex/subfiles/04-Metalogic.tex`
- L25: KEEP — lemma (swap preserves validity) — `\item \textbf{Temporal duality}: Past-future swap preserves validity`

## `typst/FormalFoundations.typ`
- L464: rule — renamed — `+ *TD*: if $tack.r phi.alt$ then $tack.r phi.alt_(chevron.l "S"|"U" chevron.r)$.`
- L484: rule — renamed — `derived from the future/until direction by TD, not separately postulated -- only the`
- L486: rule — renamed — `though $square.stroked$ is only interpreted once S5 is fused with BX below.#footnote[Seventeen named keys: two rules (TN, TD), three seriali`
- L546: rule — renamed — `Only the future/until direction of Prior-U is stated; its past/since direction follows by TD.`
- L586: rule — renamed — `+ *TD*: if $tack.r phi.alt$ then $tack.r phi.alt_(chevron.l "P"|"F" chevron.r)$, where`
- L595: rule — renamed — `MP and MN are rules; MK, MT, M5, MF, TK, T4, TB, TA, and TL are axiom schemata; TD is a rule`
- L1038: rule — renamed — `eleven primary Since/Until axioms and derives their past mirrors by the rule TD, while the`
- L1039: rule — renamed — `development has no TD rule and states all twenty-two explicitly, one pair per paper axiom --- but`
- L1220: rule — renamed — `classes are varieties. The rule TD becomes closure of the class under the signature automorphism`

## `typst/chapters/01-syntax.typ`
- L145: rule — renamed — `== Temporal Duality`

## `typst/chapters/03-proof-theory.typ`
- L23: rule — renamed — `Past mirrors (primed rows) are the temporal-duality images of their future counterparts and carry no separate short name.`
- L156: rule — renamed — `caption: ['discrete_symm_bwd' is the converse of NP, obtainable via temporal duality, and carries no separate short name.],`
- L223: rule — renamed — `caption: [Only the future/until direction of Prior-U is axiomatic; its past mirror 'prior_S_gap' is the temporal-duality image. These axioms`
- L301: rule — renamed — `#definition("Temporal Duality")[`
- L328: rule — renamed — `[Temporal Duality], ['DerivationTree.time_reflection'], [Empty only],`
- L360: rule — renamed — `There is also a *tense-primitive subsystem*: the logic of the one-place $H$/$G$ sublanguage (@sec:formulas), presentable economically as the`
- L369: rule — renamed — `- *Past mirrors are primed constructors*: past duals are generable by the TD rule alone, but the primed mirror constructors (BX1$'$--BX13$'$`

## `typst/chapters/04-metalogic.typ`
- L38: KEEP — lemma (swap preserves validity) — `- *Temporal duality*: Past-future swap preserves validity`

## `typst/chapters/05-theorems.typ`
- L44: rule — renamed — `P1--P6 then follow from TF (and its past mirror, via temporal duality) together with classical propositional reasoning and the standard moda`

## `typst/chapters/06-notes.typ`
- L51: rule — renamed — `[TD], ['DerivationTree.time_reflection'], [Inference rule],`
