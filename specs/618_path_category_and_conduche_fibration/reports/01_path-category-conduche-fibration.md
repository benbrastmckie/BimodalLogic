# Research Report: Task #618

**Task**: 618 - Formalize the path category `Path(F)` and prove `cor:path-fibration`
**Started**: 2026-10-18T05:32:05Z
**Completed**: 2026-10-18T06:05:00Z
**Effort**: 2.5 hours (research); implementation estimate in Recommendations
**Dependencies**: 563 (interval site, behavior presheaf — archived, landed), 564 (Sheaf clause — archived, landed), 616 (duration monoid, twisted-arrow site — `[completed]`), 617 (Reflection clause — `[completed]`, last commit `d034460fd`)
**Sources/Inputs**:
- Paper anchors `def:conduche`, `def:path-category`, `fact:conduche-equivalence`, `cor:path-fibration` in `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex` lines 751-801 (commented, under `\label{app:Structure}`)
- Codebase: `FormalSystem/Semantics/Presheaf/{Site,Duration,Behavior,Sheaf,Reflection}.lean`, `Presheaf.lean` aggregator, `Presheaf/README.md`; `FormalSystem/Semantics/{PartialHistory,TaskFrame,IntNormalForm,IntNormalFormEffective,Periodicity,ShiftFiniteType}.lean`
- Mathlib (pinned `v4.33.0-rc1`): `Mathlib/Combinatorics/Quiver/{Basic,Path}.lean`, `Mathlib/CategoryTheory/{Category/Basic,Functor/Basic,PathCategory/Basic,SingleObj}.lean`
- lean-lsp MCP: `lean_run_code` (four feasibility probes against the built tree), `lean_local_search` (degraded: `index: error` then `warming`)
- Gates: `scripts/check-module-invariants.sh` (C15, C23, C24, C31, C33, C34), `docs/development/REFERENCE_NORMAL_FORM.md`, `docs/reference/paper-definitions-of-record.md`
- Seed context: `specs/archive/718_omega_sequence_decidability_full_lplus/reports/01_gluing-route-seed.md` §3
**Artifacts**: - `specs/618_path_category_and_conduche_fibration/reports/01_path-category-conduche-fibration.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **All four dependencies have landed.** `Beh F l`, `Beh.restrict`/`restrictTr`, `Beh.germEquiv`, `glue` with its two restriction identities and `glue_unique`, `Dur` with its monoid laws, and `Factorization l` with factorization-linearity are all in the tree under `FormalSystem/Semantics/Presheaf/`. Nothing `Path(F)` needs is missing upstream; no spawn is required.
- **The core encoding was probed and compiles sorry-free at `[propext, Quot.sound]`.** A val-preserving `Beh.castLen`, a sum-form `glueSum : Beh F l₁ → Beh F l₂ → Beh F (l₁ + l₂)` defined as `glue` at the cut `l₁`, a `PathHom F w u` structure (`len : Dur F.Duration`, `sec : Beh F len.val`, two endpoint equations), `PathHom.ext'`, `PathHom.id` (via `Beh.ofGerm`) and `PathHom.comp` (via `glueSum`, endpoints read through the two restriction identities) all typecheck against the built tree (`lean_run_code`, this session). The dependent-length transport that the Sheaf module's notes warned about is a one-line, val-preserving cast — it is not an obstacle.
- **Recommended encoding: introduce `Mathlib.CategoryTheory` minimally, in `Path.lean` only.** `Duration.lean`'s Implementation Notes name this task as the point at which to weigh it, and the deliverable's first bullet (the general notion of a discrete Conduché fibration `P : E → BD⁺`) is not statable without a notion of category and functor. Probed: a `Category` instance on a one-object synonym `BObj D` whose homs are `Dur D` is exactly `Dur.id_comp`/`comp_id`/`comp_assoc` verbatim; `len : PathCat F ⥤ BObj F.Duration` has `map_id`/`map_comp` by `rfl`; a general `IsDiscreteConduche (P : E ⥤ BObj D) : Prop` typechecks. `Site.lean`/`Duration.lean` stay concrete; no instance is put on `Obj D` or on `F.WorldState` itself.
- **The paper's "equality, not natural isomorphism" claim is formalizable as a `rfl`.** The middle factor of the unique factorization of `e` over `l = p + l' + (l - p - l')` is, by construction, `Beh.restrictTr (Tr p) e.sec`; the theorem content is the *uniqueness* (`factor_unique`), and functoriality of the associated presheaf is then `Beh.restrictTr_id`/`restrictTr_comp` for free. This is what the docstring should say.
- **The `D = ℤ` clause has every ingredient in the tree except the window-level adjacency lemma.** `FrameOver.step`, `iter`, `taskRel_natCast_iff_iter`, the choice-free `taskRel_eq_iter_int` and `reflection_int`, and `Periodicity.iter_of_path` exist; `mem_HF_iff_adjacent_int` is the total-history analogue. Mathlib's `Quiver.Path` (import `Mathlib.Combinatorics.Quiver.Path`, no `CategoryTheory` dependency) is the free-category hom type, and Mathlib's `CategoryTheory.Paths` is *defined* with `Hom := Quiver.Path`, `id := nil`, `comp := Path.comp`, so a hom-set `Equiv` commuting with `comp`/`id`/length is literally "the free category on `(W, ⇒₁)`". The quiver must be `PLift ∘ F.step`: `Quiver.Hom` is `Type v`-valued in this Mathlib, not `Sort v` (probed).
- **One gate precondition the planner must schedule:** `def:conduche`, `def:path-category` and `fact:conduche-equivalence` have **no rows** in `docs/reference/paper-definitions-of-record.md` (only `cor:path-fibration` and `def:twisted-arrow` do), so citing them in a docstring fails check C15 unless `DANGLING` rows are added first — task 616 phase 1 (`e74fa4368`) is the precedent.
- A **sorry-free path exists** for every deliverable. The associativity and unit laws should be proved through `glue_unique` + `Beh.restrict_comp` (uniqueness of gluing), never by unfolding `glue`'s dependent `if`; the one genuinely laborious phase is the `Quiver.Path` round trip for `D = ℤ`.

## Context & Scope

The task formalizes, in a new module `FormalSystem/Semantics/Presheaf/Path.lean` (the declared `file_scope`), the instance of Johnstone's sheaf/Conduché correspondence at `X = Beh F`: the associated category `Path(F)`, the length functor, the discrete Conduché fibration property of `len`, the equality of its associated presheaf with `Beh F`, and the `D = ℤ` identification with the free category on `(W, ⇒₁)`. The HARD SCOPE LIMIT excludes Johnstone's general equivalence (`fact:conduche-equivalence`, Prop. 3.6; SSV Thm. A.2.1), which is to be recorded as cited and external.

Constraints inherited from the cluster, all re-read this session:
- `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree` closes every module in `Presheaf/` (layering lock below `Semantics/Truth.lean`).
- No `Mathlib.CategoryTheory` is imported anywhere in `FormalSystem/` or `Tests/` today (grep, this session); `Presheaf/Reflection.lean` imports `Mathlib.Tactic.Abel` as the only non-`FormalSystem` import in the cluster, so a Mathlib import beyond `Init` has in-cluster precedent.
- Every declaration carries a `Constraints consumed:` line from the closed vocabulary `{None, Compositionality, Seriality, Limit, Saturation}` (C34, `REFERENCE_NORMAL_FORM.md` §3); `## References` entries use the `[Author, *Title*][key]` form with keys resolving in root `references.bib` (`schultz2020` line 830, `johnstone1999` line 841 both exist).
- The aggregator `Presheaf.lean` is a SHARED TOUCH (dispatch description); the library root `FormalSystem.lean` is generated (`lake exe mk_all --lib FormalSystem`, C33); `Presheaf/README.md` has a generated inventory block (`scripts/readme-inventory.sh`); 616/617's wiring phases also touched `FormalSystem/README.md`, root `README.md` and `typst/generated/status.typ` (`scripts/typst-status-counts.sh`).

Evidence tier: `lean_local_search` reported `index: error` on first call and `index: warming` on the second, so **absence claims below were established by `grep` over `.lake/packages/mathlib`**, not by the LSP index. `lean_run_code` was fully functional and is the basis of every "compiles" claim.

## Findings

### Codebase Patterns

**The behavior presheaf API that `Path(F)` composes over** (`Presheaf/Behavior.lean`, `Presheaf/Sheaf.lean`):
- `Beh F l := { τ : PartialHistory F // ∀ t, τ.domain t ↔ (0 ≤ t ∧ t ≤ l) }`, indexed by a raw `l : F.Duration`, not by `Obj D`; the site-indexed form is `Beh.restrictTr (f : Tr l' l) : Beh F l.val → Beh F l'.val`. The pointwise-`Iff` design is load-bearing: it is what makes a length cast val-preserving (below).
- `glue hcomp hp hpl (τ₁ : Beh F p) (τ₂ : Beh F (l - p)) hmatch : Beh F l` is in **cut form**. `restrict_glue_left`, `restrict_glue_right`, `glue_unique`, `sheaf_clause` are its API; `glue_states_le`/`glue_states_not_le` are the `dif_pos`/`dif_neg` reading lemmas. `hmatch` is a states equation `τ₁(p) = τ₂(0)`; `compat_iff_match` relates it to the germ-section equality.
- `Beh.germ`, `Beh.ofGerm F w` (needs `[F.IsRegular]`, via `nullity_identity`), `germEquiv : Beh F 0 ≃ F.WorldState`.
- `states_eq_of_eq (h : σ = τ) r hσ hτ`, `PartialHistory.states_eq_of_time_eq`, `partialHistory_ext`, `Beh.ext` — the reading kit every Sheaf proof uses.

**The duration monoid and factorizations** (`Presheaf/Duration.lean`): `Dur D` (abbrev for `Obj D` = `PositiveCone D`), `Dur.comp a b = ⟨a.val + b.val, _⟩`, `Dur.id = ⟨0, _⟩`, laws `Dur.id_comp`/`comp_id`/`comp_assoc`/`comp_comm`; `Factorization (l : Obj D)` with fields `fst snd fst_nonneg snd_nonneg add_eq`, `Factorization.ext` (determined by `fst`), `ofCut`, `fst_le`. **`Factorization e.len` is exactly the paper's "factorization `P(e) = x + y`"** in `def:conduche`, so the fibration predicate can quantify over it directly.

**Sum-form gluing is a one-line transport away from cut-form gluing** (probed). The Sheaf module's note says the sum form "would need a dependent transport along `l₁ + l₂ - l₁ = l₂` at every statement and buys nothing"; for `Path(F)` composition the sum form is exactly what is needed, and the transport is cheap because `Beh` is a subtype with a pointwise-`Iff` condition:
```lean
def Beh.castLen {l l' : F.Duration} (h : l = l') (τ : Beh F l) : Beh F l' :=
  ⟨τ.val, fun t => by rw [← h]; exact τ.property t⟩          -- (castLen h τ).val = τ.val is rfl
def glueSum hcomp (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) (τ₁ : Beh F l₁) (τ₂ : Beh F l₂) hmatch : Beh F (l₁ + l₂) :=
  glue hcomp h₁ (le_add_of_nonneg_right h₂) τ₁ (Beh.castLen (add_sub_cancel_left l₁ l₂).symm τ₂) hmatch
```
`hmatch` is accepted **by `exact`** (definitional, since `castLen` preserves `.val` and `mem_dom` proofs are irrelevant); `simpa using hmatch` fails unless `castLen_val` is a `@[simp]` lemma. `glueSum` measured `[propext, Quot.sound]`. The two restriction identities restate at the sum form by delegation (`glueSum_restrict_left := restrict_glue_left …`, `glueSum_restrict_right := restrict_glue_right …`, the latter landing in `Beh F (l₁ + l₂ - l₁)` and equal to `castLen … τ₂`), and the endpoint readings `glueSum_states_zero` / `glueSum_states_end` follow by `states_eq_of_eq` + `Beh.restrict_states` + `states_eq_of_time_eq` — the same three-step shape as `restrict_glue_left`'s proof body. **Probe 4 (this session) compiled all of these plus `PathHom.comp` sorry-free at `[propext, Quot.sound]`.**

**The hom structure.** Probed and compiling:
```lean
structure PathHom (F : TaskFrame) (w u : F.WorldState) where
  len : Dur F.Duration
  sec : Beh F len.val
  src : sec.val.states 0 (Beh.mem_dom sec le_rfl len.property) = w
  tgt : sec.val.states len.val (Beh.mem_dom sec len.property le_rfl) = u
theorem PathHom.ext' (hl : f.len = g.len) (hs : f.sec.val = g.sec.val) : f = g   -- [propext]
def PathHom.id [F.IsRegular] (w) : PathHom F w w := ⟨Dur.id, Beh.ofGerm F w, rfl, rfl⟩
def PathHom.comp (hcomp) (f : PathHom F w u) (g : PathHom F u v) : PathHom F w v :=
  { len := Dur.comp f.len g.len, sec := glueSum hcomp f.len.property g.len.property f.sec g.sec (f.tgt.trans g.src.symm),
    src := (glueSum_states_zero hcomp _ _ _ _ _ _).trans f.src, tgt := (glueSum_states_end hcomp _ _ _ _ _ _).trans g.tgt }
```
`PathHom.ext'` is the key: the category laws reduce to a `Dur` law on `len` plus a `PartialHistory` equality on `sec.val`, so no `HEq` and no `▸` appears anywhere. The length lives in the hom (a Σ-type over `Dur`) rather than in the type, which is what lets `comp` be total and `len` be a plain projection.

**Constraint consumption.** `comp`, `glueSum`, `castLen` and the fibration proof consume *Compositionality* only (take `hcomp : TaskFrame.Compositional F.TaskRel` explicitly, the Sheaf module's convention). `id` consumes *Seriality* and *Limit* through `Beh.ofGerm`'s `[F.IsRegular]` (via `nullity_identity`). A `Category` instance needs both, so it carries `[F.IsRegular]` and the marker `Constraints consumed: Compositionality, Seriality, Limit`; `F.comp : Compositional F.TaskRel` (`TaskFrame.lean:2682`) supplies `hcomp` inside it. The binder-free twins (`PathHom.comp` at explicit `hcomp`) are what C34a's delegation rule wants.

**Reuse for `D = ℤ`** (`Semantics/IntNormalForm.lean`, `IntNormalFormEffective.lean`, `Periodicity.lean`):
- `FrameOver.step (F : FrameOver intOrder) w u := F.TaskRel w 1 u` (line 182), `iter R : ℕ → W → W → Prop` (line 130) with `iter_zero`, `iter_succ`, `iter_one`, `iter_add`.
- `taskRel_natCast_iff_iter : F.TaskRel w (n : ℤ) u ↔ iter F.step n w u` (line 196) — "iterating Compositionality identifies `⇒ₙ` with the `n`-fold composite of `⇒₁`", already proved.
- `taskRel_eq_iter_int` (Effective, line 115) and `reflection_int` (line 103): the **choice-free** sign-split form; the dispatch's "reuse that reasoning" is satisfied by consuming these, and the `_int` variants are what keep the ℤ clause off `Classical.choice`.
- `Periodicity.exists_path_of_iter` / `iter_of_path` (lines 61-97): the ℕ-indexed window ↔ iterate conversions; the ℤ-window analogue needed here is the same induction.
- `mem_HF_iff_adjacent_int` is the **total-history** version of the clause; there is no window (`[0, n]`) version in the tree — grep for `IsStepPath`/window builders found only the total `IsStepPath` (line 274). The window lemma is new content, small.
- `F.toTaskFrame` is `@[reducible]` (`TaskFrame.lean:2609`), `(F.toTaskFrame).IsRegular` is an instance (line 2957), and `Dur intOrder = {x : ℤ // 0 ≤ x}`, so `PathHom F.toTaskFrame w u` for `F : FrameOver intOrder` needs no transport.

**Gates and wiring the module must satisfy** (all re-read this session):
- C15: anchors `def:conduche`, `def:path-category`, `fact:conduche-equivalence` are **absent** from the record's manifest (grep: only prose mentions at `paper-definitions-of-record.md` lines 976-977, 1003-1004; `cor:path-fibration` has a row at line 2528 and `def:twisted-arrow` at 2519). The C15 regex `\b(def|thm|lem|cor|app|rmk):[A-Za-z0-9][A-Za-z0-9_-]*` catches any mention in `.lean`/`.md`/`.typ` live scope.
- C23: do not introduce an underscore-suffixed name whose prefix is a live declaration (naming test in `MODULE_ORGANIZATION.md` §2). `PathHom.comp`, `PathHom.id`, `Path.len` are dot-namespaced and fine.
- C24/C33: the module must be imported by `Presheaf.lean` and appear in `FormalSystem.lean` (regenerate with `lake exe mk_all --lib FormalSystem`).
- C31: bib keys `schultz2020`, `johnstone1999` resolve.
- C34: every declaration carries a marker line.

### External Resources

**Mathlib has no Conduché fibration** (grep -ri 'conduch' over `Mathlib/`: zero files) and **no discrete-fibration predicate** (grep for `DiscreteFibration|IsDiscreteFibration`: zero). The notion must be defined here. No `Fact(l)`-style factorization category either (already recorded in `Duration.lean`).

**Mathlib's free category on a quiver** (`Mathlib/CategoryTheory/PathCategory/Basic.lean`): `Paths V := V` with `instance categoryPaths : Category (Paths V)` whose `Hom X Y := Quiver.Path X Y`, `id := Path.nil`, `comp := Path.comp`. `Quiver.Path` lives in `Mathlib/Combinatorics/Quiver/Path.lean` (imports: `Quiver.Prefunctor`, `Logic.Lemmas`, `Batteries.Data.List.Basic` — **no `CategoryTheory`**), with `length`, `comp`, `comp_assoc`, `nil_comp`, `comp_nil`, `length_comp`, and the recursor `Path.rec` (probed `#check`s). `PathCategory/Basic.lean` imports `Mathlib.CategoryTheory.Quotient`, which is heavier; it is **not** needed to state the ℤ clause if the statement is a hom-set `Equiv` plus compatibility lemmas.

**`Quiver.Hom` is `Type v`-valued** (`Quiver/Basic.lean:38-40`, probed): a Prop-valued relation does not directly give a quiver. The quiver on `W` for the one-step graph is `⟨fun a b => PLift (F.step a b)⟩`; `PLift` of a `Prop` is a `Subsingleton`, so path equality is unaffected by proof terms.

**Mathlib `Category` instance on the duration monoid** (probed, `Mathlib.CategoryTheory.Functor.Basic`):
```lean
structure BObj (D : TemporalOrder) where unit : Unit        -- one object, a synonym so no instance leaks
instance : Category (BObj D) where
  Hom _ _ := Dur D; id _ := Dur.id; comp f g := Dur.comp f g
  id_comp := Dur.id_comp; comp_id := Dur.comp_id; assoc := Dur.comp_assoc
```
This is exactly the reconciliation `Duration.lean`'s note promised ("exactly the fields a `Category` instance would need"). `CategoryTheory.SingleObj M` is not usable because `Dur` carries no Mathlib `Monoid`/`AddMonoid` instance (a recorded decision in `Duration.lean`). `Mathlib.CategoryTheory.Functor.Basic` imports `Category.Basic`, `Quiver.Prefunctor`, `Tactic.CategoryTheory.CategoryStar`; oleans are present in the Mathlib cache.

**The `Functor` and the general predicate** (probed, typecheck):
```lean
def PathCat (F : TaskFrame) : Type := F.WorldState      -- synonym carrying the Category instance
instance [F.IsRegular] : Category (PathCat F) where Hom w u := PathHom F w u; id := PathHom.id; comp f g := PathHom.comp F.comp f g; …
def len [F.IsRegular] : PathCat F ⥤ BObj F.Duration where obj _ := ⟨()⟩; map f := f.len; map_id _ := rfl; map_comp _ _ := rfl
def IsDiscreteConduche {E : Type*} [Category E] (P : E ⥤ BObj D) : Prop :=
  ∀ {A B : E} (e : A ⟶ B) (fac : Factorization (P.map e)),
    ∃! t : Σ C : E, (A ⟶ C) × (C ⟶ B), t.2.1 ≫ t.2.2 = e ∧ (P.map t.2.1).val = fac.fst ∧ (P.map t.2.2).val = fac.snd
```

**Literature.** Johnstone 1999 (`johnstone1999`), Introduction and §2 (definition of discrete Conduché fibration, the twisted-arrow site and its coverage), Prop. 3.6 (the equivalence, **cited only**); SSV 2020 (`schultz2020`) Def. A.1.1, §§A.2-A.3 (associated category at `Int`, free category on a graph for `Int_ℕ`, Prop. 3.2.3), Thm. A.2.1 (the equivalence for factorization-linear categories, **cited only**). Both are in the literature briefing's COVERAGE DELTA (present in the global corpus, absent from this repo's sub-index) and were not re-read; the paper's own transposition in `appendix_cut_material.tex` lines 751-801 is the statement of record and was read in full.

### Recommendations

**R1 — Encoding: minimal `Mathlib.CategoryTheory` in `Path.lean` only, concrete elsewhere.** Import `Mathlib.CategoryTheory.Functor.Basic` (and `Mathlib.Combinatorics.Quiver.Path` for the ℤ clause) in `Path.lean`; put `Category` instances only on the synonyms `BObj D` and `PathCat F`, never on `Obj D`, `Dur D` or `F.WorldState`; leave `Site.lean`/`Duration.lean` untouched and state the associated presheaf against `Tr`/`Beh.restrictTr` concretely (no `Category` instance on `Int(D)`, no `Functor` to `Type` — that would be the general half of the cited equivalence). Record in the Implementation Notes that this is the weighing `Duration.lean` deferred, why it comes out the other way here (the first deliverable bullet is unstatable without categories and functors; the three category laws are proved either way; nothing leaks onto cluster types), and that the `assert_not_exists` lock is unaffected. **Alternative, if the planner prefers zero Mathlib category theory:** state the fibration property for `len` alone (`PathHom`-level `∃!`) and the ℤ clause as a `Quiver.Path` `Equiv` — this loses only the *general* `IsDiscreteConduche` predicate, which would then be described in prose. Either is sorry-free; R1 is the recommendation because it meets bullet 1 of the deliverable literally.

**R2 — Prove the category laws through uniqueness of gluing, not by unfolding.** `assoc` for `PathHom`: by `PathHom.ext'`, `len` is `Dur.comp_assoc`; `sec.val` equality via `glue_unique` applied to `castLen (add_assoc …) (glueSum (glueSum a b) c)`, whose left restriction to `l₁` is `a` (by `Beh.restrict_comp` chaining `restrict 0 l₁ ∘ restrict 0 (l₁ + l₂)` then `glueSum_restrict_left` twice) and whose right restriction onto `l₂ + l₃` is `glueSum b c` (itself characterized by `glue_unique`). Unit laws: `restrict 0 0 f = ofGerm (f 0)` is `Beh.ofGerm_germ` after `Beh.ext`; `restrict 0 l f = f` is `Beh.restrict_id` up to `castLen`. A small "cast kit" makes this mechanical: `castLen`, `castLen_val` (`rfl`, `@[simp]`), `castLen_castLen`, `restrict_castLen_val : (restrict p l' … (castLen h τ)).val = (restrict p l' … τ).val` (`rfl`), and `castLen_eq_iff : castLen h τ = σ ↔ τ.val = σ.val`. Never case-split on `glue`'s `dite` in this module; the Sheaf module already paid for that once.

**R3 — The fibration property for `len`, in two statements.** (a) Val-level, cast-free: `factor_exists`: for `e : PathHom w u` and `fac : Factorization e.len`, the triple `C := e.sec fac.fst`, `e₁ := ⟨⟨fac.fst,_⟩, restrict 0 fac.fst … e.sec, …⟩`, `e₂ := ⟨⟨fac.snd,_⟩, restrict fac.fst fac.snd … e.sec, …⟩` satisfies `comp e₁ e₂ = e` (by `ext'` + `glue_unique` with `υ := castLen fac.add_eq.symm e.sec` and the two restriction identities) and the two length equations; `factor_unique`: any `(C', e₁', e₂')` with those lengths and `comp e₁' e₂' = e` has `C' = e.sec fac.fst`, `e₁'.sec.val = …`, `e₂'.sec.val = …` (by `restrict_glue_left`/`right` read against `e`). (b) The packaged `IsDiscreteConduche len` as the `∃!` over `Σ C, (A ⟶ C) × (C ⟶ B)`, derived from (a). The sigma form is where the one dependent equality (`C' = C`, then `subst`) lives; keep it out of (a).

**R4 — The associated presheaf is `Beh F`, as an equality.** Define `assocRestrict (f : Tr l' l) (e : PathHom w u) (hl : e.len = l) : Σ c c', PathHom c c'` as the middle restriction with length `l'`, prove `assocRestrict_sec : (assocRestrict f e hl).2.2.sec.val = (Beh.restrictTr f (castLen … e.sec)).val` **by `rfl`**, and `assocRestrict_unique` (any middle factor of a three-fold factorization with lengths `(p, l', l - p - l')` has that `.val`) from R3 applied twice. Then functoriality of the associated presheaf is `Beh.restrictTr_id`/`restrictTr_comp` — state them as corollaries and say in the docstring that this is why the paper's `cor:path-fibration` proof can claim equality where `fact:conduche-equivalence` returns only a natural isomorphism: the middle factor is *defined* as the restriction, and uniqueness is a theorem about it. The "associated category of a sheaf" and "length functor" notions are instantiated at `X = Beh F` (that is what `Path(F)` and `len` *are*); say so in the module docstring and that the general forms are the two halves of the cited, external equivalence.

**R5 — `D = ℤ`, in two layers.** Layer 1 (the paper's first sentence): for `F : FrameOver intOrder` `[F.IsRegular]` and `n : ℤ`, `0 ≤ n`, a function `g : ℤ → F.WorldState` is the state function of some `τ : Beh F.toTaskFrame n` iff `∀ i, 0 ≤ i → i < n → F.step (g i) (g (i+1))` (`beh_int_iff_adjacent_window`). Forward: `respects_task` at `(i, i+1)` with `(i+1) - i = 1` and `step_def`. Backward: build `respects_task` from a window-iterate induction (`iter F.step (t-s).natAbs (g s) (g t)` for `0 ≤ s ≤ t ≤ n`, the ℤ-window twin of `Periodicity.iter_of_path`) and `taskRel_eq_iter_int` for both signs — choice-free by routing through the `_int` lemmas, as `ShiftFiniteType.lean` does. Layer 2 (the free category): with `stepQuiver F : Quiver F.WorldState := ⟨fun a b => PLift (F.step a b)⟩`, define `toPath : PathHom F.toTaskFrame w u → Quiver.Path w u` by induction on `len.val.toNat` (peel the last step via `restrict 0 (n-1)` and `Path.cons`), `ofPath` by `Quiver.Path.rec` (nil ↦ `PathHom.id`, cons ↦ `comp` with a one-step hom built from `step` + `reflection_int` + `nullity`), then `toPath_length : (toPath e).length = e.len.val.toNat`, `toPath_id = nil`, `toPath_comp : toPath (comp f g) = (toPath f).comp (toPath g)` ("gluing is concatenation"), and the two round trips giving `pathEquiv : PathHom F.toTaskFrame w u ≃ Quiver.Path w u`. Cite `CategoryTheory.Paths.categoryPaths` in the docstring as the definition this matches, so a reader sees it is an isomorphism of categories with Mathlib's free category without importing `PathCategory/Basic.lean`.

**R6 — Phase shape and sizing** (for the planner; 617's plan is the template): Phase 1 — record rows for the three missing anchors + module skeleton + cast kit + `glueSum` and its four lemmas (0.75 h). Phase 2 — `PathHom`, `ext'`, `id`, `comp`, the three category laws by R2, `BObj`, both `Category` instances, `len` (2 h; `assoc` is the long proof). Phase 3 — `IsDiscreteConduche`, R3 (a)+(b), R4 (2 h). Phase 4 — ℤ Layer 1 (1 h). Phase 5 — ℤ Layer 2 (2.5 h; largest risk, see Risks). Phase 6 — wiring: aggregator line (re-read immediately before editing; shared touch), `mk_all`, README inventory (`scripts/readme-inventory.sh`), `Presheaf/README.md` prose + footprint table, `typst-status-counts.sh`, full `check-module-invariants.sh`, `#print axioms` sweep (1 h). Every phase ends with a guarded scoped build of `FormalSystem.Semantics.Presheaf.Path`; the full `lake build FormalSystem` only in Phase 6 (the module is unreachable until the aggregator imports it). Total ≈ 9-10 h.

**R7 — Forwarded appendix item (translation product / pullback): pose, do not build.** With `PathHom`'s length in the hom, the report's observation reads cleanly: a `PathHom (prodFrame F).toTaskFrame (w,d) (v,e)` of length `l` projects to a `PathHom F w v` of length `l` with `e = d + l`, which is the pullback of `len` along `(D, ≤) → BD⁺`, `d ≤ e ↦ e - d`; questions (a)-(c) stay open and are not part of any phase above. Record them in the module docstring's closing paragraph as open, with a pointer to `Frames/TranslationProduct.lean` (`prodRel`, `liftH`, `projH`).

## Decisions

- **Length in the hom, not in the type.** `PathHom F w u` carries `len : Dur F.Duration` as a field; `len` is then a projection and `comp` is total. The alternative `PathHom F w u (l : Dur D)` would make `comp` land in `PathHom … (Dur.comp l₁ l₂)` and push `Dur.comp_assoc` into a type-level cast at every associativity statement. Rejected.
- **Sum-form gluing is derived from cut-form gluing by a val-preserving cast**, not re-proved. `glueSum := glue` at the cut `l₁` with `castLen`; its lemmas delegate. This keeps `Sheaf.lean` untouched and keeps the four-case `respects_task` argument proved once.
- **Endpoints are read through the restriction identities**, not through `glue_states_le`/`not_le`. The `r = 0` subtlety of the right branch is already paid for inside `restrict_glue_right`.
- **Explicit `hcomp` on `comp`/`glueSum`/the fibration proof; `[F.IsRegular]` only where `ofGerm` is reached and on the bundled `Category` instance.** Follows the Sheaf module's convention and C34a's delegation rule.
- **No general sheaf-to-category or fibration-to-presheaf construction.** The "associated presheaf" and "associated category" of `def:conduche` are instantiated at `len` and `Beh F`; the general notions are named in the docstring as the two halves of the cited `fact:conduche-equivalence`. This is the HARD SCOPE LIMIT, and no phase discovered the general proof to be cheap: extracting data from the `∃!` of a general fibration, or the gluing of a general sheaf, needs `Classical.choose` or data-carrying definitions that Johnstone does not use — a finding, not a licence.
- **`Quiver.Path` over `PLift ∘ F.step`** for the free category, importing `Mathlib.Combinatorics.Quiver.Path` rather than `Mathlib.CategoryTheory.PathCategory.Basic` (the latter pulls `CategoryTheory.Quotient` and is only needed for a `Paths V ≌ PathCat F` statement, which R5's `Equiv` + three compatibility lemmas already amount to).

## Risks & Mitigations

- **Phase 5 (`Quiver.Path` round trip) is the only phase with real proof-engineering risk.** `toPath` is defined by induction on a `ℕ` extracted from an `ℤ`-valued `len`; `toPath_comp` needs `Int.toNat_add` on nonnegative summands and a `castLen` at every peeled step. Mitigation: define `toPath` on an explicit `n : ℕ` with `hn : (n : ℤ) = len.val` first (`toPathAux`), prove everything at `toPathAux`, and derive the `len`-indexed versions with `Int.toNat_of_nonneg`; `Periodicity.exists_path_of_iter` is the in-tree model for the `n`-indexed induction. If the round trips resist, Layer 1 plus `toPath_comp`/`toPath_length` already deliver "gluing is concatenation" and "sections are paths"; the `Equiv` is the last 20 %.
- **`assoc` by `glue_unique` needs `Beh.restrict_comp` with specific offset proofs**, and `rw` on `restrict_comp` is sensitive to the proof arguments. Mitigation: the cast kit's `restrict_castLen_val` and `Beh.ext` keep every comparison at the `.val` level, where proof arguments are irrelevant; this is how `restrict_glue_left` already works.
- **C15 failure on first build of the module** if the three anchor rows are not added. Mitigation: Phase 1 adds `DANGLING` rows for `def:conduche`, `def:path-category`, `fact:conduche-equivalence` in `docs/reference/paper-definitions-of-record.md`, modelled on the `def:twisted-arrow` row (line 2519), before any docstring cites them. The record file is outside the declared `file_scope`; 616 did the same without widening scope.
- **Aggregator clobber** (shared touch with any concurrent Presheaf task; sibling 782 has no declared scope this cycle). Mitigation: re-read `Presheaf.lean` immediately before the one-line edit, stage only `Presheaf.lean` and `FormalSystem.lean` hunks, rebuild after.
- **Mathlib category-theory import changes elaboration in the module.** Probe 2 showed `simpa using hmatch` failing where probe 1 (no CategoryTheory import, but with `castLen_val` as `@[simp]`) succeeded; the robust fix is `exact hmatch` (definitional). Mitigation: declare `castLen_val` `@[simp]` and prefer `exact`/`rfl` over `simpa` at casts. The `assert_not_exists` lock is unaffected (Mathlib, not `ProofSystem`).
- **Axiom profile.** Everything probed so far is `[propext, Quot.sound]`; `Classical.choice` could only enter through `Int.toNat`/`omega` arithmetic in Phase 5 or through `simp` on `↑D` (the README records `simpa` pulling choice in `Worlds.lean`). Mitigation: `#print axioms` sweep per phase; route ℤ arithmetic through `taskRel_eq_iter_int`/`reflection_int`, never `taskRel_eq_iter`/`reflection`.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `glueSum`'s `hmatch` at `castLen τ₂` | `exact hmatch` | success | definitional (`castLen` is val-preserving) |
| same | `simpa using hmatch` | success only with `@[simp] castLen_val`; fail without | probe 1 vs probe 2 |
| `len.map_id`, `len.map_comp` | `rfl` | success | `PathHom.id.len = Dur.id`, `(comp f g).len = Dur.comp` definitionally |
| `BObj D` category laws | `exact Dur.id_comp` / `comp_id` / `comp_assoc` | success | `Duration.lean` laws verbatim |
| `PathHom.comp.src` | `(glueSum_states_zero …).trans f.src` | success | `states_eq_of_eq` + `Beh.restrict_states` + `states_eq_of_time_eq` |
| `PathHom.comp.tgt` | `(glueSum_states_end …).trans g.tgt` | success | `restrict_glue_right` read at `l₂`, cast-free |
| `PathHom.comp.src` | `rw [← f.src]` on the goal | fail (motive not type correct: `f : PathHom F w u` depends on `w`) | rewrite the hypothesis, not the goal |
| `PathHom.ext'` | `obtain`/`subst`/`Subtype.ext` | success, `[propext]` | — |

## Context Extension Recommendations

- **Topic**: Val-preserving casts on `Beh` and the sum-form gluing.
  **Gap**: `Sheaf.lean`'s Implementation Notes say the sum form "buys nothing"; it is exactly what `Path(F)` composition consumes, and the transport is a one-liner. No context file records the "cast on the length index, compare at `.val`" idiom.
  **Recommendation**: After implementation, add a paragraph to `Presheaf/README.md`'s recorded verdicts ("Sum-form gluing is cut-form gluing under a val-preserving cast") and reconcile `Sheaf.lean`'s note by pointer, so the two do not contradict each other.
- **Topic**: `Mathlib.CategoryTheory` in the Presheaf cluster.
  **Gap**: Three modules record "no `Mathlib.CategoryTheory`" with `Duration.lean` deferring the decision to this task; once `Path.lean` adopts it minimally, the three notes need a forward pointer so the decision is not re-litigated or misread as violated.
  **Recommendation**: Phase 6 adds one sentence to each of `Site.lean`, `Duration.lean`, `Reflection.lean` Implementation Notes: "weighed and adopted, synonym-scoped, in `Presheaf/Path.lean`; see its Implementation Notes."

## Appendix

- Search queries: `lean_local_search "Conduche"` (index `error`), `lean_local_search "Quiver.Path.comp"` (index `warming`, 10 hits in `Mathlib/Combinatorics/Quiver/Path.lean`); `grep -ril conduch .lake/packages/mathlib/Mathlib` (0 files); `grep -rl 'DiscreteFibration|IsDiscreteFibration' …` (0); `grep -rn 'import Mathlib.CategoryTheory' FormalSystem Tests` (0).
- Probes (`lean_run_code`, imports `FormalSystem.Semantics.Presheaf.Sheaf`, `…Duration`, and in probes 2-3 `Mathlib.CategoryTheory.Functor.Basic`): probe 1 — `castLen`, `glueSum`, `PathHom`, `ext'`, `id` compile; `glueSum` `[propext, Quot.sound]`, `ext'` `[propext]`. Probe 2 — `Quiver` Prop-valued `Hom` rejected (`Type v`), `PLift` form accepted; `#check` of `Path.length`, `length_comp`, `comp_assoc`, `nil_comp`, `comp_nil`, `rec`. Probe 3 — `BObj` `Category` instance, `PathCat` instance (laws `sorry` for shape only), `len` functor, `IsDiscreteConduche` typecheck. Probe 4 — `glueSum_restrict_left/right`, `glueSum_states_zero/end`, `PathHom.comp` sorry-free, `[propext, Quot.sound]`.
- Paper text consulted: `appendix_cut_material.tex` lines 625-801 (the `app:Structure` block and its header comment, which notes the Lean tree holds `Presheaf.sheaf_clause` and `Presheaf.directed_gluing_clause`).
- Record rows consulted: `paper-definitions-of-record.md` lines 2519 (`def:twisted-arrow`), 2528 (`cor:path-fibration`, which states "NO Path(F) exists in the tree" — true before this task).
- Gate sources: `scripts/check-module-invariants.sh` lines 2643-2720 (C15), `docs/development/MODULE_INVARIANTS.md` rows C24, C33, C34a/b, `docs/development/MODULE_ORGANIZATION.md` §2 (C23), `docs/development/REFERENCE_NORMAL_FORM.md` §§1-3.
- Issue log: three entries written to `specs/618_path_category_and_conduche_fibration/issues.jsonl` this dispatch (one `win`: feasibility probe; two `issue`: C15 precondition, degraded `lean_local_search` index).
