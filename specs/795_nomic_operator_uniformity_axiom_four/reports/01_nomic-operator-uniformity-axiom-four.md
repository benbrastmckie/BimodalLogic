# Research Report: Task #795

**Task**: 795 - Formalize the nomic operator and its three results, on the nomic frames of task 794
**Started**: 2026-10-15T02:31:00-07:00
**Completed**: 2026-10-15T02:52:00-07:00
**Effort**: ~20 minutes wall clock, nine `lean_run_code` probes
**Dependencies**: Task 794 (completed) — `FormalSystem/Semantics/Nomic/` supplies the frames, law-histories, occurrence, recovery and the three hierarchy witnesses
**Sources/Inputs**:
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` — `def:nomic-frame`, `prop:nomic-tense-free`, `thm:nomic-uniform`, `app:nomic-four`
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex` — the cut `rmk:nomic-uniform`
- `FormalSystem/Semantics/Nomic/{Frame,Recovery,ZTime,Witnesses}.lean`
- `FormalSystem/Metalogic/Independence/StateSetTruth.lean` (the `satSet` shape and its nomic forward pointer)
- `FormalSystem/OpenLanguage/` (the semantic-only language-component precedent)
- `FormalSystem/Semantics/{TruthClauses,IntNormalForm,TemporalOrder}.lean`
- `scripts/measure-refactor-partitions.py`, `scripts/check-metalogic-cycles.sh`, `scripts/check-module-invariants.sh`, `scripts/warning-budget.txt`, `docs/reference/paper-definitions-of-record.md`
- lean-lsp MCP (`lean_run_code` compiled probes against the built project; `lean_local_search` reported `index: warming`, so its empty results are not treated as proof of absence — absence claims below rest on `grep` sweeps)
**Artifacts**: - `specs/795_nomic_operator_uniformity_axiom_four/reports/01_nomic-operator-uniformity-axiom-four.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Every result in scope is already machine-checked, not merely designed.** Nine
  `lean_run_code` probes compiled against the built project and closed, sorry-free, the whole of
  `prop:nomic-tense-free` (the `satSet` bridge and the `Nomic ↔ □` collapse on the fragment),
  `thm:nomic-uniform` ((1)⇒(5), (2)⇒(5), (3)⇒(5), (5)⇒(4), (4)⇒(1)(2)(3), (5)⇔(6)), **both**
  directions of `app:nomic-four` including the `△¬(p ∧ ◯q)` countermodel, seriality (**D**) for
  the nomic operator, and the side lemma the cut `rmk:nomic-uniform` specifies. Measured axiom
  sets are `[propext, Classical.choice, Quot.sound]`, except the uniformity collapse and the
  (4)⇒(1)(2)(3) direction at `[propext]`.
- **The truth recursion cannot reuse `Semantics/TruthClauses.lean`.** That abstract clause layer
  is hard-bound to `TaskFrame`/`WorldHistory`/`TaskModel`; a nomic evaluation point is a *bare
  function* in `H_F` over a `NomicFrame`, and `H_F = ⋃_w H_F^w` is the world-history set of no
  single task frame once the frame is non-uniform. Nine derived-operator clause lemmas (`neg`,
  `and`, `iff`, `someFuture`, `allFuture`, `somePast`, `allPast`, `always`, `next`) are
  re-derived natively; each is 3–8 lines and **all nine are probed**.
- **Recommended split: frame-level half into the existing 794 cluster, language half into a new
  component.** `thm:nomic-uniform`'s conditions (1)–(6) mention no object language at all, so
  they belong in a new `FormalSystem/Semantics/Nomic/Uniformity.lean`; the operator, its truth
  clause, the tense-free bridge, validity, seriality and `app:nomic-four` belong in a new
  top-level `FormalSystem/NomicLanguage/`, following `OpenLanguage/`'s semantic-only precedent.
- **`H_F`-as-bare-functions is what makes the design work and what forces the one real cost.**
  Because 794 already carries `lawHist`/`HF` over bare `↑D → F.World`, the truth recursion needs
  no membership proof threaded through it and no transport anywhere. The price is the duplicated
  derived-operator layer named above.
- **Two gate hazards found, both avoidable.** `scripts/warning-budget.txt` has a **zero**
  baseline with every listed class `blocking`, and a linter class with *no* disposition row
  exits 2 — `linter.unnecessarySimpa`, which one probe triggered, has no row. And concurrent
  task 801's declared `file_scope` claims four of the five record/inventory files this task's
  gate set must edit.

## Context & Scope

Task 794 left the frame-level half of the paper's nomic appendix complete: `NomicFrame`, the
derived family `F.at w`, `lawHist`/`HF`, the three properties of `def:nomic-properties`,
`lem:nomic-occurrence`, `lem:nomic-recovery`, the ℤ-time presentation `ofStepFamily` with its
one-step membership bridges, and the three hierarchy witnesses. Nothing of the **operator**
exists: a repository-wide `grep` for `NomicFormula`, `NomicTruth`, `NomicModel`, `nomicSatSet`
and `NomicLanguage` outside `specs/` returns nothing, and both
`FormalSystem/OpenLanguage/README.md` and `FormalSystem/StarLanguage/README.md` record the nomic
operator as a deliberate exclusion.

This task researches the four paper anchors the dispatch names, and the six deliverables it
lists. The dense-time case of `app:nomic-four` is explicitly out of scope (the paper's own
commented remark leaves it open), as is any proof system, axiomatisation, soundness or
completeness claim for the nomic operator — the paper offers none, exactly as for `▷`/`◁`.

### Literature Proof Structure

**Source**: Brast-McKie, *Possible Worlds* (JPL submission),
`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, the nomic block of
`app:TaskSemantics`.
**Strategy**: one state-set induction (`prop:nomic-tense-free`), one cycle of implications
(`thm:nomic-uniform`), one explicit countermodel over ℤ-time (`app:nomic-four`).

#### Step Map

1. The Nomic truth clause: `M,τ,x ⊨ ◈φ` iff `M,σ,x ⊨ φ` for all `σ ∈ H_F^{τ(x)}`; the
   accessibility relation at `x` relates `τ` to each `σ ∈ H_F^{τ(x)}` — [Source]
   `def:nomic-frame`, items *Law-Histories* and *Nomological Necessity*, plus its closing
   sentence.
2. Assign each tense-free `φ` a state set `S_φ ⊆ W` with `M,τ,x ⊨ φ` iff `τ(x) ∈ S_φ`, by
   induction, with `S_{□φ} = S_{◈φ} = W` if `S_φ = W` and `∅` otherwise — [Source]
   `prop:nomic-tense-free`, the displayed recursion.
3. The `□` case consumes `cor:occurrence` (`{σ(x) | σ ∈ H_F} = W`); the `◈` case consumes
   `lem:nomic-occurrence` (`{σ(x) | σ ∈ H_F^w} = W` for every `w`) — [Source]
   `prop:nomic-tense-free`, its two middle sentences.
4. Hence `S_{◈φ} = S_{□φ}`, so `◈φ ↔ □φ` at every point, so every **S5** schema for `◈` is valid
   on the fragment and any refutation must use `S` or `U` — [Source] `prop:nomic-tense-free`,
   closing sentence and statement's second sentence.
5. `(1) ⇒ (5)`: at a time where transitivity holds, with `w := τ(x)`, `lem:nomic-occurrence`
   gives `σ ∈ H_F^w` with `σ(x) = u` for arbitrary `u`; transitivity carries every
   `ρ ∈ H_F^u = H_F^{σ(x)}` into `H_F^w`; hence `H_F ⊆ H_F^w ⊆ H_F`; every `w'` is some `τ'(x)`,
   so `H_F^{w'} = H_F` throughout — [Source] `thm:nomic-uniform` proof, first paragraph.
6. `(2) ⇒ (5)` and `(3) ⇒ (5)`: the same `w, τ, u, σ` construction, then symmetry gives
   `τ ∈ H_F^u`, and the Euclidean condition gives `H_F^w ⊆ H_F^u` for all `w, u` — [Source]
   same proof, second and third paragraphs.
7. `(5) ⇒ (4) ⇒ (1),(2),(3)`: immediate, since `H_F × H_F` is reflexive, symmetric, transitive
   and Euclidean; this is also what licenses reading the `x`-quantifier in (1)–(3) either
   existentially or universally — [Source] same proof, fourth paragraph.
8. `(5) ⇔ (6)`: `⇐` from `def:nomic-frame`; `⇒` through `lem:nomic-recovery` — [Source] same
   proof, fifth paragraph.
9. Under (4) the `(◈)` and `(□)` clauses coincide, so `◈φ ↔ □φ` for **every** `φ`, and the
   accessibility relation is `H_F × H_F`, an equivalence relation — [Source] same proof, sixth
   paragraph.
10. Seriality (**D**) holds for `◈` over every nomic frame, independently of (1)–(6), since
    `H_F^{τ(x)} ≠ ∅` by `lem:nomic-occurrence` — [Source] same proof, closing discussion.
11. `app:nomic-four` `(⇐)`: uniformity makes `◈φ ↔ □φ` valid and `□` has an **S5** logic, so
    `◈φ → ◈◈φ` is valid — [Source] `app:nomic-four` proof, first paragraph.
12. `app:nomic-four` `(⇒)`: from `¬`uniform take `v` with `H_F^v ≠ H_F` and `ρ ∈ H_F^w \ H_F^v`;
    over ℤ, *Compositionality* plus `lem:nullity` reduce `H_F^v`-membership to the one-step
    condition, so some `n` has `¬(ρ(n) ⇒_1^v ρ(n+1))`; put `|p| = {ρ(n)}`, `|q| = {ρ(n+1)}` and
    `φ := △¬(p ∧ ◯q)` — [Source] `app:nomic-four` proof, second paragraph, first three
    sentences.
13. Every `μ ∈ H_F^v` satisfies `φ` at every time (a `μ(m) = ρ(n)` would force
    `μ(m+1) ≠ ρ(n+1)`), while `ρ` falsifies `φ` at `n` — [Source] same paragraph, fourth
    sentence.
14. By `lem:nomic-occurrence` take `τ ∈ H_F^v` with `τ(0) = v` and `σ ∈ H_F^v` with `σ(0) = w`;
    then `◈φ` holds at `(τ,0)`, fails at `(σ,0)`, and `σ ∈ H_F^{τ(0)}`, so `◈◈φ` fails at
    `(τ,0)` — [Source] same paragraph, fifth through seventh sentences.
15. The same `φ` separates `◈φ` from `□φ` at `(τ,0)`, since `ρ ∈ H_F` falsifies it — [Source]
    same paragraph, last sentence.
16. The invalidity claim: the static-and-lawful witness of `prop:nomic-hierarchy` is not uniform
    and so refutes the schema — [Source] `app:nomic-four` proof, third paragraph.

#### Dependencies

- Steps 2–4 depend on step 1 and on `lem:nomic-occurrence`.
- Steps 5, 6 each depend on step 1 and `lem:nomic-occurrence`; step 6's construction is step 5's.
- Step 8 depends on `lem:nomic-recovery` (794, `lawHist_eq_iff_taskRel_eq`).
- Steps 9, 10 depend on step 7 and step 1.
- Step 11 depends on steps 7 and 9.
- Steps 12–15 depend on step 1, `lem:nomic-occurrence`, and the ℤ-time one-step characterization
  (794, `mem_lawHist_iff_isStepPath`).
- Step 16 depends on steps 12–15 and on `prop:nomic-hierarchy`'s third witness (794,
  `NomicHierarchy.F3.not_uniform`).

#### Potential Formalization Challenges

- **Step 1**: the evaluation world ranges over `H_F = ⋃_w H_F^w`, which is a set of bare
  functions and not the world-history set of any task frame. The truth recursion therefore
  cannot be an instance of `Semantics/TruthClauses.lean`. See *Findings → the clause layer*.
- **Steps 2–4**: "tense-free" is a syntactic restriction, not a separate type in the paper. It
  needs an explicit encoding in Lean; `satSet` cannot recurse on a `Prop`-valued predicate into
  `Set W`, so the recursion must be total on the full formula type.
- **Step 12**: `△` and `◯` are *derived* operators (`△φ := Hφ ∧ (φ ∧ Gφ)`, `◯φ := ⊥ U φ`), so
  the countermodel needs native collapsed-form clause lemmas for both, and `◯`'s needs
  `Order.succ x = x + 1` over `↑intOrder`.
- **Step 12**: `ρ ∉ H_F^v` has to be turned into a *one-step* violation. 794's
  `mem_lawHist_iff_isStepPath` is stated for `τ : ℤ → F.World` while `lawHist` binds
  `↑intOrder → F.World`; the two are definitionally equal but `rw` will not cross the boundary
  (794's recorded hazard). `exact`/`refine` do.

## Findings

### Codebase Patterns

#### What 794 supplies, with exact signatures

| Declaration | Signature (abridged) | Used for |
|---|---|---|
| `NomicFrame D` | `World : Type`, `[worldNonempty]`, `PosRel : World → World → D.PositiveCone → World → Prop` | the frame |
| `NomicFrame.at` | `(F : NomicFrame D) (w : F.World) : FrameOver D` | each member `F^w` |
| `NomicFrame.IsRegular` | class, `regular : ∀ w, (F.at w).IsRegular`, with `instAtIsRegular` | regularity, fires automatically at `F.at w` |
| `NomicFrame.TaskRel` | `(F) (w) : F.World → ↑D → F.World → Prop` | `⇒ʷ` |
| `NomicFrame.lawHist` | `(F) (w) : Set (↑D → F.World)` | `H_F^w`, **bare functions** |
| `NomicFrame.HF` | `(F) : Set (↑D → F.World)`, `⋃ w, F.lawHist w` | `H_F` |
| `NomicFrame.occurrence` | `(F) [F.IsRegular] (w u : F.World) (x : ↑D) : ∃ τ ∈ F.lawHist w, τ x = u` | `lem:nomic-occurrence` |
| `NomicFrame.lawHist_eq_iff_taskRel_eq` | `(F) [F.IsRegular] (w u) : F.lawHist w = F.lawHist u ↔ F.TaskRel w = F.TaskRel u` | (5)⇔(6) |
| `NomicFrame.mem_lawHist_iff_isStepPath` | `(F : NomicFrame intOrder) [F.IsRegular] (w) (τ : ℤ → F.World) : τ ∈ F.lawHist w ↔ IsStepPath (F.at w) τ` | step 12 |
| `NomicHierarchy.F3` / `F3.not_uniform` | `F3 : NomicFrame intOrder`, `¬ F3.Uniform`, with `ofStepFamily_isRegular` | step 16 |

`IsStepPath (F.at w) τ` unfolds to `∀ n : ℤ, (F.at w).step (τ n) (τ (n+1))`, and
`FrameOver.step F p q` is `F.TaskRel p 1 q` — which is why step 12's one-step violation is
reachable by `push Not` on the negated `IsStepPath`.

#### Four small frame-level facts 794 does not have

All four are one- or two-liners and all four were probed:

```lean
theorem lawHist_subset_HF (F : NomicFrame D) (w : F.World) : F.lawHist w ⊆ F.HF :=
  Set.subset_iUnion _ w

theorem exists_mem_HF_eq (F : NomicFrame D) [F.IsRegular] (w : F.World) (x : ↑D) :
    ∃ τ ∈ F.HF, τ x = w          -- "every w' is τ'(x) for some τ' ∈ H_F", step 5's last clause

theorem lawHist_nonempty (F : NomicFrame D) [F.IsRegular] (w : F.World) (x : ↑D) :
    ∃ τ, τ ∈ F.lawHist w          -- the content of seriality, step 10
```

plus the per-state transitivity of the cut remark (see *rmk:nomic-uniform* below).

#### The clause layer: why `Semantics/TruthClauses.lean` is unusable here

`TruthEnv.T` has type
`∀ {F : TaskFrame}, TaskModel F → WorldHistory F → F.Duration → Env F → L → Prop`, and every one
of `BotClause`, `ImpClause`, `BoxClause`, `UntlClause`, `SnceClause`, `StabClause` repeats that
binder set. A nomic truth relation's evaluation point is `(τ : ↑D → F.World, x : ↑D)` over a
`NomicFrame D`, its `□` clause quantifies `∀ σ ∈ F.HF` and its `◈` clause
`∀ σ ∈ F.lawHist (τ x)`. There is no instantiation: `H_F` is a union of law-history sets and, for
a non-uniform frame, is the world-history set of no task frame, so the `WorldHistory F` binder
cannot be met.

Two consequences, both measured rather than assumed:

1. The nine derived-operator clause lemmas must be restated natively. Each was probed in the
   nomic recursion and each is short; the two collapsed forms are the only ones with any
   content:

```lean
theorem always_iff (φ) : NTruth M τ x (nalways φ) ↔ ∀ y, NTruth M τ y φ := by
  rw [nalways, and_iff, and_iff, allPast_iff, allFuture_iff]
  constructor
  · rintro ⟨hp, hn, hf⟩ y
    rcases lt_trichotomy y x with h | h | h
    · exact hp y h
    · exact h ▸ hn
    · exact hf y h
  · intro h; exact ⟨fun y _ => h y, h x, fun y _ => h y⟩

theorem next_iff_succ [SuccOrder (↑D : Type)] [NoMaxOrder (↑D : Type)] (φ) :
    NTruth M τ x (nnext φ) ↔ NTruth M τ (Order.succ x) φ
```

   `always_iff` collapses the three-conjunct introduction form straight to the `∀ y` normal form
   using `↑D`'s `LinearOrder` (carried by `TemporalOrder`); `next_iff_succ` is
   `Metalogic/DiscreteNonCompactness.lean`'s `truthAt_next_iff` transcribed, and the ℤ
   specialisation `NTruth M τ x (nnext φ) ↔ NTruth M τ (x + 1) φ` closes with
   `rw [next_iff_succ …]; simp` (a `congr 1` in between does nothing and trips
   `linter.unusedTactic`).
2. **Truth-level conservativity over `Formula` is not statable in this task.** `TruthAt` lives
   over `TaskFrame`; the nomic recursion does not. A bridge exists in principle *only* under
   uniformity (condition (6) says the frame then *is* a task frame), which would make
   conservativity a corollary of the collapse rather than a general fact. Recommend recording
   this as an explicit exclusion, with the reason, rather than attempting it.

#### The `satSet` shape, coordinated with the task 792 pin

`FormalSystem/Metalogic/Independence/StateSetTruth.lean` already carries a forward pointer
written for this port: its `## References` block records that `prop:nomic-tense-free` "runs this
same state-set induction over the tense-free fragment … `□` and the nomic operator share one
clause, and there are no temporal clauses at all." The two inductions do share a shape, and the
shape detail worth copying verbatim is the **ignoring-set** `box` clause:

```lean
  | .box φ => {_w | ∀ v : W, v ∈ satSet V φ}
```

`StateSetTruth.lean`'s docstring records why: the alternative
`if satSet V φ = Set.univ then univ else ∅` would need to decide a set equality and would pull
`Classical.choice` into the *definition*. The nomic recursion reuses that form for **both** `box`
and `nomic`, which is precisely what makes `S_{◈φ} = S_{□φ}` hold by `rfl` and the collapse a
two-line consequence of the bridge.

Two differences from `satSet`, both forced:

- No `[LinearOrder W]` binder. `satSet` needs the order only for its `untl`/`snce` clauses; the
  tense-free fragment has none, so the nomic recursion takes a bare `W : Type`.
- The recursion must be **total** on the full formula type while the theorem is restricted to
  the fragment. A `Prop`-valued `TenseFree` predicate cannot be recursed into `Set W` (no large
  elimination), so the two temporal clauses get `∅` and the bridge theorem carries
  `TenseFree φ` as a hypothesis, discharging those cases by `cases h`. This is a
  partial-function convention on a total recursion, not a vacuous definition: no clause of the
  form `def Foo := True`/`Unit`/`trivial` appears anywhere in the design.

The probed statement and its three interesting cases:

```lean
inductive TenseFree : NF → Prop
  | atom (p : Atom) : TenseFree (.atom p)
  | bot : TenseFree .bot
  | imp {φ ψ} : TenseFree φ → TenseFree ψ → TenseFree (.imp φ ψ)
  | box {φ} : TenseFree φ → TenseFree (.box φ)
  | nomic {φ} : TenseFree φ → TenseFree (.nomic φ)

theorem bridge (F : NomicFrame D) [F.IsRegular] (M : NomicModel F) :
    ∀ φ : NF, TenseFree φ → ∀ (τ : ↑D → F.World) (x : ↑D),
      NTruth M τ x φ ↔ τ x ∈ nSatSet M.valuation φ
```

Both the `box` and the `nomic` case run the same three lines — `F.occurrence (τ x) v x` for the
forward direction, `h (σ x)` for the converse — the `box` case additionally lifting
`σ ∈ F.lawHist (τ x)` to `σ ∈ F.HF` by `Set.mem_iUnion.mpr ⟨τ x, hσ⟩`. The `untl`/`snce` cases
are `intro h; cases h`.

**One formalization-native strengthening worth recording.** The bridge holds for an *arbitrary*
bare `τ : ↑D → F.World`, with no `τ ∈ F.HF` hypothesis, because the `box`/`nomic` clauses
quantify over `H_F`/`H_F^{τ(x)}` and the `atom` clause reads only `τ x`. The paper states the
proposition for `τ ∈ H_F`; the Lean statement is strictly stronger. Recommend stating it in the
general form and recording the discrepancy in the docstring.

#### `OpenLanguage/` as the component precedent

`OpenLanguage/` is the tree's only **semantic-only** language component: no proof system, no
axiomatisation, no soundness or completeness claim, and its README says so in one sentence. It
is also the pattern for every mechanical obligation a new component carries:

- a separate `inductive` with a constructor-to-constructor embedding from the language it
  extends (`ofPlus`), **not** a new constructor on an existing type;
- `Formula.lean` imports nothing from `Semantics/` and no semantic module of any language, the
  "syntax before semantics" invariant that `scripts/check-metalogic-cycles.sh` assertion C
  enforces;
- every file has a row in `LANGUAGE_FILE_LAYERS` of `scripts/measure-refactor-partitions.py`
  (0 for syntax, 1 for semantics). The directory set that the cycles check uses is **read off
  that table**, so a new `"NomicLanguage"` dict entry wires the component in automatically — no
  edit to `check-metalogic-cycles.sh` itself. A file with no row makes `layer_of` *raise*, and a
  row naming a vanished file fails assertion B, so the table cannot drift either way;
- a sibling aggregator `FormalSystem/NomicLanguage.lean` (gate C8) and a directory README with a
  generated inventory block (`readme-lint.sh` check 1).

`OpenLanguage/README.md`'s "Manuscript operators without a formalization" table currently reads
*"The nomic operator of `sub:RestrictedModalities`, over a four-place task relation indexed by
world states — **Excluded.** No formalization in this tree"*. That row must be repointed, and
`StarLanguage/README.md` carries a similar note worth checking.

#### `app:nomic-four`: the countermodel, as probed

Two atoms are needed and `Atom` is `structure Atom where base : String; freshIndex : Option Nat`
with `DecidableEq`, so `⟨"p", none⟩ ≠ ⟨"q", none⟩` closes `by decide`. The valuation is the
two-clause disjunction, and the two readback lemmas need the atoms' distinctness:

```lean
  let M : NomicModel F := ⟨fun u a => (a = pA ∧ u = ρ n) ∨ (a = qA ∧ u = ρ (n + 1))⟩
  let φ : NF := nalways (nneg (nand (.atom pA) (nnext (.atom qA))))
```

The three steps that need care, all verified:

1. `¬ F.Uniform → ∃ v, F.lawHist v ≠ F.HF` by `by_contra; push Not at hc` — **`push Not`, not
   the deprecated `push_neg`** (see *Risks*).
2. `∃ ρ ∈ F.HF, ρ ∉ F.lawHist v` by
   `Set.exists_of_ssubset (LE.le.ssubset_of_ne (lawHist_subset_HF F v) hv)` — **`LE.le.ssubset_of_ne`,
   not the deprecated `HasSubset.Subset.ssubset_of_ne`**.
3. `¬ IsStepPath (F.at v) ρ` from `ρ ∉ F.lawHist v` via
   `fun hs => hρv ((NomicFrame.mem_lawHist_iff_isStepPath F v ρ).mpr hs)` — an `exact`-shaped
   term, deliberately not a `rw`, for 794's recorded carrier-boundary reason. Then
   `by_contra; push Not at hc` gives the `n` with `¬ (F.at v).step (ρ n) (ρ (n+1))`.

Inside the two claims, `rw [hpz, hqz] at hstep` *does* work: `μ z` and `ρ n` are both
`F.World`, so no carrier boundary is crossed. The closing argument is
`F.occurrence v v 0` and `F.occurrence v w 0`, then `rw [hτ0] at hμ` / `rw [hσ0]` to move
between `F.lawHist (τ 0)` and `F.lawHist v`.

The `(⇐)` direction needs no induction at all: under `F.Uniform`, `F.lawHist (τ x) = F.HF` for
*every* `τ` and `x`, so `◈` and `□` have literally the same clause and the nested `◈◈` consequent
reduces to the antecedent. Likewise the full collapse

```lean
theorem nomic_iff_box_of_uniform (F) (h : F.Uniform) (M) (τ) (x) (φ) :
    NTruth M τ x (.nomic φ) ↔ NTruth M τ x (.box φ) := by
  change (∀ σ ∈ F.lawHist (τ x), NTruth M σ x φ) ↔ ∀ σ ∈ F.HF, NTruth M σ x φ
  rw [h (τ x)]
```

holds for **every** `φ`, with no induction and at `[propext]` only — the paper's "by induction
on `φ`" is not needed once the clause sets are equated. Use `change`, not `show`: the tactic
alters the goal and `linter.style.show` is blocking (see *Risks*).

#### `rmk:nomic-uniform` (cut material) as a side lemma

The dispatch is explicit that the cut remark is a *specification*, not a result to cite. Its
content is per-**state** transitivity, which is a different notion from `thm:nomic-uniform`'s
per-**time** (1). Both halves probed:

```lean
def TransAtState (F : NomicFrame D) (w : F.World) : Prop :=
  ∀ σ ∈ F.lawHist w, ∀ x : ↑D, F.lawHist (σ x) ⊆ F.lawHist w

theorem transAtState_iff (F) [F.IsRegular] (w) :
    TransAtState F w ↔ ∀ u : F.World, F.lawHist u ⊆ F.lawHist w

theorem uniform_iff_forall_transAtState (F) [F.IsRegular] :
    (∀ w, TransAtState F w) ↔ F.Uniform
```

The `⇒` of `transAtState_iff` is the remark's "every world state `u` is the state `σ(x)` of some
such `σ`" step, which is `F.occurrence w u 0`. Cite the cut by **file and header**
(`appendix_cut_material.tex`, "the cut `rmk:nomic-uniform`"), exactly as
`NomicFrame.static_iff_taskRel_eq` cites `thm:nomic-primitive`, and add the matching `DANGLING`
record row (C15 gates the `rmk:` prefix).

### External Resources

#### Paper anchors — all four resolve

`bash scripts/check-paper-definitions.sh --resolve '<anchor>|env|-|-'` against the live working
tree:

| Anchor | `sha256` |
|---|---|
| `def:nomic-frame` | `60fdc0699603f6fd5f2a10f4e6ee8e17e96d569657e24e8b888849f6d914f60f` |
| `prop:nomic-tense-free` | `606d1c6fca3f72c502a7d34b0896bb239652ef635608cc2bd350750a4e46e7d5` |
| `thm:nomic-uniform` | `614ddcaa6433bede6548634a442ddbcb3b18f8ca0e57e8e8e38d489e167cafaf` |
| `app:nomic-four` | `34f753111d4ea9244464bdcc20b73a94f3e7ce7345689b2da67ce1f11a4f8bd8` |

The `--resolve` spec must use `env` as the kind; `Tttm`-style environment names are rejected
(`error: unknown anchor kind 'Tthm'`).

#### Record rows needed in `docs/reference/paper-definitions-of-record.md`

C15's gated prefix set is `(def|thm|lem|cor|app|rmk):` — `prop:` is **not** gated. Current state:

| Anchor | Row today | Action |
|---|---|---|
| `def:nomic-frame` | `LIVE-UNPINNED`, frames only | extend the note to name the Nomic clause's Lean home |
| `prop:nomic-tense-free` | `LIVE-UNPINNED`, **"NOT FORMALIZED"** | repoint to the new declaration; ungated, but the note is now wrong |
| `thm:nomic-uniform` | **absent** | add `LIVE-UNPINNED` (gated — C15 fails without it) |
| `app:nomic-four` | **absent** | add `LIVE-UNPINNED` (gated) |
| `rmk:nomic-uniform` | **absent** | add `DANGLING` (gated; cut material, `--resolve` structurally cannot read `appendix_cut_material.tex`) |

A `KNOWN-ANCHORS` `LIVE-UNPINNED` row satisfies C15 as long as no docstring quotes the anchor's
text verbatim; the four `sha256` values above are recorded here so a `MANIFEST` row can be
written instead if the implementation chooses to pin.

#### Gate inventory for the new files

Reusing 794's measured list, with the two additions this task's new *directory* brings:

| Gate | Obligation |
|---|---|
| C8 | sibling aggregator `FormalSystem/NomicLanguage.lean` importing every module in the directory |
| `readme-lint.sh FormalSystem` | `FormalSystem/NomicLanguage/README.md` with a generated inventory block, plus rows in `FormalSystem/README.md` |
| C33 | `lake exe mk_all --lib FormalSystem`, regenerated root committed |
| C15 | the five record rows above |
| C16 (`docBlame`) | a docstring on **every** declaration, including each `TransAt`/`SymmAt`/`EuclAt` |
| C23 | no `lemma`, no `Uppercase_x` name whose prefix is a real declaration (794 hit this: `F1_static` was rejected, `F1.static` accepted) |
| C24 | transitive `FormalSystem.Init` import — free, via `Semantics.Nomic.*` |
| C26 | **no underscore inside a `def`/`abbrev` name component** — `nSatSet`/`nomicSatSet` fine, `nomic_satSet` would fail. Theorems are unaffected |
| C28 | **zero** warning budget; see *Risks* |
| C31/C32 | `## References` bibkeys resolve in `references.bib`; relative markdown links in docstrings resolve on disk |
| C34a/C34b | a `Constraints consumed:` marker on every `[F.IsRegular]`-taking declaration reading as a constraint claim. The occurrence-consuming results consume all four (through `thm:extension`); `nomic_iff_box_of_uniform` and the (4)⇒(1)(2)(3) direction take no instance and consume none |
| `check-metalogic-cycles.sh` | the `"NomicLanguage"` entry in `LANGUAGE_FILE_LAYERS` (`"Formula": 0`, every semantic module `1`) |
| `check-copyright-headers.sh --strict` | the four-line Apache header on each new file |
| `check-paper-definitions.sh` | advisory; **ten inherited drifted anchors** make it exit 1 before this task begins. None of them is touched here |
| C35 | no obligation: the citation manifest is seeded by name and new files shift no seeded line numbers |

`docs/theorem-index.md` rows are optional (C15's second assertion checks only *existing* rows,
round-tripping each to its declaration's docstring). 794 left them out because the file sat in a
concurrent task's `file_scope`; it is **not** in task 801's scope, so this task may add them.

### Recommendations

#### A sorry-free path exists, end to end

Every one of the six deliverables was closed in a probe with zero `sorry` and zero new axioms.
No deliverable is at risk of needing a placeholder, and no part of the design depends on an
unproved lemma. Measured axiom sets:

| Probed result | `#print axioms` |
|---|---|
| `bridge` (`prop:nomic-tense-free`) | `[propext, Classical.choice, Quot.sound]` |
| `nomic_iff_box_tenseFree` | `[propext, Classical.choice, Quot.sound]` |
| `uniform_of_transAt` / `_symmAt` / `_euclAt` | `[propext, Classical.choice, Quot.sound]` |
| `transAt_of_pointUniform` ((4)⇒(1)) | `[propext]` |
| `uniform_iff_taskRel_indep` ((5)⇔(6)) | `[propext, Classical.choice, Quot.sound]` |
| `not_four_valid_of_not_uniform` (`app:nomic-four` ⇒) | `[propext, Classical.choice, Quot.sound]` |
| `four_validOn_of_uniform` (`app:nomic-four` ⇐) | compiles; no explicit measurement taken |
| `nomic_serial` (**D**) | `[propext, Classical.choice, Quot.sound]` |
| `nomic_iff_box_of_uniform` (full collapse) | `[propext]` |
| `transAtState_iff`, `uniform_iff_forall_transAtState` | `[propext, Classical.choice, Quot.sound]` |

The choice dependence is inherited, in every case, from `lem:nomic-occurrence`'s route through
`thm:extension`'s Zorn appeal — `rmk:choice` does not list these among the paper's choice-free
results, and nothing here should advertise them as choice-free. The two `[propext]` rows are the
genuinely choice-free ones and are worth pinning as such.

#### Recommended siting: a two-directory split

**Frame-level half — `FormalSystem/Semantics/Nomic/Uniformity.lean` (new, inside 794's cluster).**
`thm:nomic-uniform`'s (1)–(6) mention no object language whatsoever; they are conditions on the
accessibility relation of `def:nomic-frame`, which that definition's own closing sentence
specifies at the frame level. Putting them under `Semantics/Nomic/` keeps them beside
`lem:nomic-recovery`, which (5)⇔(6) consumes, and lets the language component import one
aggregator. Contents: the four small facts above, `accRel`, `TransAt`/`SymmAt`/`EuclAt`/
`PointUniform`, the six implications, `uniform_iff_taskRel_indep`, the `H_F × H_F` identification
with its equivalence-relation statement, and the `rmk:nomic-uniform` side lemma.

**Language half — `FormalSystem/NomicLanguage/` (new top-level component).** The dispatch names
`OpenLanguage/` as the precedent and that is the right one: semantic-only, no proof system,
syntax-before-semantics, a row per file in `LANGUAGE_FILE_LAYERS`.

#### Recommended formula type: `NomicFormula` over base `Formula`, not over `PlusFormula`

Take the six constructors of `FormalSystem/Syntax/Formula.lean` (`atom`, `bot`, `imp`, `box`,
`untl`, `snce`) plus `nomic`, with a constructor-to-constructor `ofFormula : Formula →
NomicFormula` and `ofFormula_injective`, mirroring `StarLanguage`/`OpenLanguage`. Reasons:

- `Formula` already carries every derived operator `app:nomic-four` needs (`always`, `next`,
  `and`, `neg`, `allFuture`, `allPast`), with the right-hand sides to copy verbatim so the
  embedding commutes by `rfl`.
- **Exclude `⊡`.** `prop:nomic-tense-free`'s fragment is exactly `{pᵢ, ⊥, →, □, ◈}`; the paper
  deliberately leaves `⊡` out of it. Adding `stab` would force a decision the paper does not
  make (does `⊡` belong in the fragment?) and would add a clause to `nSatSet` for no result in
  scope. Record the exclusion in the component README.
- A new constructor on an existing type is the wrong move for the same reason `OpenFormula` is
  separate: it would change the type every existing L/L⁺ theorem is stated at.

Keep `ofFormula` even though no result consumes it: it is what makes "this language extends BL"
a theorem rather than a claim in prose, it is ~20 lines, and C17 (dead-declaration scan) is
reporting-only.

#### Recommended module decomposition — seven phases

| Phase | File(s) | Content |
|---|---|---|
| 1 | `docs/reference/paper-definitions-of-record.md` | the five record rows (C15 must be green before any docstring cites the new anchors) |
| 2 | `FormalSystem/Semantics/Nomic/Uniformity.lean`, `Semantics/Nomic.lean`, `Semantics/Nomic/README.md` | the frame-level half: the four small facts, (1)–(6), the `H_F × H_F` identification, the `rmk:nomic-uniform` side lemma |
| 3 | `FormalSystem/NomicLanguage/Formula.lean`, `FormalSystem/NomicLanguage.lean`, `FormalSystem/NomicLanguage/README.md`, `scripts/measure-refactor-partitions.py`, `FormalSystem.lean` | syntax (layer 0), the derived operators, `ofFormula`; the component's aggregator, README and layer rows; regenerated root |
| 4 | `FormalSystem/NomicLanguage/NomicTruth.lean` | `NomicModel`, `NomicTruthAt`, the seven primitive clause lemmas, the nine derived ones, `nomic_iff_box_of_uniform` |
| 5 | `FormalSystem/NomicLanguage/NomicTenseFree.lean` | `TenseFree`, `nomicSatSet`, the bridge, the fragment collapse, the **S5** schemata on the fragment (K, T, 4, 5, B) |
| 6 | `FormalSystem/NomicLanguage/NomicValidity.lean` | `NomicValidOn`, seriality (**D**), the collapse as a validity, the accessibility-relation statement |
| 7 | `FormalSystem/NomicLanguage/NomicFour.lean` + gate sweep | `app:nomic-four` both directions, both schemata, the `F3` instantiation; then inventory and root regeneration, `typst-sync-check.sh`, the full guarded build, `check-module-invariants.sh` |

Phase 5's S5-on-the-fragment corollaries are worth stating explicitly, because the bridge makes
them one line each and because one of them is a genuine surprise worth recording: **T** (`◈φ → φ`)
holds on the tense-free fragment over *every* nomic frame, including non-*Lawful* ones, since the
fragment collapse already degenerates `◈` into `□`. The paper's remark that *Nomologically
lawful* "validates **T** for `◈`" is about the **full** language; on the fragment T is free. This
is the same observation as `prop:nomic-tense-free`'s closing sentence ("any refutation … must use
`S` or `U`") read for T rather than for 4, and it is a useful consistency check against
`prop:nomic-hierarchy`'s first witness.

## Decisions

- **Truth over bare functions, not over a `WorldHistory`-like wrapper.** `NomicTruthAt` takes
  `τ : ↑D → F.World` with no membership proof. 794 already pays this cost at the frame level
  (`lawHist` is a set of bare functions, because `HF`'s union does not typecheck over a family
  of `WorldHistory` types), and inheriting it means the recursion threads no proof and needs no
  transport. Validity, not truth, is where `τ ∈ F.HF` enters.
- **The frame-level half goes to `Semantics/Nomic/`, the language half to `NomicLanguage/`.**
  (1)–(6) are language-free; splitting keeps `lem:nomic-recovery` one import away from the
  (5)⇔(6) step that consumes it, and keeps the new language component to the operator alone.
- **`TenseFree` as a `Prop`-valued inductive, with a total `nomicSatSet`.** The alternative — a
  separate `TenseFreeFormula` type with an embedding — would let `nomicSatSet` be structurally
  total, but adds a second syntax type and an embedding whose only consumer is one theorem. The
  recursion's two junk clauses are documented rather than hidden, and the `cases h` discharge
  makes them unreachable in the theorem.
- **The bridge is stated for arbitrary `τ`, not for `τ ∈ F.HF`.** Strictly stronger than the
  paper's statement, free in the proof, and recorded as a formalization-native strengthening in
  the docstring.
- **No truth-level conservativity over `Formula`, and no proof system.** The first is not
  statable (different frame type); the second the paper does not offer. Both recorded as
  exclusions with reasons, in the `OpenLanguage/` house style.
- **`⊡` is excluded from `NomicFormula`.** The three results' language is BL plus `◈`, and
  `prop:nomic-tense-free`'s fragment names `□` and `◈` only.
- **The dense-time case is not attempted.** The paper's own commented remark leaves it open and
  the dispatch forbids it. Record the ℤ-time hypothesis as load-bearing in `NomicFour.lean`'s
  docstring: without a duration-indexed tense operator, a violation at a general duration cannot
  be localized at adjacent times, which is exactly what step 12 needs.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| **`scripts/warning-budget.txt` baseline is zero and every listed class is `blocking`.** The probes tripped `linter.style.show`, `linter.unusedTactic` (a no-op `congr 1`), `linter.unusedVariables` and `linter.unnecessarySimpa` | Use `change` where the goal changes, never `show`; drop the no-op `congr 1` from the `next_iff_add_one` proof; `_`-prefix every unused binder; reflow to 100 characters |
| **`linter.unnecessarySimpa` has no disposition row in `warning-budget.txt`, and a class with no row is `exit 2`, not a soft failure** | Never leave a `simpa` where `simp` closes the goal — the ℤ `Order.succ x = x + 1` step is exactly such a site (`simpa using Order.succ_eq_add_one x` → `simp`). If the class is genuinely needed, a reasoned disposition row must be added in the same change |
| **Deprecated-API warnings are `blocking` (`disposition deprecated blocking`)** | `push Not`, not `push_neg`; `LE.le.ssubset_of_ne`, not `HasSubset.Subset.ssubset_of_ne`. Both verified. 794 hit the same class with `Int.le_induction` → `Int.leInduction` |
| **Task 801's declared `file_scope` claims `docs/reference/paper-definitions-of-record.md`, `README.md`, `FormalSystem/README.md`, `docs/reference/API_REFERENCE.md` and `typst/generated/status.typ`** — four of the five are files this task's gate set must edit | Re-read each file immediately before editing; stage only this task's own hunks with an explicit file list (never a directory or glob `git add`); treat an unexpected build failure outside this task's own files as possibly a sibling's in-flight edit. If 801 is mid-dispatch on the record file, the record rows can be added as a tightly scoped hunk and committed alone |
| **`rw` across the `↑intOrder` / `ℤ` carrier boundary** — 794's recorded hazard, which bit it twice | Route every such step through `exact`/`refine`/`Iff.trans`/`Set.ext_iff`, never `rw`. The one place it matters here is lifting `ρ ∉ F.lawHist v` to `¬ IsStepPath (F.at v) ρ`; the probed term form is in *Findings* |
| **`check-paper-definitions.sh` exits 1 on ten inherited drifted anchors before this task starts** (`CO`, `def:BX`, `def:BX-z`, `def:BX-d`, `def:TMplus`, `app:discrete`, `def:id`, `def:strongest`, `thm:exist`, `lem:uniq`) | Treat it as advisory, exactly as 794's plan did. Verify only the nomic anchors individually with `--resolve`; the four `sha256` values are recorded above |
| **A transient `import FormalSystem.Semantics.Nomic` failure** reported "unknown namespace `FormalSystem.Syntax`" although the aggregator and every `.olean` were current; the identical import succeeded on retry | Retry once before concluding an aggregator is missing or the build is stale. Importing the leaf modules directly (`…Nomic.Frame`, `…Nomic.ZTime`, `…Nomic.Witnesses`) is the workaround |
| `prop:nomic-tense-free` is a `prop:` anchor, so C15 does **not** gate it, and its existing record row says "NOT FORMALIZED" | The gate will stay green with a stale row. Repoint the row anyway in Phase 1 — a silently wrong record entry is the defect C15 exists to prevent, whether or not the prefix is gated |
| Nine duplicated derived-operator clause lemmas could drift from `TruthClauses.lean`'s | Record the duplication and its cause in `NomicTruth.lean`'s docstring, naming `TruthClauses.lean`'s `TaskFrame` binder as the reason, so a future reader does not take the duplication for carelessness. Generalising `TruthClauses.lean` over the point structure is a much larger refactor across six language components and is **not** recommended in this task |

## Tactic Survey Results

Probed with `lean_run_code` against the built project rather than with `lean_multi_attempt`,
because every goal below needs a surrounding definition that does not yet exist in the tree.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `NTruth M τ x (nand φ ψ) ↔ … ∧ …` | `simp only [nand, nneg, NTruth]; tauto` | success | `tauto` closes the classical `¬(A → ¬B) ↔ A ∧ B` step |
| `nallFuture` / `nallPast` collapsed clause | `rw [...]; constructor; by_contra` | success | the `¬∃¬ ↔ ∀` step; `push Not` also works |
| `always_iff` (three conjuncts → `∀ y`) | `rcases lt_trichotomy y x` | success | `↑D`'s `LinearOrder`, carried by `TemporalOrder` |
| `next_iff_succ` | explicit term, `Order.succ_le_of_lt` / `Order.le_of_lt_succ` | success | transcribed from `Metalogic/DiscreteNonCompactness.lean`'s `truthAt_next_iff` |
| `Order.succ x = x + 1` at `↑intOrder` | `simp` | success | `simpa using Order.succ_eq_add_one x` also closes it but trips `linter.unnecessarySimpa` |
| `NTruth M τ x (nnext φ) ↔ NTruth M τ (x+1) φ` | `rw [next_iff_succ …]; simp` | success | an intervening `congr 1` does nothing (`linter.unusedTactic`) |
| the tense-free bridge, `box` and `nomic` cases | `obtain … := F.occurrence (τ x) v x` then `rwa [hv]` | success | `Set.mem_iUnion.mpr ⟨τ x, hσ⟩` lifts to `F.HF` in the `box` case |
| the bridge's `untl`/`snce` cases | `intro h; cases h` | success | `TenseFree` has no constructor at those shapes |
| `(1) ⇒ (5)` | `Set.Subset.antisymm` + `Set.mem_iUnion.mp` | success | needs `lawHist_subset_HF` and `exists_mem_HF_eq` |
| `(4) ⇒ (1)/(2)/(3)` | `rw [h τ hτ x] at …` | success | choice-free, `[propext]` |
| `(5) ⇔ (6)` | `lawHist_eq_iff_taskRel_eq` in both directions, `▸` for the `mpr` leg | success | `rw` is avoided on the `▸` leg |
| `¬ F.Uniform → ∃ v, …` | `by_contra; push Not at hc` | success | `push_neg` works but is deprecated-blocking |
| `∃ ρ ∈ F.HF, ρ ∉ F.lawHist v` | `Set.exists_of_ssubset (LE.le.ssubset_of_ne …)` | success | `HasSubset.Subset.ssubset_of_ne` is deprecated |
| `pA ≠ qA` for `⟨"p", none⟩`, `⟨"q", none⟩` | `decide` | success | `Atom` derives `DecidableEq` |
| `nomic_iff_box_of_uniform` | `change …; rw [h (τ x)]` | success | `[propext]`; `show` trips `linter.style.show` |
| seriality (**D**) | explicit term on `lawHist_nonempty` | success | `F.occurrence w w x` supplies the witness |
| `transAtState_iff` (the cut remark) | `obtain … := F.occurrence w u 0` | success | the remark's "every `u` is some `σ(x)`" step |

No tactic was found to fail in a way that blocks the design. `aesop`, `omega`, `decide` and
`hammer_premise` were not needed: every goal in scope is set-theoretic bookkeeping over
`lawHist`/`HF` plus the occurrence lemma, and the explicit terms are both shorter and
choice-honest.

## Context Extension Recommendations

- **Topic**: The abstract truth-clause layer's frame binding.
  **Gap**: `context/project/lean4/` has no note recording that `Semantics/TruthClauses.lean` is
  instantiable only by a language whose evaluation point is `(TaskModel F, WorldHistory F,
  F.Duration)`, and that a semantics over a *different* frame type must re-derive the
  derived-operator layer. This task rediscovered it by reading the class signatures; the next
  non-`TaskFrame` semantics (a nomic one, a neighbourhood one, a two-dimensional one) will
  rediscover it again.
  **Recommendation**: a short note under `context/project/lean4/patterns/` naming the binder
  set, the nine derived-operator lemmas, and the "generalising the layer is a six-component
  refactor" verdict, so the cost is a looked-up fact rather than a re-derived one.

- **Topic**: `warning-budget.txt`'s zero baseline and its *missing-row is exit 2* rule.
  **Gap**: the Lean context's build/gate material does not name the classes that are blocking at
  zero, nor the deprecated-API spellings currently in flux (`push_neg` → `push Not`,
  `HasSubset.Subset.ssubset_of_ne` → `LE.le.ssubset_of_ne`, `Int.le_induction` →
  `Int.leInduction`). Two consecutive tasks have now paid for the same discovery.
  **Recommendation**: extend `context/project/lean4/operations/` with a short "zero-warning
  budget" section listing the blocking classes, the three current deprecations, and the fact
  that an *unlisted* class exits 2 rather than failing softly.

## Appendix

### Search queries and probes

- `lean_local_search "NomicFrame.lawHist"` — seven hits across the four 794 modules;
  `index: warming`, so this is corroborating evidence, not an absence proof.
- `lean_run_code` probes, in order: the formula type + truth recursion + `TenseFree` +
  `nomicSatSet` + the bridge + the fragment collapse; the frame-level six-way equivalence; the
  nine derived-operator clause lemmas with the ℤ `succ` check; `app:nomic-four` `(⇐)`;
  `app:nomic-four` `(⇒)` (two runs, the second after fixing one `rw [and_iff]` that needed
  `niff` unfolded first); a targeted probe of the three fixes (`niff_iff`,
  `LE.le.ssubset_of_ne`, `push Not`); the full `(⇒)` again, clean; seriality + the full collapse
  + the accessibility-relation identity + the `F3` instantiation; the `rmk:nomic-uniform` side
  lemma.
- `grep -rn "NomicFormula\|NomicTruth\|NomicModel\|nomicSatSet\|NomicLanguage"` over the
  repository outside `specs/` — one hit, in `specs/TODO.md`.
- `bash scripts/check-paper-definitions.sh --resolve '<anchor>|env|-|-'` for the four anchors.

### Documentation consulted

- `scripts/measure-refactor-partitions.py` — `LANGUAGE_FILE_LAYERS`, the "a new file in a
  language directory needs a row here; without one `layer_of` raises" rule, and the
  pre-merge-origin rationale.
- `scripts/check-metalogic-cycles.sh` — assertion C reads its syntax and semantics module sets
  off that table and fails loudly on a degenerate (empty) set.
- `scripts/check-module-invariants.sh` — C8, C15 (both assertions), C16, C23, C24, C26, C28,
  C31, C32, C33, C34a/b, C35 headers.
- `scripts/warning-budget.txt` — the disposition table and the zero baseline.
- `FormalSystem/OpenLanguage/README.md` — the semantic-only component contract, the
  paper-label correspondence table, and the "Manuscript operators without a formalization" row
  that this task repoints.
- `FormalSystem/Metalogic/Independence/StateSetTruth.lean` — the `satSet` recursion, the
  ignoring-set `box` clause and its choice rationale, and the `prop:nomic-tense-free` forward
  pointer written for this port.
- `FormalSystem/Semantics/Nomic/README.md` and the four 794 modules — signatures, the
  carrier-boundary hazard, and the recorded choice dependence.
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` lines 3705–3890;
  `appendix_cut_material.tex` lines 612–620.

### Notes for the paper's author (different repository, out of scope here)

The `% PORT:` markers under `prop:nomic-tense-free`, `thm:nomic-uniform` and `app:nomic-four`
can be cleared once this task lands, and their proofs closed with `\leanproof{...}` citations.
Declaration names should be chosen in Phase 2 and Phases 5–7 so that no rename is needed later,
exactly as 794 did for `NomicFrame.occurrence` and
`NomicFrame.lawHist_eq_iff_taskRel_eq`.
