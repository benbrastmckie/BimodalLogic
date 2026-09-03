# Galois over Mathlib + Correspondence Tidy — Research Report

**Task**: 525 (WAVE 3, theorem layer)
**Session**: sess_1788407456_70233f_525
**Date**: 2026-09-02
**Findings covered**: C-06, C-18, C-21, C-24, C-25, G-06, G-13 (C-14 and U8 excluded — see §8)

---

## 0. Executive summary

Every one of the six work items was **verified by compilation**, not by reading. Three probe
files were elaborated against the pinned toolchain with `lake env lean`; all three exit clean
with zero errors. Nothing in this report is a guess about whether Lean will accept it.

| Item | Verdict | Evidence |
|---|---|---|
| (1) Galois layer on Mathlib polars | **Confirmed, all 7 projections + 7 free lemmas typecheck** | probe A |
| (2) `galoisClosed_of_indicator_iff` + retarget | **Confirmed, both corollaries become one-liners** | probe C |
| (3) `translation_realizes` | **Confirmed; needs a permissive twin the review did not name** | probe B |
| (4) C-21 relocation decision | **DO NOT MOVE — soundness is genuinely needed** | §4, measured |
| (5) `corrAtom` | **Parameterise, do not promote** | §5 |
| (6) Delete `arch_of_lub` | **Confirmed drop-in; edge is acyclic and cheap** | probe D |

Two corrections to the task's premises, both material to planning:

- **The Concept route is strictly better than the `GaloisConnection` route** that G-ecosystem
  §3.2's mapping table prescribes. That table routes `mod_th_mod` through
  `mod_th_gc.dual.u_l_u_eq_u` and budgets "one extra line for `OrderDual` simp cleanup".
  Measured: Mathlib's `lowerPolar_upperPolar_lowerPolar` gives it directly with **no
  `OrderDual` anywhere**. Same for `Mod (S₁ ∪ S₂) = Mod S₁ ∩ Mod S₂`, which the task
  description attributes to `GaloisConnection.l_sup` — it is `lowerPolar_union`, a plain
  `@[simp]` lemma, no dual. Use §3.2's table as motivation, not as the implementation.
- **C-21's Lean-side half is already done.** `Metalogic/Independence.lean:20-31` already
  describes three result families over six modules and explicitly narrates its own repair. Only
  `Independence/README.md:6` still carries the singular "The result carried here is…" framing.

Line-number drift: the review's anchors for the three (T1) proofs (`:354`, `:419`, `:485`) are
stale — a prior task moved `translationFrame`/`permissiveFrame` to `Semantics/Frames/Standard.lean`,
shrinking the file from 563 to **409** lines. Current anchors are `:199`, `:264`, `:330`. The
proof bodies themselves were **not** shortened: 64 / 65 / 78 lines, 207 total, matching the
review's 209.

---

## 1. Item (1) — the Galois layer over `Mathlib.Order.Concept`

### 1.1 The abbrevs elaborate

The primary risk C-06 flagged ("verify the `abbrev`s elaborate before committing; if
`Set TaskFrame`'s universe (`Type 1`) causes friction, fall back to…") is **discharged**. The
following elaborate with zero errors and are `rfl`-defeq to the current hand-rolled definitions:

```lean
def validOnRel (F : TaskFrame) (φ : Formula) : Prop := F.ValidOn φ

abbrev Th  : Set TaskFrame → Set Formula := upperPolar validOnRel
abbrev Mod : Set Formula → Set TaskFrame := lowerPolar validOnRel
abbrev GaloisClosed : Set TaskFrame → Prop := Order.IsExtent validOnRel
```

Verified: `example (K : Set TaskFrame) : Th' K = FormalSystem.Semantics.Th K := rfl` and the
`Mod` analogue both close by `rfl`. The universe is a non-issue — Concept's
`variable {α β : Type*}` gives independent universes, so `α := TaskFrame : Type 1`,
`β := Formula : Type` is fine. **No fallback to `th_eq_upperPolar` is needed.**

The explicit/strict-implicit binder mismatch (`{φ | ∀ F ∈ K, …}` vs
`{b | ∀ ⦃a⦄, a ∈ s → r a b}`) does not obstruct defeq: binder info is not part of expression
identity for `isDefEq`.

### 1.2 The six theorem bodies, verified

Each of these typechecks as written. Keep the names and docstrings; replace only the bodies.

| Current | New body |
|---|---|
| `th_anti h` | `upperPolar_anti _ h` |
| `mod_anti h` | `lowerPolar_anti _ h` |
| `subset_mod_th K` | `subset_lowerPolar_upperPolar _ K` |
| `subset_th_mod S` | `subset_upperPolar_lowerPolar _ S` |
| `mod_th_mod S` | `lowerPolar_upperPolar_lowerPolar _ S` |
| `th_mod_th K` | `upperPolar_lowerPolar_upperPolar _ K` |
| `galoisClosed_mod S` | `Order.isExtent_lowerPolar` |

### 1.3 `GaloisClosed` changes meaning — handle deliberately

This is the one semantic (not cosmetic) change in item (1). Currently
`GaloisClosed K : Prop := Mod (Th K) = K`, an **equation**. `Order.IsExtent r K` is
`K ∈ Set.range (lowerPolar r)`, a **range membership**. They are equivalent by
`Order.isExtent_iff`, not defeq.

Verified in both directions:
- `example (K) : GaloisClosed' K ↔ FormalSystem.Semantics.GaloisClosed K := Order.isExtent_iff`
- `Order.isExtent_iff.mpr galoisClosed_sat_dense` accepts the *existing* equation-shaped proof.

Consequences, all cheap:
- `galoisClosed_of_indicator` must wrap its result in `Order.isExtent_iff.mpr`.
- `galoisClosed_mod` gets **shorter** — `Order.isExtent_lowerPolar` is `⟨_, rfl⟩`.
- **Add a compatibility lemma** so the equation stays reachable and the docstring stays true:
  ```lean
  /-- `GaloisClosed K` unfolds to the fixed-point equation `Mod (Th K) = K`. -/
  theorem galoisClosed_iff {K : Set TaskFrame} : GaloisClosed K ↔ Mod (Th K) = K :=
    Order.isExtent_iff
  ```

Consumer audit (repo-wide grep): `GaloisClosed` is **produced** only in `Indicator.lean`
(twice) and **mentioned** in docstrings (`Metalogic.lean`, `LexIntWitness.lean`,
`Correspondence/README.md`). **Nothing consumes a `GaloisClosed` hypothesis as an equation.**
The change is safe.

### 1.4 The free lemmas — all seven verified

The task asks for four; seven are available and all typecheck. Recommended as named theorems:

```lean
/-- An intersection of Galois-closed frame classes is Galois-closed. -/
theorem galoisClosed_iInter {ι : Sort*} (f : ι → Set TaskFrame)
    (hf : ∀ i, GaloisClosed (f i)) : GaloisClosed (⋂ i, f i) := Order.IsExtent.iInter f hf

theorem galoisClosed_inter {K K' : Set TaskFrame}
    (h : GaloisClosed K) (h' : GaloisClosed K') : GaloisClosed (K ∩ K') := h.inter h'

theorem galoisClosed_univ : GaloisClosed Set.univ := Order.IsExtent.univ

/-- `Mod` turns unions of formula sets into intersections of model classes. -/
theorem mod_union (S₁ S₂ : Set Formula) : Mod (S₁ ∪ S₂) = Mod S₁ ∩ Mod S₂ :=
  lowerPolar_union _ S₁ S₂

theorem mod_iUnion {ι : Sort*} (f : ι → Set Formula) : Mod (⋃ i, f i) = ⋂ i, Mod (f i) :=
  lowerPolar_iUnion _ f

theorem mod_empty : Mod ∅ = Set.univ := lowerPolar_empty _
theorem th_empty  : Th  ∅ = Set.univ := upperPolar_empty _
```

Note `mod_union`/`mod_iUnion` are the `l_sup`/`l_iSup` the task asks for, obtained **without**
the dual. `u_top` is `mod_empty`/`th_empty`. `lt_iff_lt` is available only through the dualised
connection and buys nothing here — **recommend dropping it** from the deliverable list.

### 1.5 The explicit `GaloisConnection`

G-ecosystem §3.2's shape, verified verbatim:

```lean
/-- The `Mod`/`Th` adjunction as an explicit Mathlib `GaloisConnection`. -/
theorem mod_th_gc : GaloisConnection (α := Set Formula) (β := (Set TaskFrame)ᵒᵈ)
    (OrderDual.toDual ∘ Mod) (Th ∘ OrderDual.ofDual) :=
  gc_lowerPolar_upperPolar validOnRel
```

Include it — it satisfies G-06's "zero `GaloisConnection` occurrences repo-wide" complaint and
is the discoverable name. But **do not derive the six lemmas from it**; §1.2's polar lemmas are
dual-free and shorter.

### 1.6 Mechanics

- Add `import Mathlib.Order.Concept` to `Galois.lean`. Verified to import cleanly into this
  legacy (non-`module`) tree despite Concept being a `module`-system file with
  `@[expose] public section`.
- Add `Order` to the `open` line (`open FormalSystem.Syntax FormalSystem.ProofSystem Order`),
  or fully qualify `Order.IsExtent`. Probes used `open Order` with no clash.
- Update `Galois.lean`'s "## Import seam" section: it currently asserts the module imports
  `Semantics/Validity.lean` **only**. That sentence becomes false. The new Mathlib edge opens no
  `Semantics → ProofSystem`-style seam, so the seam claim survives — but the wording must change.
- Update the "## Main results" list with the new names.

**Optional, not required for acceptance** — `mod_union` pays off in the `Independence/`
sandwiches only if `AxiomSet` is decomposed as a union. The enabling lemma is one line and
verified:
```lean
theorem axiomSet_mono {fc₁ fc₂ : FrameClass} (h : fc₁ ≤ fc₂) : AxiomSet fc₁ ⊆ AxiomSet fc₂ :=
  fun _ ⟨ax, hax⟩ => ⟨ax, le_trans hax h⟩
```
The `by_cases ax.minFrameClass ≤ FrameClass.Dense` split at `RationalWitness.lean:118` is that
union decomposition done by hand. Converting it is a genuine but separable win; scope it
explicitly or leave it out.

---

## 2. Item (2) — `galoisClosed_of_indicator_iff`

Verified. The iff-form and **both retargeted corollaries** compile:

```lean
theorem galoisClosed_of_indicator_iff {K : Set TaskFrame} (φ : Formula)
    (h : ∀ F : TaskFrame, F.ValidOn φ ↔ F ∈ K) : GaloisClosed K :=
  galoisClosed_of_indicator φ (fun F hF => (h F).mpr hF) (fun F hv => (h F).mp hv)

theorem galoisClosed_sat_dense : GaloisClosed {F : TaskFrame | FrameClass.Sat FrameClass.Dense F} :=
  galoisClosed_of_indicator_iff _ validOn_neg_nextTop_iff

theorem galoisClosed_isDiscrete : GaloisClosed {F : TaskFrame | F.IsDiscrete} :=
  galoisClosed_of_indicator_iff _ validOn_nextTop_iff_isDiscrete
```

The defeq `F ∈ {F | Sat .Dense F}` ≡ `DenselyOrdered F.Duration` holds (as
`galoisClosed_sat_dense`'s existing docstring asserts), so no bridging is needed. Each corollary
drops from 3 lines to 1. Keep the two-argument `galoisClosed_of_indicator` — C-24 says "keeping
the current one", and the iff form is defined in terms of it.

---

## 3. Item (3) — naming the atom-realisation step

### 3.1 The review's proposed signature is the wrong shape

C-18 proposes an existential:
`∃ M τ, ∀ t, TruthAt M τ.val t (Formula.atom corrAtom) ↔ t ∈ A`. This is worse than what it
replaces: both (⇒) proofs need the *specific* `translationModel D A` by name in order to feed
it to `h (translationFrame D) (Formula.atom p) M τ x`, and an existential forces an `obtain`
that discards that identity. **Recommend the direct equational form instead.** Verified:

```lean
/-- The translation frame's reference total history, bundled as an `HF`. -/
def translationHF (D : TemporalOrder) : (translationFrame D).toTaskFrame.HF :=
  ⟨translationHist D, translationHist_isTotal D⟩

/-- **Atom realisation.** The translation frame realises an arbitrary `A ⊆ ↑D` as the truth set
of an atom along its reference history. -/
theorem translation_realizes (D : TemporalOrder) (A : Set ↑D) (p : Atom) (t : ↑D) :
    TruthAt (translationModel D A) (translationHF D).val t (Formula.atom p) ↔ t ∈ A :=
  translationModel_atom D A p t

theorem translation_realizes_allPast (D : TemporalOrder) (A : Set ↑D) (p : Atom) (u : ↑D) :
    TruthAt (translationModel D A) (translationHF D).val u (Formula.atom p).allPast
      ↔ ∀ r < u, r ∈ A := by
  rw [Truth.past_iff]
  exact forall_congr' fun r => forall_congr' fun _ => translation_realizes D A p r

theorem translation_realizes_allFuture (D : TemporalOrder) (A : Set ↑D) (p : Atom) (u : ↑D) :
    TruthAt (translationModel D A) (translationHF D).val u (Formula.atom p).allFuture
      ↔ ∀ r, u < r → r ∈ A := by
  rw [Truth.future_iff]
  exact forall_congr' fun r => forall_congr' fun _ => translation_realizes D A p r
```

`translation_realizes_allPast` is the real payload: it is **exactly** `hHiff`, hand-built inline
at `DurationFrames.lean:341-351` inside `validOn_co_iff_isComplete`, and it is the same step the
discrete proof performs twice ad hoc (`:277-281` for the antecedent, `:299-304` for the
consequent).

### 3.2 The dense proof needs a permissive twin — the review missed this

C-18 says "two of the three (`df`, `co`) use the *same* witness frame". Correct, and the
consequence it does not draw is that `validOn_dn_iff_denselyOrdered` uses
**`permissiveFrame`**, not `translationFrame`, so `translation_realizes` does not touch it.
Without a twin, item (3) improves two of three proofs and the "three (T1) proofs visibly
parallel" acceptance criterion fails. Verified twin:

```lean
def permissiveHF (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D) (f : ↑D → Bool) :
    (permissiveFrame D so nm).toTaskFrame.HF :=
  ⟨permissiveHist D so nm f, permissiveHist_isTotal D so nm f⟩

theorem permissive_realizes (D : TemporalOrder) (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D)
    (f : ↑D → Bool) (p : Atom) (t : ↑D) :
    TruthAt (permissiveModel D so nm) (permissiveHF D so nm f).val t (Formula.atom p)
      ↔ f t = true :=
  permissiveModel_atom D so nm f p t
```

### 3.3 Realistic line budget

C-18's "209 → ~110" assumes C-05 (`@[simp]` lemmas) and C-12 (`HF.ofTotal`) are also applied.
Both are **already in the tree**: `translationModel_atom` and `permissiveModel_atom` are already
`@[simp]`, and `WorldHistory.ofTotal` exists at `Semantics/WorldHistory.lean:143` with
`ofTotal_isTotal` (:152) and `@[simp] ofTotal_domain` (:166). So the plumbing C-18 counted has
partly been paid down already, and the remaining saving is smaller than 209 → 110. Measured
plumbing that the realisation lemmas actually remove:

- three `set τ : … .HF := ⟨…, …⟩ with hτ` blocks (2 lines each) → `translationHF`/`permissiveHF`
- ~9 `simp only [hτ, hM, translationModel_atom]` / `[hτ, permissiveModel_atom]` incantations
- the 11-line inline `hHiff` at `:341-351`

**Realistic target: 207 → ~150-160 lines**, with the three arguments visibly parallel. Plan to
the parallelism criterion, not to the 110 number.

Secondary opportunity (optional): `translationHist` (:110-118) and `permissiveHist` (:146-161)
still build the `domain := fun _ => True` record literally, which `WorldHistory.ofTotal` exists
to replace — the `ofTotal` docstring at `:130` explicitly says "Use `ofTotal` in preference to a
literal `domain := fun _ => True` record."

---

## 4. Item (4) — C-21: **do not relocate**. Measured.

The task asks to "check whether RationalWitness/LexIntWitness genuinely need
`Metalogic.Soundness` or whether StaticFrame's constant-truth calculus suffices."

**They genuinely need it.** Three call sites, all in the sandwiches, all resolving to
declarations in `Metalogic/Soundness.lean` itself (not the lighter `SoundnessLemmas/` tree):

| Site | Uses | Defined at |
|---|---|---|
| `RationalWitness.lean:119` `ratStaticFrame_mem_mod` | `axiom_dense_valid` | `Metalogic/Soundness.lean:1352` |
| `RationalWitness.lean:170` `sat_dedekind_subset_mod_axiomSet` | `axiom_dedekind_valid` | `Metalogic/Soundness.lean:1491` |
| `LexIntWitness.lean:173` `sat_discrete_subset_mod_axiomSet` | `axiom_discrete_valid` | `Metalogic/Soundness.lean:1360` |
| `LexIntWitness.lean:124` `lexIntStaticFrame_mem_mod` | `axiom_valid` | `Metalogic/Soundness.lean` |

StaticFrame's constant-truth calculus covers only the *non-Base* axiom branches (`prior_UZ`,
`prior_SZ`, `z1`, `prior_U_gap`, `prior_S_gap`, `sep`). The `minFrameClass ≤ .Base` /
`≤ .Dense` branch — the bulk of the 45 axioms — is discharged by soundness and by nothing else.
Since the **lower half of each sandwich** (`Sat fc ⊆ Mod (AxiomSet fc)`) *is* soundness of those
axioms, no reorganisation removes the dependency without deleting the result.

Moving these files to `Semantics/Correspondence/NonClosure.lean` would therefore create a
`Semantics → Metalogic.Soundness` import edge. That edge is **explicitly refused** in the tree's
own documentation: `Metalogic/Decidability/Verified/Decidable.lean:2758-2760` — "It is
emphatically **not** an edge to `Metalogic/Soundness.lean`, which remains refused".

**Verdict: take C-21's recommendation-1 (docs) and its documented fallback for
recommendation-2 (pointer discipline). Do not move any file.**

### 4.1 What actually needs editing

- `Metalogic/Independence.lean:14-49` — **already correct**. Lines 20-31 read "Three results are
  carried here, over six modules — the opening sentence of this docstring used to say 'the one
  result carried here', which stopped being true two witnesses ago", then enumerate all three
  families. No change needed. (The task description's premise that `:17-19` still says "the one
  result" is stale.)
- `Metalogic/Independence/README.md:6-9` — **still wrong**. Reads "The result carried here is
  that the paper's `CO` principle does **not** derive Reynolds's `Axiom.prior_U_gap`…". Rewrite
  to the three families, mirroring `Independence.lean`'s wording.
- `Metalogic/Independence/README.md` module table — stale line counts, measured with `wc -l`:
  `CoNotPriorU.lean` listed 584 / actual 552; `LoopingDuration.lean` listed 273 / actual 235;
  `LexIntWitness.lean` listed 258 / actual 200; `ClockFrame.lean` listed 240 / actual 236.
  (`RationalWitness.lean` 200 and `StaticFrame.lean` 323 are correct.) Regenerate with
  `scripts/readme-inventory.sh`.
- `Semantics/Correspondence/README.md` — add the reciprocal "See also" in **Key Results** naming
  `sat_dedekind_ssubset_mod_axiomSet` and `sat_discrete_ssubset_mod_axiomSet` as the non-closure
  complement of `galoisClosed_sat_dense` / `galoisClosed_isDiscrete`. Its **Related
  Documentation** section already points at the Independence README; the Key Results section
  does not.
- `Semantics/Correspondence/Indicator.lean` header — already names `LexIntWitness.lean` at `:41`
  and `:147`. Add the `RationalWitness.lean` half so the four-part picture (dense closed /
  paper-discrete closed / `Sat .Discrete` not closed / `Sat .Dedekind` not closed) is stated in
  one place.

---

## 5. Item (5) — `corrAtom`: parameterise, do not promote

C-25 offers "promote to non-`private`" **or, better, "drop it: both uses could take the atom as
a parameter"**. Take the second.

Grounds: (a) `DurationFrames.lean:177-179`'s own comment already says "any atom would do";
(b) the sibling `FwdRec.lean` `validOn_atomic_density_iff_fwdRec` already has a `∀ p : Atom`
binder yet inlines `Atom.mk "p" none` twice, at `:88` and `:97` (the review's `:104,:113`
anchors have drifted) — parameterising is what makes those two inlines removable; (c) `CoNotPriorU.lean` and `DiscreteNonCompactness.lean` already
take `(a : Atom)` parameters, so parameterisation is the established repo idiom; (d) a promoted
`Semantics.corrAtom` is a new public name with no mathematical content.

Verified: the §3.1 realisation lemmas all carry `(p : Atom)` and typecheck. Concretely:

1. Give `translation_realizes`, `translation_realizes_allPast`, `translation_realizes_allFuture`
   and `permissive_realizes` a `(p : Atom)` binder.
2. Delete `private def corrAtom`; the three (T1) proofs instantiate at any atom — use
   `Atom.mkBase "p"` (`Syntax/Atom.lean:117`), which already exists and is the idiomatic
   spelling of `⟨"p", none⟩`.
3. Replace `FwdRec.lean:88,97`'s two `Atom.mk "p" none` inlines with `Atom.mkBase "p"` (they sit
   in the (⇒) branch, where the theorem's own `p` binder is not in scope).

Out of scope but worth a `NOTE:` — `Metalogic/DiscreteNonCompactness.lean:253,282` and
`Metalogic/DedekindNonCompactness.lean:426,454` each re-inline `⟨"p", none⟩` / `⟨"q", none⟩`
via `set`. Same smell, different territory (`Metalogic/`, and task 524's neighbourhood).

---

## 6. Item (6) — delete `arch_of_lub`. Verified drop-in.

`Metalogic/SoundnessLemmas/Separability.lean:79` `private theorem arch_of_lub` is a
character-level copy of `Semantics/DurationClassification.lean:125` `archimedean_of_lub`, with
one difference: the private copy carries an **extra, unused `[Nontrivial D]`**. The public
lemma is therefore strictly more general and is a drop-in. Verified:

```lean
example {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) : Archimedean D :=
  Semantics.archimedean_of_lub h_lub
```

The single call site is `Separability.lean:148` inside `exists_countable_order_dense`, which has
`[Nontrivial D]` in scope, so the extra binder is discharged by simply not being needed.

### 6.1 The import edge is acyclic and cheap — measured

`Separability.lean` gains `import FormalSystem.Semantics.DurationClassification`. The transitive
`FormalSystem` closure of that module is **exactly three modules** —
`Semantics.DurationClassification`, `Semantics.TaskFrame`, `Semantics.TemporalOrder` — and
contains **no `FormalSystem.Metalogic` module at all**. No cycle; negligible build cost.

### 6.2 Three docstrings become false and must be edited in the same change

This is the part G-13 does not mention, and skipping it converts a duplication fix into a
documentation defect.

1. **`Metalogic/Decidability/Verified/Decidable.lean:2755-2757`** — "**On the import.**
   `SoundnessLemmas/Separability.lean` imports **only** Mathlib
   (`Algebra.Order.Archimedean.Basic`, `Data.Set.Countable`) — it mentions neither formulas nor
   truth — so the edge into this tree is acyclic by inspection". After the change it imports a
   `FormalSystem.Semantics` module. Rewrite to state the new closure (3 `Semantics` modules, no
   `Metalogic`), preserving the acyclicity claim, which still holds and is now measured rather
   than asserted. The adjacent sentence refusing the edge to `Metalogic/Soundness.lean` is
   unaffected and must stay.
2. **`Semantics/DurationClassification.lean:56-64`** — the "## Relation to
   `Metalogic/SoundnessLemmas/Separability.lean`" section says "That file carries a `private`
   copy of the same Archimedean argument (`arch_of_lub`) … The duplication is deliberate and is
   noted in both places rather than resolved by moving the helper, which would drag `Metalogic`
   proofs into a rebase." Delete or rewrite the whole section: the duplication is resolved, and
   the measurement in §6.1 refutes the stated reason for keeping it.
3. **`Separability.lean:73-78`** — the `arch_of_lub` docstring's own "Deliberate duplicate of
   `FormalSystem.Semantics.archimedean_of_lub` … This copy stays `private` and stays here"
   paragraph goes with the theorem.

---

## 7. Verification performed

Four probe files, all elaborated with `lake env lean` against the pinned toolchain
(Lean v4.33.0-rc1, Mathlib `79d0395a`), all **exit 0 with zero diagnostics**:

| Probe | Covers | Result |
|---|---|---|
| A — `GaloisProbe.lean` | abbrevs at `Type 1`; `rfl` defeq vs current `Th`/`Mod`; all 6 projections; `Order.isExtent_iff` bridge; `mod_th_gc`; 7 free lemmas; iff-indicator | clean |
| B — `RealizeProbe.lean` | `translationHF`, `translation_realizes{,_allPast,_allFuture}`, `permissiveHF`, `permissive_realizes`, all with `(p : Atom)` | clean |
| C — `IndicatorProbe.lean` | `galoisClosed_of_indicator_iff`; both retargeted corollaries; `IsExtent.inter` on the two existing results; `axiomSet_mono` | clean |
| D — `ArchProbe.lean` | `Semantics.archimedean_of_lub` at Separability's exact binder set | clean |

Probe sources are in the session scratchpad
(`/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/958b4e1c-5d27-4d7d-8049-a8e185f95ecd/scratchpad/`).
No source file under `FormalSystem/` was modified — this was a research dispatch. Working tree
carried only `specs/` changes throughout; no foreign source modifications or foreign builds
observed.

### 7.1 C2 baseline

`galoisClosed_*` are **not** C2 entries. Per `specs/ROADMAP.md:359-362`, C2 covers exactly four
theorems (`BXCanonical.completeness`, `.completeness_dense`, `.completeness_discrete`,
`.Chronicle.countermodel_dense`), plus two checked separately at
`scripts/check-module-invariants.sh:716-720`. `grep -rn galoisClosed scripts/` returns nothing.
The only C2-relevant risk is the new `Mathlib.Order.Concept` import; that module's own imports
are `Mathlib.Data.Set.Lattice` and `Mathlib.Order.Closure`, neither of which can introduce an
axiom beyond `propext` / `Classical.choice` / `Quot.sound`. Re-run
`scripts/check-module-invariants.sh` at the end regardless.

---

## 8. Explicit exclusions (per the task's DO NOT list)

- **C-14 / Walk / MinCyc** — not touched. `FwdRecPeriodicity.lean` is out of territory.
- **G-ecosystem §3.3 `ClosureOperator`** — not taken. Mathlib does offer `extentClosure`
  (`Concept.lean:159`), but §3.3's judgement that the `OrderDual` coercions cost more than they
  save stands, and §1.4's `IsExtent` corollaries deliver the same value dual-free.
- **U8 (`LexInt` namespace generalisation to `α ×ₗ ℤ`)** — listed in the task header but it is a
  `Semantics/LexCarrier.lean` + `LexIntWitness.lean` refactor discharging **C-16**, not one of
  the six numbered work items, and it collides with the item-(4) decision to leave
  `LexIntWitness.lean` in place. Recommend deferring to its own task.

---

## 9. Recommended phase decomposition

Ordered by dependency; each phase is independently buildable and green.

| Phase | Scope | Files | Risk |
|---|---|---|---|
| 1 | Galois layer on Concept (§1) + `galoisClosed_of_indicator_iff` (§2) | `Galois.lean` | Low — all verified |
| 2 | Retarget the two corollaries; add the `RationalWitness` pointer | `Indicator.lean` | Low |
| 3 | Realisation lemmas + `(p : Atom)`; delete `corrAtom`; rewrite the three (T1) proofs | `DurationFrames.lean`, `FwdRec.lean` | Medium — the only real proof work |
| 4 | Delete `arch_of_lub`, add the import, fix the three docstrings (§6.2) | `Separability.lean`, `DurationClassification.lean`, `Decidable.lean` | Low |
| 5 | READMEs: `Correspondence/README.md` (line counts + `Frames/Standard.lean` note + Key Results pointer), `Independence/README.md` (opening paragraph + line counts) | 2 READMEs | Low |

`Correspondence/README.md`'s module table is stale in four of six rows (measured):
`DurationFrames.lean` listed 563 / actual 409, `FwdRec.lean` 131 / 119,
`FwdRecPeriodicity.lean` 445 / 485, `FwdRecBridge.lean` 186 / 155. `Galois.lean` (183) and
`Indicator.lean` (161) are correct today and will both change in phases 1-2. Its
`DurationFrames.lean` description also still claims the file contains the translation and
permissive frames, which now live in `Semantics/Frames/Standard.lean`. Regenerate the table
with `scripts/readme-inventory.sh` **after** phases 1-4, not before.

Phase 3 is where a plan should spend its budget; phases 1, 2, 4 are transcription of verified
code. Zero sorries throughout — nothing here requires a proof that was not compiled during this
research.
