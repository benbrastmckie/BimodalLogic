# Proposal B: Demand-indexed checked rewriting, temporal unfolding, and a one-way semantic backend

Status: independent design draft (pinned `81ae7a6`). Tags used throughout:
- **[SRC]**: the declaration exists and I read it.
- **[NEW-def]**: a new definition that needs only routine construction.
- **[NEW-thm]**: a new theorem whose proof is not done yet.
- **[PROPOSED]**: tactic syntax. None of it exists.

## 0. Architecture in one paragraph

There are three layers and the dependency direction between them is fixed.

1. **Theorem layer** (`Theorems/ProofMode/Rewrite*.lean`, with TM and TM⁺ twins). It holds pure `def`s that build `DerivationTree` / `PlusDerivationTree` values for positional congruence, demand discharge, folding/unfolding and context mirroring.
2. **Elaborator layer** (`Automation/ProofMode/Rewrite.lean`, `Simp.lean`). It plans a rewrite path, computes what each scope demands, and builds terms only from layer 1.
3. **Semantic layer** (`Semantics/ProofMode/*.lean`). Its goals are `TruthEnv.T M τ t e φ`. It may import native derivations through `soundness_in` / `plus_soundness_in` and nothing else.

No layer-1 or layer-2 module may import a completeness module or eliminate a `Nonempty`. This is enforced with `assert_not_exists`, following the pattern of `Semantics/TruthTransport.lean`.

The central idea is that **every syntactic position has a "demand modality"**. A rewrite at depth n is justified by exactly one premise: the composite demand word applied to the local implication. The engine computes that premise, discharges it when a checked route exists, and otherwise exposes it as an ordinary goal.

## 1. Source facts this design depends on (audited)

- **Native judgments.** `DerivationTree fc Γ φ` (`ProofSystem/Derivation.lean`) and `PlusDerivationTree` (`PlusLanguage/Derivation.lean`) are `Type`-valued. The rules `necessitation`, `temporal_necessitation` and `time_reflection` take only `[]` contexts. In TM the only primitive temporal axioms are the future ones; Since facts come from TR (`DerivedAxioms.leftMonoSinceH`, `rightMonoSince`, `enrichmentSince`). TM⁺ has the past mirrors as constructors.
- **Paper basis.** §3.2 gives MP, MN, TN and TR ("If ⊢φ then ⊢φ⟨s|u⟩") as theorem-level rules, plus UC, UG, US, UF, UI, CN, TS, MF and NB. §3.3 adds UZ, NN, PU and SEP. TM_z and TM_r are only *weakly* complete, so even a theoretical semantic-to-native route is unavailable for contextual goals.
- **Monotonicity.** These rules give monotonicity in every non-implication position:
  - `TemporalDerived.untilMonoGuard` and `untilMonoEvent` (UG/UC, Base);
  - `sinceMonoGuard` and `sinceMonoEvent`;
  - `fMono` and `pMono`;
  - `gDistribution` and `hDistribution`;
  - `modal_k_dist`, and `stab_k` for TM⁺.
- **Next and Previous.** `X φ = untl ⊥ φ` and `Y φ = snce ⊥ φ`.
  - `ProofMode.nextK` and `prevK` are **fc-polymorphic** (`DiscreteUnfolding.nextConj` plus `eventMono`).
  - Only `nextNecessitation` and `prevNecessitation` need `ZTime ≤ fc`.
  - `ProofMode.nextConsequence` is Base because it routes through `G(φ→ψ)`.
- **Unfolding.**
  - `DiscreteUnfolding.unfoldForward e g` is `.ZTime`, `unfoldBackward e g` is `.Base`, and `unfoldTable{Forward,Backward}` follow the same pattern.
  - `unfoldBackwardSince e g` is the ZTime TR mirror of `unfoldForward`.
  - The Base Since converse is absent; the docstring says "the same two-line recipe".
- **Interaction lemmas.** `Combinators.temporalFutureDerived : ⊢ □φ → G□φ`, `Theorems/Interaction.lean temporalPastDerived : ⊢ □φ → H□φ`, `Combinators.modal4`, `PlusAxiom.box_stab`, `stabNecessitation`, and `ModalS5.iff`.
- **TM⁺ lifting.** `PlusLanguage.ProofMode.liftContext op nec dist` is already a generic context lifter for any operator that has necessitation and K.
- **Semantics.**
  - `TruthClauses` provides clause classes with an inert `Env` (TM and TM⁺ use `PUnit`) and derived-operator lemmas. It has **no** `next`/`prev` characterization.
  - `soundness_in` and `plus_soundness_in` (side condition `fc.Sat F`).
  - `TimeShift.timeShift_preserves_truth`, `plusTruthAt_timeShift`, `Truth.box_const`.
  - `truthAt_rev` and `plusTruthAt_rev` move to `M.rev, τ.rev, -t`; `FrameClass.Sat.rev` exists.
  - `WorldHistory F` is a subtype of total `PartialHistory`, so task-respect obligations travel with the history.
- **State-locality.**
  - `PlusFormula.StateLocal` admits `box _` and `stab _` with **arbitrary** arguments; `isPlusStateLocal_of_stateLocal`, `isPlusStateLocal_box/stab`, `stab_of_stateLocal`.
  - There is **no TM `StateLocal`**, but `PlusValidity.plusTruthAt_ofFormula` bridges to it.

## 2. Area 1: checked rewriting and simplification

### 2.1 Positions and demands

A *position spec* records one constructor step from a context to its hole.

```lean
-- [NEW-def] theorem layer, TM (Plus twin identical in shape)
structure PosStep (fc : FrameClass) where
  wrap   : Formula → Formula          -- c(·): the context one level up
  demand : Formula → Formula          -- D(·)
  flips  : Bool                        -- antecedent-of-imp only
  -- the transfer theorem: from D(Y ⇒ Z) to c Y ⇒ c Z (or c Z ⇒ c Y if flips)
  transfer : ∀ Y Z, ⊢[fc] (demand (Y.imp Z)).imp
                 (if flips then (wrap Z).imp (wrap Y) else (wrap Y).imp (wrap Z))
  dmono  : ∀ P Q, (⊢[fc] P.imp Q) → ⊢[fc] (demand P).imp (demand Q)
```

The table below is source-backed per row. Every transfer theorem is Base unless the row says otherwise.

| Hole position | demand D | transfer source |
|---|---|---|
| `imp X ·` | id | `prop_k`/`bCombinator` |
| `imp · W` | id, flips | contrapositive composition (`Combinators.bCombinator`) |
| `box ·` | □ | `Axiom.modal_k_dist` |
| `stab ·` (TM⁺) | ⊡ | `PlusAxiom.stab_k` |
| `untl · e` (guard) | G | `untilMonoGuard` |
| `untl g ·` (event, g ≠ ⊥) | G | `untilMonoEvent` |
| `untl ⊥ ·` (X event) | **X or G** | `nextK` (X) / `untilMonoEvent` (G) |
| `snce · e`, `snce g ·` | H | `sinceMonoGuard` / `sinceMonoEvent` |
| `snce ⊥ ·` (Y) | **Y or H** | `prevK` / `sinceMonoEvent` |

`dmono` holds at Base for □, ⊡, G and H by necessitation plus K.

For X it also holds at Base: TN and `untilMonoEvent` give `⊢ P→Q ⟹ ⊢ XP → XQ` with no successor-existence premise. **Only `⊢ X P` from `⊢ P` needs ZTime.** This is how the design satisfies brief item 4.

Derived operators need no separate rows: ◇, F, G, ∧, ∨ and △ unfold to these primitives. For proof-term size I add *macro steps* for `and`, `or`, `someFuture` and `allFuture` (each a two-step composite proved once), so paths read in surface terms.

### 2.2 Composite congruence

```lean
-- [NEW-thm] by induction on the path (no search)
def congrPath : (p : List (PosStep fc)) → (A B : Formula) →
  ⊢[fc] (demandWord p (if odd p then B.imp A else A.imp B)).imp (plug p A ⇒ plug p B)
```

The definitions are:
- `demandWord [s₁,…,sₙ] X = s₁.demand (… (sₙ.demand X))`, outermost first.
- The direction of `⇒` is fixed by the parity of flips along the path.

Each step composes as follows. Given a closed `⊢ P → (Y ⇒ Z)` for the inner path, apply `s.dmono` to get `⊢ D P → D(Y ⇒ Z)`, then `s.transfer` to get `D(Y⇒Z) → (c Y ⇒ c Z)`, then `impTrans`. A rewrite with an *equivalence* runs `congrPath` twice, once per direction. *Monotone rewriting*, which uses an implication only, is first-class: it is allowed exactly when the hole's parity matches the implication's direction.

### 2.3 Demand discharge (bounded, ordered, transparent)

Given a premise source `e` and a required `W(A⇒B)`, where W is a demand word, the discharger tries these routes in order and stops at the first success:

1. **Closed premise** `e : ⊢[fc] A⇒B`. Apply necessitation for each letter: MN, TN, `pastNecessitation`, `stabNecessitation`. **Whenever an X or Y letter occurs, re-plan that step with its G or H alternative**, so a closed rewrite never needs ZTime. The cost is linear in |W|.
2. **Boxed fact** `Γ ⊢ □(A⇒B)`. This needs a new lemma, `boxDischarge : ⊢ □P → W P` for every W over {□, ⊡, G, H} [NEW-thm]. Its proof is induction on W using:
   - `modal4`;
   - `temporalFutureDerived` / `temporalPastDerived`, followed by G/H-mono of `modal_t`;
   - `box_stab ∘ modal4` for ⊡;
   - final `modal_t`.

   X and Y letters re-plan to G and H here as well, because `□P → X□P` fails over dense frames.
3. **G-fact** `Γ ⊢ G(A⇒B)`. Discharges W ∈ G⁺ via `gTransitivity`. The H mirror works the same way.
4. **Next-fact** `Γ ⊢ X(A⇒B)`. Discharges only W = X, using the X demand via `nextK`, and is valid at any fc.
5. **State-local fact (TM⁺ only).** If `(A⇒B).StateLocal` and `Γ ⊢ A⇒B`, then `Γ ⊢ ⊡(A⇒B)`. This needs `stabOfStateLocal : φ.StateLocal → ⊢⁺[fc] φ → ⊡φ` [NEW-thm]. The proof is recursion on φ using:
   - `atom_stab`;
   - `box_stab ∘ modal4` for `box`;
   - `stab_4` for `stab`;
   - ⊡-S5 (`stab_5`) for negation and implication.
   It is **not** limited to a propositional fragment, which follows brief item 8.
6. **Otherwise** the requirement is exposed as an ordinary Lean goal `Γ ⊢[fc] W(A⇒B)`, and the diagnostic reports the path and demand word.

Each attempt is a constant-size term check (`isDefEq` at reducible transparency on Formula `Expr`s), with no search inside formulas.

### 2.4 Hard counterexamples (all fixed in the validation matrix)

- **C1, present-only equivalence under G.** `[p ↔ q, G p] ⊬ G q`. Take ℤ with p, q true at 0 and p true, q false at 1. A rewrite engine that accepted ε-demand facts under G would be unsound. The engine exposes `Γ ⊢ G(p → q)`, which is unprovable.
- **C2, `F F A ↔ F A`.** Only `FFA → FA` is Base (`futureCollapse`). Over ℤ with A true only at t+1, `F A` holds at t but `F F A` does not. `lsimp` may therefore use `futureCollapse` only at positive positions, as a one-way rule.
- **C3, `G G A ↔ G A`.** The `GGA → GA` direction is DN, which is `.Dense` (`LinearityDerived.density`). Over ℤ with A false only at t+1, `GGA` holds at t and `GA` does not. The rule carries a Dense gate.
- **C4, X under G with a closed rule.** At Base, `[G X A] ⊢ G X B` from `⊢ A↔B` must succeed without ZTime. The path [G, X] is re-planned to demand GG, which is discharged by TN.
- **C5, contextual TR.** `[G p] ⊢ G p` does not give `[G p] ⊢ H p`. See §3.3.

### 2.5 Object context versus derived facts

There are three distinct operations, and they differ in which context they touch.

- **`lrw e at d`**, where `d` is a Lean local `Γ ⊢ C[A]`. This is pure `ctxMp(congr, d)`. The context is unchanged and nothing else is invalidated.
- **`lrw e at h`**, where `h` names an *object assumption* A ∈ Γ. The default is **cut mode**: the goal `Γ ⊢ φ` becomes `C[B] :: Γ ⊢ φ`, reconstructed by `ProofMode.cut (ctxMp congr (assumption))`. Since Γ ⊆ C[B] :: Γ, every outer Lean local still passes `adaptProof`'s inclusion check.
- **`lrw e at h replace`**. Here Γ' is Γ with C[A] replaced by C[B]. Reconstruction is `substContext d' σ`, where σ sends C[B] to its derivation *in Γ* and everything else to `assumption`. This is sound even when `e` itself used `h`, because σ is evaluated in the old Γ. The cost is that outer locals typed at Γ are rejected inside Γ' by the existing inclusion check, which fails safely. Replace mode is opt-in and its trace lists the invalidated locals.

Goal rewriting runs the reverse direction (`B⇒A` at the hole's parity) and reconstructs with `ctxMp`.

### 2.6 Nested scopes

The scope tactics (`lmodal_intro`, `ltemporal_intro`, `lstep`) produce a body goal over the de-modalized `using` selection, and outer locals are unusable inside it. Inside a body, a rewrite therefore needs `W(A⇒B)` **in the body's context**. The user captures what is required at the scope boundary:
- capture `□(A⇒B)` with `using [hAB]` and the body receives `A⇒B`;
- or capture a G-fact for G scopes.

Optionally, scope tactics may attach `mdata` describing the enclosing scope stack [□, G, …] **for diagnostics only**. The error message would then read "at the outermost goal this rewrite needs □G(A⇒B); capture it with `using`". Proof terms never read that metadata.

### 2.7 `lsimp` registry

- **Entries.** An entry is `@[lsimp]` on a **closed** `⊢[fc] iff L R` or an oriented `⊢[fc] L.imp R`. It records its minimum frame (from the statement's `fc` or from a `ZTime ≤ fc`-style hypothesis), its orientation, and whether it is size-decreasing (`sizeOf R < sizeOf L`, checked on a fresh-atom instance when the entry is registered). Non-decreasing entries go to a separate small fuel pool.
- **Contextual facts are never registered.** They are passed as `lsimp [hAB]` and go through §2.3 per redex.
- **Mirroring.** A future-direction closed entry automatically gets a TR twin (`time_reflection` plus a `reflect_time_*` `simp only` normalization proved at registration). A contextual entry never does.
- **Seed set (source-backed).** Double negation, `ModalS5.s5DiamondBox`, `boxConjIff`, `diamondDisjIff`, `futureCollapse`/`pastCollapse` (oriented), `untilImpF` (oriented), `density` (Dense-gated, oriented GG→G), and `top` / `bot` absorption from the `Propositional` combinators.
- **Algorithm.**
  - Traverse innermost-first, left to right, trying rules in declaration order.
  - Defaults: `fuel := 32`, `depth := 12`.
  - No backtracking: an undischargeable redex is skipped and logged.
  - Rules gated above Base are used only if `decide` proves the gate on a concrete fc or a gate hypothesis is in the local context; they never spawn a ZTime goal mid-run.
  - `lsimp?` emits the equivalent `lrw` script, so a simplification can be frozen into an explicit, reviewable proof.

## 3. Area 2: richer temporal reasoning

### 3.1 Until/Since unfolding: the asymmetry made explicit

| Wrapper [NEW-def unless SRC] | Statement (guard g, event e) | Gate | Source |
|---|---|---|---|
| `untilUnfold hZ` | `U g e → X e ∨ X(g ∧ U g e)` | `ZTime ≤ fc` | `(unfoldForward e g).lift hZ` [SRC] |
| `untilFold` | converse | Base | `unfoldBackward` via `baseThm` [SRC] |
| `sinceUnfold hZ` | `S g e → Y e ∨ Y(g ∧ S g e)` | ZTime | `unfoldBackwardSince` [SRC] |
| `sinceFold` | converse | **Base** | TR of `unfoldBackward` plus one reflect lemma [NEW-thm, trivial] |
| table forms | `X g ∧ X U` variants | same split | `unfoldTable*` [SRC]; Since table mirrors [NEW-thm] |
| `untilIntro` | `Γ ⊢ G g → Γ ⊢ F e → Γ ⊢ U g e` | Base | `untilMonoGuard` with `G(⊤→g)` from G g [NEW-def] |

The asymmetry is semantic. Folding consumes an X or Y fact, and that fact already asserts a covering successor or predecessor. Unfolding must *produce* one.

Counterexample **C6**: over ℚ with p true only at 1, `U ⊤ p` holds at 0 while `X p` and `X(…)` are both false, since there is no successor at all. So `untilUnfold` without its gate would be unsound at Base and Dense.

Strictness also rules out the "reflexive" unfolding `U g e → e ∨ (g ∧ U g e)`, and no wrapper offers it. `sinceFold` earns its existence through a real consumer, `lfold since`; it is not a resurrected unused wrapper.

[PROPOSED] Tactics:
- `lunfold until at h [as he hstep]` checks the ZTime gate exactly as `lstep` does today: it solves the reflexive instance or exposes the certificate goal.
- `lfold until` / `lfold since` reduce the goal to the disjunction.

### 3.2 Strictness discipline

There is no temporal T. Reflexive variants are explicit conjunctions using the [SRC] defs `weakFuture` / `weakPast` / `always`. Tactics never manufacture the present conjunct.

`weakUntil φ ψ := (untl ψ φ).or ψ.allFuture` puts its **guard second**, so `lrw` paths are computed on the primitive `untl`, never on surface argument order. The validation matrix pins this case.

### 3.3 Time reflection: what is and is not allowed

- **Allowed: mirroring a closed derivation.** `lmirror d` takes `d : ⊢[fc] φ` to `⊢[fc] φ.reflectTime`, normalized by the `Formula.reflect_time_*` lemmas.
- **Allowed: mirroring a whole context.**

  ```lean
  -- [NEW-def] TM⁺: liftContext reflectTime (·.time_reflection) (fun _ _ => identity _)
  def mirrorCtx : Γ ⊢[fc] φ → Γ.map reflectTime ⊢[fc] φ.reflectTime
  ```

  Here K is the identity, because `reflectTime (A.imp B)` is definitionally the implication of the reflected sides. The TM version is the same recursion as `generalizedTemporalK`.
- **Forbidden: reflecting the conclusion while keeping Γ.** Counterexample C5 shows why.
- **Semantic reflection** (§4.3) changes the *model* to `M.rev`. It is never a same-model operation.

### 3.4 Native versus semantic temporal operations; time carriers

Native rules know only the `FrameClass` tag, so there is no carrier there. Carrier-generic reasoning belongs to the semantic layer, over `F.Duration`. Discrete facts there come from `IsZTime` via `FrameClass.Sat`, never from tags.

The temporal-ops contract is:
- Native ZTime tactics (`lstep`, `linvariant`, `lunfold`) take the frame inequality.
- Semantic ZTime steps take `Sat .ZTime F`.

No tactic converts between the two. Native-to-semantic conversion goes only through soundness (§4.2).

## 4. Area 3: semantic proof backend

### 4.1 Goals reuse the shared clause API

Semantic goals are `TruthEnv.T M τ t e φ`, with `e = PUnit.unit` for TM and TM⁺. Tactic frontends rewrite only with **existing** `TruthClauses` lemmas: `ImpClause.imp_clause`, `BoxClause.box_clause`, `UntlClause.untl_clause`, `SnceClause.snce_clause`, `StabClause.stab_clause`, `neg_iff`, `and_iff`, `or_iff`, `diamond_iff`, `someFuture_iff`, `allFuture_iff`, `somePast_iff`, `allPast_iff`, `dstab_iff`, `always_iff_tri`, `after_iff_of_isNextTime`.

[PROPOSED] syntax: `sintro`, `sbox σ`, `sfuture s hs`, `sevent ⟨s, hs, h⟩`, `suntil ⟨s, hs, he, hg⟩`.

There is no new semantic recursor and no new framework. The one clause-level addition fits the `TruthClauses` contract (a derived abbrev plus a characterization, no attribute, no recursion):

```lean
-- [NEW-thm] in TruthClauses, Future/Past sections
abbrev next (φ : L) : L := UntlClause.untl BotClause.bot φ
theorem next_iff : T M τ t e (next φ) ↔ ∃ s, t ⋖ s ∧ T M τ s e φ   -- Covby; Base, no SuccOrder needed
theorem prev_iff : T M τ t e (prev φ) ↔ ∃ s, s ⋖ t ∧ T M τ s e φ
```

It also needs `rfl` pins in `ValidityLayerTest.lean`, matching `Formula.next` and `PlusFormula.next`.

### 4.2 Fact and goal transport

| Operation | Changes | Source | Restriction |
|---|---|---|---|
| `sOfNative d hSat hΓ` | native → truth | `soundness_in` / `plus_soundness_in` [SRC] | every context formula must be proved true at (M, τ, t) |
| `sState h hEq` | history, same time | TM⁺: `isPlusStateLocal_of_stateLocal`; TM: [NEW-thm] `Formula.StateLocal φ := (ofFormula φ).StateLocal` + `plusTruthAt_ofFormula` | **whole** `box`/`stab` subformulas qualify; U/S do not (`not_isPlusStateLocal_someFuture` is the counterexample) |
| `sShift h Δ` | history **and** time | `timeShift_preserves_truth`, `plusTruthAt_timeShift` [SRC] | moves to `σ.timeShift Δ`; no closure hypothesis is needed |
| `sBoxConst` | time/history for □φ | `Truth.box_const` [SRC]; TM⁺ analogue [NEW-thm] | □-headed formulas only |
| `sReflect` | **model** → `M.rev`, τ.rev, −t, φ.reflectTime | `truthAt_rev`, `plusTruthAt_rev`, `FrameClass.Sat.rev` [SRC] | not a same-model step; useful only when the conclusion is itself quantified over a rev-closed class |

Dispatch is on the existing elaborator `Language` enum (`tm` / `plus`), not a new transport class. L⋆ is deliberately excluded because its `Env` is not inert under shift.

### 4.3 The one-way rule

There is no `nativeOfSem`, no `Nonempty.some`, and no completeness import. This is enforced in three ways:
- `assert_not_exists` for the BXCanonical completeness entry points and for `Classical.choice`-producing bridges in the theorem and elaborator modules;
- a CI grep test that no `Automation/ProofMode` file imports `Metalogic/BXCanonical`;
- documentation that a semantic proof concludes a `Prop` about a particular model or class and stops there.

## 5. Bounded automation over Type-valued trees

- Terms are built by MetaM application of named `def`s. `simp` and `decide` are never run on a `DerivationTree` type, and derivation values are never reduced with `whnf`.
- Closed rule instances are shared through `thmIn` of a constant, so a path of length n adds O(n) applications.
- Planning (path, parity, demand word, discharge route) runs **before** any term is built. A failed plan builds nothing and reports.
- All budgets are explicit (`fuel`, `depth`). Rules are tried in a fixed order with no backtracking, and every skipped redex is logged with the reason: frame gate, undischargeable demand, or wrong parity.
- Formula matching uses `operatorArgs?`-style head checks plus a fixed table of derived-operator unfoldings (`someFuture ↦ untl top`, `next ↦ untl bot`, and so on). It never uses `whnf` at default transparency.

## 6. Compositional examples ([PROPOSED] syntax; providers are opaque)

```lean
-- E1 (C4): closed equivalence under G∘X, Base; no ZTime goal is produced.
example (A B : Formula) (e : ⊢ ModalS5.iff A B) : [A.next.allFuture] ⊢ B.next.allFuture := by
  lstart h
  lrw e at d := h      -- path [G-macro, X-event] replanned to demand G(G(A→B)); TN·TN
  lexact d

-- E2: contextual rewrite discharged from a boxed fact.
example (A B C : Formula) : [(ModalS5.iff A B).box, (C.and A).someFuture] ⊢ (C.and B).someFuture := by
  lstart hAB hCA
  lrw hAB at hCA       -- demand G(A→B): temporalFutureDerived ; G-mono(modal_t)
  lexact hCA

-- E3 (C1): fails, with the exposed goal shown.
example (A B : Formula) : [ModalS5.iff A B, A.allFuture] ⊢ B.allFuture := by
  lstart hAB hA
  lrw hAB at hA        -- error: needs Γ ⊢ G(A→B); scope [G]; ε-fact insufficient

-- E4: compositional spec reuse with an opaque provider and unfolding.
example (fc) (hZ : FrameClass.ZTime ≤ fc) (req busy done : Formula)
    (spec : ⊢[fc] (req.imp (Formula.untl busy done)).allFuture) :
    [req.someFuture] ⊢[fc] (done.next.or (busy.and (Formula.untl busy done)).next).someFuture := by
  lstart hr
  lhave hu : (Formula.untl busy done).someFuture := (futureConsequence (thmIn spec) hr)
  lmono (untilUnfold hZ busy done) at hu   -- positive F-position; demand G discharged by TN
  lexact hu

-- E5: semantic import, then shift, with no reverse step.
example (d : [A] ⊢[fc] B) (hF : fc.Sat F) (h : TruthAt M τ t A) :
    TruthAt M (τ.timeShift (t - x)) x B := by
  have hB := sOfNative d hF (by simpa using h)
  exact (TimeShift.timeShift_preserves_truth M τ x t B).mpr hB
```

E4 uses the existing `ProofMode.futureConsequence` and `thmIn`.

## 7. Milestones and acceptance

| M | Content | Acceptance (targeted module builds only) |
|---|---|---|
| 1 | `PosStep`, the TM/TM⁺ table, `congrPath`, `boxDischarge` | E1/E2 term-mode tests; C1 has no derivation route (demand exposed); C4 at `.Base` |
| 2 | `lrw` for goals, Lean locals, object hyps in cut/replace modes, mdata diagnostics | replace mode rejects stale locals via the existing inclusion check; cut mode keeps them |
| 3 | Temporal: `untilIntro`, `sinceFold`, wrappers, `lunfold`/`lfold`, `mirrorCtx`, `lmirror` | C5 rejected; C6 gate test (`lunfold` at `.Dense` fails to elaborate) |
| 4 | `stabOfStateLocal` and TM⁺ ⊡ discharge | `⊢⁺ (□p ∧ ¬q) → ⊡(□p ∧ ¬q)` test; `F p` refused |
| 5 | `lsimp` registry, seed rules, `lsimp?` | C2/C3 oriented and gated; fuel-exhaustion message test; `lsimp?` script round-trips |
| 6 | Semantic: `next_iff`/`prev_iff`, TM `StateLocal`, frontends, `sOfNative`, no-completeness guards | E5; `rfl` pins; `assert_not_exists` compiles |

**Validation matrix.** About 18 examples in one test file per milestone:
- languages {TM, TM⁺} × frame classes {Base, ZTime, Dense} × outcomes {succeeds, refused with diagnostic};
- C1–C6 as negative tests, checked with `fail_if_success` or a documented exposed goal.

No full rebuild is needed.

## 8. Obligations still to prove or decide

1. **Theorems:** `congrPath`; `boxDischarge`; `stabOfStateLocal`; `sinceFold` and the Since table mirrors; `untilIntro`; `mirrorCtx` (TM version); TM `Formula.StateLocal` soundness via `plusTruthAt_ofFormula`; the TM⁺ `box_const` analogue; `next_iff`/`prev_iff`.
2. **Optional:** `⊢ △P → G H P`. It is valid on linear orders and would let `always`-facts discharge mixed G/H demands. Its derivation is unknown to me, and the design does not depend on it.
3. **Elaborator:** the derived-operator unfolding table; the registry's frame-gate check; the `lsimp?` printer.
4. **Glue:** `soundness_ztime` uses `SuccOrder`/`PredOrder` instances while `Sat .ZTime` uses `IsZTime`. `sOfNative` goes through `soundness_in` to avoid this, but any semantic ZTime frontend needs instance glue.

## 9. Strongest objections to this proposal

1. **Primitive-level paths and derived operators.** `and`, `or`, `◇`, `G` and `F` are encoded through `imp`/`bot`/`untl`, so paths cross several negations. The macro steps hide this, but each one is a hand-maintained composite. A mismatch between a macro and the primitive encoding would show up as a confusing demand or parity error, not as unsoundness. That is a real usability risk, and §2.1 does not fully specify the matcher.
2. **Replace mode is awkward.** It invalidates outer locals, and I only report them rather than transport them. A closed-reverse-equivalence transporter was considered and left out.
3. **Silent demand re-planning.** Routing X through G (closed facts) and through □ (boxed facts) is correct but implicit. A user who supplies `X(A⇒B)` and a closed rule in the same call could be surprised by which route was taken. The trace mitigates this; it does not remove it.
4. **`lsimp` is deliberately weak.** It is closed-only for registered rules, has no AC normalization, no contextual registry, and checks size decrease on a single instance, which is a heuristic rather than a termination proof (fuel is the actual guarantee).
5. **The semantic backend is narrow.** It dispatches on the two-value `Language` enum, so L⋆ or other languages would need elaborator edits. I judged a transport class speculative, but a reviewer may disagree. `sReflect` is of limited practical use because it changes the model.
6. **Unmeasured performance.** Elaboration cost and derivation-term size for deep paths are unmeasured. `Type`-valued trees might make `isDefEq` on intermediate types expensive.
7. **Diagnostics can be stale.** The scope-trail `mdata` is diagnostic only, and it can be wrong if ordinary Lean tactics restructure goals between scopes.
8. **`stabOfStateLocal` cases are unchecked.** Its negation and implication cases depend on ⊡-S5 reasoning I have not checked in detail; if a case needs more than `stab_5`, Milestone 4's scope shrinks.
