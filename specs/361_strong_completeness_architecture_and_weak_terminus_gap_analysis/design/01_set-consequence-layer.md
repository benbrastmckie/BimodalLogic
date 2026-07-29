# Design: the set-based consequence layer

**Source**: `reports/01_strong-completeness-architecture-gap-analysis.md` §2 (authoritative).
**Status**: design proposal. **Nothing in this document exists in the tree.**
**Intended consumer**: the spawned task N3 (symbolic ID `S0`).

---

## STANDING CONSTRAINT BANNER

> Every Lean fragment in this document is a **design proposal held inside a `specs/` document**,
> not a tree edit. At the time of writing, a separate session owns task 418 and holds the
> advisory build lock `.lake/.task-418-build.lock`. While that lock is held:
>
> - **MUST NOT** run `lake build`, `lake clean`, `lake exe`, or the `lean_build` MCP tool.
> - **MUST NOT** create, edit, or delete any file under `FormalSystem/` or `Tests/`.
> - **PERMITTED**: read-only `lean-lsp` queries and `Read`/`Grep`/`Glob` over the tree.
>
> The downstream implementer inherits this constraint **only if the lock is still held** when
> the task is dispatched. Check `.lake/.task-418-build.lock` before assuming it applies.

---

## 1. Module header

| Field | Value |
|---|---|
| Proposed module path | `FormalSystem/Metalogic/SetConsequence.lean` |
| Verified absent from the tree | yes — `git ls-files 'FormalSystem/**'` has no near-match for `setconsequence` |
| Intended consumer | `FormalSystem/Metalogic/StrongCompleteness.lean` (imports this module) |
| Namespace | `FormalSystem.Metalogic` |

Proposed imports (each named because the definitions below cite it):

```lean
import FormalSystem.Syntax.Formula            -- Formula, Formula.next (:490)
import FormalSystem.Semantics.Truth           -- TruthAt (:128-137), ShiftClosed (:333)
import FormalSystem.Semantics.Validity        -- valid (:79), ValidDense (:169), …
import FormalSystem.ProofSystem.Derivable     -- Derivable (:69), Derivable.weaken (:147)
import FormalSystem.Metalogic.Core.MaximalConsistent  -- SetConsistent (:96), contextToSet (:123)
```

The module **must not** import anything from `FormalSystem/Metalogic/BXCanonical/`. The set layer
is vocabulary; the chronicle machinery is a countermodel engine, and (per
`design/02_compactness-route.md` §Q2) the two must not become entangled.

---

## 2. Finitary set-derivability (report §2.1)

```lean
namespace FormalSystem.Metalogic

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

/--
Finitary derivability from a possibly-infinite premise set. A derivation is a finite object
and can cite only finitely many premises, so this is the only derivability notion a finitary
proof system can support over `Set Formula`.
-/
def SetDerivable (fc : FrameClass) (Γ : Set Formula) (φ : Formula) : Prop :=
  ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ Derivable fc L φ
```

This is exactly the relation named in `StrongCompleteness.lean`'s module docstring (:34-38) and
in the `consequence_completeness_dedekind_of_engine` docstring region (:257-272).

**Why this shape and no other**: it deliberately matches `SetConsistent`
(`Core/MaximalConsistent.lean:96`), verified verbatim as

```lean
def SetConsistent {fc : FrameClass} (S : Set Formula) : Prop :=
  ∀ L : List Formula, (∀ φ ∈ L, φ ∈ S) → Consistent (fc := fc) L
```

so the two compose without an adapter. `Consistent Γ` unfolds to `¬Derivable fc Γ Formula.bot`
(`MaximalConsistent.lean:67`), and `Derivable fc G p` unfolds to `Nonempty (DerivationTree fc G p)`
(`ProofSystem/Derivable.lean:69`) — both facts are load-bearing for the proofs in §4 below.

---

## 3. Per-class set-based semantic consequence (report §2.2)

Each definition below is the corresponding validity predicate's binder list **verbatim** from
`FormalSystem/Semantics/Validity.lean`, with the premise hypothesis
`(∀ ψ ∈ Γ, TruthAt M Omega τ t ψ)` inserted before the conclusion — the same surgery that
`SemanticConsequenceDedekindDense` (`StrongCompleteness.lean:128`) performs on
`ValidDedekindDense`. `Γ : Set Formula` rather than `Γ : Context` is the only difference from the
finite-context forms; `∀ ψ ∈ Γ` elaborates identically for `Set` and `List`.

Binder-list anchors, each re-read against the tree in this session:

| Definition below | Mirrors | `Validity.lean` line (verified) |
|---|---|---|
| `SetSemanticConsequenceBase` | `valid` | 79 |
| `SetSemanticConsequenceDense` | `ValidDense` | 169 |
| `SetSemanticConsequenceDiscrete` | `ValidDiscrete` | 187 |
| `SetSemanticConsequenceDedekindDense` | `ValidDedekindDense` | 276 |

```lean
/-- Set-based semantic consequence over `FrameClass.Base`. Binder list: `valid` (Validity.lean:79). -/
def SetSemanticConsequenceBase (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    (∀ ψ ∈ Γ, TruthAt M Omega τ t ψ) → TruthAt M Omega τ t φ

/-- Set-based semantic consequence over `FrameClass.Dense`. Binder list: `ValidDense` (:169). -/
def SetSemanticConsequenceDense (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    (∀ ψ ∈ Γ, TruthAt M Omega τ t ψ) → TruthAt M Omega τ t φ

/-- Set-based semantic consequence over `FrameClass.Discrete`. Binder list: `ValidDiscrete` (:187).
    Stated for completeness of the layer; strong completeness at this class is REFUTED
    (non-compactness — see `design/02_compactness-route.md`). -/
def SetSemanticConsequenceDiscrete (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D] [PredOrder D]
    [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    (∀ ψ ∈ Γ, TruthAt M Omega τ t ψ) → TruthAt M Omega τ t φ

/-- Set-based semantic consequence over dense Dedekind-complete carriers. Binder list:
    `ValidDedekindDense` (:276) — the `soundness_dedekind` target. Non-compact. -/
def SetSemanticConsequenceDedekindDense (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D]
    (_ : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    (∀ ψ ∈ Γ, TruthAt M Omega τ t ψ) → TruthAt M Omega τ t φ
```

---

## 4. Basic lemmas (report §2.3)

```lean
/-! ### Monotonicity -/

theorem setDerivable_mono {fc : FrameClass} {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetDerivable fc Γ φ) : SetDerivable fc Δ φ := by
  obtain ⟨L, hL, hd⟩ := h
  exact ⟨L, fun ψ hψ => h_sub (hL ψ hψ), hd⟩

theorem setSemanticConsequenceBase_mono {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceBase Γ φ) : SetSemanticConsequenceBase Δ φ := by
  intro D _ _ _ _ F M Omega h_sc τ h_mem t h_all
  exact h D F M Omega h_sc τ h_mem t (fun ψ hψ => h_all ψ (h_sub hψ))
-- and the three siblings, each a one-line binder permutation of this.

/-! ### Finite restriction / agreement with the finite-context layer -/

/-- Every set-derivation restricts to a finite context. Definitional, but worth naming: it is
    the statement the compactness argument consumes. -/
theorem setDerivable_iff_exists_finite {fc : FrameClass} (Γ : Set Formula) (φ : Formula) :
    SetDerivable fc Γ φ ↔ ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ Derivable fc L φ :=
  Iff.rfl

/-- A finite context is set-derivable from its own carrier set. -/
theorem setDerivable_of_derivable {fc : FrameClass} (Γ : Context) (φ : Formula)
    (h : Derivable fc Γ φ) : SetDerivable fc (Core.contextToSet Γ) φ :=
  ⟨Γ, fun _ hψ => hψ, h⟩

/-- …and conversely, so the set layer is a conservative extension of the finite layer. -/
theorem derivable_of_setDerivable_contextToSet {fc : FrameClass} (Γ : Context) (φ : Formula)
    (h : SetDerivable fc (Core.contextToSet Γ) φ) : Derivable fc Γ φ := by
  obtain ⟨L, hL, hd⟩ := h
  exact hd.weaken hL

/-- Membership gives derivability. -/
theorem setDerivable_of_mem {fc : FrameClass} {Γ : Set Formula} {φ : Formula} (h : φ ∈ Γ) :
    SetDerivable fc Γ φ :=
  ⟨[φ], by simpa using h, ⟨DerivationTree.assumption _ _ (by simp)⟩⟩

/-! ### The bridge to `SetConsistent` (already in the tree, Core/MaximalConsistent.lean:96) -/

theorem not_setConsistent_of_setDerivable_bot {fc : FrameClass} {Γ : Set Formula}
    (h : SetDerivable fc Γ Formula.bot) : ¬ Core.SetConsistent (fc := fc) Γ := by
  obtain ⟨L, hL, hd⟩ := h
  exact fun hcons => hcons L hL hd
```

### Implementer notes on these proofs

These proof scripts are **report-level sketches, not elaborated Lean**. Three specific points the
implementer should expect to adjust, each grounded in a definition verified this session:

1. `derivable_of_setDerivable_contextToSet` uses `hd.weaken hL`. The tree's
   `Derivable.weaken` (`ProofSystem/Derivable.lean:147`) has signature
   `(h : Derivable fc G p) (hsub : G ⊆ D) : Derivable fc D p` — it wants a `List`/`Context`
   subset relation `L ⊆ Γ`, whereas `hL : ∀ ψ ∈ L, ψ ∈ Core.contextToSet Γ`. Since
   `contextToSet Γ = {φ | φ ∈ Γ}` (`MaximalConsistent.lean:123`) these are definitionally the
   same statement, but a coercion step (`fun _ h => hL _ h`) is likely required at elaboration.
2. `not_setConsistent_of_setDerivable_bot` relies on `Consistent Γ` unfolding to
   `¬Derivable fc Γ Formula.bot` (`MaximalConsistent.lean:67`). The `exact fun hcons => hcons L hL hd`
   is correct modulo that unfold; a `simp only [Core.Consistent]` may be needed.
3. `setDerivable_of_mem` cites `DerivationTree.assumption`. The exact constructor name and arity
   were **not** verified against `ProofSystem/Derivation.lean` in this session — the implementer
   must confirm it before transcribing. `[UNVERIFIED]`

---

## 5. Strong completeness and how it is discharged (report §2.4)

```lean
/-- **Strong completeness for `FrameClass.Dense`** — the reserved statement. -/
def StrongCompletenessDense : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula),
    SetSemanticConsequenceDense Γ φ → SetDerivable FrameClass.Dense Γ φ

/-- Semantic compactness of the Dense consequence relation, stated in the form the
    completeness derivation actually consumes. -/
def CompactDense : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula), SetSemanticConsequenceDense Γ φ →
    ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ ValidDense (L.foldr Formula.imp φ)

/--
**Strong completeness = compactness + weak completeness.** No new proof-theoretic machinery,
no `Γ`-relative Lindenbaum, no widened subformula root: the countermodel engine is used
unchanged, as a single-formula engine, exactly as `StrongCompleteness.lean`'s engine contract
(:40-43) specifies.

`derivable_foldr_imp_iff` (StrongCompleteness.lean:222) is already proved and already generic
in `fc`, so it needs no per-class instance.
-/
theorem strongCompletenessDense_of_compact (hc : CompactDense)
    (engine : ∀ ψ : Formula, ValidDense ψ → Derivable FrameClass.Dense [] ψ) :
    StrongCompletenessDense := by
  intro Γ φ h
  obtain ⟨L, hL, hvalid⟩ := hc Γ φ h
  exact ⟨L, hL, (derivable_foldr_imp_iff L φ).mpr (engine _ hvalid)⟩
```

**Verified in this session**: `derivable_foldr_imp_iff` exists at `StrongCompleteness.lean:222`
and is generic in `{fc : FrameClass}`. The engine contract prose is at `StrongCompleteness.lean:40-43`
("the engine never sees a context. It is fed the single formula `Γ.foldr Formula.imp φ` and
returns a derivation from `[]`").

**Verified in this session**: the `engine` hypothesis for Dense is *already dischargeable today*.
`lean_verify` against current oleans reports
`FormalSystem.Metalogic.BXCanonical.completeness_dense` with axioms exactly
`[propext, Classical.choice, Quot.sound]` — no `sorryAx`. Its type is
`ValidDense φ → Derivable FrameClass.Dense [] φ` (`Completeness.lean:255-256`), which is exactly
the `engine` shape. **So `CompactDense` is the entire remaining obligation for Dense strong
completeness.** For Base, the analogous statement additionally waits on the Transfer.lean sorry
(see `design/03_weak-terminus-status.md`).

The model-existence form, which is what the ultraproduct construction proves directly:

```lean
def SatisfiableDenseSet (Γ : Set Formula) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (_ : DenselyOrdered D) (_ : Nontrivial D)
    (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (_ : ShiftClosed Omega) (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    ∀ ψ ∈ Γ, TruthAt M Omega τ t ψ

def ModelExistenceDense : Prop :=
  ∀ Γ : Set Formula,
    (∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) → SatisfiableDenseSet {ψ | ψ ∈ L}) →
    SatisfiableDenseSet Γ
```

`ModelExistenceDense → CompactDense` is a contraposition through the `Formula.neg` clause of
`TruthAt` and `truthAt_foldr_imp` (`StrongCompleteness.lean:147`, verified present, already proved
and already stated at the bare `TaskModel` binder set so it is reusable here unchanged).

---

## 6. Acceptance criteria for the implementing task

The task that lands this module (N3 / `S0`) is accepted when **all** of the following hold:

1. **Zero sorries.** No `sorry`, no `admit`, no vacuous placeholder (`def X := True`,
   `theorem X := trivial`, and every variant). If a lemma cannot be proved, the task escalates
   as [BLOCKED] rather than landing a placeholder.
2. **No `BXCanonical/` import.** `grep -c 'import FormalSystem.Metalogic.BXCanonical'` on the new
   module returns 0.
3. **Binder-list fidelity.** Each of the four `SetSemanticConsequence*` definitions is
   byte-comparable to its `Validity.lean` binder list (rows of the table in §3 above) with only
   the premise hypothesis `(∀ ψ ∈ Γ, TruthAt M Omega τ t ψ)` inserted before the conclusion. Any
   deviation — a reordered instance binder, a `Type*` where the source says `Type` — is a defect,
   not a style choice: `Validity.lean:77` records that `Type` (not `Type*`) is deliberate, "to
   avoid universe level issues in proofs".
4. **`#print axioms` on every new declaration** reports no `sorryAx`.
5. **`StrongCompleteness.lean` imports the new module** and still builds.

---

## 7. Not in this layer

- **`SetSemanticConsequenceDedekind`** (against `ValidDedekind`, `Validity.lean:241` — the
  no-`DenselyOrdered` variant, verified present) can be added by exactly the same recipe. It is
  **not** the soundness target and is **not** needed by the programme, so it is deliberately
  omitted. Add it only if a consumer appears.
- **The compactness proofs themselves.** `CompactDense` / `CompactBase` are *stated* here and
  proved elsewhere (see `design/02_compactness-route.md`); this module supplies vocabulary only.
- **`consequence_completeness_*` for Base/Dense/Discrete** — the finite-context layer reserved at
  `StrongCompleteness.lean:314-340`. That is task 362's territory and is mechanical once each
  class's engine exists.

---

## 8. Divergences from the research report

None material for this document. All Lean fragments are reproduced from report §2.1-§2.4; every
`Validity.lean`, `MaximalConsistent.lean`, `Derivable.lean`, and `StrongCompleteness.lean` line
number cited above was independently re-verified against the tree in this session and matched.
The only additions are the implementer notes in §4 (three elaboration risks the report did not
call out) and the explicit acceptance criteria in §6.
