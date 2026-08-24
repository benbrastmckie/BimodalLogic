# Research: landing the set-based consequence layer

**Task type**: lean4 · **Session**: `sess_1787608533_153fad_423` · **Dispatch**: 6

**Governing design document**:
`specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/01_set-consequence-layer.md`
(hereafter **design/01**).

**Headline**: the module is fully implementable at zero sorries, and the complete text has been
**empirically verified to compile** in this session via `lean_run_code` against the live oleans —
all 19 declarations elaborate with zero diagnostics and `#print axioms` reports no `sorryAx` on
any of them. But design/01's §3 and §5 Lean fragments are **stale**: they were written against a
semantics that the tree no longer has. Transcribing them verbatim would fail to elaborate at all.
Section 2 below is the corrected, verified text.

---

## 1. Two blocking divergences between design/01 and the current tree

### D1 (critical) — the `Omega` / `ShiftClosed` binder pair no longer exists

design/01 §3 writes every `SetSemanticConsequence*` binder list as

```lean
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    (∀ ψ ∈ Γ, TruthAt M Omega τ t ψ) → TruthAt M Omega τ t φ
```

The live tree has no such thing:

- `ShiftClosed` **does not exist** anywhere under `FormalSystem/` outside `Boneyard/`
  (`grep -rn "def ShiftClosed" FormalSystem/` returns only
  `Boneyard/StrictSemanticsLegacy/Bundle/CanonicalConstruction.lean:347`, and that is
  `ShiftClosedCanonicalOmega`, a different declaration).
- `TruthAt` (`FormalSystem/Semantics/Truth.lean:159`) is **four-ary**, `TruthAt M τ t φ`. There is
  no admissible-history-set argument.
- Every validity predicate now uses the totality binder `(_ : τ.IsTotal)` in place of the
  `Omega`/`ShiftClosed`/`τ ∈ Omega` triple. `Validity.lean`'s own docstring (near :180) records
  the reason explicitly: *"There is no admissible-history parameter and no shift-closure side
  condition … totality is trivially preserved by `timeShift` … so time-shift invariance carries
  no side condition to quantify over. `TruthAt` takes no set argument."*

The design doc's §1 import list is affected too: it names `ShiftClosed (:333)` from
`Semantics/Truth`, which is gone.

**Consequence**: acceptance criterion 3 ("byte-comparable to its `Validity.lean` source") is the
binding constraint and it points at the *current* file, not at design/01's code block. **Where
design/01 §3/§5 and `Validity.lean` disagree, `Validity.lean` wins.** The task description is
already alert to this — it gives the four line hints as "hints only, re-verify by symbol before
use".

Line hints re-verified by symbol this session, all four correct:

| Definition to write | Mirrors | `Validity.lean` line (verified) |
|---|---|---|
| `SetSemanticConsequenceBase` | `valid` | 94 |
| `SetSemanticConsequenceDense` | `ValidDense` | 206 |
| `SetSemanticConsequenceDiscrete` | `ValidDiscrete` | 222 |
| `SetSemanticConsequenceDedekindDense` | `ValidDedekindDense` | 310 |

(design/01's own table cites 79/169/187/276 — all four have drifted. `ValidDedekind`, the §7
out-of-scope one, is now at :275, not :241.)

The `Type` vs `Type*` note is confirmed: the "deliberate" doc-comment is at `Validity.lean:92`
("Note: Uses `Type` (not `Type*`) to avoid universe level issues in proofs"), one line above
`def valid`. All four sources use bare `Type`. Use bare `Type`.

**In-tree precedent for exactly this surgery**: `SemanticConsequenceDedekindDense`
(`FormalSystem/Metalogic/StrongCompleteness.lean:129`) is `ValidDedekindDense`'s current binder
list with `(∀ ψ ∈ Γ, TruthAt M τ t ψ) →` inserted before the conclusion. It is the live template.
The only difference for this task is `Γ : Set Formula` instead of `Γ : Context`.

### D2 (blocking) — `strongCompletenessDense_of_compact` has a circular dependency

design/01 §5 proves `strongCompletenessDense_of_compact` using `derivable_foldr_imp_iff`, cited as
`StrongCompleteness.lean:222` — and that is where it still is. But `StrongCompleteness.lean` is
the module that **imports** `SetConsequence.lean`. Putting the theorem in `SetConsequence.lean`
as written is an import cycle.

Verified directly: compiling `#check @FormalSystem.Metalogic.derivable_foldr_imp_iff` against
`SetConsequence.lean`'s import set returns `Unknown identifier`. All four `foldr_imp` lemmas
(`truthAt_foldr_imp` :147, `derivable_of_derivable_foldr_imp` :184,
`derivable_foldr_imp_of_derivable` :205, `derivable_foldr_imp_iff` :222) live **only** in
`StrongCompleteness.lean`; nothing equivalent is in `Core/DeductionTheorem.lean`.

Everything else in §5 — `StrongCompletenessDense`, `CompactDense`, `SatisfiableDenseSet`,
`ModelExistenceDense` — is pure vocabulary and elaborates in `SetConsequence.lean` with no
problem (verified).

**Two resolutions, both empirically verified to compile. Recommend Option C.**

- **Option C (recommended)** — put the three §5 *definitions* plus `StrongCompletenessDense` in
  `SetConsequence.lean`, and place the single theorem `strongCompletenessDense_of_compact` in
  `StrongCompleteness.lean` (below the existing `derivable_foldr_imp_iff`, after the new import).
  Both files are in `file_scope`, so this needs no scope widening. It is a pure *addition* to
  both files — no deletion, no docstring churn. And it is arguably more faithful to design/01's
  own framing than the literal text is: §7 says this module "supplies vocabulary only", and
  `strongCompletenessDense_of_compact` is the one *theorem* in §5, not vocabulary.

- **Option M (alternative)** — relocate `derivable_of_derivable_foldr_imp`,
  `derivable_foldr_imp_of_derivable`, and `derivable_foldr_imp_iff` from `StrongCompleteness.lean`
  down into `SetConsequence.lean`, then transcribe §5 verbatim. Verified: all three reproduce
  **unchanged, character for character**, in `SetConsequence.lean`'s import context — they need
  only `Core.deductionConverse`, `Derivable.deduction`, and `Derivable.weaken`, all reachable via
  `Core/MaximalConsistent.lean`. Both files share namespace `FormalSystem.Metalogic`, so the sole
  in-proof consumer (`StrongCompleteness.lean:278`) keeps working untouched.
  Cost: deleting ~45 lines plus docstrings from `StrongCompleteness.lean`, whose module docstring
  cites them at :93, :95, and :371 — that bookkeeping is the only reason to prefer C.
  Do **not** duplicate the lemmas into both files; move or don't.

`truthAt_foldr_imp` (:147) is not needed by anything in scope and should stay put under either
option.

---

## 2. Verified module text

The following elaborated with **zero diagnostics** in a single `lean_run_code` against the live
oleans. It is the design/01 §2–§5 content with D1 applied. Docstrings are omitted here for
density — the implementer should carry design/01's docstrings across, editing out the
`Omega`/`ShiftClosed` references and correcting the cited line numbers.

### Imports (design/01 §1, corrected)

```lean
import FormalSystem.Syntax.Formula
import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.Validity
import FormalSystem.ProofSystem.Derivable
import FormalSystem.Metalogic.Core.MaximalConsistent

namespace FormalSystem.Metalogic

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem
```

`Semantics.Validity` alone would suffice (it transitively supplies `Truth`, and
`Core.MaximalConsistent` supplies `ProofSystem`), but the explicit list documents intent and
matches design/01. No `BXCanonical` import, satisfying acceptance criterion 2.

### §2 — set-derivability

```lean
def SetDerivable (fc : FrameClass) (Γ : Set Formula) (φ : Formula) : Prop :=
  ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ Derivable fc L φ
```

Unchanged from design/01. Composes with `Core.SetConsistent`
(`Core/MaximalConsistent.lean:96`, verified verbatim as design/01 quotes it).

### §3 — the four per-class predicates (D1-corrected)

```lean
def SetSemanticConsequenceBase (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

def SetSemanticConsequenceDense (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

def SetSemanticConsequenceDiscrete (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D] [PredOrder D]
    [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

def SetSemanticConsequenceDedekindDense (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D]
    (_ : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ
```

Each binder block above was produced by mechanically slicing `Validity.lean` from the line after
the `def` header to the line before `TruthAt M τ t φ`, so byte-comparability (criterion 3) holds
by construction. Line-continuation and indentation are the source's, including `ValidDense`'s and
`ValidDedekindDense`'s wrapping of `[Nontrivial D]` onto its own line.

### §4 — basic lemmas

```lean
theorem setDerivable_mono {fc : FrameClass} {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetDerivable fc Γ φ) : SetDerivable fc Δ φ := by
  obtain ⟨L, hL, hd⟩ := h
  exact ⟨L, fun ψ hψ => h_sub (hL ψ hψ), hd⟩

theorem setSemanticConsequenceBase_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceBase Γ φ) : SetSemanticConsequenceBase Δ φ := by
  intro D _ _ _ _ F M τ hτ t h_all
  exact h D F M τ hτ t (fun ψ hψ => h_all ψ (h_sub hψ))

theorem setSemanticConsequenceDense_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceDense Γ φ) : SetSemanticConsequenceDense Δ φ := by
  intro D _ _ _ _ _ F M τ hτ t h_all
  exact h D F M τ hτ t (fun ψ hψ => h_all ψ (h_sub hψ))

theorem setSemanticConsequenceDiscrete_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceDiscrete Γ φ) :
    SetSemanticConsequenceDiscrete Δ φ := by
  intro D _ _ _ _ _ _ _ _ F M τ hτ t h_all
  exact h D F M τ hτ t (fun ψ hψ => h_all ψ (h_sub hψ))

theorem setSemanticConsequenceDedekindDense_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceDedekindDense Γ φ) :
    SetSemanticConsequenceDedekindDense Δ φ := by
  intro D _ _ _ _ _ hlub F M τ hτ t h_all
  exact h D hlub F M τ hτ t (fun ψ hψ => h_all ψ (h_sub hψ))

theorem setDerivable_iff_exists_finite {fc : FrameClass} (Γ : Set Formula) (φ : Formula) :
    SetDerivable fc Γ φ ↔ ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ Derivable fc L φ :=
  Iff.rfl

theorem setDerivable_of_derivable {fc : FrameClass} (Γ : Context) (φ : Formula)
    (h : Derivable fc Γ φ) : SetDerivable fc (Core.contextToSet Γ) φ :=
  ⟨Γ, fun _ hψ => hψ, h⟩

theorem derivable_of_setDerivable_contextToSet {fc : FrameClass} (Γ : Context) (φ : Formula)
    (h : SetDerivable fc (Core.contextToSet Γ) φ) : Derivable fc Γ φ := by
  obtain ⟨L, hL, hd⟩ := h
  exact hd.weaken (fun _ hx => hL _ hx)

theorem setDerivable_of_mem {fc : FrameClass} {Γ : Set Formula} {φ : Formula} (h : φ ∈ Γ) :
    SetDerivable fc Γ φ :=
  ⟨[φ], by simpa using h, ⟨DerivationTree.assumption _ _ (by simp)⟩⟩

theorem not_setConsistent_of_setDerivable_bot {fc : FrameClass} {Γ : Set Formula}
    (h : SetDerivable fc Γ Formula.bot) : ¬ Core.SetConsistent (fc := fc) Γ := by
  obtain ⟨L, hL, hd⟩ := h
  exact fun hcons => hcons L hL hd
```

The four sibling `_mono` lemmas are *not* verbatim copies of the Base one: each `intro` pattern
carries one `_` per instance binder, so Base takes 4, Dense 5, Discrete 8, and DedekindDense 5
plus a *named* `hlub` (the LUB hypothesis is explicit, so it must be threaded to `h` as
`h D hlub F M τ hτ t`). Getting these counts wrong is the likeliest transcription slip.

**Resolution of design/01's three flagged elaboration risks**, all settled empirically:

1. *`derivable_of_setDerivable_contextToSet` / the `weaken` coercion.* Real, and the fix is the
   one design/01 predicted. `Derivable.weaken` (`ProofSystem/Derivable.lean:147`) is
   `(h : Derivable fc G p) (hsub : G ⊆ D) : Derivable fc D p`. Bare `hd.weaken hL` does not go
   through; `hd.weaken (fun _ hx => hL _ hx)` does. (`Core.contextToSet Γ = {φ | φ ∈ Γ}` at
   `MaximalConsistent.lean:123`, so the two sides are definitionally equal and the eta-expansion
   is all that is needed.)
2. *`not_setConsistent_of_setDerivable_bot` and the `Consistent` unfold.* **Not** a risk — no
   `simp only [Core.Consistent]` is needed. `exact fun hcons => hcons L hL hd` elaborates as
   written, because `SetConsistent` (`:96`) unfolds to `∀ L, (∀ φ ∈ L, φ ∈ S) → Consistent L`
   and `Consistent` (`:67`) to `¬Derivable fc Γ Formula.bot` definitionally.
3. *`DerivationTree.assumption`, marked `[UNVERIFIED]` by design/01.* Now **verified**:
   `FormalSystem/ProofSystem/Derivation.lean:105` declares
   `| assumption (Γ : Context) (φ : Formula) (h : φ ∈ Γ) : DerivationTree fc Γ φ` — arity 3, as
   design/01 guessed. `Derivable fc G p` is `Nonempty (DerivationTree fc G p)`
   (`Derivable.lean:69`), so the outer `⟨…⟩` is the `Nonempty.intro`. The fragment compiles
   exactly as written.

### §5 — strong-completeness statements

```lean
def StrongCompletenessDense : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula),
    SetSemanticConsequenceDense Γ φ → SetDerivable FrameClass.Dense Γ φ

def CompactDense : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula), SetSemanticConsequenceDense Γ φ →
    ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ ValidDense (L.foldr Formula.imp φ)

def SatisfiableDenseSet (Γ : Set Formula) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (_ : DenselyOrdered D) (_ : Nontrivial D)
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    ∀ ψ ∈ Γ, TruthAt M τ t ψ

def ModelExistenceDense : Prop :=
  ∀ Γ : Set Formula,
    (∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) → SatisfiableDenseSet {ψ | ψ ∈ L}) →
    SatisfiableDenseSet Γ
```

`SatisfiableDenseSet`'s existentials over instance-valued binders were a plausible elaboration
risk; they are not one. `FormulaSatisfiable` (`Validity.lean:190`) is already exactly this shape
in the tree — `∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
(_ : Nontrivial D) (F : TaskFrame D) …` — so the pattern is precedented, and the version above
compiles. `SatisfiableAbs` (`:170`) is the same idea for contexts. The version above is
`FormulaSatisfiable` with `(_ : DenselyOrdered D)` inserted in `ValidDense`'s binder position and
the conclusion generalised to `∀ ψ ∈ Γ`.

And then, per D2, in **`StrongCompleteness.lean`** (Option C):

```lean
theorem strongCompletenessDense_of_compact (hc : CompactDense)
    (engine : ∀ ψ : Formula, ValidDense ψ → Derivable FrameClass.Dense [] ψ) :
    StrongCompletenessDense := by
  intro Γ φ h
  obtain ⟨L, hL, hvalid⟩ := hc Γ φ h
  exact ⟨L, hL, (derivable_foldr_imp_iff L φ).mpr (engine _ hvalid)⟩
```

verbatim from design/01 — verified to compile once `derivable_foldr_imp_iff` is in scope.

---

## 3. Acceptance-criteria status (design/01 §6)

All five are reachable; four are pre-verified in this session against the live oleans.

| # | Criterion | Status |
|---|---|---|
| 1 | Zero sorries, zero vacuous placeholders | **Verified.** Full module text elaborated with zero diagnostics; every declaration has real content. |
| 2 | `grep -c 'import FormalSystem.Metalogic.BXCanonical'` on the new module returns 0 | **Verified by construction** — the import list in §2 above has no BXCanonical entry, and nothing in the module needs one. |
| 3 | Binder lists byte-comparable to `Validity.lean`, `Type` not `Type*` | **Verified.** Blocks mechanically sliced from `Validity.lean` at :94/:206/:222/:310; all four use bare `Type`; the "deliberate" doc-comment is at :92. Note this is against the *current* file, contradicting design/01's own §3 code block (see D1). |
| 4 | `#print axioms` on every new declaration reports no `sorryAx` | **Verified.** All 19 declarations run: each reports `[propext]` only, except `setDerivable_of_mem` (`[propext, Quot.sound]`). No `sorryAx` anywhere. Upstream dependencies also checked clean: `Core.deductionConverse` `[propext]`, `Derivable.weaken` `[propext]`, `Derivable.deduction` `[propext, Classical.choice, Quot.sound]`, `Core.SetConsistent` `[propext]`, `Core.contextToSet` none. |
| 5 | `StrongCompleteness.lean` imports the module and still builds | **Not yet run** — needs a real `lake build` after the files land. This is the one criterion that cannot be pre-verified from snippets. |

For criterion 5: add `import FormalSystem.Metalogic.SetConsequence` to `StrongCompleteness.lean`'s
import block (currently lines 7–10). `FormalSystem/Metalogic.lean` already imports
`StrongCompleteness`, so the new module is transitively reachable from the library root with no
aggregator edit — which is just as well, since `Metalogic.lean` is outside `file_scope`.

---

## 4. Environment and scope notes

- **The design/01 build-lock banner does not apply.** `.lake/.task-418-build.lock` is absent;
  `FormalSystem/` edits and `lake build` are permitted. (design/01 explicitly says to re-check.)
- **`FrameClass`** is `ProofSystem/Axioms.lean:519`, constructors `Base | Dense | Discrete |
  Dedekind`. There is no `.DedekindDense` constructor — `SetSemanticConsequenceDedekindDense` is
  named for `ValidDedekindDense`, and `StrongCompletenessDense` correctly targets
  `FrameClass.Dense`.
- **design/01 §5's "engine is already dischargeable" claim still holds.**
  `BXCanonical.completeness_dense` is at `Completeness.lean:256` with type
  `ValidDense φ → Derivable FrameClass.Dense [] φ`, matching the `engine` hypothesis shape. Its
  module docstring records it as sorryAx-free. Nothing in this task consumes it — noted only so
  the downstream Dense branch knows the hypothesis is live.
- **Out of scope, per design/01 §7 and the task description**: `SetSemanticConsequenceDedekind`
  (against `ValidDedekind`, now `:275`); the compactness proofs themselves; `consequence_completeness_*`
  for Base/Dense/Discrete. `truthAt_foldr_imp` relocation is also out of scope.
- **Not attempted, deliberately**: no `lake build` was run, since no tree edit was made. The
  research used `lean_run_code` against existing oleans throughout.

---

## 5. Recommended phase decomposition

1. **Write `FormalSystem/Metalogic/SetConsequence.lean`** — header, imports, §2, §3, §4, and the
   four §5 definitions, using the verified text in section 2 above, with design/01's docstrings
   carried across and D1-corrected. Build.
2. **Edit `FormalSystem/Metalogic/StrongCompleteness.lean`** — add the import; add
   `strongCompletenessDense_of_compact` after `derivable_foldr_imp_iff` (Option C). Build.
3. **Verification gate** — `lake build`; `grep -c 'import FormalSystem.Metalogic.BXCanonical'`;
   binder-list diff against `Validity.lean`; `#print axioms` sweep over all new declarations.

Phases 1 and 2 touch disjoint files and are both well under one agent run.
