# Finite-frame discharge of *Spherical* and *Limit* over `D = Int`

- **Task**: 440 — `finite_frame_discharge_of_spherical_and_limit`
- **Started**: TBD
- **Completed**: TBD
- **Effort**: TBD
- **Dependencies**: TBD
- **Sources/Inputs**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
- **Type**: lean4
- **Session**: `sess_1786598333_f1a43e`
- **Date**: 2026-08-12
- **Dispatch**: orchestrator, seq 1
- **Paper anchors consumed** (via `specs/paper-definitions-of-record.md`, never bare line
  numbers): `def:frame#Spherical`, `def:frame#Limit`, `def:frame#Seriality`,
  `def:frame#Compositionality`, `def:directed`, `def:task-relation`, `thm:extension`,
  `cor:occurrence`, `lem:step`, and the currently **untracked** `cor:spherical-finite`.

---

## Executive summary

Every claim below was machine-checked against the live tree this pass.

1. **The lint passes.** `bash scripts/check-paper-definitions.sh` exits 0 silently — case (a).
   No drifted anchors. Safe to consume the record.

2. **Deliverable 1 is NOT done.** `spherical_of_finite` does not exist anywhere in
   `FormalSystem/`. The cross-task note that task 417 had landed it is wrong: 417's own plan
   still marks that step `[NOT STARTED]`, and the declaration appears only in `specs/` prose.

3. **Worse — 417's "machine-checked green" proof does not compile.** It calls
   `Set.Finite.exists_minimal`, **which does not exist in this Mathlib** (v4.33.0-rc1,
   `79d0395a`). Verified by `lean_local_search` and by direct grep of the Mathlib source. The
   417 report's transcription must be treated as unverified, not as a preserved asset.

4. **A working proof exists** (given below), needs two new imports, and **depends on
   `Classical.choice`**.

5. **The task's choice-free acceptance test is UNSATISFIABLE, and this is now proved, not
   guessed.** I machine-checked a derivation of **weak excluded middle** (`¬¬P ∨ ¬P`) from
   `Spherical R` at the two-element carrier `Bool` over `D = Int`. That derivation itself uses
   only `[propext, Quot.sound]`. WLEM is not provable in Lean's intuitionistic core, so **no
   `Classical.choice`-free proof of `spherical_of_finite` can exist.** See §3.

6. **Task 420 has landed in full, and it guts Deliverable 2.** `TaskFrame` now carries
   `serial`, `limit`, `spherical`, `comp` (with `interpolates` projected) *and* `nonempty` as
   structure fields. `extension`, `occurrence`, `step`, `hF_nonempty`, and `isTotal_of_isMax`
   take **zero** axiom hypotheses. The "GAP" the task description is built on no longer exists.

7. **Net re-scope**: Deliverable 1 survives with a corrected proof and a corrected acceptance
   test. Deliverable 2 collapses to near-nothing. Deliverable 3 becomes a stale-docstring
   repair. Recommended: proceed, but replan.

---

## 1. Verified state of the tree

### 1.1 Build is green

```
lake build FormalSystem.Semantics.Extension.Extension \
           FormalSystem.Metalogic.Decidability.FMP.FiniteModel
→ Build completed successfully (1370 jobs).
```

Warnings only (unused section variables, overlapping instances, `Try this` hints). No errors.

### 1.2 Task 420's frame-axiom-field refactor HAS LANDED

The task description says 420 is `[PARTIAL]` and that "once 420 lands, these specializations
become mechanical." 420 is `COMPLETED` (`649eb75f6 task 420: complete orchestration`), and its
refactor is fully in the tree.

`FormalSystem/Semantics/TaskFrame.lean:472` — the `TaskFrame` structure now carries:

| Field | Type | Landed by |
|---|---|---|
| `nonempty` | `Nonempty WorldState` | 420 phase 14.2.2 |
| `TaskRel` | `WorldState → D → WorldState → Prop` | pre-existing |
| `nullity_identity` | `∀ w u, TaskRel w 0 u ↔ w = u` | pre-existing |
| `comp` | `TaskFrame.Compositional TaskRel` | 420 |
| `converse` | `∀ w d u, TaskRel w d u ↔ TaskRel u (-d) w` | pre-existing |
| `serial` | `TaskFrame.Serial TaskRel` | 420 |
| `limit` | `∀ w u, (∀ x, 0 < x → ∃ y, \|y\| < x ∧ TaskRel w y u) → u = w` | 420 |
| `spherical` | `TaskFrame.Spherical TaskRel` | 420 |

`TaskFrame.lean:1358-1373` carries five `example`s that pin each field to the bare-relation
predicate by `rfl`. The `[Nontrivial D]` binder is now on the structure itself
(420 phase 14.2.3).

### 1.3 The extension chain takes no loose axiom hypotheses

Every consumer the task description names as "taking four loose hypotheses" now takes none:

| Declaration | Actual signature | Loose axiom hypotheses |
|---|---|---|
| `PartialHistory.step` | `(F : TaskFrame D) (τ : PartialHistory F) (z : D)` | 0 |
| `PartialHistory.extension` | `(F : TaskFrame D) (τ : PartialHistory F)` | 0 |
| `PartialHistory.occurrence` | `(F : TaskFrame D) (w : F.WorldState) (x : D)` | 0 |
| `PartialHistory.hF_nonempty` | `(F : TaskFrame D) (w : F.WorldState)` | 0 |
| `PartialHistory.isTotal_of_isMax` | `(F : TaskFrame D) {τ} (hmax : IsMax τ)` | 0 |

`Step.lean:127` applies `F.spherical` directly. `Extension.lean:56-64` already documents that
"that refactor has landed."

**The premise of Deliverable 2 is therefore false.** There are no two remaining obligations to
factor out, because there are no obligations at all at the consumer sites — they moved to frame
*construction* sites.

### 1.4 `FiniteTaskFrame` and its one live construction

`FiniteTaskFrame D` (`TaskFrame.lean:1329`) extends `TaskFrame D` with
`finite_world : Finite WorldState`. Because it *extends* `TaskFrame`, it inherits all four
axioms as fields — nothing to bundle.

The only live construction is `FiniteFilteredTaskFrame` (`FMP/FiniteModel.lean:159`), whose
`toTaskFrame` is `RefinedFilteredTaskFrame D phi`; that frame discharges `spherical` via
`TaskFrame.spherical_of_permissive` (`FMP/Filtration.lean:305`), not via finiteness.
`FiniteModel.lean:183-204` re-exports the four axioms as inherited theorems.

### 1.5 `customFrame` collision check

`customFrame : TaskFrame Int` with `WorldState := Bool` lives at
`Tests/BimodalTest/Semantics/TaskFrameTest.lean:61` and already discharges all four axioms via
the permissive-class helpers. Task 417's plan proposes promoting it out of `Tests/`.

**No collision with this task.** This task adds a library lemma in `TaskFrame.lean`; it does
not move or edit `customFrame`. If 417 promotes it, that is additive on a different file. Worth
noting only that `customFrame`'s `spherical` discharge would *not* be improved by
`spherical_of_finite` — `spherical_of_permissive` is already choice-free there and is strictly
better (see §3.4).

---

## 2. Deliverable 1 — `spherical_of_finite`

### 2.1 The paper source

`cor:spherical-finite` resolves cleanly against the live paper
(`scripts/check-paper-definitions.sh --resolve "cor:spherical-finite|env|-|-"`):

```
sha256: 76258a4c835d4fa0dde3fd037da52e706d0f20c9d7872ab523d3b81597b99b9d
\begin{Cthm} \label{cor:spherical-finite}
	Every frame $\F = \tuple{W, \D, \Rightarrow}$ with finite $W$ satisfies \textit{Spherical}, choice-free.
\end{Cthm}
```

The proof (as quoted in 417's report) is the ⊆-least-member argument: finitely many distinct
members, directedness iterated yields a ⊆-least `S*`, `S*` is nonempty and equals `⋂ S`.

### 2.2 The 417 transcription is broken

417's report presents this as verified green:

```lean
obtain ⟨Sstar, hStar⟩ := (Set.toFinite S).exists_minimal hne
```

Against this tree it produces:

```
error: failed to synthesize instance of type class Finite ↑S
error: Invalid field `exists_minimal`: The environment does not contain `Finite.exists_minimal`
```

`Set.Finite.exists_minimal` does not exist in this Mathlib, and neither does
`Set.Finite.exists_minimal_wrt` (grep over `.lake/packages/mathlib/Mathlib/` returns nothing).
Do not carry that snippet forward.

### 2.3 A proof that does compile

Machine-checked green this pass via `lean_run_code`:

```lean
omit [IsOrderedAddMonoid D] in
theorem spherical_of_finite {W : Type} [Finite W] (R : W → D → W → Prop) :
    TaskFrame.Spherical R := by
  intro S hdir hmem
  obtain ⟨hne, hd⟩ := hdir
  obtain ⟨Sstar, hStarMem, hStarMin⟩ :=
    exists_minimal_of_wellFoundedLT (α := Set W) (fun s => s ∈ S) hne
  have hsub : ∀ T ∈ S, Sstar ⊆ T := by
    intro T hT
    obtain ⟨S', hS'mem, hS'sub⟩ := hd Sstar hStarMem T hT
    have h1 : S' ⊆ Sstar := fun x hx => (hS'sub hx).1
    have h2 : Sstar ⊆ S' := hStarMin hS'mem h1
    exact fun x hx => (hS'sub (h2 hx)).2
  obtain ⟨x, hx⟩ := (hmem Sstar hStarMem).2
  exact ⟨x, fun T hT => hsub T hT hx⟩
```

**Two new imports are required** in `TaskFrame.lean`:

- `Mathlib.Order.Minimal` — for `exists_minimal_of_wellFoundedLT`
- `Mathlib.Data.Fintype.Powerset` — for `Set.instFinite`, without which
  `WellFoundedLT (Set W)` does not synthesize

Both were confirmed necessary by removing each and observing the failure. `Mathlib.Data.Fintype.Powerset`
is already used elsewhere in the tree (`FMP/FiniteModel.lean:132` cites `Set.instFinite`).

Application to the bundled structure elaborates:

```lean
example [Nontrivial D] (F : FiniteTaskFrame D) : TaskFrame.Spherical F.TaskRel := by
  haveI := F.finite_world
  exact spherical_of_finite F.TaskRel
```

(`finite_world` is a plain field, not an instance, so the `haveI` is required at every use site.)

Note the proof consumes only *finiteness*, *directedness*, and *member nonemptiness* — the
`IsFiber R s ∨ IsSegment R s` disjunct is never used, matching the paper's own
`%% CHANGE (sigma-elim)` remark that the finite-`W` argument is indifferent to member kind.

### 2.4 Axiom profile — the bad news

```
#print axioms spherical_of_finite
→ 'spherical_of_finite' depends on axioms: [propext, Classical.choice, Quot.sound]
```

Choice enters through the finiteness API, not through the argument's shape:

| Ingredient | `#print axioms` |
|---|---|
| `Set.toFinite` | *no axioms* |
| `Finite.exists_equiv_fin` | *no axioms* |
| `Set.instFinite` | `propext, Classical.choice, Quot.sound` |
| `Finite.to_wellFoundedLT` | `propext, Classical.choice, Quot.sound` |
| `exists_minimal_of_wellFoundedLT` | `propext, Classical.choice, Quot.sound` |

---

## 3. The central finding: choice-freeness is IMPOSSIBLE, not merely awkward

The task says: *"If a choice-free proof is genuinely awkward in Lean, say so in the docstring
with the specific obstruction rather than silently shipping a `Classical.choice` dependency."*

The obstruction is stronger than awkwardness. It is a **theorem**.

### 3.1 Machine-checked: `Spherical` on a finite carrier implies weak excluded middle

I constructed a task relation on `Bool` over `D = Int` whose fibers include `{true}`, `{false}`,
and `univ`, and a directed family over it whose intersection being nonempty decides `¬¬P ∨ ¬P`.
Verified green this pass via `lean_run_code`:

```lean
def R : Bool → Int → Bool → Prop := fun w d u => (d = 0 ∧ w = u) ∨ (d = 3)
-- Fib R w 0 = {w}   and   Fib R w 3 = Set.univ

theorem wlem_of_spherical (hSph : TaskFrame.Spherical R) (P : Prop) : ¬¬P ∨ ¬P := by
  set S : Set (Set Bool) :=
    {s | (s = {true} ∧ P) ∨ (s = {false} ∧ ¬P) ∨ s = Set.univ} with hS
  ... -- family is directed and all members are nonempty fibers, both proved constructively
  obtain ⟨b, hb⟩ := hSph S hdir hmem
  have htrue  : P  → b = true  := fun hp  => hb {true}  (Or.inl ⟨rfl, hp⟩)
  have hfalse : ¬P → b = false := fun hnp => hb {false} (Or.inr (Or.inl ⟨rfl, hnp⟩))
  cases hbv : b with
  | true  => exact Or.inl (fun hnp => absurd (hbv.symm.trans (hfalse hnp)) (by decide))
  | false => exact Or.inr (fun hp  => absurd (hbv.symm.trans (htrue  hp))  (by decide))
```

```
#print axioms wlem_of_spherical
→ 'wlem_of_spherical' depends on axioms: [propext, Quot.sound]
```

The full 50-line source is reproducible from this report; the directedness proof is a nine-case
`rintro` on the membership disjunctions, and the two cross cases are discharged by
`absurd hp hnp'` — no classical reasoning anywhere.

**Reading.** `Bool` is finite. If `spherical_of_finite` were provable with axioms
`[propext, Quot.sound]`, then composing it with `wlem_of_spherical` would prove `¬¬P ∨ ¬P` for
every `P` with those same axioms. Weak excluded middle is not derivable in Lean's intuitionistic
core. Therefore **`spherical_of_finite` cannot be proved without `Classical.choice`.**

### 3.2 Why the paper is still right

The paper's "choice-free" is a claim about **ZF vs ZFC** — the argument does not need the axiom
of choice, given classical logic. That claim is correct and is exactly the contrast
`thm:extension`'s footnote draws against the Zorn appeal.

Lean's `Classical.choice` is a different thing: it is the *single* axiom from which Lean derives
**both** excluded middle (via Diaconescu) and the axiom of choice. Lean has no separate
`Classical.em` axiom to print. So `#print axioms` cannot distinguish "uses AC" from "uses LEM",
and the task's proposed regression test — assert `Classical.choice` is absent — tests the wrong
proposition and can never pass.

This is a genuine mismatch between the paper's metatheory and Lean's axiom accounting, not a
defect in either. It should be recorded, not papered over.

### 3.3 What CAN be asserted: the choice-free core, isolated

The classical content is confined to exactly one step. Everything downstream of "a ⊆-minimal
member exists" is not merely choice-free but **axiom-free**. Machine-checked this pass:

```lean
theorem sInter_nonempty_of_directed_of_minimal {W : Type} {S : Set (Set W)}
    (hd : ∀ S₁ ∈ S, ∀ S₂ ∈ S, ∃ S' ∈ S, S' ⊆ S₁ ∩ S₂)
    (hne : ∀ s ∈ S, s.Nonempty)
    {Sstar : Set W} (hStarMem : Sstar ∈ S)
    (hStarMin : ∀ ⦃T⦄, T ∈ S → T ⊆ Sstar → Sstar ⊆ T) :
    (⋂₀ S).Nonempty := ...
```

```
#print axioms sInter_nonempty_of_directed_of_minimal
→ 'sInter_nonempty_of_directed_of_minimal' does not depend on any axioms
```

Zero axioms — not even `propext`. This is the paper's actual mathematical content
("directedness upgrades minimal to least; least is nonempty and equals the intersection"),
and it is fully constructive. Only the *existence* of a minimal member is classical, and §3.1
shows that step is irreducibly so.

**Recommended acceptance test**, replacing the unsatisfiable one:

1. `#print axioms sInter_nonempty_of_directed_of_minimal` → `[]` (regression-tested).
2. `#print axioms spherical_of_finite` → exactly `[propext, Classical.choice, Quot.sound]`,
   with a regression test asserting **no other** axiom and, in particular, no dependence on
   `PartialHistory.exists_maximal_extension` (the Zorn instance). *That* is the paper's real
   claim: the finite case does not go through Zorn.
3. A `#print axioms wlem_of_spherical`-style test pinning `[propext, Quot.sound]`, documenting
   *why* test (2) cannot be strengthened.

This preserves the corollary's entire point — no Zorn — while stating something Lean can check.

### 3.4 Do NOT re-derive `spherical_of_subsingleton` from `spherical_of_finite`

417's plan Phase 2 proposes re-deriving `spherical_of_subsingleton`'s body from the new lemma
because `Subsingleton W → Finite W`. Verified:

```
lean_verify FormalSystem.Semantics.TaskFrame.spherical_of_subsingleton
→ axioms: ["propext"]
```

`spherical_of_subsingleton` is currently choice-free. Routing it through `spherical_of_finite`
would **regress it to `Classical.choice`**, and would propagate that regression to
`trivialFrame`, `intTimeFrame`, and `genericTimeFrame`. The same applies to
`spherical_of_permissive` and `spherical_of_eq` at finite carriers.

`spherical_of_finite` is a *strictly weaker-axiom-profile-costing* addition. It should be an
**additional** route for relations of arbitrary shape, never a replacement for the existing
class helpers.

### 3.5 Where `spherical_of_finite` genuinely earns its place

With `spherical` now a required `TaskFrame` field, every new frame construction must discharge
it. The existing routes all constrain the *relation shape*:

| Existing helper | Requires |
|---|---|
| `spherical_of_subsingleton` | `Subsingleton W` |
| `spherical_of_permissive` | `R w d u ↔ (d ≠ 0 ∨ w = u)` |
| `spherical_of_eq` | `R w d u ↔ w = u` |
| `multiFamGen_spherical` | deterministic-shift carrier `FamIdx × D` |

**None applies to an arbitrary relation on a finite carrier** — which is precisely what a
Z3-produced countermodel is. `spherical_of_finite` is the only route that will discharge the
`spherical` field for the frames the downstream consumers (ModelChecker 153/154, BimodalLogic
441) actually build. Its value is undiminished by the re-scope; if anything 420 raised it, since
the field is now mandatory rather than an optional hypothesis.

---

## 4. Deliverable 2 — collapsed

### 4.1 *Limit* over `Int`: already structural

The description's recipe — "*Limit* from `TaskFrame.limit_of_succOrder` applied to the
structure's own `nullity_identity` field" — is correct as mathematics and already realised as
practice. `limit_of_succOrder` (`TaskFrame.lean:673`) takes exactly
`(hnull : ∀ w u, R w 0 u ↔ w = u)`, which `nullity_identity` supplies verbatim, and `SuccOrder Int`
/ `NoMaxOrder Int` are both available.

But since 420, `limit` is a **field**. It is discharged once, at frame construction, and read off
thereafter. There is no downstream obligation to package. A `FiniteTaskFrame Int` *already has*
`F.limit`. A separate "Limit for finite Int frames" lemma would have no consumer.

### 4.2 *Seriality* and *Interpolates*: also already fields

`serial` is a field; `interpolates` is a `theorem` projection of the `comp` field
(`TaskFrame.lean:604`). They are not "remaining obligations" at any consumer.

Separately worth recording (verified by 417's counterexample probe, and consistent with what I
see here): **Seriality is not automatic over `Int`, and finiteness does not rescue it.** It
remains a genuine obligation at *construction* sites. `Interpolates` likewise.

### 4.3 `extension_of_finite` / `occurrence_of_finite` are hypothesis-free eta-wrappers

Because `extension` and `occurrence` take only `(F : TaskFrame D)`, the proposed specializations
reduce to:

```lean
theorem extension_of_finite (F : FiniteTaskFrame Int) (τ : PartialHistory F.toTaskFrame) :
    ∃ σ : F.toTaskFrame.HF, PartialHistory.Extends σ.val.toPartialHistory τ :=
  PartialHistory.extension F.toTaskFrame τ

theorem occurrence_of_finite (F : FiniteTaskFrame Int) (w : F.WorldState) (x : Int) :
    ∃ τ : F.toTaskFrame.HF, τ.val.states x (τ.property x) = w :=
  PartialHistory.occurrence F.toTaskFrame w x
```

Zero hypotheses; the whole content is the `toTaskFrame` coercion, which the existing
`Coe (FiniteTaskFrame D) (TaskFrame D)` instance (`TaskFrame.lean:1342`) already provides.

**Assessment**: their only remaining value is discoverability — giving a model checker a name to
cite that mentions `FiniteTaskFrame` and `Int`. That is a real but small benefit. Land them if
the downstream consumers want a stable citable name; do not present them as discharging
anything. They must be documented as coercion wrappers, or they will read as if they carried
content they do not.

**Recommendation**: consult ModelChecker 153/154's actual citation needs before landing these.
If those tasks can cite `PartialHistory.occurrence` directly, skip them entirely.

---

## 5. Deliverable 3 — documentation, re-scoped to stale-docstring repair

`Extension.lean`'s module docstring is now internally inconsistent — 420 updated one section but
not the others.

| Location | Text | Status |
|---|---|---|
| `Extension.lean:56-64` | "that refactor has landed… `TaskFrame` carries [the four axioms] as structure data" | correct |
| `Extension.lean:45-48` | "*Spherical* … enters only as a hypothesis binder handed straight to `step`… the four binders are pass-through arguments" | **STALE** — there are no binders |
| `Extension.lean:66-68` | "the structure carries no `Nonempty WorldState` field yet" | **STALE** — `nonempty` landed in 420 phase 14.2.2 |
| `Extension.lean:239-242` | "This needs a world state … which `TaskFrame` does not [supply]" | **STALE** — same reason |
| `Extension.lean:181-182` | "*Spherical* is not threaded in directly — it is handed to `step`" | borderline; reword |

The task asks to "record that the finite specialization exists and what it costs, beside the
existing note that the FRAME-INTRINSIC form is gated on the frame-axiom-field refactor." **That
gating note no longer exists** — it was replaced when 420 landed. So Deliverable 3 becomes:

1. Repair the four stale passages above.
2. Add a note recording what `spherical_of_finite` costs — specifically the §3 finding: no Zorn,
   but `Classical.choice` unavoidably, with the WLEM derivation cited as the reason.

Optional but recommended: since `F.nonempty` now exists, `hF_nonempty` could drop its explicit
`w` argument (`hF_nonempty (F) : Nonempty F.HF := ... F.nonempty.elim ...`). That is a real
simplification 420 enabled but did not take. **Flag only** — it changes a signature and is
outside this task's additive-only remit.

---

## 6. Re-pinning `cor:spherical-finite` in the record

`specs/paper-definitions-of-record.md:144-154` records this as a known residual gap: three
anchors (`cor:spherical-finite`, `lem:nesting`, `lem:nonempty`) are untracked, and tracked
`thm:extension`'s footnote cross-references the untracked `cor:spherical-finite`.

**This task should close the `cor:spherical-finite` half of that gap**, because it is the task
that transcribes it into Lean. Once `spherical_of_finite`'s docstring quotes the anchor, an
undetected drift would silently invalidate a docstring citation.

`lem:nesting` and `lem:nonempty` are not consumed by this task; leave them to 417.

Per the record's own four-step protocol (§"How to extend this record"), the resolved values are
already in hand:

```
cor:spherical-finite|env|-|-|76258a4c835d4fa0dde3fd037da52e706d0f20c9d7872ab523d3b81597b99b9d
```

Add a `### \`cor:spherical-finite\`` prose entry quoting the statement verbatim, add the manifest
row above, rewrite the residual-gap paragraph to say the cross-reference is now closed (noting
`lem:nesting`/`lem:nonempty` remain open), and re-run the lint expecting a case-(a) pass.

**Coordination risk**: 417's plan Phase 1 proposes tracking all three anchors. If both tasks run,
they will conflict on this file. Whichever lands first should be checked for before writing.

---

## 7. Recommendations

Ordered, with the re-scope applied.

1. **Re-pin `cor:spherical-finite`** in `specs/paper-definitions-of-record.md` with hash
   `76258a4c…`, before any Lean docstring quotes it. Check whether 417 already did it.

2. **Land the two-lemma decomposition in `TaskFrame.lean`**, beside the existing
   `sInter_nonempty_of_directed_of_univ_or_singleton` (:832):
   - `sInter_nonempty_of_directed_of_minimal` — axiom-free, the paper's actual argument;
   - `spherical_of_finite` — the classical minimal-element step composed with it.

   Add imports `Mathlib.Order.Minimal` and `Mathlib.Data.Fintype.Powerset`.

3. **Replace the acceptance test.** Assert `sInter_nonempty_of_directed_of_minimal` has *no*
   axioms and `spherical_of_finite` has *exactly* `[propext, Classical.choice, Quot.sound]` and
   no Zorn dependency. Do not assert absence of `Classical.choice` — §3.1 proves that
   unachievable.

4. **Land `wlem_of_spherical` as a regression test**, in `Tests/`. It is the evidence for
   recommendation 3 and prevents a future agent from "fixing" the axiom profile by chasing an
   impossible proof. Its own axiom profile `[propext, Quot.sound]` should be pinned.

5. **Write the docstring obstruction note** on `spherical_of_finite`, per the task's explicit
   instruction, stating: the paper's "choice-free" is ZF-vs-ZFC; Lean's `Classical.choice`
   supplies LEM as well as AC; the corollary is not intuitionistically provable (cite
   `wlem_of_spherical`); what *is* preserved is the absence of Zorn.

6. **Do NOT re-derive** `spherical_of_subsingleton`, `spherical_of_permissive`, or
   `spherical_of_eq` from `spherical_of_finite` (§3.4). Add a docstring line saying so, since
   417's plan currently proposes the opposite.

7. **Repair `Extension.lean`'s four stale docstring passages** (§5) and add the cost note.

8. **Defer or drop `extension_of_finite` / `occurrence_of_finite`** pending confirmation from
   ModelChecker 153/154 that a `FiniteTaskFrame`-named alias is wanted. They carry no content.

9. **Do not touch** the extension chain's proofs, `Boneyard`, or `TaskFrame`'s fields. The
   additive-only remit still holds and is now easy to honour, since the only new code is two
   lemmas plus imports.

---

## 8. Risks

| Risk | Severity | Mitigation |
|---|---|---|
| A dispatch trusts 417's non-compiling snippet and burns cycles debugging | High | §2.2/§2.3 give the working proof and the exact two imports |
| A dispatch chases the impossible choice-free proof | High | §3.1 is machine-checked; recommendation 4 lands it as a permanent test |
| Re-deriving existing helpers regresses their axiom profiles | Medium | §3.4; the `spherical_of_subsingleton` = `[propext]` measurement is the tripwire |
| Conflict with 417 on `paper-definitions-of-record.md` and on `TaskFrame.lean` | Medium | §6; check the file before writing; both edits are additive and mergeable |
| Landing contentless `*_of_finite` wrappers that read as if they discharge obligations | Low | §4.3; either document them as coercion aliases or skip |
| Adding `Mathlib.Data.Fintype.Powerset` to `TaskFrame.lean` widens a low-level import | Low | Already imported transitively elsewhere in the tree; build verified green |

---

## 9. Open questions for the planner

1. Should `spherical_of_finite` be stated with `[Finite W]` (as the description says) or take
   `Finite W` as an explicit argument? The `FiniteTaskFrame.finite_world` field is *not* an
   instance, so every use site needs `haveI := F.finite_world`. An explicit-argument variant
   `spherical_of_finite' (h : Finite W)` beside the instance form would remove that friction.
   Recommend landing both; cost is one line.

2. Does the record file's owner accept closing only the `cor:spherical-finite` third of the
   residual gap, or should all three anchors move together (coordinating with 417)?

3. Do ModelChecker 153/154 need a `FiniteTaskFrame`-named citation, or will
   `PartialHistory.occurrence` do? This decides whether §4.3 lands at all.
