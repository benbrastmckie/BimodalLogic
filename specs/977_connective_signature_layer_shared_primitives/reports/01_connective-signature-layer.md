# Research Report: Task #977

**Task**: 977 - connective_signature_layer_shared_primitives
**Started**: 2026-11-23T19:35:31Z
**Completed**: 2026-11-23T19:44:58Z
**Effort**: Implementation estimate 3 to 5 phases; the signature and clause-class rebase are small (6 generic files, 8 instance sites), the per-language rewrite is mechanical and measured to change no stored definition body
**Dependencies**: None for research and planning. Implementation waits on the temporal contribution (head `5ecc91d63`) merging.
**Sources/Inputs**:
- Codebase: `FormalSystem/Syntax/Formula.lean`, `FormalSystem/PlusLanguage/Formula.lean`, `FormalSystem/StarLanguage/Formula.lean`, the five other language syntax files, `FormalSystem/Semantics/TruthClauses.lean`, `TemporalRules.lean`, `TemporalIntervals.lean`, `Truth.lean`, `FormalSystem/Tactic/{FormulaSyntax,FormulaViews,Attr}.lean`, `FormalSystem/Metalogic/Expressiveness/SeparationZ/Syntax.lean`, `Tests/BimodalTest/Semantics/ValidityLayerTest.lean`
- Records: `records/proof-mode-architecture.md`, `records/milestones.md`, `ORGANISATION.md`
- Open contribution: temporal branch at `5ecc91d63` (`FormalSystem/PlusLanguage/TemporalViews.lean`, `FormalSystem/Tactic/TemporalFormulaViews.lean`)
- Model: `~/Projects/cslib/Cslib/Foundations/Logic/Connectives.lean` (224 lines, measured)
- Compiled probes: three scratch files run with `lake env lean` against the existing build, preserved under `specs/977_connective_signature_layer_shared_primitives/prototypes/`
**Artifacts**: - specs/977_connective_signature_layer_shared_primitives/reports/01_connective-signature-layer.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **First question, settled: option (i).** The signature is the syntactic half of the clause classes. It sits at layer 0 in `FormalSystem/Syntax/`, the clause classes of `TruthClauses.lean` are restated over it, and the derived operators that file defines move down to it. Option (ii) is not buildable: the clause classes need a `TruthEnv` instance, which needs `TruthAt`, which is defined by recursion on the formula type at layer 1, while the per-language operators are consumed at layer 0. Option (iii) is the present state.
- **The clause classes should become `Prop`-valued mixins over the signature**, not classes that `extend` it. Both compile; the mixin form has one instance path to each operator and the `extends` form has two.
- **A per-language name must not be defined as the signature operator applied at that type.** Measured: after unfolding such a name, `simp only [Truth.imp_iff]` does not fire and `rw [Truth.imp_iff]` fails, because the term is `Sig.neg φ` over instance projections and not `Formula.imp φ Formula.bot`. 749 `simp`/`rw` sites in 137 files unfold these names.
- **The per-language bodies can instead be generated from the single signature definition.** A prototype elaborator that unfolds the signature operator one layer and resolves instance projections produces bodies structurally identical to the ones in the tree in 63 of 63 cases (20 for `Formula`, 17 for `PlusFormula`, 16 for `StarFormula`, 10 for `USForm`). The encoding is then written once and no downstream proof changes.
- **Reducibility: do not make the per-language Boolean and dual definitions `abbrev` in this task.** Measured on L: it does make a view definitional, and it also flips the normal form of the truth simp set (`and_iff` stops firing, `imp_iff` wins). The signature-level operators stay `abbrev`, as the `TruthClauses` ones are today.
- **Two corrections to the task description.** The doubled operators number 17, not 18, and one of them, `reflectTime`, is a recursion on the inductive type and cannot be written on a signature class.

## Context & Scope

The task asks for a signature layer under `FormalSystem` so that `Formula`, `PlusFormula` and `StarFormula` are instances of one interface, and for a ruling on where the derived operators have their one home given that `Semantics/TruthClauses.lean` already defines them generically. Primitives stay minimal and the `Atom` type stays fixed; both are constraints, not questions. Research was limited to reading, counting and compiling scratch files; no file under `FormalSystem/` or `Tests/` was edited.

The report of `investigate_stability_as_modal_family` does not exist (the task is not started), so nothing was read from it.

## Findings

### Codebase Patterns

**What is duplicated, measured.**

- `Formula` has 35 definitions in its namespace, `PlusFormula` 23, `StarFormula` 22. The intersection of the first two is 17 names: `after allFuture allPast always and diamond kMinus kPlus neg next or prev reflectTime someFuture somePast sometimes top`. The description's "eighteen" lists these same 17.
- Across all nine formula types (the three above, `OpenFormula`, `HybridFormula`, `QuantFormula`, `NomicFormula`, `MinusFormula`, `USForm`) there are 124 definitions of operators the signature would carry.
- `TruthClauses.lean` defines 17 operator `abbrev`s (`neg top and or diamond someFuture allFuture kPlus after somePast allPast kMinus always dstab someFuture' somePast' always'`), and `TemporalRules.lean` two more (`next`, `prev`). `TemporalIntervals.lean` defines no operator: its six clause lemmas are stated about inline terms such as `or ev (and g (UntlClause.untl g ev))`.
- `next`/`prev` exist in five places: `Formula`, `PlusFormula`, `StarFormula`, `USForm` and `TemporalRules`; `NomicFormula` has `next` only.

**How the clause classes are built.** Each of `BotClause`, `ImpClause`, `BoxClause`, `UntlClause`, `SnceClause`, `StabClause`, `AllFutureClause`, `AllPastClause`, `AtomClause` takes `[TruthEnv L]` and bundles the operator with its truth clause. The operator therefore cannot be named without a truth relation. Seven languages and one test toy declare instances (8 `TruthEnv` instance sites, 7 `AtomClause`). Every clause field is `Iff.rfl` or `fun h => h`.

**How far the generic layer reaches.** References to a clause-class operator projection (`ImpClause.imp` and the like) number 139, in 5 files: `GenericSchemata.lean` 110, `TruthClauses.lean` 14, `ValidityLayerTest.lean` 7, `TemporalIntervals.lean` 6, `TemporalRules.lean` 2. `RankProgress.lean` opens the namespace. Outside the test file, no module names a `TruthClauses` operator with a qualified name. The rebase of the clause classes is therefore confined to six library files and eight instance sites.

**How far the per-language names reach.** References to the sixteen non-recursive shared operators on any `*Formula` type number 7488, in 448 of 1202 Lean files. Of these, 749 in 137 files are inside a `simp`, `rw`, `dsimp` or `delta` list, and 31 in 13 files are `unfold` calls. These sites depend on what the definition unfolds *to*.

**Layering.** `ORGANISATION.md` puts `Syntax/` and `Tactic/` at layer 0 and `Semantics/` at layer 1. `Syntax/Formula.lean` imports `Syntax/Atom.lean` only; `Semantics/TaskModel.lean` imports `Syntax/Formula.lean`. `SeparationZ/Syntax.lean` imports `FormalSystem.Init` and Mathlib only. A signature module importing `FormalSystem.Init` alone is below every formula type, including `USForm`.

**The temporal contribution, at `5ecc91d63`.** `PlusLanguage/TemporalViews.lean` defines `release`, `trigger`, `weakUntil`, `weakSince`, `strongRelease`, `strongTrigger`, `before`, `inclusiveUntil`, `inclusiveSince` on `PlusFormula` and `inclusiveUntil`, `inclusiveSince` on `Formula`, each with an `*_expand` equality proved by `rfl`. `Tactic/TemporalFormulaViews.lean` registers 20 view rows, 10 per language. `inclusiveUntil` is guard first; `release` and `weakUntil` are event first. `TemporalIntervals.inclusiveUntil_iff` takes `(g ev)` and `release_iff`/`weakUntil_iff` take `(event guard)`, so the merged clause lemmas already agree with those orders.

**Operator recognition today.** `FormulaSyntax.Language` has two constructors, `tm` and `plus`, and `Language.operatorName` is a table of 20 name pairs. `operatorArgs?` checks the head constant and falls back to `isDefEq` against a probe built with `mkAppM`. The enum is consumed in `FormulaPositions.lean` and three `Automation/ProofMode/` modules.

### External Resources

**cslib `Connectives.lean`.** One class per primitive (`HasBot`, `HasUntil`, `HasSince`, `HasNext` locally; `HasImp`, `HasBox` and others from `Operators.lean`), then bundles. Three points bear on the port.

- `neg` and `top` are *fields with default values* on `PropositionalConnectives`. An instance may override a default, so the class does not guarantee the encoding. Operators defined as functions over the primitive classes do guarantee it, and are what `TruthClauses.lean` already uses. Port the class-per-primitive shape and not the defaulted fields.
- cslib's scoped notation collides with each formula type's local notation once an instance is registered; the file documents this at length. This repository attaches notation to the per-language names (`prefix:80 "△" => Formula.always`). The signature here should declare no notation.
- cslib's `ModalConnectives` is box-only while its `Modal.Proposition` has a primitive diamond. Under the design below the mismatch cannot arise: a signature instance is declared from the constructors of the inductive, and a derived operator has no class.

### The first question: one home for the derived operators

| Option | What it is | Evidence | Verdict |
|---|---|---|---|
| (i) Signature below, clause classes over it | Primitive-operator classes at layer 0; derived operators defined once there; clause classes state truth clauses about the signature operators | Prototype 1 compiles: generic `neg_iff` over mixin clause classes, the L instance with `Iff.rfl` fields, and a per-language wrapper delegating without `show` | Adopt |
| (ii) Clause classes stay the one home, syntax takes operators from them | `Formula.neg` defined from `TruthClauses.neg` | `TruthClauses.neg` needs `[TruthEnv Formula]`, whose instance is declared in `Semantics/Truth.lean` after `TruthAt`, which recurses on `Formula`. `Formula.neg` is used by `Formula.complexity`, the axioms and the derivation trees, all at layer 0 | Not buildable without inverting the layer order |
| (iii) Two layers tied by `rfl` rows | Per-language definitions and generic definitions, pinned equal in a test file | This is the present state: 85 qualified `TruthClauses.*` rows in `ValidityLayerTest.lean`. Adding a syntactic signature beside it makes three copies | Reject as the design; keep the rows as a regression gate |

Option (i) answers the layering question directly: the operators move *down* one layer, and `TruthClauses.lean` imports the signature. Nothing moves up.

**Mixin or `extends`.** Two ways to put the clause classes over the signature were compiled.

- *Mixin*: `class BotClause (L) [TruthEnv L] [HasBot L] : Prop`, carrying the clause only. The bundles (`BoolClauses`, `UntlClauses`, `StabClauses`, `TenseClauses`) become `Prop` classes extending the mixins. A language declares its signature instances in its syntax file and one clause bundle in its truth file, whose fields are the clause proofs alone.
- *`extends`*: `class BotClause (L) [TruthEnv L] extends HasBot L`. The language then has two instances of `HasBot`: the one its syntax file declares and `BotClause.toHasBot`. Measured: they are equal by `rfl`, also under `with_reducible_and_instances`, and resolution picks the direct one. It works, and it is a second path that every later instance has to keep definitionally equal.

The mixin form is recommended. It is also the form the architecture record already describes for the semantic side: "one per operator".

**What the answer fixes.**

- *Interval operators (deliverable b)*: `inclusiveUntil`, `inclusiveSince`, `release`, `trigger`, `weakUntil`, `weakSince` are defined once on the signature, and the six lemmas of `TemporalIntervals.lean` are restated about them. Because the signature operators are `abbrev`s, the restated statements are the same terms as the inline ones, so existing callers still unify.
- *`next` and `prev` (deliverable c)*: one definition on the signature over `[HasBot L] [HasUntl L]`. `TemporalRules.next`/`prev` are deleted in its favour. `USForm` is given signature instances, which it can take since the signature imports `Init` only.
- *What temporal rules are stated about*: semantic rules are stated over the signature operators with the clause mixins as hypotheses; derivation rules, when `proof_mode_abstract_frontend_interface` arrives, take the signature as a requirement and add the derivation relation.
- *Recognition at L⋆ (deliverable d)*: see Prototype 1, G6, below.

### Compiled probes

All three files were run with `lake env lean` against the existing build. Prototype 2 exits 0. Prototype 1 exits 1 on one error, the `rw` failure of G3, which is the finding. Prototype 3 exits 1 on one error in its last example (R5), a mis-stated `rw` of mine that tests nothing; its goal trace shows that an `abbrev` operator still displays under its folded name. Every other declaration in both files elaborates.

**Prototype 1** (`prototypes/01_signature-mixin-recognition.lean.txt`).

| Probe | Result |
|---|---|
| G1. `Formula.neg φ = Sig.neg φ := rfl` and nine more rows, at `Formula` and `StarFormula`, including `release`, `weakUntil`, `next`, `dstab` | all elaborate |
| G2. Mixin clause classes, generic `neg_iff`, L instance, wrapper delegation without `show` | elaborates |
| G3. `def Formula.negS φ := Sig.neg φ`; unfold it, then `simp only [Truth.imp_iff]` | does not fire |
| G3. Same, then `rw [Truth.imp_iff]` | fails: pattern `Formula.imp ?φ ?ψ` not found in `Sig.neg φ` |
| G4. `def Formula.negG φ := sig% (Sig.neg φ)`; stored body | `fun φ => φ.imp Formula.bot`, no signature constant; `simp only [Truth.imp_iff]` fires |
| G5. `extends` variant: two `HasBot Formula` paths | equal by `rfl` and by `with_reducible_and_instances rfl` |
| G6. Recognition through the signature: `diamond`, `allFuture`, `dstab`, `next` at `StarFormula`; `weakUntil` at `Formula` | recognized, arguments recovered |
| G6. `dstab` at `Formula` | reported absent: no `HasStab Formula` instance |
| G6. `diamond` against `a.neg` at `StarFormula` | correctly rejected |

G6 uses no per-language name table: it takes the formula's type, builds the signature operator at that type with fresh arguments, and calls `isDefEq`. The `stab` guard that `Language.operatorName` raises by hand ("stability requires TM⁺") becomes a failed instance search.

**Prototype 2** (`prototypes/02_generated-bodies.lean.txt`). A function `oneLayer` delta-unfolds the head signature operator once, replaces each remaining `Sig.op` application at type `T` by `T.op`, and reduces each class projection of an instance to the constructor. Its output is compared by `Expr` equality with the body stored in the tree.

| Type | Operators compared | Structurally identical |
|---|---|---|
| `Formula` | 20 (the 16 shared, plus `release trigger weakUntil weakSince`) | 20 |
| `PlusFormula` | 17 (the 16 shared, plus `dstab`) | 17 |
| `StarFormula` | 16 | 16 |
| `USForm` | 10 | 10 |

So a definition written `def Formula.and (φ ψ : Formula) : Formula := sig% Sig.and φ ψ` stores exactly the term `(φ.imp ψ.neg).neg` that the tree stores now. Its equation lemma, its `unfold` behaviour and every one of the 749 unfold sites are unchanged, and the encoding appears in one place.

**Prototype 3** (`prototypes/03_reducibility.lean.txt`). `abbrev` copies `negA`, `andA`, `diamondA` of three L operators.

| Probe | `def` (today) | `abbrev` |
|---|---|---|
| R1. `φ.diamond = φ.neg.box.neg` by `with_reducible rfl` | fails; needs default transparency | holds |
| R2. `rw [diamond_iff]` on the unfolded shape `((φ.imp ⊥).box.imp ⊥)` | no match | matches; `simp only` also matches |
| R3. `simp only [imp_iff, and_iff]` on `TruthAt (φ.and ψ)` | `TruthAt φ ∧ TruthAt ψ`; `imp_iff` unused | `(TruthAt φ → TruthAt ψ → TruthAt ⊥) → TruthAt ⊥`; `and_iff` reported unused, in either argument order |
| R3. `simp only [neg_iff]` on `TruthAt (φ.imp ⊥)` | no match | rewrites to `¬ TruthAt φ` |
| R4. `rfl` fold lemma `φ.imp ⊥ = φ.neg` under `simp only` | folds | still folds |

R1 and R2 are the benefit the description anticipates: with reducible operators a rule about `◇` applies to `¬□¬` with no view step. R3 is the cost: L's ten clause wrappers carry `@[simp, truth_norm]`, and with reducible operators the primitive `imp_iff` takes the term before `and_iff` can, so the set's normal form changes. The size of that change across the library was not measured; it needs a full build on a branch.

### Recommendations

1. Adopt option (i): a module `FormalSystem/Syntax/Connectives.lean` importing `FormalSystem.Init` only, holding one class per primitive operator (`HasBot`, `HasImp`, `HasBox`, `HasUntl`, `HasSnce`, `HasStab`, `HasAllFuture`, `HasAllPast`) and the derived operators as `abbrev`s over them, with no notation and no defaulted fields. [VERIFIED: PASS -- Prototype 1 G1 and Prototype 2 compiled with `lake env lean`; the ten G1 rows and the six `rfl` ties of Prototype 2 elaborate against `Formula`, `PlusFormula`, `StarFormula` and `USForm`. `HasAllFuture`/`HasAllPast` for L⁻ were not instantiated in a probe]
2. Restate the clause classes of `TruthClauses.lean` as `Prop`-valued mixins over the signature, and delete that file's operator `abbrev`s and `TemporalRules.next`/`prev` in favour of the signature's. [VERIFIED: PASS -- Prototype 1 G2: mixin `BotClause`/`ImpClause`, a bundle, the L instance with `Iff.rfl` fields, generic `neg_iff`, and wrapper delegation without `show`, compiled with `lake env lean`. Verified for the Boolean tier at L only; the other tiers and the six other languages follow the same shape and were not compiled]
3. Define each per-language name by generating its body from the signature definition (`def Formula.and (φ ψ : Formula) : Formula := sig% Sig.and φ ψ`), keeping `def` and each name's docstring. [VERIFIED: PASS -- Prototype 2 `#compare_generated`: 63 of 63 generated bodies are `Expr`-equal to the tree's, exit 0]
4. Do not define a per-language name as the bare signature operator (`def Formula.neg φ := Sig.neg φ`). [VERIFIED: FAIL -- Prototype 1 G3 via `lake env lean`: after unfolding, `simp only [Truth.imp_iff]` does not fire and `rw [Truth.imp_iff]` fails; revised to: recommendation 3]
5. Leave `reflectTime`, `complexity`, `modalDepth`, `atoms` and the other recursions per language; they recurse on the inductive type, which the signature does not abstract. If their duplication is to be removed it is a derive handler, in a separate task. [No compiled gate applicable]
6. Define `inclusiveUntil`, `inclusiveSince` (guard first) and `release`, `trigger`, `weakUntil`, `weakSince` (event first) once on the signature; restate the six lemmas of `TemporalIntervals.lean` about them; regenerate the eleven definitions of `TemporalViews.lean` by recommendation 3 and leave its `*_expand` lemmas and the 20 view rows as they are. [VERIFIED: PASS -- Prototype 2: `release`, `trigger`, `weakUntil`, `weakSince` at `Formula` are among the 20 identical bodies, and `Formula.trigger φ ψ = Sig.trigger φ ψ := rfl` elaborates. `inclusiveUntil`/`inclusiveSince` are not on `main` and were not compared; Prototype 1 defines `Sig.inclusiveUntil` with the body `TemporalIntervals.inclusiveUntil_iff` is stated about]
7. Give `USForm` signature instances and generate its `next`/`prev` like the others, so all five copies are one definition; keep `rfl` rows in `ValidityLayerTest.lean` as the regression gate. [VERIFIED: PASS -- Prototype 2: `USForm` 10 of 10 bodies identical; `USForm.next φ = Sig.next φ := rfl` and the `prev` row elaborate]
8. Rewrite `FormulaSyntax.operatorArgs?` to build its probe from the signature operator at the formula's own type, so that the 20-pair name table goes and any type with instances is recognized. Keep `Language` for what it still selects, the TM or TM⁺ rule name. [VERIFIED: PASS -- Prototype 1 G6 `#recognize`: five operators recognized at `StarFormula` and `Formula` with arguments recovered, an absent operator reported through instance failure, a wrong operator rejected]
9. Make no per-language definition reducible in this task. If definitional views are wanted, measure it on a branch with a full build first, starting from the `truth_norm` set. [VERIFIED: FAIL -- Prototype 3 R3 via `lake env lean`: with `abbrev` operators `and_iff` is reported unused and `imp_iff` rewrites the term instead; revised to: keep `def`, and obtain view rows mechanically, one `rfl` row per signature operator per language]
10. Keep `HasStab` as its own class whatever `investigate_stability_as_modal_family` concludes. That ruling is about which rule family `⊡` files under; a one-class-per-primitive signature has a class for `stab` either way. [No compiled gate applicable]

## Decisions

- The one home for the derived operators is a syntactic signature at layer 0 (option (i)). `TruthClauses.lean` keeps the clauses and the lemmas and loses the operators.
- Clause classes are mixins over the signature, not extensions of it.
- Per-language names remain, as generated `def`s. They are needed for dot notation (`φ.neg`) and for the notation declarations, and they are what 7488 references name.
- cslib's defaulted-field form of `neg` and `top` is not ported.
- No user decision is raised. The landing order is already ruled (after the temporal contribution), and the first question is settled by the layer order and the compiled probes.

## Risks & Mitigations

- **The generating elaborator is new metaprogramming at layer 0.** It is about 20 lines in the prototype. Mitigation: gate it with a test that compares each generated body to a literal expected term, so a change in its output fails a test and not a proof 400 files downstream.
- **Order of definition matters to the generator.** `oneLayer` rewrites `Sig.neg` to `T.neg` only if `T.neg` already exists; otherwise it leaves the signature term, which is the failure of recommendation 4. Mitigation: the generator should raise when a signature constant survives in its output. The prototype does not do this yet.
- **The mixin rebase touches `GenericSchemata.lean` heavily** (110 projection references, 34 instance binders). The change is a rename plus added signature binders. Mitigation: do it as one phase with its own build, before any per-language file is touched.
- **The temporal contribution is rebased by its author, not here.** If it lands with a changed `TemporalViews.lean`, recommendation 6's counts change. Mitigation: re-run `#compare_generated` on the merged tree as the first step of implementation.
- **`TemporalIntervals.olean` is absent from the local build** (the module merged after the last build). The probes did not import it. The claim that its lemmas restate without change rests on reading, not on a compile.
- **`HasAllFuture`/`HasAllPast` and L⁻.** L⁻ derives `someFuture` in the opposite direction (`someFuture'` in `TruthClauses.lean`). The signature needs both forms under distinct names, as the clause layer has now.

## Tactic Survey Results

No proof goals were under investigation; the tactics below were run only as probes of unfolding behaviour.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `Formula.X φ = Sig.X φ` (16 rows across probes) | `rfl` | success | default transparency |
| `φ.diamond = φ.neg.box.neg` | `with_reducible rfl` | fail for `def`, success for `abbrev` | N/A |
| `TruthAt M τ t (Sig.neg φ)` | `simp only [Truth.imp_iff]` | fail | no progress |
| `TruthAt M τ t (Sig.neg φ)` | `rw [Truth.imp_iff]` | fail | pattern not found |
| `TruthAt M τ t (φ.imp Formula.bot)` (generated body) | `simp only [Truth.imp_iff]` | success | N/A |
| `TruthAt M τ t (φ.andA ψ)` | `simp only [imp_iff, andA_iff]` | success, to the implication form | `andA_iff` unused |

## Context Extension Recommendations

- **Topic**: Instance-projection terms are not constructor terms for `simp` and `rw`.
- **Gap**: No Lean context file states that a definition whose body is a typeclass-generic operator unfolds to instance projections that constructor-keyed lemmas do not match, or that the body can be generated in constructor form instead.
- **Recommendation**: Add a short pattern file under `.claude/context/project/lean4/patterns/` (through the source store) with Prototype 1 G3 and G4 as the worked example.

## Appendix

- Probe commands: `lake env lean <file>` on each of the three prototype files, from the repository root, with a 280-second timeout.
- Counting commands: `git ls-files '*.lean' | xargs grep -cE <pattern>` for the reference counts; `comm -12` over sorted `def`/`abbrev` names for the intersections.
- Temporal contribution inspected with `git show 5ecc91d63:<path>`; the local branch `pr8-head` (`49a7efe23`) is an earlier head and lacks `TemporalFormulaViews.lean`.
- Lean search tools (leansearch, loogle, leanfinder) were not used: the question concerned this repository's own definitions and elaborator behaviour, not Mathlib lemmas.
