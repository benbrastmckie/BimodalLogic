# Research: refuted-route comment correction and the `ℚ ×ₗ ℤ` carrier probe

**Task type**: lean4
**Session**: sess_1787608533_153fad_421
**Scope**: `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` (comment-only),
`FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean` (new file)

---

## 0. Executive summary

Both deliverables are small and **both are now machine-verified as feasible**, not merely
plausible:

1. **(a)** The refuted-route comment sits at `Transfer.lean:1081-1083` (exact text quoted in §2).
   It is three `--` lines inside the body of `countermodel_discrete`, immediately above the
   `sorry` at `:1084`. Replacing it touches nothing else. The `ℤ ×ₗ ℤ` witness the replacement
   must record is *realizable in this repository's own semantics*: all four `FrameClass.Base`
   carrier binders discharge at `ℤ ×ₗ ℤ` by instance search (verified, §4.2).
2. **(b)** The probe block **compiles**. A candidate `DiscreteCarrierProbe.lean` was written,
   built as a real project module under the library's own `leanOptions`
   (`lake build FormalSystem.Metalogic.BXCanonical.DiscreteCarrierProbe` → `✔ [1359/1359]`,
   zero errors, zero new warnings), and then removed from the tree. Its full verified text is in
   §5.1 and can be landed as-is.

The single non-obvious finding, and the one that would have cost the implementation phase a
dispatch: **`IsOrderedAddMonoid (ℚ ×ₗ ℤ)` does NOT resolve in the project's current import
closure.** `Mathlib.Algebra.Order.Monoid.Prod` is not reachable from any `FormalSystem` module
today, and it is not even built by default (`lake build Mathlib.Algebra.Order.Monoid.Prod` was
needed once). One added import line fixes it; without it the probe fails with
`failed to synthesize IsOrderedAddMonoid (Lex (ℚ × ℤ))`. See §4.3.

Baseline recorded before any work: `scripts/check-module-invariants.sh` → **ALL CHECKS PASSED**,
C3 reporting the sole structural sorry as `countermodel_discrete` in `Transfer.lean`.

---

## 1. Zero-debt / no-new-sorry posture

Neither deliverable introduces or removes a proof obligation. (a) is comment text; (b) is a block
of anonymous `example`s. The live non-Boneyard sorry count stays at 1 by construction. Nothing in
this report recommends a `sorry`, an axiom, or a deferral.

**One acceptance-criterion note.** The task's acceptance line "`#print axioms` on any new
declaration shows no `sorryAx`" is **vacuous under the recommended implementation**, because the
CarrierProbe pattern the task asks the new block to mirror uses `example` exclusively, and
`example`s create no named constants to run `#print axioms` on. This is not a gap — it is the
correct reading of "CarrierProbe-style example block". The implementer should record the criterion
as vacuously satisfied rather than inventing a named theorem to satisfy it. (If the orchestrator
prefers a checkable declaration, the minimal honest choice is to name exactly one of the four
instance probes, e.g. `theorem discreteCarrier_isOrderedAddMonoid : IsOrderedAddMonoid (ℚ ×ₗ ℤ) :=
inferInstance` — but this exports a redundant declaration and diverges from the mirrored pattern,
so it is *not* the recommendation.)

---

## 2. Deliverable (a): the exact comment to replace

### 2.1 Located text (verified this session)

`FormalSystem/Metalogic/WeakCanonical/Transfer.lean`, lines **1081-1083** (the task's hint said
"near :1081-1083" — exact). Anchor by the opening text `-- Two candidate routes: (i) a Base-MCS`:

```lean
  -- Two candidate routes: (i) a Base-MCS → Discrete-MCS transfer lemma that lets
  -- countermodel_discrete_reynolds_v2 apply, or (ii) a Henkin-style discrete canonical
  -- model built directly from a Base-MCS. See the section docstring above.
```

Immediately above (`:1077-1080`) are four `-- SORRY: open obligation …` lines that must be left
alone; immediately below (`:1084`) is the `sorry`, which this task must not touch.

### 2.2 The refutation, re-verified against the tree

Every load-bearing claim of design doc §5.3 was re-checked against source, not taken on trust:

| Claim | Verified at | Status |
|---|---|---|
| `z1` is Discrete-only | `ProofSystem/Axioms.lean:593` — `\| z1 _ => .Discrete` | confirmed |
| `z1 φ = G(Gφ→φ) → (FGφ→Gφ)` | `Axioms.lean:347-348` | confirmed verbatim |
| `z1` is the IsSuccArchimedean axiom | `Axioms.lean:342-346` docstring | confirmed |
| `FrameClass.Base` has no Archimedean binder | `Semantics/Validity.lean:94-98` — `valid` binds exactly `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]` | confirmed |
| `ℤ ×ₗ ℤ` is an admissible Base carrier | all four binders resolve by `inferInstance` (§4.2) | **newly machine-verified** |
| `nextTop` = "an immediate successor exists" | `WeakCanonical/ReflexiveCanonical.lean:694` — `untl ⊥ (⊥ → ⊥)`, guard-first, so: some strictly later `s` with `⊤` there and `⊥` throughout `(t,s)` | confirmed |
| Lindenbaum available | `Core/MaximalConsistent.lean`, `set_lindenbaum` | confirmed present |

So: over `D := ℤ ×ₗ ℤ` with `p` true exactly at points `≥ (1,0)`, every `(a,b)` has immediate
successor `(a,b+1)` ⇒ `nextTop` holds everywhere ⇒ `□ nextTop` holds; `Gp` holds exactly at points
`≥ (1,0)` ⇒ `Gp → p` holds everywhere ⇒ `G(Gp→p)` holds at `(0,0)`; `FGp` holds at `(0,0)` with
witness `(1,0)`; `Gp` fails at `(0,0)` with witness `(0,1)` (which is `> (0,0)` but `≱ (1,0)`).
Antecedent true, consequent false ⇒ `Axiom.z1 p` false at `(0,0)`. Hence
`{□ nextTop, G(Gp→p), FGp, ¬Gp}` is Base-satisfiable, therefore Base-consistent, therefore extends
by Lindenbaum to a Base-MCS containing `□ nextTop` that is Discrete-inconsistent. **No Base-to-
Discrete MCS transfer lemma can exist.**

### 2.3 Recommended replacement text

```lean
  -- Route (i) is REFUTED and MUST NOT be re-attempted. It proposed a Base-MCS → Discrete-MCS
  -- transfer lemma so that countermodel_discrete_reynolds_v2 could be applied. The witness that
  -- kills it: D := ℤ ×ₗ ℤ (lexicographic, first coordinate dominant — an admissible Base carrier,
  -- since AddCommGroup/LinearOrder/IsOrderedAddMonoid/Nontrivial all resolve there), with `p`
  -- true exactly at the points ≥ (1,0). Every point (a,b) has the immediate successor (a,b+1), so
  -- `nextTop` holds everywhere and `□ nextTop` holds. `Gp` holds exactly at points ≥ (1,0), so
  -- `Gp → p` holds everywhere and `G(Gp → p)` holds at (0,0). `FGp` holds at (0,0), witness
  -- (1,0). But `Gp` FAILS at (0,0), witness (0,1) — which is > (0,0) yet ≱ (1,0). Antecedent
  -- true, consequent false: `Axiom.z1 p` is false at (0,0). Since `Axiom.z1` is Discrete-only
  -- (`Axiom.minFrameClass`, ProofSystem/Axioms.lean), {□ nextTop, G(Gp→p), FGp, ¬Gp} is
  -- Base-consistent and extends by Lindenbaum (`set_lindenbaum`) to a Base-MCS that contains
  -- `□ nextTop` and is Discrete-INCONSISTENT. No such transfer lemma can exist.
  --
  -- The surviving route is (ii): construct the discrete canonical model directly over a
  -- non-Archimedean carrier. `FrameClass.Base` imposes no Archimedean-ness — `valid`
  -- (Semantics/Validity.lean) binds only AddCommGroup/LinearOrder/IsOrderedAddMonoid/Nontrivial,
  -- with no `IsSuccArchimedean` — so ℚ ×ₗ ℤ is admissible: it is discretely ordered with
  -- successor (q,n) ↦ (q,n+1), hence validates `nextTop` everywhere. See
  -- `Metalogic/BXCanonical/DiscreteCarrierProbe.lean` for the compile-time confirmation that the
  -- parametric bundle-flow machinery elaborates at that carrier.
```

**Deliberate wording constraint.** The acceptance criterion is that the
`"(i) a Base-MCS … (ii) a Henkin-style …"` block no longer appears. The replacement above
therefore does **not** reproduce the original sentence's phrasing: it never writes "Two candidate
routes", and it describes route (ii) as "construct the discrete canonical model directly over a
non-Archimedean carrier" rather than the original "a Henkin-style discrete canonical model built
directly from a Base-MCS". A verification grep should anchor on the opener
`Two candidate routes: (i) a Base-MCS` and require zero hits.

### 2.4 Optional in-scope strengthening (flagged, not assumed)

The enclosing section docstring (`Transfer.lean:1049-1067`) ends, at `:1064-1066`:

> `countermodel_discrete_reynolds_v2` cannot be reused directly, since its signature demands
> `SetMaximalConsistent (fc := FrameClass.Discrete)` and a Base-MCS is not automatically
> Discrete-consistent.

"not automatically" now understates what §2.2 establishes: a Base-MCS containing `□ nextTop`
**provably need not** be Discrete-consistent. This is docstring-only and inside the file's scope,
so it is landable under this task, but it is not in the acceptance criteria. Recommend the
planner make it an explicit, separately-checkable sub-step so it is a decision rather than drift.

### 2.5 Out-of-scope observation: prose/code notation drift on `U`

`Formula.untl` is **guard-first** since the guard-first migration
(`specs/decisions/untl-snce-argument-order.md`, DECIDED 2026-08-17), and `nextTop = untl ⊥ ⊤`.
But repository *prose* still writes `U(⊤,⊥)` for `nextTop` — 125 occurrences across
`FormalSystem/`, and **zero** occurrences of `U(⊥,⊤)`. Under guard-first reading, `U(⊤,⊥)` names
the always-false formula, so the prose convention was not migrated with the code.

This is a real repo-wide inconsistency and it is **out of scope here** (task 421 is one comment
block). The concrete consequence for this task: the replacement text in §2.3 sidesteps the
ambiguity entirely by naming the Lean identifier `nextTop` instead of any `U(-,-)` prose form.
Recommend *not* introducing `U(⊥,⊤)` into this file, which would create a second convention in a
tree that is currently uniform, and recommend surfacing the drift as a separate task.

---

## 3. Deliverable (b): what the probe must mirror

The pattern is `section CarrierProbe … end CarrierProbe` in
`FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean:69-105` (task hint said :69-105 —
exact). It contains, at `D := ℝ`, four anonymous `example`s:

1. `bundleFlowFrame B : TaskFrame ℝ`
2. `bundleFlowModel B : TaskModel (bundleFlowFrame B)`
3. the flow-line history space `{σ | ∀ t, σ.domain t} : Set (WorldHistory (bundleFlowFrame B))`
4. the load-bearing one: `bundleFlow_completeness_from_neg_membership` applied end-to-end

Their target declarations live in `FormalSystem/Metalogic/Algebraic/FlowFrame.lean`
(`bundleFlowFrame` :455, `bundleFlowHistory` :460, `bundleFlowModel` :467,
`bundleFlow_completeness_from_neg_membership` :791), all under
`variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`
(:438) — note `Type`, not `Type*`, and `ℚ ×ₗ ℤ` is in `Type 0`, so this is fine, and it matches
the `∃ (D : Type) …` shape of `countermodel_discrete`'s own statement.

`CompletenessDedekind.lean:106-116` additionally carries a separate "`ℝ` discharges the binders"
block of bare `inferInstance` examples. The recommended probe folds both shapes into one section.

---

## 4. Machine-verified instance findings

All checks run with `lake env lean` against the project's built import closure.

### 4.1 The Mathlib instance: name resolved, namespace corrected

`.lake/packages/mathlib/Mathlib/Algebra/Order/Monoid/Prod.lean:51-59` declares
`instance isOrderedMonoid` inside `namespace Prod` → `namespace Lex`. The design doc §5.6 says
"in the `Lex` namespace"; the **full name is `Prod.Lex.isOrderedMonoid`**, not `Lex.isOrderedMonoid`.
The design doc's residual `[UNVERIFIED]` on the `to_additive`-generated name is now **resolved**:

```
#check @Prod.Lex.isOrderedAddMonoid
@Prod.Lex.isOrderedAddMonoid : ∀ {α : Type u_1} {β : Type u_2} [inst : AddCommMonoid α]
  [inst_1 : Preorder α] [AddLeftStrictMono α] [inst_3 : AddCommMonoid β] [inst_4 : Preorder β]
  [IsOrderedAddMonoid β], IsOrderedAddMonoid (Lex (α × β))
```

The guessed name `Prod.Lex.isOrderedAddMonoid` was **correct**.

### 4.2 The four Base binders fire at both carriers

Both `ℚ ×ₗ ℤ` (the recommended carrier) and `ℤ ×ₗ ℤ` (the §5.3 refutation witness) discharge all
four, by `inferInstance`, no `noncomputable` needed:

| Binder | `ℚ ×ₗ ℤ` | `ℤ ×ₗ ℤ` |
|---|---|---|
| `AddCommGroup` | resolves | resolves |
| `LinearOrder` | resolves | resolves |
| `IsOrderedAddMonoid` | resolves (with §4.3 import) | resolves (with §4.3 import) |
| `Nontrivial` | resolves | resolves |

The specific sub-instance the design doc flagged as the risk — `AddLeftStrictMono ℚ` — **is
found**, as `IsLeftCancelAdd.addLeftStrictMono_of_addLeftMono ℚ`. The instance genuinely fires; it
is not merely declared.

### 4.3 **BLOCKER FOUND AND CLEARED**: the import is missing today

Against the project's current closure (probe file importing
`FormalSystem.Metalogic.BXCanonical.CompletenessDedekind` and nothing else):

```
error: Unknown constant `Prod.Lex.isOrderedAddMonoid`
error: failed to synthesize instance of type class IsOrderedAddMonoid (Lex (ℚ × ℤ))
```

`Mathlib.Algebra.Order.Monoid.Prod` is in **no** `FormalSystem` module's import closure, and its
`.olean` was not even present in `.lake/packages/mathlib/.lake/build/` — a one-off
`lake build Mathlib.Algebra.Order.Monoid.Prod` (398 jobs, 894 ms) was required before it could be
imported at all. Adding the import line to the new file fixes it permanently; Lake will build the
module as part of the normal `lake build` once it is in the closure.

**Import minimality, measured by drop-one testing:**

| Import | Needed? |
|---|---|
| `FormalSystem.Metalogic.Algebraic.FlowFrame` | yes (supplies the whole bundle-flow API) |
| `Mathlib.Algebra.Order.Monoid.Prod` | **yes** — dropping it reproduces the §4.3 failure |
| `Mathlib.Algebra.Order.Group.Int` | no — already in `FlowFrame`'s closure |
| `Mathlib.Algebra.Order.Ring.Rat` | no — already in `FlowFrame`'s closure |

(`IsOrderedAddMonoid ℤ` is the piece `Mathlib.Algebra.Order.Group.Int` supplies; the project gets
it via `Core/MaximalConsistent.lean:11`.)

**No `open scoped Prod` is required** — the `×ₗ` notation is already in scope through
`FlowFrame`'s closure. The `ℝ` CarrierProbe's `open` list transfers unchanged except that
`FormalSystem.Metalogic.Algebraic` must be opened at the top level of the new file (in
`CompletenessDedekind.lean` it is opened inside the section).

---

## 5. The verified probe file

### 5.1 Text that compiled

Written to `FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean`, built with
`lake build FormalSystem.Metalogic.BXCanonical.DiscreteCarrierProbe` → `✔ [1359/1359] … Build
completed successfully`, **zero errors and zero warnings attributable to this file** (the build
surfaced only pre-existing `linter.unusedSectionVars` / `linter.overlappingInstances` warnings
originating in `FlowFrame.lean:666,791`). The file was then removed; the tree is unmodified.

```lean
import FormalSystem.Metalogic.Algebraic.FlowFrame
import Mathlib.Algebra.Order.Monoid.Prod

namespace FormalSystem.Metalogic.BXCanonical

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle
open FormalSystem.Semantics
open FormalSystem.Metalogic.Algebraic

section DiscreteCarrierProbe

variable {fc : FrameClass}

example : AddCommGroup (ℚ ×ₗ ℤ) := inferInstance
example : LinearOrder (ℚ ×ₗ ℤ) := inferInstance
example : IsOrderedAddMonoid (ℚ ×ₗ ℤ) := inferInstance
example : Nontrivial (ℚ ×ₗ ℤ) := inferInstance

noncomputable example (B : BFMCS (fc := fc) (ℚ ×ₗ ℤ)) : TaskFrame (ℚ ×ₗ ℤ) := bundleFlowFrame B

noncomputable example (B : BFMCS (fc := fc) (ℚ ×ₗ ℤ)) : TaskModel (bundleFlowFrame B) :=
  bundleFlowModel B

noncomputable example (B : BFMCS (fc := fc) (ℚ ×ₗ ℤ)) :
    Set (WorldHistory (bundleFlowFrame B)) :=
  {σ | ∀ t, σ.domain t}

noncomputable example (B : BFMCS (fc := fc) (ℚ ×ₗ ℤ)) (root : Formula)
    (h_rtc : B.RestrictedTemporallyCoherent root)
    (h_buc : B.RestrictedBackwardUntilSinceCoherent root)
    (h_fuc : B.RestrictedForwardUntilSinceCoherent root)
    (φ : Formula) (h_sub : φ ∈ subformulaClosure root)
    (fam : FMCS (fc := fc) (ℚ ×ₗ ℤ)) (hfam : fam ∈ B.families)
    (w₀ t : ℚ ×ₗ ℤ) (h_neg_in : φ.neg ∈ fam.mcs (w₀ + t)) :
    ¬TruthAt (bundleFlowModel B) (bundleFlowHistory ⟨fam, hfam⟩ w₀) t φ :=
  bundleFlow_completeness_from_neg_membership B root h_rtc h_buc h_fuc φ h_sub
    ⟨fam, hfam⟩ w₀ t h_neg_in

end DiscreteCarrierProbe

end FormalSystem.Metalogic.BXCanonical
```

The implementation should additionally prepend the standard copyright header (as in the sibling
modules) and a module docstring explaining, in the voice of the `ℝ` CarrierProbe's own docstring,
that these `example`s exist to fail loudly if the bundle-flow machinery ever acquires a binder
`ℚ ×ₗ ℤ` cannot discharge, and that the carrier is the route-(ii) recommendation refuted-route
comment in `Transfer.lean` points at.

### 5.2 **Required wiring** — otherwise invariant C6 fails

A new `.lean` file that no aggregator imports is an *unreachable module*.
`scripts/check-module-invariants.sh` C6 asserts "all 37 unreachable live module(s) are manifested"
and C8 asserts one aggregator per subdirectory. So the implementation **must** add

```lean
import FormalSystem.Metalogic.BXCanonical.DiscreteCarrierProbe
```

to `FormalSystem/Metalogic/BXCanonical.lean` (which already aggregates the 17 sibling modules,
`CompletenessDedekind` among them), and should add a line for it to that file's `## Architecture`
list. Without this the module is unreachable, C6/C7 counts shift, and the acceptance gate fails
for a reason unrelated to the mathematics.

`BXCanonical.lean` is itself reached from `FormalSystem/Metalogic/StrongCompleteness.lean`, so
this also puts `Mathlib.Algebra.Order.Monoid.Prod` into the main build closure. That is the one
residual risk worth a full-build check (§6).

---

## 6. Residual risks

1. **New Mathlib instances entering the main closure.** Importing
   `Mathlib.Algebra.Order.Monoid.Prod` transitively adds the `Prod` and `Prod.Lex` ordered-monoid
   instances (`instIsOrderedCancelMonoid`, `ExistsMulOfLE`, `CanonicallyOrderedMul`,
   `Prod.Lex.isOrderedCancelMonoid`, …) to instance search for everything downstream of
   `BXCanonical.lean`. This is low risk — none of them apply to the carriers the tree actually
   uses (`ℝ`, `ℚ`, `ℤ`) — but it is exactly the kind of change that shows up as an unrelated
   elaboration slowdown or a diamond. **Mitigation: run the full `lake build` and the full
   `scripts/check-module-invariants.sh`, not just the single-module build.** The single-module
   build performed in this research does *not* cover this.
2. **Comment-grep phrasing.** See §2.3: the replacement must avoid re-emitting the original
   sentence shape, or a naive acceptance grep may still match.
3. **Vacuous `#print axioms` criterion.** See §1.
4. **Notation drift.** See §2.5 — a hazard to *future* readers, not to this task's gates.

Nothing here blocks implementation. No route in this report requires a `sorry`.

---

## 7. Verification commands for the implementation phase

```bash
# (a) the refuted-route block is gone
grep -n "Two candidate routes: (i) a Base-MCS" FormalSystem/Metalogic/WeakCanonical/Transfer.lean   # expect: no hits
grep -c "sorry" FormalSystem/Metalogic/WeakCanonical/Transfer.lean                                   # expect: unchanged

# (b) the probe module builds, then the whole tree does
lake build FormalSystem.Metalogic.BXCanonical.DiscreteCarrierProbe
lake build

# gates
bash scripts/check-module-invariants.sh      # expect ALL CHECKS PASSED, C3 sole sorry = countermodel_discrete
```

Baseline for comparison, captured this session before any edit: all of C1-C10 PASS;
C2 axiom sets `completeness = [propext, sorryAx, Classical.choice, Quot.sound]`,
`completeness_dense`/`completeness_discrete`/`countermodel_dense` each
`[propext, Classical.choice, Quot.sound]`; C7 counts 448 live `.lean` files
(394 `FormalSystem/` + 53 `Tests/`), 411 reachable, 37 unreachable. Landing the probe **with**
the §5.2 aggregator import should move the live-file count to 449/395 and the reachable count to
412, leaving unreachable at 37.

---

## 8. Source anchors

| What | Where |
|---|---|
| Refuted-route comment | `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1081-1083` |
| `countermodel_discrete` / its `sorry` | `Transfer.lean:1068` / `:1084` (do not touch) |
| Section docstring (optional strengthening) | `Transfer.lean:1049-1067` (sentence :1064-1066) |
| `CarrierProbe` pattern to mirror | `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean:69-105` |
| Aggregator to extend | `FormalSystem/Metalogic/BXCanonical.lean` |
| Bundle-flow API + binder list | `FormalSystem/Metalogic/Algebraic/FlowFrame.lean:438,455,460,467,791` |
| `valid` binder list (no Archimedean) | `FormalSystem/Semantics/Validity.lean:94-98` |
| `Axiom.z1`, `Axiom.minFrameClass` | `FormalSystem/ProofSystem/Axioms.lean:342-348, 591-593` |
| `nextTop` | `FormalSystem/Metalogic/WeakCanonical/ReflexiveCanonical.lean:694` |
| Mathlib lex instance | `.lake/packages/mathlib/Mathlib/Algebra/Order/Monoid/Prod.lean:51-59` |
| Governing design doc | `specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/03_weak-terminus-status.md` §5.3, §5.5, §5.6 |
| Guard-first decision | `specs/decisions/untl-snce-argument-order.md` |
