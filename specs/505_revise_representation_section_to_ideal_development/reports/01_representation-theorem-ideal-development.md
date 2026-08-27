# Research Report: The Representation Theorem for TM⁺ as It Should Be Developed

- **Task**: 505 - Revise representation section to ideal development
- **Started**: 2026-08-27T00:05:00Z
- **Completed**: 2026-08-27T00:50:00Z
- **Effort**: 3 hours
- **Dependencies**: None (the sibling algebraic-representation tasks 125, 497-502 are affected by this report but do not block it; see Findings §4)
- **Sources/Inputs**:
  - Document: `typst/FormalFoundations.typ` — §1 (lines 142-599), §2 (600-753), §3 (754-1021), §4 (1022-1152), §5 `<sec:representation>` (1153-1581), preamble (1-141)
  - Lean, semantics: `FormalSystem/Semantics/ShiftSet.lean` (structure `ShiftSet`, `frame`, `forward_repr`, `reverse_repr`, `sep_not_derivable`)
  - Lean, algebraic layer: `FormalSystem/Metalogic/Algebraic/README.md`, `LindenbaumQuotient.lean` (`boxQuot`, `hQuot`, `sigmaQuot`), `InteriorOperators.lean` (`boxInterior`, `H_monotone`), `UltrafilterMCS.lean` (`ultrafilter_correspondence`), `FlowFrame.lean` (`multiFamTaskFrameGen`, `WorldState := FamIdx × D`, `multiFamGen_spherical`)
  - Lean, completeness: `Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (C0-C5'), `Metalogic/SetConsequence.lean` (`StrongCompletenessBase`, `CompactBase`, `ModelExistenceBase`), `Metalogic/DiscreteNonCompactness.lean`
  - Lean, archived seed: `FormalSystem/Boneyard/UltrafilterFrame/TenseS5Algebra.lean` (class `STSA`)
  - Syntax: `FormalSystem/Syntax/Formula.lean` (`someFuture`, `allFuture`, `somePast`, `allPast` derived from `untl`/`snce`)
  - Prior research: `specs/503_revise_representation_section_with_literature/reports/01_representation-literature-research.md` (§5.2-5.3), task descriptions 125, 492-502 in `specs/TODO.md`
  - Bibliography: `typst/bibliography.bib` (keys present: `jonssontarski1951/1952`, `blackburnderijkevenema2001`, `venema2007algebrascoalgebras`, `gehrkevosmaer2011`, `burgess1982axioms`, `xu1988until`, `reynolds1992`, `stone1936`, `goldblatt1992logics`, `fine1975elementarymodal`, `goldblatt2003ghv`)
- **Artifacts**: this report
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Executive Summary

- The representation theorem for TM⁺ should be stated as follows: **every TM⁺-algebra embeds, point-completely, into a product of complex algebras of shift-set flows, one factor per □-component, the temporal order of each component being discrete or dense according to the algebra's discreteness element `N1`.** "Point-completely" means every ultrafilter of the algebra is the theory of some point. A □-simple algebra embeds into the complex algebra of a *single* flow. Every complex algebra of a task frame is a TM⁺-algebra (algebraic soundness), so the class of representable algebras is exactly the class of TM⁺-algebras.
- The failure of the T-axioms for the strict G and H is **immaterial**. The representation uses only that G, H are normal multiplicative operators that are transitive, serial, weakly linear, and tense-conjugate to F, P. Irreflexivity is neither expressible nor needed: strictness lives in the order on the duration sort D, not in a relation on the point set. Interior operators should not appear in the section at all; □ is an S5 (monadic) operator and G, H are K4-type tense operators.
- Strict Since/Until as primitives are **accommodated, and they pay**: U and S are additive only in the event argument, so they are not Jónsson–Tarski operators and get no relation on the ultrafilter frame; their content is carried by the order on D in the representing flow. In return, the discreteness element `n = N1 = ⊥ U ⊤` is central (NB says `n ≤ □n`), so every □-simple TM⁺-algebra is homogeneously discrete (`n = 1`) or dense (`n = 0`), which is what lets the representing flow be built over a single temporal order per component. This is the algebraic form of the Case Split of §3.
- **Spherical is not an obstruction** to the theorem so stated. The representing frames are the frames induced by shift sets: deterministic, so every fiber and segment is a singleton or empty and Spherical is discharged outright (the third pattern of §3, `multiFamGen_spherical`; `ShiftSet.frame`). Where Spherical's work reappears is in the direct chronicle construction, as the Step Lemma for chronicles, and there it is discharged by compactness of the Stone space of ultrafilters — a theorem, not a frame axiom.
- The proof architecture is: algebraic soundness; the Lindenbaum algebra as the free algebra; the ultrafilter frame and the Jónsson–Tarski embedding of the (□, F, P)-reduct; the component decomposition through the congruences `θ_U`; model existence per component from weak completeness plus compactness (Łoś over the elementary class of shift sets); one flow per component by saturation; and the factorization `h = π⁻¹ ∘ η_JT` with `π` surjective. Every ingredient is either machine-checked, planned in the Lean tree (the shift-set ultraproduct chain), or standard model theory.
- Per class: point-complete representation holds for the base and dense classes; for TM⁺_f the representing temporal orders are ℤ-groups (models of Th(ℤ,+,<)) and for TM⁺_c divisible ordered abelian groups (models of Th(ℝ,+,<)), never ℤ or ℝ themselves, by the two non-compactness witnesses. What survives over ℤ-flows and ℝ-flows is the SP-representation of the Lindenbaum algebra, which is weak completeness restated. The section should say all of this positively and nothing else: the four-way distinction, the ladder, the descriptive-frame duality, the Sahlqvist table, the two Routes, the gate, and the Obstruction subsection all go.

## Context & Scope

**What is being specified.** The content of a rewritten `<sec:representation>` in `typst/FormalFoundations.typ`: the theorem as it ought to be stated and proved for the logic TM⁺ of the language BL⁺ over task-frame semantics, with strict Since and Until primitive and G, H derived. The report fixes the objects, the theorem statement, the proof architecture, the per-class refinements, the section outline, the cut list, the cross-reference edits, and the style rules. It does not itself edit the document.

**Fixed inputs, not up for revision here.** The language and semantics of §1 (strict U/S, guard-first; task frames with the four axioms; possible worlds as total histories; □ ranging over all of `H_F` at a time). The proof systems of §1. The results of §2-§3 (soundness; the three weak completeness theorems; the Dichotomy and Case Split; the bundled-family truth lemma; the three Spherical discharge patterns). The shift-set representation of task models in `ShiftSet.lean`.

**Out of scope.** Topological duality (recovering the algebra from its dual space); decidability; the BL-level system TM, which is incomplete over task frames and therefore has no representation theorem of this kind (one sentence in the section suffices); the disjoint-union question of §4 except insofar as the component decomposition answers it.

**The three questions the user posed, answered in Findings §1.** Whether the failure of T for G, H is an issue; whether strict primitives can be accommodated; which stray material must go.

## Findings

### 1. The three questions

**1.1 The T-axioms for G and H.** Not an issue, and the interior-operator framing is the wrong frame. Jónsson and Tarski's theorem, in its modern statement (@blackburnderijkevenema2001 Thm 5.43), applies to Boolean algebras with *normal additive operators*; the dual box-type operators need only be normal and multiplicative (`G1 = 1`, `G(a ∧ b) = Ga ∧ Gb`). Reflexivity (`Ga ≤ a`), idempotence, and the fixed-point description are the S4/closure-algebra special case and play no role for tense operators, which are K-type by default and have never satisfied T in the tense-logic tradition (Kt, K4t, the tense algebras of the Jónsson–Tarski conjugate-pair theory). What the representation actually uses of G and H is:

| Property | Equation | Source axiom |
|---|---|---|
| normal, multiplicative | `G1 = 1`, `G(a∧b) = Ga ∧ Gb` | TN, TK (derivable from UC, UG in BX) |
| transitive | `Ga ≤ GGa` | T4 (derivable in BX) |
| serial | `F1 = 1` | TB |
| weakly linear | `Fa ∧ Fb ≤ F(a∧b) ∨ F(a∧Fb) ∨ F(Fa∧b)` | TL |
| tense-conjugate | `a ≤ GPa`, `a ≤ HFa` | TA and mirror |
| □-interaction | `□a ≤ □Ga`, `□a ≤ □Ha` | MF and mirror |

Nothing in that list mentions T, and irreflexivity — which the strict semantics might seem to demand of `R_G` — is not modally definable and is not needed: on the representing flow, strictness is the strict order on D, and a periodic history (`sh(w, d) = w` for some `d > 0`) makes `R_G` reflexive at `w` on the point set without disturbing any truth clause. The document should therefore state, once and positively, that G and H are transitive, serial, weakly linear, tense-conjugate normal operators, and never mention interior operators. Even for □ the right description is "an S5 operator" (Halmos's monadic algebras): `□1 = 1`, `□(a∧b) = □a∧□b`, `□a ≤ a`, `¬□a ≤ □¬□a`. `InteriorOperators.lean`'s `boxInterior` remains a true fact about □ but is not the representation's hypothesis.

**1.2 Strict Since and Until as primitives.** Accommodated, in the following precise way. On the complex algebra of a shift set, `X U Y = {w : ∃d > 0, sh(w,d) ∈ Y ∧ ∀e (0 < e < d → sh(w,e) ∈ X)}`. This is normal and additive in the *event* argument `Y` and only monotone in the *guard* argument `X`: `(X ∩ X') U Y ⊊ (X U Y) ∩ (X' U Y)` in general, because the two witnesses need not coincide. So U and S are not operators in the Jónsson–Tarski sense, and the ultrafilter frame of a TM⁺-algebra carries no relation for them. This is exactly right: the *relational* skeleton of the representation is the (□, F, P)-reduct, which is a genuine BAO, and the content of U and S is carried by the *order on D* in the representing flow, where the clause above is literally the definition. The truth lemma for U and S at a point of a chronicle is Burgess's (C0-C5', `ChronicleTypes.lean`), and in the model-existence proof it is the Łoś lemma's U-case. The section should say this in one definition and one remark: U and S are operations of the algebra and of every complex algebra; they are represented through the order on D, not through the ultrafilter frame.

The payoff of the strict primitives for the representation is the discreteness element. Put `n := N1 = ⊥ U ⊤` ("the present has an immediate successor"). NB reads `n ≤ □n`, and with T, `□n = n`: `n` is a □-fixed point, hence central in the sense below. In a □-simple algebra `n ∈ {0, 1}`, so every □-simple TM⁺-algebra is *homogeneously* discrete or dense, and its representing flow lives over a single discrete or single dense temporal order. Without the strict `N`, the base-language algebra has no such element, which is the algebraic shadow of TM's incompleteness (§3's remark on the BL-level schema).

**1.3 Spherical.** Not an obstruction, and the section's present Obstruction subsection rests on aiming at the wrong frame. The representing frame is not the ultrafilter frame `Uf(A)` made into a task frame with world states the ultrafilters and fibers `R_x[U]`; it is the frame induced by a shift set (`ShiftSet.frame`), whose task relation is functional (`u = sh(w, d)`). On such a frame every fiber is a singleton and every segment a singleton or empty, so a ⊇-directed family of nonempty ones is a family of copies of one singleton and Spherical holds outright (`ShiftSet.frame.spherical`; `multiFamGen_spherical` for the bundled family of §3). Compositionality, Seriality, and Nullity are likewise free; Limit is the shift set's `sep` axiom and is first-order. Spherical's *work* reappears in exactly one place — the Step Lemma of the direct chronicle construction (Findings §3.4) — and there it is discharged by compactness of the Stone space `Uf(A)`, because `R_F[U] = ⋂{η(a) : Ga ∈ U}` is closed. That is a theorem about ultrafilters, not an axiom about task frames, and it is the correct home of the compactness intuition the present §5 attaches to descriptive general frames.

### 2. The objects

**2.1 TM⁺-algebras.** A TM⁺-algebra is a Boolean algebra `(A, ∧, ∨, ¬, 0, 1)` with a unary operation □ and binary operations U, S, with the derived operations

`Fa := 1 U a`, `Ga := ¬F¬a`, `Pa := 1 S a`, `Ha := ¬P¬a`, `Na := 0 U a`, `△a := Ha ∧ a ∧ Ga`,

satisfying: the S5 equations for □ (above); `□a ≤ □Ga` and `□a ≤ □Ha` (MF and its mirror); and, for each schema of BX of §1 and its `⟨S|U⟩`-mirror, the inequality obtained by reading `φ → ψ` as `[φ] ≤ [ψ]`, together with `G1 = H1 = 1` (the rule TN and its mirror) and `□1 = 1` (MN). The rule TD becomes closure of the class under the signature automorphism swapping U with S — which holds because the defining set of inequalities is mirror-closed — and is not an operation of the algebra. The subclasses of TM⁺_d-, TM⁺_f-, TM⁺_c-algebras add DN and `n = 0`; UZ and Z1; Prior-U and Sep. All four classes are varieties.

Two design decisions follow. (i) The signature is `(□, U, S)`, matching `Formula` (`allFuture`, `allPast` are `def`s over `untl`/`snce`); G, H, F, P are derived, and the archived `STSA` seed's separate `G`, `H` fields are the derived operations, not primitives. (ii) `sigma` is not in the signature: the Lindenbaum algebra happens to carry the swap as an automorphism, `Cm(F)` for a flow F carries it only as an isomorphism `Cm(F) ≅ Cm(F^op)` with the time-reversed flow, and an abstract TM⁺-algebra need not carry it at all. `sigmaQuot` is a tool for deriving mirror theorems, not part of the representation.

**2.2 Complex algebras.** For a shift set `S = (Ω, D, sh, A)` (Findings §2.4), `Cm(S) := 𝒫(Ω)` with

- `□X := Ω` if `X = Ω`, else `∅` (□ is the universal modality on Ω);
- `X U Y := {w : ∃d > 0, sh(w,d) ∈ Y ∧ ∀e (0 < e < d → sh(w,e) ∈ X)}`, and `X S Y` the mirror with `d < 0`;

so that `FX = {w : ∃d>0, sh(w,d) ∈ X}`, `GX = {w : ∀d>0, sh(w,d) ∈ X}`, and `NX ≠ ∅` only when D has a least positive element. For a task frame F, `Cm(F) := Cm(ShiftSet.ofModel F) = 𝒫(H_F)` with `sh(τ, d) = τ(· + d)`; by `reverse_repr`, `M, τ, t ⊨ φ` iff `τ + t ∈ ‖φ‖` where `‖φ‖ := {τ : M, τ, 0 ⊨ φ}`, and `‖·‖` is a homomorphism from the Lindenbaum algebra to `Cm(F)` by the truth clauses. On a frame induced by a shift set, world states and possible worlds coincide (`H_{S.frame} ≅ Ω` via `τ ↦ τ(0)`, `total_eq_orbit`), so `Cm(S.frame) = 𝒫(W)` and every subset of Ω is the proposition of an atom under some valuation `|p| ⊆ W`. This removes the "proper subalgebra of `𝒫(H_F × D)`" concern of the current §5: on the representing class of frames the algebra of propositions is the full powerset of the world-state set.

**2.3 Algebraic soundness; the free algebra; weak completeness restated.**

- *Algebraic soundness.* `Cm(F)` is a TM⁺-algebra for every task frame F; a TM⁺_d-algebra when D is dense; a TM⁺_f-algebra when `D ≅ ℤ`; a TM⁺_c-algebra when `D ∈ {ℤ, ℝ}`. This is the Soundness theorem of §2 read equationally (`soundness_linear`, `soundness_dense`, `soundness_discrete`, `soundness_Int`). `Cm(S)` is □-simple for every shift set (□ takes only the values `∅`, `Ω`), and simplicity of the (□)-reduct implies simplicity of the full algebra.
- *The free algebra.* The Lindenbaum algebra `Fr(X)` on a set of atoms X is the free TM⁺-algebra on X (`LindenbaumAlg`, `BooleanStructure`); its ultrafilters are the maximal consistent sets (`ultrafilter_correspondence`). Every TM⁺-algebra A is a quotient `q : Fr(A) ↠ A`, `x_a ↦ a`.
- *Weak completeness restated.* For a class K of task frames, `Fr(ω) ∈ SP Cm(K)` iff TM⁺ is weakly complete over K: the map `φ ↦ (‖φ‖^M)_M`, over all models M on frames in K, is a homomorphism into `∏_M Cm(F_M)`, injective exactly when every non-theorem is refuted in some model. So `completeness_dense`, `completeness_discrete`, `completeness_dedekind_engine` are already representation theorems of SP-type for the three Lindenbaum algebras over the dense, ℤ-time, and ℝ classes. The point-complete theorem of §3 below is the strengthening in which every ultrafilter is realized at a point.

**2.4 Shift sets: the two-sorted first-order presentation.** A shift set is a structure for the two-sorted signature `(Ω, D; <, +, 0, sh, (A_p)_p)` with D a nontrivial ordered abelian group, `sh_zero`, `sh_add`, `sep` (Limit: `∀w u ((∀x>0 ∃y (|y| < x ∧ u = sh(w,y))) → u = w)`), and Ω nonempty (`ShiftSet`). Task models and shift sets are the same structures up to truth: `forward_repr` and `reverse_repr` are both proved. Shift-set truth is given by the standard translation `φ ↦ φ*(w, t)`: `p* := A_p(sh(w,t))`; `(□φ)* := ∀w' φ*(w', t)`; `(φ U ψ)* := ∃d > t (ψ*(w,d) ∧ ∀e (t < e < d → φ*(w,e)))`; each `φ*` is a first-order formula of the two-sorted language. Consequences:

- The class of all shift sets is elementary; so are the dense ones (add density of D) and the discrete ones (add "D has a least positive element"). Compactness for these classes is the Łoś theorem for ultraproducts of shift sets applied to the standard translation (the chain planned in the Lean tree under `strong_completeness`: ultraproduct carrier, Łoś, `CompactBase`, `CompactDense`).
- ℤ-time is not elementary: the models of `Th(ℤ, +, <)` (Presburger arithmetic) are the ℤ-groups, discrete ordered abelian groups with `D/nD ≅ ℤ/nℤ`, of which `ℤ ×_lex ℤ` is one. ℝ is not elementary: `Th(ℝ, +, <)` is the complete theory of nontrivial divisible ordered abelian groups (Robinson–Zakon), of which ℚ is a model. The two non-compactness witnesses (`discrete_consequence_not_compact`; Reynolds for ℝ) are the modal shadows of these two facts.

**2.5 The ultrafilter frame and the Jónsson–Tarski reduct.** For a TM⁺-algebra A, `Uf(A)` is its set of ultrafilters with `U R_□ V` iff `∀a (□a ∈ U → a ∈ V)`, `U R_F V` iff `∀a (Ga ∈ U → a ∈ V)` (equivalently `∀a (a ∈ V → Fa ∈ U)`), and `U R_P V` the mirror. From the equations of §2.1, verified directly (each is also the canonical correspondent of a Sahlqvist axiom):

- `R_□` is an equivalence relation (S5);
- `R_F` is transitive (T4), serial (TB), and weakly linear (TL): `U R_F V` and `U R_F V'` imply `V R_F V'` or `V = V'` or `V' R_F V`;
- `R_P = R_F⁻¹` (TA and mirror);
- `R_F ⊆ R_□` and `R_P ⊆ R_□` (MF: if `□a ∈ U` then `□Ga ∈ U`, so `Ga ∈ U`, so `a ∈ V` for any `V ∈ R_F[U]`); hence each `R_□`-class is closed under `R_F` and `R_P`.

No reflexivity or irreflexivity condition appears. The Jónsson–Tarski map `η(a) := {U : a ∈ U}` is an injective homomorphism from the `(□, F, P)`-reduct of A into the relational complex algebra of `(Uf(A), R_□, R_F, R_P)` (@jonssontarski1951; @blackburnderijkevenema2001 Thm 5.43). The `BooleanStructure`/`UltrafilterMCS` layer is this for the Lindenbaum algebra; the archived `UltrafilterFrame.lean` seed has the relations and most of the lemmas above. `Uf(A)` is not, and need not be, a task frame.

**2.6 Components.** For `U ∈ Uf(A)` put `F_U := {a : □a ∈ U}`. It is a filter (□ multiplicative), closed under □ (S5), under G and H (MF and mirror); the relation `a θ_U b` iff `(a ↔ b) ∈ F_U` is a congruence of the full signature — compatibility with U and S follows from UC and UG (`G(b ↔ b') ≤ ((a U b) ↔ (a U b'))`, `G(a ↔ a') ≤ ((a U b) ↔ (a' U b))`) composed with MF. Then:

- `A/θ_U` is □-simple: `□[a] ∈ {0, 1}`, since `□a θ_U 1` iff `□a ∈ U` and `□a θ_U 0` iff `¬□a ∈ U` (using `¬□a ≤ □¬□a`);
- `θ_U = θ_V` iff `U R_□ V`, and the ultrafilters of `A/θ_U` correspond to the `R_□`-class of U;
- `⋂_U θ_U` is the identity (`□(a ↔ b) ≤ (a ↔ b)`), so A is a subdirect product of its □-simple quotients, one per `R_□`-class;
- A is □-simple iff `R_□` is the universal relation on `Uf(A)`;
- `n = N1` is □-fixed (NB, T), so `n ∈ {0, 1}` in a □-simple algebra: `n = 1` iff `N1` lies in every ultrafilter (the discrete component), `n = 0` iff `¬N1` does (the dense component). This is the Case Split of §3 (`mcs_mixed_case_absurd`) stated for an arbitrary TM⁺-algebra, and the role of NB is exactly the centrality of `n`.

### 3. The theorem

**3.1 Statement.**

> **Theorem (Representation).** Let A be a TM⁺-algebra. For every `R_□`-class k of `Uf(A)` there is a shift set `S_k = (Ω_k, D_k, sh_k, A_k)` over a temporal order `D_k` — discrete if `n = 1` in `A/θ_k`, dense if `n = 0` — and a homomorphism `h_k : A → Cm(S_k)` such that:
> 1. `h := (h_k)_k : A → ∏_k Cm(S_k)` is injective, and each `h_k` induces an injective homomorphism `A/θ_k ↪ Cm(S_k)`;
> 2. (point-completeness) for every ultrafilter V in the class k there is `w ∈ Ω_k` with `{a : w ∈ h_k(a)} = V`; that is, `π_k : Ω_k → Uf(A)`, `w ↦ {a : w ∈ h_k(a)}`, maps onto k;
> 3. `S_k` induces a task frame (`S_k.frame`, a translation flow) and a task model in which `h_k(a)` is the proposition of a.
>
> If A is □-simple there is a single class, and `A ↪ Cm(S)` point-completely into the complex algebra of one flow. Conversely, every `Cm(S)` is a □-simple TM⁺-algebra.
>
> **Per class.** If A is a TM⁺_d-algebra, every `D_k` is dense (and may be taken divisible). If A is a TM⁺_f-algebra, every `D_k` is a ℤ-group, elementarily equivalent to ℤ. If A is a TM⁺_c-algebra, every `D_k` is a divisible ordered abelian group, elementarily equivalent to ℝ.

The theorem is sense (iii) of the current section's opening list — abstract algebra to task frame and back — with "and back" supplied by `reverse_repr`; the per-class clause is what the shift-set programme's first-order payoff actually is.

**3.2 Proof architecture.** Six steps; each names what it consumes.

1. *Components.* By §2.6, A is a subdirect product of the □-simple `A/θ_k`; it suffices to represent a □-simple algebra point-completely by one shift set, and then `h_k := (A ↠ A/θ_k ↪ Cm(S_k))`.
2. *Free presentation.* For □-simple A and an ultrafilter `U₀` of A, `q : Fr(A) ↠ A` and `M := q⁻¹(U₀)` is a maximal consistent set of the language with atom set `{x_a : a ∈ A}`.
3. *Model existence.* There is a task model, hence a shift set S, with a point `w₀ ∈ Ω` whose theory at time 0 is M. This is strong completeness for a language of arbitrary atom cardinality, obtained from weak completeness for the countable language (a finite subset of M mentions finitely many atoms, which may be renamed into the countable language) plus compactness over the relevant elementary class of shift sets (Łoś). For the dense class the finite subsets are realized over ℚ by `completeness_dense`; for ℤ-time over ℤ by `completeness_discrete`; over ℝ by `completeness_dedekind_engine`; over the base class by `completeness`. The ultraproduct's duration group is the ultraproduct of the finite-stage groups, which is where the per-class clause comes from: an ultrapower of ℤ is a ℤ-group, an ultrapower of ℚ or ℝ is a divisible ordered abelian group.
4. *Descent.* `h : Fr(A) → Cm(S)`, `φ ↦ ‖φ‖`, is a homomorphism; it factors through q, because `q(φ) = 1` gives `□△φ ∈ M`, so `φ` is true at every history at every time and `‖φ‖ = Ω`. The induced `h̄ : A → Cm(S)` realizes `U₀` at `w₀`.
5. *One flow per component.* Expand S by unary predicates `P_a := h̄(a)` for `a ∈ A`. The statements "h̄ is a homomorphism" are first-order sentences of the expanded two-sorted language (the clauses of §2.2 are first-order over Ω and D). Pass to an `|A|⁺`-saturated elementary extension `S'`: it is again a shift set of the same elementary class, `h̄' (a) := P_a^{S'}` is again a homomorphism, and for every ultrafilter V of A the type `{P_a(x) : a ∈ V}` is finitely satisfiable in S (for `a ∈ V`, `◇a ∈ U₀`, and `h̄` preserves ◇, so `h̄(a) ≠ ∅`), hence realized in `S'`. Injectivity of `h̄'` on the □-simple A follows: `a ≠ 0` lies in some ultrafilter, which is realized. (The bundled family of §3, one chronicle per ultrafilter over a common D, is the constructive form of the same step.)
6. *Factorization.* With `π : Ω → Uf(A)`, `w ↦ {a : w ∈ h̄(a)}`, one has `h̄ = π⁻¹ ∘ η_JT` on A, and point-completeness is surjectivity of π. So the task-frame representation is the Jónsson–Tarski embedding of the `(□, F, P)`-reduct composed with the fibration of the point set over the ultrafilter frame; the extra content of the theorem — the order on D that represents U and S, and the existence of enough points — is exactly what π adds.

**3.3 What each step is, in the tree.** Step 1 is new algebra on `LindenbaumAlg`/an abstract class (short). Step 2 is `LindenbaumAlg` plus the universal property of the free algebra (short). Step 3 is the completeness results of §2 plus the ultraproduct chain (`ShiftSet` ultraproduct, Łoś, `CompactBase`, `CompactDense`, `StrongCompletenessBase`, `StrongCompletenessDense`), which is the planned `strong_completeness` work. Step 4 is the Collapse proposition of §2 (`□ ↔ □△`). Step 5 is standard model theory (saturated elementary extensions of two-sorted structures) or, constructively, the bundled-family construction of §3 (`BFMCS`, `multiFamTaskFrameGen`). Step 6 is `ultrafilter_correspondence` plus `reverse_repr`.

**3.4 The direct construction, and where Spherical's work goes.** For a □-simple A with `n = 0`, the theorem also has the direct canonical-model proof, which the section should carry as a remark because it is the continuation of §3 and exhibits the third discharge pattern:

- A *chronicle* is `c : D → Uf(A)` (D dense) with `c(s) ∈ R_F[c(t)]` for `t < s`, Burgess's coherence conditions C0-C4' for U and S, and *saturation* (C5, C5'): every `a U b ∈ c(t)` has a witness `s > t` with `b ∈ c(s)` and `a ∈ c(e)` for `t < e < s`, and mirror. Ω is the set of all chronicles, `sh(c, d) := c(· + d)`, `h̄(a) := {c : a ∈ c(0)}`; the truth lemma at `(c, 0)` is exactly the C-conditions; □ is handled by Ω being the set of *all* chronicles (Forward/Backward coherence of the bundled family).
- *Every partial chronicle extends to a total one* (the Extension theorem of §1, for chronicles). Its Step Lemma: for a new point z, the constraints on `c(z)` are the sets `R_F[c(t)]` for `t < z`, `R_P[c(s)]` for `s > z`, and the clopens `η(a)` demanded by the U/S coherence conditions; each is closed in the Stone topology of `Uf(A)` (`R_F[U] = ⋂{η(a) : Ga ∈ U}`), the family is ⊇-directed, and it has the finite intersection property by the insertion lemma (`PointInsertion.lean` for the Lindenbaum case). Compactness of `Uf(A)` gives a point in the intersection. This is Spherical's role in §1, played by Stone compactness on the algebra side; on the flow itself Spherical is trivial.
- For `n = 1` the chronicle is forced one step at a time (`c(t + 1) = {a : Na ∈ c(t)}`), and a promise not kept in finitely many steps needs a witness at infinite distance, i.e. a non-Archimedean discrete D. That is the shape of the ℤ-exclusion in §3.5; over the base class it is the reason the discrete components are represented over ℤ-groups rather than ℤ.

**3.5 Limits, stated positively.** For TM⁺_f there is no point-complete representation over ℤ-flows: the Lindenbaum algebra has an ultrafilter (the one containing the non-compactness witness of `DiscreteNonCompactness.lean`) realized at no point of any model over ℤ. For TM⁺_c there is none over ℝ-flows (Reynolds). What holds over ℤ-flows and ℝ-flows is the SP-representation of the Lindenbaum algebra, i.e. `completeness_discrete` and `completeness_dedekind_engine`; what holds point-completely is the theorem's per-class clause, over ℤ-groups and over divisible ordered abelian groups. Nothing about a "gate" needs saying: the theorem's statement already carries the per-class information.

### 4. Consequences for the Lean stack (informational; not this task's deliverable)

- The complex algebra should be built on shift sets (`𝒫(Ω)`), as task 498's "powerset of the world-history space" already intends; the `STSA` signature should drop `sigma`, replace the three interior fields for `box` by the S5 equations, and carry U and S (or at minimum F and P as the Jónsson–Tarski operators), since the unary `(box, G, H)` fragment does not determine the algebra (task 497, 501).
- `Uf(A)` need not be a task frame; task 499's obligation "prove Spherical for the ultrafilter frame" is the wrong target and should be retired in favour of `ShiftSet.frame` as the representing frame. The relational lemmas of §2.5 are the part of the `UltrafilterFrame.lean` seed worth porting.
- Task 500's reconciliation question is answered here: the algebraic and shift-set routes are one theorem; the η-embedding factors as `π⁻¹ ∘ η_JT` and lands in `Cm(ShiftSet.ofModel F M)`, and the ultraproduct chain (491-493) is Step 3 of its proof.
- The base-class instance of the theorem inherits the single `sorryAx` of `completeness` (§3's dead-code edge).

### 5. Mapping the current section to the revised section

**Keep (reworded, without status prose):** the definition of the Lindenbaum algebra (as the free algebra) and the ultrafilter/MCS correspondence; the Stone remark (one sentence); the tense-algebra observation that F and P are conjugate and so complete operators (one sentence, in §2.1's remark); the Jónsson–Tarski attribution footnote (perfect extension / canonical extension, `gehrkevosmaer2011`); the shift-set definition; the two model-theoretic facts about ℤ and ℝ (restated positively as ℤ-groups and divisible groups); the per-class results; the disjoint-union fact (one sentence: a product of complex algebras is not the complex algebra of one frame, which is why the theorem is stated over a family of flows).

**Cut entirely:** the opening four-way distinction and its footnote; the six-rung table and figure; the "README states this precisely" paragraph; the "three gaps" list; the `sigmaQuot` paragraph; the "fixing an inaccuracy" paragraph; the Canonicity definition and Sahlqvist table; the Descriptive General Frame definition; the Duality theorem; "Spherical, diagnosed"; "Open question, re-posed"; Route T and Route M; the "scoping, rather than retracting" remark; "shift sets are ordinary mathematics here, not names in the development"; the gate remark; the Kamp/expressive-completeness remark; the entire Obstruction subsection; the "What remains genuinely unsettled" remark. The `<sec:duality>` label is referenced only inside §5 and goes with it.

**Cross-reference edits outside the section:** line 128 (abstract sentence beginning "Section 5 lays out a six-rung ladder"); line 340 ("That localization is what makes *Spherical* the identified obstruction of @sec:representation" — now: the representing frames of §5 are deterministic, so the localization is what lets them avoid Spherical); line 898 footnote (keep; still true); line 1005 ("The algebraic layer of @sec:representation measures zero sorries" — keep or name the modules); line 1096 (§4's disjoint-union remark: now points at the component decomposition, "represented over a family of frames, one temporal order per component").

## Decisions

- **D1.** The representation theorem is stated for BL⁺/TM⁺ with strict U, S primitive, in the signature `(□, U, S)` with G, H, F, P, N derived. TM at the BL level gets one sentence (no representation theorem, by incompleteness).
- **D2.** The representing frames are the frames induced by shift sets (translation flows); `Cm(F) := 𝒫(H_F)`. The ultrafilter frame is used for its relational skeleton only.
- **D3.** The theorem is point-complete and per-component (one flow per `R_□`-class); the □-simple case is the headline. Per-class temporal orders: dense; ℤ-groups; divisible ordered abelian groups.
- **D4.** Interior operators, `sigma`, descriptive general frames, duality, Sahlqvist classification, Routes T/M, metric operators, and the gate do not appear.
- **D5.** Lean status is confined to `#leansrc` tags and at most one compact table at the end of the section; no status prose, no meta-commentary.
- **D6.** The direct chronicle construction appears as one remark (Findings §3.4), because it continues §3 and is the honest location of the compactness argument.

## Recommendations

### R1. Section outline (prescriptive)

The section title becomes `= The Representation Theorem <sec:representation>` (label unchanged). Environments as in §1-§3 (`#definition`, `#proposition`, `#theorem`, `#lemma`, `#remark`, `#leansrc`).

1. *Opening paragraph* (3-4 sentences). What the theorem says; that the representable algebras are exactly the TM⁺-algebras; that point-completeness is model existence, hence strong completeness, per class.
2. `== Algebras and Complex Algebras`
   - `#definition("TM⁺-algebra")` — Findings §2.1, with the derived operations and the subclasses; footnote on TD as closure under the swap.
   - `#remark` — the operator properties actually used (the table of §1.1 in prose), U/S additive in the event argument only; F, P conjugate hence complete operators.
   - `#definition("Complex algebra")` — of a shift set and of a task frame; `#leansrc("Semantics.ShiftSet", "ofModel")`, `("Semantics.ShiftSet", "reverse_repr")`.
   - `#proposition("Algebraic soundness")` — with the four `soundness_*` tags; Cm(S) is □-simple.
   - `#lemma("Lindenbaum–Tarski")` — free algebra; ultrafilters = MCSs; `#leansrc` `LindenbaumAlg`, `mcsToUltrafilter`/`ultrafilter_correspondence`.
   - `#proposition("Weak completeness, algebraically")` — `Fr(ω) ∈ SP Cm(K)` iff weak completeness over K; the three proved instances named by tag.
3. `== Shift Sets`
   - `#definition("Shift set")` — the four axioms and the valuation; `#leansrc("Semantics", "ShiftSet")`.
   - `#definition("Standard translation")` — `φ*`.
   - `#theorem("Task models are shift sets")` — `forward_repr`, `reverse_repr`.
   - `#corollary` — elementary classes (base, dense, discrete); ℤ-groups and divisible groups as the elementary hulls of ℤ and ℝ.
   - `#proposition("Compactness")` — Łoś for the standard translation over elementary classes; failure over ℤ and ℝ with the two witnesses (`discrete_consequence_not_compact`; @reynolds1992).
4. `== The Ultrafilter Frame`
   - `#definition("Ultrafilter frame")` — `R_□`, `R_F`, `R_P`.
   - `#lemma("Relational correspondents")` — the five items of Findings §2.5.
   - `#proposition("Jónsson–Tarski")` — `η` on the `(□, F, P)`-reduct; footnote (perfect/canonical extension).
   - `#proposition("Components")` — `θ_U`, subdirect product of □-simple quotients, `n` central, discrete/dense dichotomy for □-simple algebras; cross-reference to §3's Case Split.
5. `== The Representation Theorem`
   - `#theorem("Representation")` — Findings §3.1 verbatim in the document's notation, per-class clause included.
   - `#proof` — the six steps of §3.2, each one paragraph, naming the ingredient it consumes and its `#leansrc` where one exists.
   - `#remark("The canonical construction")` — Findings §3.4: chronicles over `Uf(A)`, the Step Lemma discharged by Stone compactness, the flow needing no Spherical; cross-reference to §1's Extension and §3's third pattern.
   - `#proposition("ℤ-time and ℝ")` — Findings §3.5, positively.
   - `#remark` — one sentence each: BL-level TM has no such theorem (incompleteness); a product of complex algebras is not a complex algebra, which is why the theorem ranges over a family of flows (answers §4's disjoint-union remark).
6. *Optional* `#figure(table(...))` — declarations consumed by the proof and their axiom status, mirroring §3's table; no prose around it beyond a caption.

### R2. Style rules for the rewrite

- No sentence about the section, a draft, a README, a ladder, a rung, a gap, a next step, a gate, or what is "not claimed"; no "candidly", "honestly", "re-posed", "retracting", "scoping".
- No route that is not taken: no descriptive general frames, no metric operators in the object language, no `Uf(A)`-as-task-frame, no interior operators.
- No task numbers in the document (repository rule).
- Lean status only via `#leansrc` tags and the optional table.
- Definitions precede use; every theorem has either a proof sketch or a citation; every citation key exists in `bibliography.bib`.

### R3. Bibliography additions

- Halmos, P. R., *Algebraic Logic* (Chelsea, 1962) or "Algebraic logic I: monadic Boolean algebras", *Compositio Math.* 12 (1956) — for □ as a monadic operator.
- Chang, C. C. and Keisler, H. J., *Model Theory*, 3rd ed. (North-Holland, 1990) — Łoś, saturated elementary extensions, ultraproducts of two-sorted structures.
- Robinson, A. and Zakon, E., "Elementary properties of ordered abelian groups", *Trans. AMS* 96 (1960) — completeness of the theories of ℤ-groups and of divisible ordered abelian groups.
- Optional: Kowalski, T., "Varieties of tense algebras", *Rep. Math. Logic* 32 (1998) — tense algebras without T.

### R4. Phasing for the plan

1. Ground-truth pass: confirm the `#leansrc` anchors above resolve (`scripts/typst-sync-check.sh`), add the bibliography entries.
2. Write `== Algebras and Complex Algebras` and `== Shift Sets`.
3. Write `== The Ultrafilter Frame` and `== The Representation Theorem`.
4. Delete the old subsections; apply the five cross-reference edits and the abstract sentence.
5. Compile both typst documents; run `scripts/typst-sync-check.sh`; read the section once end-to-end against R2.

## Risks & Mitigations

- **R-1. Over-claiming Lean status.** The base-class instance depends on `completeness` (one `sorryAx`) and the ultraproduct chain is planned, not landed. *Mitigation:* the theorem is stated as mathematics with proof; the optional table records status; no sentence asserts machine-checking of the theorem itself.
- **R-2. Step 5 (saturation) is model theory the document has not used before.** *Mitigation:* cite Chang–Keisler; offer the bundled-family construction of §3 as the constructive alternative in the same paragraph.
- **R-3. The ℤ-group / divisible-group clause could be misread as a claim that Cm of such flows validates Z1 or CO.** *Mitigation:* state explicitly that the embedding is into a subalgebra; `Cm(S_k)` itself need not lie in the subvariety.
- **R-4. Cross-references from §1 and §4 silently break.** *Mitigation:* the five edits in Findings §5 are listed with line numbers; the plan's phase 4 applies them.
- **R-5. The sibling Lean tasks (497-501, 125, 500) are planned against the old target.** *Mitigation:* Findings §4 records the needed re-targeting; a separate revision of those task descriptions is recommended after this section lands.

## Appendix

- **Typst anchors referenced:** `<sec:system>`, `<sec:histories>`, `<sec:dichotomy>`, `<sec:construction>`, `<sec:completeness-status>`, `<sec:contingency>`, `<sec:representation>`; internal-only `<sec:duality>` (to be removed).
- **Lean anchors for `#leansrc`:** `Semantics.ShiftSet` (`ShiftSet`, `frame`, `ofModel`, `forward_repr`, `reverse_repr`, `sep_not_derivable`); `Metalogic.Algebraic.LindenbaumQuotient` (`LindenbaumAlg`); `Metalogic.Algebraic.BooleanStructure` (BooleanAlgebra instance); `Metalogic.Algebraic.UltrafilterMCS` (`mcsToUltrafilter`, `ultrafilter_correspondence`); `Metalogic.Algebraic` (`multiFamTaskFrameGen`, `multiFamGen_spherical`); `Metalogic.Bundle` (`BFMCS`); `Metalogic.BXCanonical` (`completeness_dense`, `completeness_discrete`, `completeness_dedekind_engine`, `completeness`); `Metalogic.BXCanonical.Chronicle` (`Chronicle`, `PointInsertion`); `Metalogic.SetConsequence` (`StrongCompletenessBase`, `CompactBase`, `ModelExistenceBase`); `Metalogic.DiscreteNonCompactness` (`discrete_consequence_not_compact`); `FrameConditions` (`soundness_linear`, `soundness_dense`, `soundness_discrete`, `soundness_Int`).
- **Bibliography keys used by the outline:** `jonssontarski1951`, `jonssontarski1952`, `blackburnderijkevenema2001`, `venema2007algebrascoalgebras`, `gehrkevosmaer2011`, `burgess1982axioms`, `xu1988until`, `reynolds1992`, `stone1936`; plus the additions of R3.
- **Lines of the current section by subsection:** opening 1153-1215; Algebraic Layer 1217-1292; Duality 1294-1427; Shift-Set Target 1429-1516; Obstruction 1518-1580.
