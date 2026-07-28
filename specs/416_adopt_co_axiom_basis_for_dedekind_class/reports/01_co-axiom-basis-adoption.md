# Research Report: Adopt CO Axiom Basis for the Dedekind Class

- **Task**: 416 `adopt_co_axiom_basis_for_dedekind_class`
- **Session**: sess_1785280411_23b0e6_416
- **Date**: 2026-07-28
- **Agent**: lean-research-hard-agent (H2+H3+H4 active; H5 not activated)
- **Reference grounding**: Tier 1 (literature-backed: `possible_worlds.tex`, `fix.md` C4, Reynolds 1992)
- **Status**: researched — **with one BLOCKING finding for the planner (Finding 3)**

---

## Summary

The paper's CO axiom (JPL `possible_worlds.tex` line 3250) was read verbatim, its operator
notation resolved, and a candidate Lean formalization produced against the repo's existing
`Formula` API (all operators already exist). Every consumption site of the Reynolds-style
basis (`prior_U_gap`, `prior_S_gap`, `sep`) was enumerated with file:line. The Mathlib Hölder
API was located and signature-verified in the pinned Mathlib (`v4.33.0-rc1`).

**BLOCKING (H4)**: adversarial analysis produced a concrete independence-model sketch showing
that **CO very likely does NOT syntactically derive `prior_U_gap` / `prior_S_gap` / `sep`**.
The two bases are frame-equivalent (both frame-characterize Dedekind completeness over dense
orders) but are plausibly NOT deductively equivalent: Reynolds's basis appears strictly
stronger. The deductive containment runs in the direction *opposite* to the task's premise:
Reynolds basis ⊢ CO (derivation sketch found, Hilbert-translatable), while CO ⊬ Reynolds
axioms (independence sketch over a ℚ-flow with a US-invisible gap — the classical Stavi
phenomenon). If the sketch is right, the paper's own deferred claim that BX_c (base + CO) is
complete for the complete class is also false as stated. Details and the recommended
resolution (adopt CO *as a derived theorem* of the retained Reynolds basis, and route a
paper-side correction through the fix.md C4 process) are in Findings 3-5.

---

## Findings

### Finding 1 — CO verbatim (Tier 1 source quote)

The delegation's path `/home/benjamin/Philosophy/Papers/possible_worlds.tex` has only 2253
lines; the "line 3250" reference resolves to the JPL version
`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (3472 lines). Both
files state the same CO axiom; the JPL line numbers are used below (current-tex line 1109
carries the identical formula).

JPL `possible_worlds.tex:3248-3255` (Definition `def:TMplus-c`), verbatim:

```latex
The \textit{Complete Burgess--Xu Tense Logic} \textbf{BX}$_c$ is the smallest extension of
the base logic \textbf{BX}$_b$ to include all instances of the following axioms:
  \aitem[CO]{TMP-CO} $\always(\Past\varphi \rightarrow \future\Past\varphi)
    \rightarrow (\Past\varphi \rightarrow \Future\varphi)$.
This axiom coincides with \textbf{\aref{CO}} in \textbf{TM}, though it is expressed in
$\BL^+$.\footnote{Note that every Archimedean discrete temporal order is complete (Dedekind),
so \textbf{TM}$^+_{fc}$ = \textbf{TM}$^+_f$ for Archimedean frames. The complete extension is
substantive for non-Archimedean orders.}
```

**Operator notation** (JPL line 442, verbatim definitions): `\past φ := ¬\Past¬φ`,
`\future φ := ¬\Future¬φ`; capital `\Past`/`\Future` are the boxes H ("always has been") and
G ("always going to be"); lowercase are the diamonds P/F; and
`\always φ := \Past φ ∧ φ ∧ \Future φ` (temporal triangle △ — NOT metaphysical □).

**Informal statement of CO**:

> △(Hφ → f Hφ) → (Hφ → Gφ)
> "If, at all times, whenever φ has always been the case there is a later time at which φ
> has still always been the case, then: if φ has always been the case, φ will always be the
> case."

This is the Prior/Burgess-style Dedekind-completeness axiom: it asserts that the definable
downward-closed region {t : Hφ at t}, if it has no last point (the △-antecedent), cannot be
a proper gap-cut — Hφ must then propagate to all future times.

The footnote at 3252-3255 ("substantive for non-Archimedean orders") is already flagged as
**false** by fix.md C4 (no non-Archimedean order is complete); its correction is a mandatory
paper-side edit outside this repo's scope.

### Finding 2 — Candidate Lean formalization of CO

All required operators already exist in `FormalSystem/Syntax/Formula.lean`:
`someFuture` (F, line 131), `somePast` (P, 141), `allFuture` (G, 151), `allPast` (H, 161),
`always` (△ = `φ.allPast.and (φ.and φ.allFuture)`, line 460 — exactly the paper's
△φ := Hφ ∧ φ ∧ Gφ).

Proposed constructor (replacing the three Reynolds constructors at
`FormalSystem/ProofSystem/Axioms.lean:377-401` if the basis swap proceeds — but see
Finding 3 before planning that):

```lean
/-- CO (Dedekind completeness): `△(Hφ → F(Hφ)) → (Hφ → Gφ)`.
Paper axiom CO of BX_c (def:TMplus-c). -/
| co (φ : Formula) :
    Axiom ((Formula.always (φ.allPast.imp φ.allPast.someFuture)).imp
      (φ.allPast.imp φ.allFuture))
```

with `minFrameClass = .Dedekind`. Confidence: High that this elaborates (all four operators
are total `Formula → Formula` functions verified by direct read; composition is trivially
well-typed). Note `co` is **not** `swapTemporal`-closed: `(co φ).swapTemporal` is the mirror
axiom △(Gφ' → P(Gφ')) → (Gφ' → Hφ'), not an instance of `co`. The repo already handles this
situation for `sep` (see `Soundness.lean:1649-1652` and `sep_swap_valid`); a CO adoption
needs the analogous `co_valid` + `co_swap_valid` pair targeting `ValidDedekindDense`.

**Semantic convention locked** (`FormalSystem/Semantics/Truth.lean:134-137`): `untl φ ψ` is
event-first — ∃ s > t: φ at s ∧ ψ throughout (t,s); `snce` is the mirror. All derivability
analysis below uses this convention.

### Finding 3 — BLOCKING: CO very likely does NOT derive the Reynolds gap axioms

This is the crux the delegation asked to attack adversarially. Verdict per axiom:

**(a) Frame-level (semantic) equivalence: YES.** Over the repo's semantics (durations `D`
with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`, arbitrary valuations), CO is
frame-valid on exactly the Dedekind-complete flows, and so are Prior-U/Prior-S (an arbitrary
valuation can paint any cut, so frame validity pins genuine completeness — the "definable
completeness" caveat applies to theories/models, not to frame validity). The repo has
already proved the gap axioms valid from the LUB hypothesis alone
(`Soundness.lean:1482 prior_U_gap_valid`, `1531 prior_S_gap_valid`, and `sep_valid` /
`sep_swap_valid`; the docstring at 1476-1481 notes only LUB + linear order are consumed).
`co_valid` would go through by the same `IsLUB` argument (new lemma, moderate).

**(b) Deductive (Hilbert) derivability: strong evidence of NO.** Independence-model sketch:

Work over ℚ-time. Fix rational m < irrational g, and rationals r_n ↓ g (accumulating at g
strictly from above). Let atom p be true everywhere except on
X := (ℤ-points ≤ m) ∪ {r_n : n ≥ 1} (isolated ¬p points). Pick rational t ∈ (m, g).

- **Prior-U fails** at t for p: the antecedent holds (p throughout (t,g) gives `U(⊤,p)`;
  ¬p at r_1 gives `F¬p`), but the consequent `U(¬p ∨ K⁺(¬p), p)` needs a witness s with p
  throughout (t,s), forcing s < g; there ¬p is false, and `K⁺(¬p)` = "¬p throughout some
  interval right after s" is false everywhere in this model (¬p holds only at isolated
  points). So the consequent has no witness.
- **All CO instances plausibly hold**: a CO violation requires a US-definable formula χ
  whose H-region has its cut exactly at the gap g. The candidate χ := ¬P(¬p) fails because
  the integer ¬p-points below m make P(¬p) true everywhere in the relevant region; finite
  nesting (¬P(¬p ∧ P(¬p ∧ ...))) peels only finitely many past ¬p-points; and formulas that
  would distinguish "¬p accumulating at g from above" from "isolated ¬p far away" need to
  see accumulation, which finite-depth US formulas cannot (standard
  Ehrenfeucht–Fraïssé/composition argument: points in (m,g) and (g,r_k) are k-equivalent
  for depth-k US formulas). This is precisely the classical **Stavi phenomenon**: over
  non-complete orders, US is strictly weaker than FO, and gap-cuts can be FO-definable yet
  US-invisible. Every US-definable set in this structure has its cuts at realized points,
  where CO instances hold vacuously or harmlessly.
- The model class {this model, its temporal mirror} is closed under the needs of the rules
  (`modus ponens`, both necessitations, `temporal_duality`, weakening — mirror handles
  duality; take Omega a single history so □ is inert; value other atoms ⊥). Base, `density`,
  `dense_indicator`, and all CO instances valid; `prior_U_gap` refuted. Hence
  **`DerivationTree` over {base, density, dense_indicator, co} cannot derive
  `prior_U_gap`** — modulo writing out the EF argument rigorously (pen-and-paper grade;
  NOT formalized, NOT found in literature — this is an original adversarial construction
  and must be independently checked before being treated as a theorem).

`prior_S_gap` is the definitional temporal mirror (`Soundness.lean:1438`), so the mirror
model gives the same verdict. For `sep` the same technique applies with even more room
(sep concerns accumulation patterns of φ-boundaries; Reynolds needed it as a primitive and
notes even the long line satisfies it) — at minimum its derivability from CO is unproven
anywhere.

**(c) The converse direction DOES look derivable: Reynolds basis ⊢ CO.** Sketch (finitary,
Hilbert-translatable): assume △(Hχ → fHχ) and Hχ at t; suppose ¬Gχ, i.e. F¬χ. From the
△-antecedent at t, Hχ → fHχ gives s > t with Hχ at s, so χ throughout (t,s), so `U(⊤,χ)`
at t; with F¬χ this feeds **Prior-U at χ**, yielding a witness s with χ on (t,s) and
(¬χ ∨ K⁺¬χ) at s. But Hχ at t plus χ on (t,s) gives Hχ at s; the △-antecedent's G-component
gives Hχ → fHχ at s, whence some s' > s with Hχ at s', so χ at s (kills ¬χ) and χ
throughout (s,s') (kills K⁺¬χ). Contradiction; so Gχ. The point-shifting steps use only
K-style distribution and BX_b's U/S interaction — a real but standard derivation-engineering
effort in the repo's `DerivationTree`.

**(d) Consequence for the paper.** cor:tm-completeness (JPL ~3284-3293) defers the
completeness of TM⁺_c — i.e. of the CO basis — to "the Lean 4 repository"; there is **no
independent literature citation** backing completeness of base+CO for the complete class
(Reynolds 1992's completeness for ℝ uses Prior-U/Prior-S/Sep as primitives, and that choice
now looks forced, not stylistic). If Finding 3(b) holds, BX_c as defined in the paper is
deductively too weak and the paper's def:TMplus-c / completeness claim needs a paper-side
correction (e.g., define BX_c with the Reynolds axioms and derive CO, or scope the claim).
That correction belongs to the fix.md C4 process, not to this repo.

### Finding 4 — Recommended resolution (for the planner)

The task description ("CO becomes the official basis; gap principles re-derived as internal
theorems") cannot be executed as written if Finding 3(b) is right, and there is no sound
fallback that hides the problem (zero-debt policy: no sorry, no axiom smuggling). Options,
in recommended order:

1. **Inverted alignment (recommended)**: keep the Reynolds triple as the official
   `Axiom` constructors (they are the deductively stronger, completeness-proof-bearing
   basis) and **add CO as a derived internal theorem**
   `theorem co_derived (φ) : DerivationTree fc [] (co-formula φ)` for `.Dedekind ≤ fc`,
   via Finding 3(c). Also add `co_valid : ValidDedekindDense (co-formula φ)` semantically.
   This achieves a one-basis story in which the paper's CO is a *theorem* of the repo's
   Dedekind class, and surfaces the paper-side correction through C4. Definitional
   alignment then means aligning the *paper* to the mathematically forced basis, which
   fix.md C4 option 2 explicitly contemplated ("or switch the paper's BX_c basis to the
   Reynolds axioms").
2. **Attempt-then-fallback**: a bounded spike phase attempting explicit Hilbert derivations
   of the three gap formulas from CO (this would refute Finding 3(b) constructively). If
   any derivation succeeds, the basis swap becomes viable for that axiom; if the spike
   fails within budget, fall back to option 1. Given the independence sketch, the expected
   outcome is failure; budget accordingly (small).
3. **Basis swap regardless** (NOT recommended): swap to `Axiom.co` and mark all six
   derivation-consuming sites [BLOCKED] pending the (likely impossible) derivations.

Under option 1, the rebase surface for 408/411 is **empty** (they keep consuming the
Reynolds constructors), and the new deliverables are: `Axiom`-layer docstring updates, the
`co_derived` Hilbert derivation, `co_valid`/`co_swap_valid`, Hölder lemmas/docs (Findings
6-8), and FrameClass doc alignment (Finding 9).

### Finding 5 — Complete consumption-site worklist (the 408/411 rebase surface if a swap were forced)

Actual `DerivationTree.axiom` instantiations (the mathematically hard sites):

| Site | Axiom | Instance formula | Role |
|---|---|---|---|
| `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGapWitness.lean:151` | prior_U_gap | `F φ` | limit-MCS future witness at unselected real (Reynolds Thm 3) |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGuardWitness.lean:141` | prior_S_gap | `ψ` | past mirror of the above |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGuardAbove.lean:145` | prior_U_gap | `ψ` | guard-above variant |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean:905` | prior_U_gap | `chronicleEff root p` | `SemanticPriorU` of bridge structure (Reynolds §4 Cor 1 cl 3) |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean:952` | prior_S_gap | `chronicleEff root p` | `SemanticPriorS` |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean:1002` | sep | `chronicleEff root p` | `SemanticSep`, feeds `IsDensePriorSepStructure` → Doets embedding (§9) |

Note on the MonadicBridge sites: the downstream Doets machinery consumes
`SemanticPriorU/S/Sep` as *properties of the constructed ℚ-structure*, and those properties
genuinely require the gap instances to be theorems of the frame class (a ℚ-structure with a
definable region whose sup is a gap real falsifies `SemanticPriorU` while — per Finding 3(b)
— potentially satisfying all CO instances). So under a CO basis these three theorems have
no local workaround; they inherit the full force of the derivability problem. The three
GapWitness/GuardWitness/GuardAbove sites, by contrast, sit at global limit-cut
configurations where a direct CO-based rework was verified feasible by sketch (χ below r /
¬χ above r; H/G/f coherence steps only — but this would require adding Since-coherence
hypotheses where `limitFutureWitness_of_priorU` currently assumes only Until-coherence).

Mechanical sites (constructor case arms; rename/reshape only):

- `FormalSystem/Metalogic/Soundness.lean:885-887, 945-947, 1010-1012, 1118-1120,
  1290-1292` (absurd arms at lower frame classes), `1780-1782` (validity dispatch),
  `1798-1803` (swapTemporal dispatch)
- `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean:379-381, 659-661,
  938-940, 960-962`
- `FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean:676-678, 1252-1254`
- `FormalSystem/Automation/FormulaEnumerator.lean:1425-1431`
- `FormalSystem/Automation/MachineAppendixExport.lean:253-255`

Validity lemmas (would be retained as semantic facts in every scenario):
`Soundness.lean:1482` (`prior_U_gap_valid`), `:1531` (`prior_S_gap_valid`), plus
`sep_valid` / `sep_swap_valid` (same file, `sep` block at ~1649 ff.).

Tableau side (task-411 territory): rule counterparts at
`FormalSystem/Metalogic/Decidability/Tableau.lean:152-160` (rule declarations),
`1259-1294` (rule applications), `1443` (docs). Under the recommended option 1 these are
untouched; under a basis swap they would need CO-shaped tableau rules plus reproved
soundness — a substantial 411 rebase.

Docstring-only references (update prose, no proof change):
`SoundnessLemmas/Separability.lean:47`, `WeakCanonical/PriorDefsDense.lean:33-136`,
`WeakCanonical/Kamp/KPlusFaithful.lean`, `WeakCanonical/Kamp/PriorINF.lean`,
`Bundle/LimitMCS.lean`, `Bundle/RealExtensionBundle.lean`,
`ChronicleRealExtension.lean` (multiple), `ChronicleToCountermodel.lean:484`.

### Finding 6 — Hölder classification: verified Mathlib API (pinned Mathlib, v4.33.0-rc1)

All names below verified present in `.lake/packages/mathlib` (grep + `lean_local_search`)
with signatures from `lean_leanfinder` cross-checked against the source files:

| Mathlib name | Signature (verified) | File |
|---|---|---|
| `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` | `∀ (G) [AddCommGroup G] [LinearOrder G] [IsOrderedAddMonoid G] [Archimedean G], Nonempty (G ≃+o ℤ) ∨ DenselyOrdered G` | `Mathlib/GroupTheory/ArchimedeanDensely.lean` |
| `LinearOrderedAddCommGroup.discrete_iff_not_denselyOrdered` | `... [Archimedean G], Nonempty (G ≃+o ℤ) ↔ ¬DenselyOrdered G` | same |
| `Archimedean.of_locallyFiniteOrder` | `[AddCommGroup G] [LinearOrder G] [IsOrderedAddMonoid G] [LocallyFiniteOrder G] → Archimedean G` | same (line 215) |
| `Archimedean.exists_orderAddMonoidHom_real_injective` | `∀ (M) [AddCommGroup M] [LinearOrder M] [IsOrderedAddMonoid M] [Archimedean M], ∃ f : M →+o ℝ, Function.Injective f` | `Mathlib/Data/Real/Embedding.lean:232` |
| `Archimedean.embedReal` | `(M) [...] [One M] [ZeroLEOneClass M] [NeZero (1:M)] [Archimedean M] : M →+o ℝ` (bundled, preserves the chosen unit) | `Mathlib/Data/Real/Embedding.lean:198` |
| `AddSubgroup.dense_or_cyclic` | additive subgroup of an archimedean linear ordered additive group with order topology is dense or cyclic | `Mathlib/Topology/Algebra/Order/Archimedean.lean:77` (`to_additive` of `Subgroup.dense_or_cyclic`) |

The typeclass set of `discrete_or_denselyOrdered` and
`exists_orderAddMonoidHom_real_injective` matches the repo's duration binders
(`TaskFrame.lean:99`) **exactly** — no adapter needed beyond supplying `Archimedean`.

### Finding 7 — What Mathlib does NOT have (verified absences; do not cite these as existing)

- **"Dedekind-complete linearly ordered abelian group ⇒ Archimedean"**: not found for
  groups (searches: leanfinder ×2, local grep of `Mathlib/Algebra/Order/`,
  `Mathlib/GroupTheory/`). Only the field version exists:
  `ConditionallyCompleteLinearOrderedField.to_archimedean` (`Mathlib/Algebra/Order/CompleteField.lean`).
  For the repo this is a **cheap hand-proof** (~15-25 lines) against the repo's explicit
  LUB hypothesis (`∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB x`-form as in
  `ValidDedekind`, `Validity.lean:231`): if ¬Archimedean, {n • a} is bounded above, its
  LUB s satisfies s - a < s, giving some n with s - a < n • a, so s < (n+1) • a ≤ s.
- **"Nontrivial dense Dedekind-complete linearly ordered abelian group ≃+o ℝ"**: no
  packaged theorem. A composition path exists from verified pieces (complete ⇒ Archimedean
  [hand] → `exists_orderAddMonoidHom_real_injective` → image subgroup dense by
  `AddSubgroup.dense_or_cyclic` + density/nontriviality → surjectivity from completeness),
  but it is a moderate analysis-flavored development (~100-200 lines, order-topology
  plumbing). **Recommendation: record as docs**, per the task's "lemmas where cheap, else
  docs" instruction — it is not cheap.
- **"Complete + discrete = ℤ"**: composable and cheap: nontrivial + LUB-complete ⇒
  Archimedean (hand lemma above) + ¬DenselyOrdered ⇒ `Nonempty (D ≃+o ℤ)` via
  `discrete_iff_not_denselyOrdered`. **Recommendation: prove as a lemma** (~10 lines given
  the hand lemma), or docs if the planner trims scope.

### Finding 8 — Hölder lemma/doc targets (concrete statements)

Cheap tier (recommended as actual lemmas, e.g. a new
`FormalSystem/Semantics/DurationClassification.lean` or a section in `Validity.lean`):

```lean
/-- A Dedekind-complete (LUB) nontrivial duration group is Archimedean. -/
theorem archimedean_of_lub {D : Type} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D]
    (h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) :
    Archimedean D

/-- Hölder dichotomy for Dedekind-complete duration groups:
    ℤ (discrete) or densely ordered. -/
theorem complete_duration_discrete_or_dense {D : Type} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D]
    (h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) :
    Nonempty (D ≃+o ℤ) ∨ DenselyOrdered D
  -- := (LinearOrderedAddCommGroup.discrete_or_denselyOrdered D) with the hand instance

/-- Complete-but-discrete is exactly ℤ. -/
theorem complete_not_dense_iso_int {D : Type} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D]
    (h_lub : ...) (h : ¬DenselyOrdered D) : Nonempty (D ≃+o ℤ)
```

Docs tier: dense + complete + nontrivial ≃ ℝ (hence `ValidDedekindDense`'s model class is,
up to iso of the duration group, exactly real flow), TM_c = Th(ℤ) ∩ Th(ℝ), and the false
paper footnote (no non-Archimedean order is complete) — recorded in the FrameClass
docstring and `Validity.lean` docstrings, with the Mathlib names from Finding 6 cited as
the backing facts.

### Finding 9 — FrameClass docs vs the paper's TM_c / TM⁺_dc distinction

Current state (verified by read):

- `Axioms.lean:404-447` (FrameClass docstring): calls Dedekind "valid on dense
  Dedekind-complete frames (paradigmatically ℝ)".
- `Validity.lean:240-254` (`ValidDedekindDense`): "ℝ is the paradigm model".
- `ValidDiscrete` (`Validity.lean:187-193`) assumes `IsSuccArchimedean`/`IsPredArchimedean`
  — already the ℤ-time reading (fix.md C5 confirms Lean is aligned there; no new task).

Required doc updates:

1. Replace "paradigmatically ℝ" with the Hölder-sharp statement: by
   `discrete_or_denselyOrdered` + completeness ⇒ Archimedean, a nontrivial dense
   Dedekind-complete duration group is order-and-group isomorphic to ℝ — so
   `FrameClass.Dedekind` / `ValidDedekindDense` is the paper's **TM⁺_dc** (real flow),
   not TM⁺_c.
2. State explicitly that the paper's **TM⁺_c** (complete simpliciter; class = {ℤ, ℝ} up to
   iso; theory = Th(ℤ) ∩ Th(ℝ)) has **no repo frame class**: the complete-but-discrete
   case is exactly ℤ and is covered by `FrameClass.Discrete` (`ValidDiscrete`), while
   `ValidDedekind` (density-free) exists as a predicate but is not any soundness target
   (its docstring already explains why).
3. Record the CO/Reynolds basis relationship per Findings 3-4 (whichever option the
   planner adopts), so the docstring stops implying the two bases are interchangeable.

### Finding 10 — Soundness-side deliverables for CO (needed under every option)

Whether CO becomes a constructor (option 3/2) or a derived theorem (option 1), the
semantic layer wants:

- `co_valid : ValidDedekindDense ((Formula.always (φ.allPast.imp φ.allPast.someFuture)).imp (φ.allPast.imp φ.allFuture))` —
  direct `IsLUB` argument on the set {t' : Hφ holds below t'}; same proof shape as
  `prior_U_gap_valid` (`Soundness.lean:1482`), reusing `exists_isGLB_of_lub`
  (`Soundness.lean:1453`) machinery style. Under option 1 this is optional
  (derivability + soundness already gives validity) but worth having as an independent
  check.
- `co_swap_valid` for the mirror formula, following the `sep_swap_valid` precedent
  (`Soundness.lean:1649-1652` explains the non-self-dual pattern) — only needed if `co`
  becomes a constructor (the `temporal_duality` soundness case, `Derivation.lean:155`).

---

## Literature Proof Structure (Tier 1)

Source chain: fix.md §C4 (decision) → JPL possible_worlds.tex def:TMplus-c line 3250 (CO) +
cor:tm-completeness ~3284 (completeness deferred to this repo) → Reynolds 1992 (gap-axiom
basis US/R for ℝ; printed p.168 axioms, p.169 definable-completeness caveat, Thm 3 p.176,
Lemma 10 p.184) → repo transcription (Chronicle files = Reynolds §§3-9; Doets embedding).

| Step | Source | Content | Lean counterpart | Translation note |
|---|---|---|---|---|
| 1 | tex 3250 | CO axiom for BX_c | proposed `Axiom.co` / `co_derived` (Finding 2/4) | △, H, G, F all exist in `Formula` |
| 2 | tex ~3284 | TM⁺_c completeness "established in the Lean repo" | NOT yet formalized; premise of this task | no independent citation exists — see Finding 3(d) |
| 3 | Reynolds p.168 | Prior-U, Prior-S, Sep as primitives of US/R | `Axioms.lean:377-401` (exists, sorry-free) | faithful; docstrings quote the source |
| 4 | Reynolds p.169 | axioms enforce only *definable* completeness | docstrings `Axioms.lean:362-365` | the caveat is why frame- and deductive-equivalence diverge (Finding 3) |
| 5 | Reynolds Thm 3 / §4 Cor 1 / §9+Doets | canonical-model completeness over ℝ | Chronicle files (consumption sites, Finding 5) | consumes the gap axioms as axioms; cannot survive a CO swap unchanged |
| 6 | Hölder (classical); fix.md C4 | complete ordered ab. group ≅ ℤ or ℝ | Mathlib API Finding 6 + hand lemmas Finding 8 | Mathlib splits it: Archimedean [needs hand lemma] then dichotomy/embedding |

## Tactic Survey Results

Not applicable in the usual sense (no proof positions were open to attempt); the
tool-verified work in this dispatch was API verification: `lean_local_search` (3 calls:
positive hits for the ArchimedeanDensely triple; verified-negative for
`exists_orderAddMonoidHom_real_injective` prompting the direct source-grep that located it
in the pinned Mathlib), `lean_leanfinder` (4 calls), plus direct pinned-Mathlib source
reads for signature confirmation.

## Adversarial Self-Verification

Adversarial pass performed against the draft findings; it **triggered a revision**: the
initial framing (execute the basis swap, derive gap principles from CO) was inverted into
Finding 4's recommendation after the independence sketch of Finding 3(b) survived attack
attempts (three candidate derivation tricks — χ := φ ∨ ¬Pφ globalization, finite ¬P-nesting,
K⁺/K⁻ accumulation detection — were each defeated by the adversary model; the χ := p ∨ ¬Pp
trick works only when p has no past exceptions, which cannot be assumed).

### Claim Verification Table

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| CO verbatim is `△(Hφ→fHφ)→(Hφ→Gφ)` at JPL tex 3250; `\always`=△ (temporal), capitals are boxes | direct file read of tex 3248-3255 + macro defs at 183, 442 | source read (Tier 1) | High |
| Delegation's tex path has no line 3250; JPL copy is the referenced one | `wc -l`: 2253 vs 3472; identical formula at current-tex 1109 | shell verification | High |
| Repo axioms verbatim as quoted; `minFrameClass = .Dedekind`; not `prior_UZ`/`prior_SZ` | `Axioms.lean:377-401` read | source read | High |
| `Formula.always` = Hφ ∧ (φ ∧ Gφ) matches paper △ | `Formula.lean:460` | source read | High |
| `untl` is event-first (∃s>t: φ at s ∧ ψ on (t,s)) | `Truth.lean:134-137` | source read (note: paper line 3100 describes the convention with opposite wording; the truth clause is authoritative) | High |
| `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` exists in pinned Mathlib with stated signature | ArchimedeanDensely.lean | `lean_local_search` hit + leanfinder signature + file present | High |
| `Archimedean.exists_orderAddMonoidHom_real_injective` exists in pinned Mathlib | `Mathlib/Data/Real/Embedding.lean:232` | direct source read (after a `lean_local_search` miss — the miss was the search tool, not absence) | High |
| No Mathlib "complete ordered group ⇒ Archimedean" (groups; field version only) | searches + greps of Algebra/Order, GroupTheory | leanfinder ×2 + grep; absence claims are inherently weaker | Medium |
| No Mathlib "dense complete ordered group ≃+o ℝ" packaged theorem | same | search + grep | Medium |
| Gap axioms and CO are all frame-valid on Dedekind-complete flows; repo already proves the gap side from LUB alone | `Soundness.lean:1476-1481, 1482, 1531` | source read; `co_valid` itself is to-prove (sketch only) | High (gap side) / Medium (co_valid) |
| **CO does NOT Hilbert-derive prior_U_gap** (independence model over ℚ with US-invisible gap) | original construction, Finding 3(b); Stavi phenomenon as background | adversarial construction, pen-and-paper sketch; EF argument NOT written out; NOT machine-checked; no literature confirmation | Medium — but even at Medium it is planning-blocking, because the opposite claim has NO support at all |
| Reynolds basis ⊢ CO (derivation sketch) | Finding 3(c) | pen-and-paper sketch, Hilbert-translatability judged from repo's existing derivation infrastructure | Medium |
| Paper's BX_c completeness has no independent citation; deferred to this repo | tex ~3284-3293 read | source read | High |
| Consumption-site worklist complete | repo-wide greps (constructor name + `Axiom.` qualified) | exhaustive grep, cross-checked file list | High |
| MonadicBridge sites have no CO-local workaround; GapWitness-style sites do (with added Since-coherence hypotheses) | `ChronicleMonadicBridge.lean:870-1010`, `ChronicleLimitGapWitness.lean:76-165` reads + semantic sketches | source read + sketch | Medium |

### Contradiction Log

1. **Task premise vs Finding 3(b)**: the task/fix.md C4 decision presumes gap principles
   are derivable from CO; the independence sketch says otherwise. Resolution per
   precedence: the primary mathematical source (Reynolds 1992's choice of primitives +
   the classical Stavi phenomenon) outranks the task description's presumption, and no
   source supports derivability. Resolved in favor of Finding 3(b) at Medium confidence;
   surfaced as BLOCKING rather than silently "resolved". The resolving check not yet
   performed: a rigorous EF/composition proof of US-indefinability of the cut in the
   adversary model (or, conversely, an explicit Hilbert derivation refuting it).
2. **`lean_local_search` miss vs leanfinder hit** for
   `exists_orderAddMonoidHom_real_injective`: resolved by direct source read of the pinned
   Mathlib file (present at `Embedding.lean:232`) — hover/source outranks search-index
   absence.
3. **Paper wording of the untl convention (tex 3100, "guard first") vs repo truth clause
   (event first)**: resolved by the truth clause (`Truth.lean:134`), which is the
   authority for repo-side reasoning; the paper's prose description is about its own
   notation and does not change any finding.

### Recommendations modified after verification

- Initial draft recommendation "swap basis, derive gap axioms" replaced by Finding 4's
  option 1 (retain Reynolds basis, derive CO, correct the paper) after the derivability
  attack succeeded.
- Initial plan to cite `Archimedean.embedReal` as the primary Hölder handle replaced by
  `exists_orderAddMonoidHom_real_injective` (the bundled `embedReal` needs an arbitrary
  anchor `One M` instance, which the duration binders do not carry).

## Recommended next steps (for the planner)

1. Decide between Finding 4 options 1 and 2 (recommend 1, or 2 with a small spike budget).
   This decision should be surfaced to the user, since option 1 reverses the task
   description's direction and implies a paper-side C4 re-revision.
2. Plan the CO derivation (`co_derived` from Prior-U per Finding 3(c)) and `co_valid`.
3. Plan the cheap Hölder lemmas (Finding 8) and the FrameClass/Validity doc alignment
   (Finding 9), which are valuable and safe under every option.
4. Keep the tableau (411) and completeness (408) targets on the Reynolds basis unless the
   spike refutes Finding 3(b).

## References

- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (lines 183,
  442, 3100, 3176, 3221-3260, 3280-3320)
- `/home/benjamin/Philosophy/Papers/possible_worlds.tex` (lines 1100-1125)
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/Comments/fix.md` (§C4 lines 156-165,
  §C5 167-175, downstream propagation 190-197)
- Reynolds 1992, "An axiomatization for Until and Since over the reals without the IRR
  rule" (as transcribed in repo docstrings; printed pp.168-169, 176, 184)
- Repo files as cited per-finding
- Mathlib (pinned v4.33.0-rc1): `Mathlib/GroupTheory/ArchimedeanDensely.lean`,
  `Mathlib/Data/Real/Embedding.lean`, `Mathlib/Topology/Algebra/Order/Archimedean.lean`,
  `Mathlib/Algebra/Order/CompleteField.lean`
