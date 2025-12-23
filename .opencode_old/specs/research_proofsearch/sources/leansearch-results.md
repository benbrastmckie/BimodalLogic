# LeanSearch Results: LEAN 4 Proof Search Implementations

**Date**: 2025-12-20 17:50:17
**Total Queries**: 10
**Total Results**: 150

---

## Query 1: bounded depth first search proof automation
**Results Found**: 15

### Result 1
- **Name**: `Mathlib.Tactic.Order.Graph.buildTransitiveLeProofDFS`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Order.Graph.Basic`
- **Relevance Score**: 98.16/100 (distance: 0.0184)
- **Signature**: ` (g : Graph) (v t : Nat) (tExpr : Expr) : StateT DFSState MetaM (Option Expr)`
- **Type Signature**: `Mathlib.Tactic.Order.Graph →
  Nat → Nat → Lean.Expr → StateT Mathlib.Tactic.Order.Graph.DFSState Lean.Meta.MetaM (Option Lean.Expr)`
- **Description**: Depth-first search for constructing transitive order proofs - The function performs a depth-first search (DFS) on a graph \( g \), starting from vertex \( v \), to find a path to vertex \( t \). If such a path exists, it constructs a proof that the atom corresponding to \( v \) is less than or equal to the atom corresponding to \( t \) by transitivity of the order relation, using the edge proofs along the path. If no path is found, it returns `none`.

### Result 2
- **Name**: `Mathlib.Tactic.Order.Graph.DFSState`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Order.Graph.Basic`
- **Relevance Score**: 97.2/100 (distance: 0.0280)
- **Type Signature**: `Type`
- **Description**: DFS state for order tactic graphs - The structure representing the state for a depth-first search (DFS) algorithm used in the `order` tactic. This state is utilized when traversing a graph where vertices represent atoms and edges represent the `≤` relation between them.

### Result 3
- **Name**: `implMaxDepth`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Deprecated.MLList.BestFirst`
- **Relevance Score**: 97.16/100 (distance: 0.0284)
- **Signature**: ` (maxSize : Option Nat) (maxDepth : Option Nat) (f : α → MLList m α) (a : α) : MLList m α`
- **Type Signature**: `{ω α : Type} →
  (prio : α → Thunk ω) →
    (ε : α → Type) →
      [inst : LinearOrder ω] →
        [inst_1 : (a : α) → Estimator (prio a) (ε a)] →
          [I : ∀ (a : α), WellFoundedGT (Set.range ((inst_1 a).bound (prio a))).Elem] →
            [Ord ω] →
              [Ord α] →
                {m : Type → Type} →
                  [Monad m] →
                    [Alternative m] →
                      [(a : α) → Bot (ε a)] → Option Nat → Option Nat → (α → MLList m α) → α → MLList m α`
- **Description**: Best-First Search with Maximum Depth - The function `implMaxDepth` implements a best-first search algorithm with an optional maximum depth constraint. Given an initial element `a` of type `α`, a function `f : α → MLList m α` that lazily generates the neighbors of any element, and optional parameters `maxSize` (for beam search) and `maxDepth` (to bound the search depth), it returns a lazy list of elements reachable from `a` via `f`, where the search prioritizes nodes according to a lower-bound estimate of their priority and does not explore beyond depth `maxDepth` if specified. If `maxDepth` is `none`, it delegates to the unbounded-depth implementation `impl`.

### Result 4
- **Name**: `Mathlib.Tactic.TFAE.dfs`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.TFAE`
- **Relevance Score**: 96.64/100 (distance: 0.0336)
- **Signature**: `(i j : ℕ) (P P' : Q`
- **Type Signature**: `Array (Prod Nat (Prod Nat Lean.Expr)) →
  Array (Qq.Quoted (Lean.Expr.sort Lean.Level.zero)) →
    Nat →
      Nat →
        (P P' : Qq.Quoted (Lean.Expr.sort Lean.Level.zero)) →
          Qq.Quoted P → StateT (Std.HashSet Nat) Lean.Meta.MetaM (Qq.Quoted P')`
- **Description**: Depth-first search for TFAE implications - The function `dfs` uses depth-first search to find a path from proposition `P` to proposition `P'` in a directed graph where nodes correspond to propositions in a TFAE (The Following Are Equivalent) list and edges correspond to known implications between them.

### Result 5
- **Name**: `Mathlib.Tactic.Order.Graph.buildTransitiveLeProof`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Order.Graph.Basic`
- **Relevance Score**: 96.24/100 (distance: 0.0376)
- **Signature**: ` (g : Graph) (idxToAtom : Std.HashMap Nat Expr) (s t : Nat) : MetaM (Option Expr)`
- **Type Signature**: `Mathlib.Tactic.Order.Graph → Std.HashMap Nat Lean.Expr → Nat → Nat → Lean.Meta.MetaM (Option Lean.Expr)`
- **Description**: Transitive proof construction for order relations via DFS - Given a graph `g` representing a `≤`-relation between vertices (atoms), and a mapping `idxToAtom` from vertex indices to their corresponding expressions, the function `buildTransitiveLeProof` constructs a proof that vertex `s` is less than or equal to vertex `t` by performing a depth-first search (DFS) on the graph. If a path from `s` to `t` exists, it returns a proof of `s ≤ t` by composing the edge proofs using transitivity (`le_trans`). If no such path exists, it returns `none`.

### Result 6
- **Name**: `bestFirstSearch`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Deprecated.MLList.BestFirst`
- **Relevance Score**: 96.12/100 (distance: 0.0388)
- **Type Signature**: `{m : Type → Type} →
  {α : Type} →
    [Monad m] →
      [Alternative m] →
        [LinearOrder α] →
          (α → MLList m α) →
            α →
              optParam (Option Nat) Option.none →
                optParam (Option Nat) Option.none → optParam Bool Bool.true → MLList m α`
- **Description**: Best‑First Graph Search with Configurable Bounds and Deduplication - Given a starting element `a : α`, a function `next : α → MLList m α` that lazily generates the neighbors of each node, and optional parameters `maxDepth : ℕ` (default `0`, meaning no bound), `maxQueued : ℕ` (default `0`, meaning no bound), and `removeDuplicatesBy? : Option (α → α → Bool)` (default `none`, meaning no deduplication), the function `bestFirstSearch` performs a best‑first traversal of the implicit graph defined by `next`. It returns a lazy list (`MLList m α`) of reachable nodes, ordered by a priority determined by the underlying queue structure. The search respects the depth bound `maxDepth` (if nonzero) and discards low‑priority nodes when the queue size exceeds `maxQueued` (if nonzero). If `removeDuplicatesBy?` is provided with an equivalence relation, previously visited nodes are not revisited.

**Informal name**  
Best‑First Graph Search with Configurable Bounds and Deduplication

### Result 7
- **Name**: `Mathlib.Tactic.Order.Graph.DFSState.casesOn`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Order.Graph.Basic`
- **Relevance Score**: 95.57/100 (distance: 0.0443)
- **Type Signature**: `{motive : Mathlib.Tactic.Order.Graph.DFSState → Sort u} →
  (t : Mathlib.Tactic.Order.Graph.DFSState) → ((visited : Array Bool) → motive { visited := visited }) → motive t`
- **Description**: Case Analysis Principle for Depth-First Search State - Let `DFSState` be a structure used in depth-first search on a directed graph. For any predicate `P` on `DFSState`, if `P` holds for every possible constructor of `DFSState`, then `P` holds for every element of `DFSState`.

**Informal name**  
Case Analysis Principle for Depth-First Search State

### Result 8
- **Name**: `Mathlib.Tactic.Order.Graph.DFSState.recOn`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Order.Graph.Basic`
- **Relevance Score**: 95.4/100 (distance: 0.0460)
- **Type Signature**: `{motive : Mathlib.Tactic.Order.Graph.DFSState → Sort u} →
  (t : Mathlib.Tactic.Order.Graph.DFSState) → ((visited : Array Bool) → motive { visited := visited }) → motive t`
- **Description**: Recursion Principle for Depth‑First Search State - Let `DFSState` be a structure used in depth-first search (DFS) for graphs. The function `recOn` provides a recursion principle for `DFSState`: given a predicate `P` on `DFSState`, to prove `P s` for every `DFSState` `s`, it suffices to prove `P` for a `DFSState` constructed from a vertex `v`, a list of vertices `stack`, a set of visited vertices `visited`, and a graph `g`.

**Informal name**  
Recursion Principle for Depth‑First Search State

### Result 9
- **Name**: `Mathlib.Tactic.Order.Graph.DFSState.mk`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Order.Graph.Basic`
- **Relevance Score**: 94.29/100 (distance: 0.0571)
- **Type Signature**: `Array Bool → Mathlib.Tactic.Order.Graph.DFSState`
- **Description**: Constructor for Depth-First Search State in Order Graph - The constructor `DFSState.mk` creates a depth-first search state for graphs used in the `order` tactic, where vertices represent mathematical atoms and edges represent the `≤` relation between them.

**Informal name**
Constructor for Depth-First Search State in Order Graph

**Note:** Since this appears to be an internal implementation detail of a tactic rather than a mathematical theorem, the informal description focuses on its role within the mathematical reasoning system rather than providing a traditional mathematical statement.

### Result 10
- **Name**: `Ordnode.Bounded.weak`
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.Ordmap.Invariants`
- **Relevance Score**: 93.25/100 (distance: 0.0675)
- **Signature**: ` {t : Ordnode α} {o₁ o₂} (h : Bounded t o₁ o₂) : Bounded t ⊥ ⊤`
- **Type Signature**: `∀ {α : Type u_1} [inst : Preorder α] {t : Ordnode α} {o₁ : WithBot α} {o₂ : WithTop α},
  t.Bounded o₁ o₂ → t.Bounded WithBot.bot.bot WithTop.top.top`
- **Description**: Relaxation of Bounds in Bounded Binary Search Trees - Let $t$ be a binary search tree of type $\mathrm{Ordnode}\ \alpha$ with bounds $o_1 \in \mathrm{WithBot}\ \alpha$ and $o_2 \in \mathrm{WithTop}\ \alpha$. If $t$ is bounded below by $o_1$ and above by $o_2$, then $t$ is also bounded below by $\bot$ and above by $\top$ (i.e., the bounds can be relaxed to the minimum and maximum values, respectively).

### Result 11
- **Name**: `Mathlib.Tactic.Order.Graph.DFSState.noConfusion`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Order.Graph.Basic`
- **Relevance Score**: 92.41/100 (distance: 0.0759)
- **Type Signature**: `{P : Sort u} →
  {x1 x2 : Mathlib.Tactic.Order.Graph.DFSState} → Eq x1 x2 → Mathlib.Tactic.Order.Graph.DFSState.noConfusionType P x1 x2`
- **Description**: No Confusion Property for Depth‑First Search State - The function `noConfusion` is a helper function used to prove that the `DFSState` structure in the `order` tactic’s graph module does not introduce any contradictions; i.e., distinct constructors of `DFSState` produce distinct values.

**Informal name**  
No Confusion Property for Depth‑First Search State

### Result 12
- **Name**: `Mathlib.Tactic.TFAE.proveImpl`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.TFAE`
- **Relevance Score**: 91.73/100 (distance: 0.0827)
- **Signature**: `(i j : ℕ) (P P' : Q`
- **Type Signature**: `Array (Prod Nat (Prod Nat Lean.Expr)) →
  Array (Qq.Quoted (Lean.Expr.sort Lean.Level.zero)) →
    Nat →
      Nat →
        (P P' : Qq.Quoted (Lean.Expr.sort Lean.Level.zero)) →
          Lean.Meta.MetaM (Qq.Quoted (Lean.Expr.forallE Lean.Name.anonymous P P' Lean.BinderInfo.default))`
- **Description**: Implication proof in TFAE via depth-first search - The function `proveImpl` attempts to prove the implication \( P_i \to P_j \) between two propositions \( P_i \) and \( P_j \) in a TFAE (The Following Are Equivalent) list, where \( i \) and \( j \) are indices into the list. It uses depth-first search to find a chain of implications connecting \( P_i \) to \( P_j \).

### Result 13
- **Name**: `Mathlib.Tactic.Order.Graph.DFSState.rec`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Order.Graph.Basic`
- **Relevance Score**: 90.73/100 (distance: 0.0927)
- **Type Signature**: `{motive : Mathlib.Tactic.Order.Graph.DFSState → Sort u} →
  ((visited : Array Bool) → motive { visited := visited }) → (t : Mathlib.Tactic.Order.Graph.DFSState) → motive t`
- **Description**: Recursion Principle for Depth‑First‑Search State in Order‑Tactic Graphs - The `DFSState` structure in the `order` tactic’s graph module is defined by a recursion principle that allows constructing a function on `DFSState` by specifying its values on the two fields `todo` and `visited`, where `todo` is a list of vertices to be processed and `visited` is a set of vertices already processed.

**Informal name**  
Recursion Principle for Depth‑First‑Search State in Order‑Tactic Graphs

### Result 14
- **Name**: `Mathlib.Tactic.Order.Graph.DFSState.mk.sizeOf_spec`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Order.Graph.Basic`
- **Relevance Score**: 90.19/100 (distance: 0.0981)
- **Type Signature**: `∀ (visited : Array Bool),
  Eq (Mathlib.Tactic.Order.Graph.DFSState._sizeOf_inst.sizeOf { visited := visited })
    (instHAdd.hAdd 1 ((Array._sizeOf_inst Bool).sizeOf visited))`
- **Description**: Size of Depth-First Search State Equals Sum of Its Components - The size of a `DFSState` structure, as defined by the `sizeOf` function, is equal to the sum of the sizes of its two fields: the set of visited vertices and the stack of vertices to be processed.

**Informal name**  
Size of Depth-First Search State Equals Sum of Its Components

### Result 15
- **Name**: `Ordnode.Bounded.weak_left`
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.Ordmap.Invariants`
- **Relevance Score**: 89.26/100 (distance: 0.1074)
- **Signature**: ` : ∀ {t : Ordnode α} {o₁ o₂}, Bounded t o₁ o₂ → Bounded t ⊥ o₂`
- **Type Signature**: `∀ {α : Type u_1} [inst : Preorder α] {t : Ordnode α} {o₁ : WithBot α} {o₂ : WithTop α},
  t.Bounded o₁ o₂ → t.Bounded WithBot.bot.bot o₂`
- **Description**: Relaxation of Lower Bound in Bounded Binary Search Trees - Let $t$ be a binary search tree of type $\mathrm{Ordnode}\ \alpha$ and let $o_1 \in \mathrm{WithBot}\ \alpha$, $o_2 \in \mathrm{WithTop}\ \alpha$ be bounds. If $t$ is bounded below by $o_1$ and above by $o_2$, then $t$ is also bounded below by $\bot$ and above by $o_2$ (i.e., the lower bound can be relaxed to the minimum value).

---

## Query 2: proof search tactic implementation
**Results Found**: 15

### Result 1
- **Name**: `Mathlib.Tactic.ITauto.prove`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 98.53/100 (distance: 0.0147)
- **Signature**: `(Γ : Context) (B : IProp) : StateM Nat (Bool`
- **Type Signature**: `Mathlib.Tactic.ITauto.Context → Mathlib.Tactic.ITauto.IProp → StateM Nat (Prod Bool Mathlib.Tactic.ITauto.Proof)`
- **Description**: Proof Search in Intuitionistic Propositional Logic - The function `prove` takes a proof context $\Gamma$ and a propositional formula $B$ in intuitionistic logic, and returns a state monad computation that produces a pair of a Boolean value and a proof term. The Boolean indicates whether the proof search was successful, and the proof term is a valid derivation of $B$ from $\Gamma$ if successful. The algorithm applies intuitionistic proof rules in three levels:  
- Level 1: Validity-preserving rules without splitting (e.g., handling $\top$, $\bot$, $\to$).  
- Level 2: Validity-preserving splitting rules (e.g., splitting conjunctions in goals and disjunctions in hypotheses).  
- Level 3: Non-validity-preserving splitting rules (e.g., case splitting on disjunctions in goals) applied only as a last resort.

### Result 2
- **Name**: `Mathlib.Tactic.Propose.propose'`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 97.87/100 (distance: 0.0213)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Forward reasoning lemma search tactic - The tactic `have? using a, b, c` searches for lemmas that utilize each of the local hypotheses `a`, `b`, and `c`, reporting any matches via trace messages. The variant `have? : t using a, b, c` restricts the search to lemmas whose type matches `t` (which may contain placeholders `_`). Additionally, `have?! using a, b, c` not only reports matches but also applies them to the local goal state using the `have` tactic. Unlike `apply?`, this tactic does not consider the current goal, focusing solely on the types of the provided hypotheses.

### Result 3
- **Name**: `Mathlib.Tactic.Find.tactic#find_`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Find`
- **Relevance Score**: 95.7/100 (distance: 0.0430)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Find command for definitions and lemmas - The `#find` command searches for definitions and lemmas in the library by pattern matching on their types. It can be used with various patterns, such as `_ + _ = _ + _` to find commutativity lemmas or `Nat → Nat` to find functions between natural numbers. The command is also available as a tactic within proofs to find applicable lemmas for the current goal.

### Result 4
- **Name**: `Mathlib.Tactic.ITauto.search`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 95.66/100 (distance: 0.0434)
- **Type Signature**: `Mathlib.Tactic.ITauto.Context → Mathlib.Tactic.ITauto.IProp → StateM Nat (Prod Bool Mathlib.Tactic.ITauto.Proof)`
- **Description**: Search phase of the G4ip intuitionistic proof procedure - The function `search` implements the search phase of the `G4ip` algorithm for intuitionistic propositional logic. Given a proof context `Γ` (a set of assumptions with their proofs) and a goal proposition `A`, it returns a pair `(b, p)` where `b` is a Boolean indicating success and `p` is a proof object for the goal, or fails if no proof is found. The search phase applies level‑1 and level‑3 rules of the algorithm, including the key rule that from `Γ, P, P → A` we can derive `Γ, P, A`.

**Informal name**  
Search phase of the G4ip intuitionistic proof procedure

### Result 5
- **Name**: `Mathlib.Tactic.Find.tacticFind`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Find`
- **Relevance Score**: 94.78/100 (distance: 0.0522)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Find tactic for applicable lemmas - The `find` tactic searches for lemmas that can be applied to the current goal in a proof context.

### Result 6
- **Name**: `Mathlib.Tactic.Find.command#find_`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Find`
- **Relevance Score**: 94.12/100 (distance: 0.0588)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Find command for definitions and lemmas - The `#find` command in Lean is used to search for definitions and lemmas by pattern matching on their types. For example, it can find expressions matching patterns like `_ + _ = _ + _` or `Nat → Nat`.

### Result 7
- **Name**: `Lean.Elab.runTactic'`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Lean.Elab.Tactic.Meta`
- **Relevance Score**: 93.9/100 (distance: 0.0610)
- **Type Signature**: `Lean.MVarId →
  Lean.Syntax →
    optParam Lean.Elab.Term.Context { } → optParam Lean.Elab.Term.State { } → Lean.Meta.MetaM (List Lean.MVarId)`
- **Description**: *Cannot be determined - this appears to be a Lean implementation detail rather than a mathematical theorem.* - *Cannot be determined - this appears to be a Lean implementation detail rather than a mathematical theorem.*

**Informal name**
*Cannot be determined - this appears to be a Lean implementation detail rather than a mathematical theorem.*

### Result 8
- **Name**: `Mathlib.LibraryNote.fact non-instances`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Logic.Basic`
- **Relevance Score**: 92.52/100 (distance: 0.0748)
- **Signature**: ` : LibraryNote✝`
- **Type Signature**: `LibraryNote`
- **Description**: Library Note on Fact Non-Instances - A library note in Mathlib: "In most cases, we should not have global instances of `Fact`; typeclass search is not an advanced proof search engine, and adding any such instance has the potential to cause slowdowns everywhere. We instead declare them as lemmata and make them local instances as required."

### Result 9
- **Name**: `Mathlib.Tactic.TFAE.proveImpl`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.TFAE`
- **Relevance Score**: 92.36/100 (distance: 0.0764)
- **Signature**: `(i j : ℕ) (P P' : Q`
- **Type Signature**: `Array (Prod Nat (Prod Nat Lean.Expr)) →
  Array (Qq.Quoted (Lean.Expr.sort Lean.Level.zero)) →
    Nat →
      Nat →
        (P P' : Qq.Quoted (Lean.Expr.sort Lean.Level.zero)) →
          Lean.Meta.MetaM (Qq.Quoted (Lean.Expr.forallE Lean.Name.anonymous P P' Lean.BinderInfo.default))`
- **Description**: Implication proof in TFAE via depth-first search - The function `proveImpl` attempts to prove the implication \( P_i \to P_j \) between two propositions \( P_i \) and \( P_j \) in a TFAE (The Following Are Equivalent) list, where \( i \) and \( j \) are indices into the list. It uses depth-first search to find a chain of implications connecting \( P_i \) to \( P_j \).

### Result 10
- **Name**: `Mathlib.Tactic.generalizeProofsElab`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.GeneralizeProofs`
- **Relevance Score**: 91.85/100 (distance: 0.0815)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: `generalize_proofs` Tactic - The tactic `generalize_proofs` replaces proof terms occurring in the goal or specified hypotheses with new local hypotheses. This is particularly useful for referring to proofs later in a proof (e.g., when dealing with functions like `Classical.choose` that depend on proofs) and for handling dependent type issues.  

- `generalize_proofs` generalizes proofs in the target.  
- `generalize_proofs at h₁ h₂` generalizes proofs in hypotheses `h₁` and `h₂`.  
- `generalize_proofs at *` generalizes proofs in the entire local context.  
- `generalize_proofs pf₁ pf₂ pf₃` uses names `pf₁`, `pf₂`, and `pf₃` for the generalized proofs (use `_` to leave proofs unnamed).  

If a proof already exists in the local context, it is reused. When generalizing at a hypothesis `h` that is a let-binding, the value is cleared, and duplicates are eliminated. The tactic can abstract proofs under binders (producing universally quantified proofs) and recursively abstract proofs from the types of generalized proofs (controlled via `maxDepth`).  

**Example**:  
Given a goal `[1, 2].nthLe 1 (by simp) = 2`, applying `generalize_proofs h` replaces the proof term `(by simp)` with a hypothesis `h : 1 < [1, 2].length`, resulting in the goal `[1, 2].nthLe 1 h = 2`.

### Result 11
- **Name**: `Mathlib.Tactic.Propose.tacticHave!?:_Using__`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 90.86/100 (distance: 0.0914)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Forward reasoning lemma suggestion tactic - The tactic `have!? : t using a, b, c` attempts to find and apply a lemma that uses all of the local hypotheses `a`, `b`, and `c`, optionally restricted to lemmas whose type matches `t` (which may contain placeholders `_`). Unlike `apply?`, this tactic focuses on forward reasoning by examining the available hypotheses rather than working backward from the current goal.

### Result 12
- **Name**: `Mathlib.Tactic.Polyrith.tacticPolyrithOnly[_]`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Polyrith`
- **Relevance Score**: 90.67/100 (distance: 0.0933)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: `polyrith` Tactic - The `polyrith` tactic is no longer supported in Mathlib, as it relied on a defunct external service.

### Result 13
- **Name**: `Mathlib.Tactic.Tauto.tautoCore`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Tauto`
- **Relevance Score**: 90.6/100 (distance: 0.0940)
- **Signature**: ` : TacticM Unit`
- **Type Signature**: `Lean.Elab.Tactic.TacticM Unit`
- **Description**: Core loop of the `tauto` tactic - The core loop of the `tauto` tactic repeatedly breaks down propositions until no further progress is made. At each step, it attempts to use `assumption` and `contradiction` to discharge goals immediately. The loop applies introduction of variables, distributes negations in hypotheses using de Morgan’s laws, performs case analysis on conjunctions, disjunctions, existentials, and `False`, and refines disjunctions into implications. It also applies constructors for conjunctions, bi-implications, and `True`. The loop terminates when no subgoals change.

### Result 14
- **Name**: `Mathlib.Tactic.GeneralizeProofs.AContext.ctorIdx`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.GeneralizeProofs`
- **Relevance Score**: 89.48/100 (distance: 0.1052)
- **Type Signature**: `Mathlib.Tactic.GeneralizeProofs.AContext → Nat`
- **Description**: *Unable to generate informal name - the input describes a tactic implementation component rather than a mathematical concept.* - *Unable to generate informal statement - the input appears to describe a programming tactic implementation detail rather than a mathematical theorem, and no formal statement was provided.*

**Informal name**
*Unable to generate informal name - the input describes a tactic implementation component rather than a mathematical concept.*

### Result 15
- **Name**: `Mathlib.Tactic.RewriteSearch.tacticRw_search_`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.RewriteSearch`
- **Relevance Score**: 88.16/100 (distance: 0.1184)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Removal of the `rw_search` Tactic - The tactic `rw_search` has been removed from Mathlib.

---

## Query 3: heuristic guided proof search
**Results Found**: 15

### Result 1
- **Name**: `Mathlib.Tactic.Propose.propose'`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 97.07/100 (distance: 0.0293)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Forward reasoning lemma search tactic - The tactic `have? using a, b, c` searches for lemmas that utilize each of the local hypotheses `a`, `b`, and `c`, reporting any matches via trace messages. The variant `have? : t using a, b, c` restricts the search to lemmas whose type matches `t` (which may contain placeholders `_`). Additionally, `have?! using a, b, c` not only reports matches but also applies them to the local goal state using the `have` tactic. Unlike `apply?`, this tactic does not consider the current goal, focusing solely on the types of the provided hypotheses.

### Result 2
- **Name**: `Mathlib.Tactic.ITauto.prove`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 96.24/100 (distance: 0.0376)
- **Signature**: `(Γ : Context) (B : IProp) : StateM Nat (Bool`
- **Type Signature**: `Mathlib.Tactic.ITauto.Context → Mathlib.Tactic.ITauto.IProp → StateM Nat (Prod Bool Mathlib.Tactic.ITauto.Proof)`
- **Description**: Proof Search in Intuitionistic Propositional Logic - The function `prove` takes a proof context $\Gamma$ and a propositional formula $B$ in intuitionistic logic, and returns a state monad computation that produces a pair of a Boolean value and a proof term. The Boolean indicates whether the proof search was successful, and the proof term is a valid derivation of $B$ from $\Gamma$ if successful. The algorithm applies intuitionistic proof rules in three levels:  
- Level 1: Validity-preserving rules without splitting (e.g., handling $\top$, $\bot$, $\to$).  
- Level 2: Validity-preserving splitting rules (e.g., splitting conjunctions in goals and disjunctions in hypotheses).  
- Level 3: Non-validity-preserving splitting rules (e.g., case splitting on disjunctions in goals) applied only as a last resort.

### Result 3
- **Name**: `Mathlib.Tactic.Propose.tacticHave?!:_Using__`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 95.85/100 (distance: 0.0415)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Forward reasoning tactic with lemma suggestion - The tactic `have?!` attempts to find a lemma that utilizes each of the provided local hypotheses `a, b, c`. The variant `have?! : t using a, b, c` restricts the search to lemmas with type `t` (which may contain placeholders `_`). Unlike `apply?`, which performs backward reasoning by looking at the goal, `have?!` focuses on forward reasoning by examining the given hypotheses.

### Result 4
- **Name**: `Mathlib.Meta.FunProp.tryTheoremWithHint?`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.FunProp.Core`
- **Relevance Score**: 95.08/100 (distance: 0.0492)
- **Signature**: `(e : Expr) (thmOrigin : Origin)
    (hint : Array (Nat`
- **Type Signature**: `Lean.Expr →
  Mathlib.Meta.FunProp.Origin →
    Array (Prod Nat Lean.Expr) →
      (Lean.Expr → Mathlib.Meta.FunProp.FunPropM (Option Mathlib.Meta.FunProp.Result)) →
        optParam Bool Bool.false → Mathlib.Meta.FunProp.FunPropM (Option Mathlib.Meta.FunProp.Result)`
- **Description**: Theorem application with hints for function properties - The function `tryTheoremWithHint?` takes an expression `e`, a theorem identifier `thmOrigin` (classifying the source of the theorem), and an array of natural numbers `hint` (indicating which arguments to prioritize during synthesis). It attempts to apply the theorem specified by `thmOrigin` to prove a function property for `e`, using the hints to guide argument synthesis.

### Result 5
- **Name**: `Mathlib.Tactic.Propose.tacticHave!?:_Using__`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 93.67/100 (distance: 0.0633)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Forward reasoning lemma suggestion tactic - The tactic `have!? : t using a, b, c` attempts to find and apply a lemma that uses all of the local hypotheses `a`, `b`, and `c`, optionally restricted to lemmas whose type matches `t` (which may contain placeholders `_`). Unlike `apply?`, this tactic focuses on forward reasoning by examining the available hypotheses rather than working backward from the current goal.

### Result 6
- **Name**: `Mathlib.Tactic.ITauto.search`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 93.39/100 (distance: 0.0661)
- **Type Signature**: `Mathlib.Tactic.ITauto.Context → Mathlib.Tactic.ITauto.IProp → StateM Nat (Prod Bool Mathlib.Tactic.ITauto.Proof)`
- **Description**: Search phase of the G4ip intuitionistic proof procedure - The function `search` implements the search phase of the `G4ip` algorithm for intuitionistic propositional logic. Given a proof context `Γ` (a set of assumptions with their proofs) and a goal proposition `A`, it returns a pair `(b, p)` where `b` is a Boolean indicating success and `p` is a proof object for the goal, or fails if no proof is found. The search phase applies level‑1 and level‑3 rules of the algorithm, including the key rule that from `Γ, P, P → A` we can derive `Γ, P, A`.

**Informal name**  
Search phase of the G4ip intuitionistic proof procedure

### Result 7
- **Name**: `Mathlib.Tactic.Hint.hint`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Hint`
- **Relevance Score**: 92.89/100 (distance: 0.0711)
- **Signature**: ` (stx : Syntax) : TacticM Unit`
- **Type Signature**: `Lean.Syntax → Lean.Elab.Tactic.TacticM Unit`
- **Description**: Hint Tactic - The `hint` tactic runs all tactics registered via `register_hint` on the current goal, reporting successful ones with a "Try these:" suggestion. If a tactic succeeds and closes the goal, subsequent tactics are not executed.

### Result 8
- **Name**: `Mathlib.Tactic.Polyrith.tacticPolyrithOnly[_]`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Polyrith`
- **Relevance Score**: 91.73/100 (distance: 0.0827)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: `polyrith` Tactic - The `polyrith` tactic is no longer supported in Mathlib, as it relied on a defunct external service.

### Result 9
- **Name**: `Mathlib.Tactic.Find.command#find_`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Find`
- **Relevance Score**: 91.55/100 (distance: 0.0845)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Find command for definitions and lemmas - The `#find` command in Lean is used to search for definitions and lemmas by pattern matching on their types. For example, it can find expressions matching patterns like `_ + _ = _ + _` or `Nat → Nat`.

### Result 10
- **Name**: `Mathlib.Tactic.Find.tacticFind`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Find`
- **Relevance Score**: 91.24/100 (distance: 0.0876)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Find tactic for applicable lemmas - The `find` tactic searches for lemmas that can be applied to the current goal in a proof context.

### Result 11
- **Name**: `Mathlib.Tactic.Find.tactic#find_`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Find`
- **Relevance Score**: 91.18/100 (distance: 0.0882)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Find command for definitions and lemmas - The `#find` command searches for definitions and lemmas in the library by pattern matching on their types. It can be used with various patterns, such as `_ + _ = _ + _` to find commutativity lemmas or `Nat → Nat` to find functions between natural numbers. The command is also available as a tactic within proofs to find applicable lemmas for the current goal.

### Result 12
- **Name**: `Mathlib.LibraryNote.fact non-instances`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Logic.Basic`
- **Relevance Score**: 91.12/100 (distance: 0.0888)
- **Signature**: ` : LibraryNote✝`
- **Type Signature**: `LibraryNote`
- **Description**: Library Note on Fact Non-Instances - A library note in Mathlib: "In most cases, we should not have global instances of `Fact`; typeclass search is not an advanced proof search engine, and adding any such instance has the potential to cause slowdowns everywhere. We instead declare them as lemmata and make them local instances as required."

### Result 13
- **Name**: `Mathlib.Tactic.Propose.propose`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 90.05/100 (distance: 0.0995)
- **Type Signature**: `Lean.Meta.DiscrTree Lean.Name →
  Lean.Expr → Array Lean.Expr → optParam Nat 15 → Lean.Meta.MetaM (Array (Prod Lean.Name Lean.Expr))`
- **Description**: Forward Reasoning Lemma Suggestion: `have? using` - The tactic `propose` (invoked as `have? using a, b, c`) attempts to find a lemma that uses all the specified local hypotheses `a, b, c`. The variant `have? : t using a, b, c` restricts the search to lemmas whose type matches `t` (which may contain placeholders `_`). Unlike `apply?`, which performs backward reasoning by matching the goal, `propose` focuses on forward reasoning by analyzing the hypotheses.

**Informal name**  
Forward Reasoning Lemma Suggestion: `have? using`

### Result 14
- **Name**: `suggestSteps`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Widget.Calc`
- **Relevance Score**: 89.55/100 (distance: 0.1045)
- **Signature**: `(pos : Array Lean.SubExpr.GoalsLocation) (goalType : Expr) (params : CalcParams) :
    MetaM (String`
- **Type Signature**: `Array Lean.SubExpr.GoalsLocation →
  Lean.Expr → CalcParams → Lean.Meta.MetaM (Prod String (Prod String (Option (Prod String.Pos String.Pos))))`
- **Description**: Suggested Steps for Calculator Proof - Given an array of goal locations, the goal type expression, and parameters for the calculator widget, the function `suggestSteps` returns a string containing suggested intermediate steps for a `calc` proof block. These steps are generated by replacing selected sub-expressions in the goal with metavariables and constructing a chain of equalities or inequalities.

### Result 15
- **Name**: `Mathlib.Tactic.Hint.hintStx`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Hint`
- **Relevance Score**: 87.15/100 (distance: 0.1285)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Hint tactic - The `hint` tactic attempts all tactics registered via `register_hint tac` on the current goal and reports which ones succeed.

---

## Query 4: proof caching memoization
**Results Found**: 15

### Result 1
- **Name**: `Mathlib.Meta.FunProp.cacheResult`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.FunProp.Core`
- **Relevance Score**: 96.46/100 (distance: 0.0354)
- **Signature**: ` (e : Expr) (r : Result) : FunPropM Result`
- **Type Signature**: `Lean.Expr → Mathlib.Meta.FunProp.Result → Mathlib.Meta.FunProp.FunPropM Mathlib.Meta.FunProp.Result`
- **Description**: Caching a result without subgoals in the `fun_prop` tactic - The function `cacheResult` takes an expression `e` and a result `r` and, if `r` has no remaining subgoals, stores the pair `(e, r)` in a cache within the `FunPropM` monad.

### Result 2
- **Name**: `memoFix`
- **Type**: opaque
- **Library**: Mathlib
- **Module**: `Mathlib.Util.MemoFix`
- **Relevance Score**: 95.11/100 (distance: 0.0489)
- **Signature**: ` {α : Type u} {β : Type v} [Nonempty β] (f : (α → β) → (α → β)) : α → β`
- **Type Signature**: `{α : Type u} → {β : Type v} → [Nonempty β] → ((α → β) → α → β) → α → β`
- **Description**: Memoized Fixed-Point Function - Given a nonempty type $\beta$ and a function $f \colon (\alpha \to \beta) \to (\alpha \to \beta)$, the function $\text{memoFix}(f) \colon \alpha \to \beta$ computes the least fixed point of $f$ with memoization, caching previously computed values for efficiency. This is particularly useful for recursive computations where the same inputs may be processed multiple times, such as in tree traversals.

### Result 3
- **Name**: `Mathlib.Meta.FunProp.cacheFailure`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.FunProp.Core`
- **Relevance Score**: 90.67/100 (distance: 0.0933)
- **Signature**: ` (e : Expr) : FunPropM Unit`
- **Type Signature**: `Lean.Expr → Mathlib.Meta.FunProp.FunPropM Unit`
- **Description**: Cache for failed goals in `fun_prop` - A function that stores the expression `e` in a cache of failed goals, so that the `fun_prop` tactic can fail quickly when encountering the same goal again.

### Result 4
- **Name**: `Mathlib.Tactic.CC.CCM.mkCCHCongrTheorem`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.CC.MkProof`
- **Relevance Score**: 88.16/100 (distance: 0.1184)
- **Signature**: ` (fn : Expr) (nargs : Nat) : CCM (Option CCCongrTheorem)`
- **Type Signature**: `Lean.Expr → Nat → Mathlib.Tactic.CC.CCM (Option Mathlib.Tactic.CC.CCCongrTheorem)`
- **Description**: Generate heterogeneous congruence theorem - Given a function expression `fn` and a natural number `nargs`, this function attempts to generate a congruence theorem for `fn` with `nargs` arguments, supporting heterogeneous equality (`HEq`). It first checks a cache for an existing theorem; if not found, it generates a new one using `mkCCHCongrWithArity`, caches the result (or failure), and returns it.

### Result 5
- **Name**: `Mathlib.Meta.FunProp.State.failureCache`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.FunProp.Types`
- **Relevance Score**: 81.29/100 (distance: 0.1871)
- **Type Signature**: `Mathlib.Meta.FunProp.State → Lean.ExprSet`
- **Description**: *Cannot be generated - this is a meta-programming implementation detail* - *Cannot be generated - this is a meta-programming implementation detail*

**Informal name**
*Cannot be generated - this is a meta-programming implementation detail*

### Result 6
- **Name**: `Mathlib.Tactic.Ring.Cache.mk.noConfusion`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Ring.Basic`
- **Relevance Score**: 78.79/100 (distance: 0.2121)
- **Description**: Injectivity of the `Cache.mk` Constructor - This is an internal technical lemma used in the implementation of the `ring` tactic, which states that the `noConfusion` property holds for the constructor `mk` of the `Cache` structure. Specifically, it asserts that if two instances of `Cache.mk` are equal, then their corresponding arguments are equal.  

**Informal name**  
Injectivity of the `Cache.mk` Constructor

### Result 7
- **Name**: `Mathlib.Tactic.GeneralizeProofs.abstractProofs`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.GeneralizeProofs`
- **Relevance Score**: 78.4/100 (distance: 0.2160)
- **Signature**: ` (e : Expr) (ty? : Option Expr) : MAbs Expr`
- **Type Signature**: `Lean.Expr → Option Lean.Expr → Mathlib.Tactic.GeneralizeProofs.MAbs Lean.Expr`
- **Description**: Proof Abstraction in Expressions - The function `abstractProofs` takes an expression `e` and an optional expected type `ty?`, and recursively abstracts all proof subterms in `e` that are of the form `f a₁ ... aₙ` where `f` is a term not containing any bound variables and each `aᵢ` is a bound variable (i.e., a variable not present in the initial local context). Each such proof is replaced by a new local hypothesis, and the abstracted proofs are recorded in the state. The function propagates expected types to ensure type correctness, and it avoids abstracting proofs that depend on non-bound variables when the `abstract` configuration flag is false.

### Result 8
- **Name**: `Mathlib.Meta.FunProp.State.cache`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.FunProp.Types`
- **Relevance Score**: 77.46/100 (distance: 0.2254)
- **Type Signature**: `Mathlib.Meta.FunProp.State → Lean.Meta.Simp.Cache`
- **Description**: Cache Component in Functional Properties State Management - The `cache` component within the state management system of the functional properties (`funProp`) environment extension in Mathlib's metaprogramming framework.

**Informal name:**
Cache Component in Functional Properties State Management

**Explanation:**
Since this appears to be an implementation detail rather than a mathematical concept, the informal statement describes its role within the system rather than providing a mathematical characterization. The name reflects that this is a cache mechanism within the state management of the functional properties extension.

### Result 9
- **Name**: `Mathlib.Tactic.Propose.proposeLemmas`
- **Type**: opaque
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 76.49/100 (distance: 0.2351)
- **Signature**: ` : DeclCache (DiscrTree Name)`
- **Type Signature**: `Batteries.Tactic.DeclCache (Lean.Meta.DiscrTree Lean.Name)`
- **Description**: Lemma Cache for Forward Reasoning Tactics - The declaration cache `proposeLemmas` maintains a discrimination tree of lemma names that can be used by the `have?` tactic to suggest relevant lemmas based on given hypotheses.

### Result 10
- **Name**: `Mathlib.Tactic.TermCongr.M`
- **Type**: abbrev
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.TermCongr`
- **Relevance Score**: 75.2/100 (distance: 0.2480)
- **Type Signature**: `Type → Type`
- **Description**: Monad for Caching Congruence Results in Congruence Quotation Tactics - The abbreviation `Mathlib.Tactic.TermCongr.M` denotes a monad used in the auxiliary function `mkCongrOfAux` for caching congruence results (`CongrResult`).

### Result 11
- **Name**: `Mathlib.Tactic.CC.CCM.getCache`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.CC.MkProof`
- **Relevance Score**: 73.26/100 (distance: 0.2674)
- **Signature**: ` : CCM CCCongrTheoremCache`
- **Type Signature**: `Mathlib.Tactic.CC.CCM Mathlib.Tactic.CC.CCCongrTheoremCache`
- **Description**: Retrieve congruence closure theorem cache - This function retrieves the congruence closure theorem cache from the current state of the congruence closure monad.

### Result 12
- **Name**: `Mathlib.Meta.FunProp.State.mk.sizeOf_spec`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.FunProp.Types`
- **Relevance Score**: 70.9/100 (distance: 0.2910)
- **Description**: N/A - N/A  

**Informal name**  
N/A  

**Explanation**  
The provided input does not contain a formal mathematical theorem or definition. The “formal statement” field is empty, and the surrounding information describes a Lean metaprogramming environment extension (`funProp`) rather than a mathematical result. Therefore, no meaningful informal translation or naming can be produced.

### Result 13
- **Name**: `Mathlib.Tactic.generalizeProofsElab`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.GeneralizeProofs`
- **Relevance Score**: 70.42/100 (distance: 0.2958)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: `generalize_proofs` Tactic - The tactic `generalize_proofs` replaces proof terms occurring in the goal or specified hypotheses with new local hypotheses. This is particularly useful for referring to proofs later in a proof (e.g., when dealing with functions like `Classical.choose` that depend on proofs) and for handling dependent type issues.  

- `generalize_proofs` generalizes proofs in the target.  
- `generalize_proofs at h₁ h₂` generalizes proofs in hypotheses `h₁` and `h₂`.  
- `generalize_proofs at *` generalizes proofs in the entire local context.  
- `generalize_proofs pf₁ pf₂ pf₃` uses names `pf₁`, `pf₂`, and `pf₃` for the generalized proofs (use `_` to leave proofs unnamed).  

If a proof already exists in the local context, it is reused. When generalizing at a hypothesis `h` that is a let-binding, the value is cleared, and duplicates are eliminated. The tactic can abstract proofs under binders (producing universally quantified proofs) and recursively abstract proofs from the types of generalized proofs (controlled via `maxDepth`).  

**Example**:  
Given a goal `[1, 2].nthLe 1 (by simp) = 2`, applying `generalize_proofs h` replaces the proof term `(by simp)` with a hypothesis `h : 1 < [1, 2].length`, resulting in the goal `[1, 2].nthLe 1 h = 2`.

### Result 14
- **Name**: `Mathlib.Tactic.GeneralizeProofs.MAbs`
- **Type**: abbrev
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.GeneralizeProofs`
- **Relevance Score**: 70.25/100 (distance: 0.2975)
- **Type Signature**: `Type → Type`
- **Description**: Proof Abstraction Monad for Generalization - The monad `MAbs` is used to abstract proofs in preparation for generalization. It maintains a cache of expression-type pairs and operates within a reader context (`AContext`) and a state (`AState`). This monad is part of the infrastructure for the `generalize_proofs` tactic, which replaces proof terms in the goal or selected hypotheses with named local hypotheses.

### Result 15
- **Name**: `Mathlib.Tactic.Ring.Cache.recOn`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Ring.Basic`
- **Relevance Score**: 67.23/100 (distance: 0.3277)
- **Description**: Recursion Principle for the Ring Tactic Cache - Given a type `α` equipped with a commutative semiring structure, and given a function `f` that maps each element `x : α` to a proposition `P x`, the principle of recursion on the ring tactic cache states:  
If `P` holds for the base case (the empty cache) and if, whenever `P` holds for a cache `c`, it also holds for the cache obtained by adding a new element `x` to `c`, then `P` holds for every cache.

More formally, let `Cache` be the inductive type representing the ring tactic’s internal cache. For any predicate `P : Cache → Prop`,  
\[
P(\text{empty}) \quad \text{and} \quad \forall (c : \text{Cache}) (x : α),\ P(c) \rightarrow P(\text{add}\ x\ c)
\]  
implies  
\[
\forall (c : \text{Cache}),\ P(c).
\]

**Informal name**  
Recursion Principle for the Ring Tactic Cache

---

## Query 5: modal logic proof search
**Results Found**: 15

### Result 1
- **Name**: `Mathlib.Tactic.ITauto.search`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 96.32/100 (distance: 0.0368)
- **Type Signature**: `Mathlib.Tactic.ITauto.Context → Mathlib.Tactic.ITauto.IProp → StateM Nat (Prod Bool Mathlib.Tactic.ITauto.Proof)`
- **Description**: Search phase of the G4ip intuitionistic proof procedure - The function `search` implements the search phase of the `G4ip` algorithm for intuitionistic propositional logic. Given a proof context `Γ` (a set of assumptions with their proofs) and a goal proposition `A`, it returns a pair `(b, p)` where `b` is a Boolean indicating success and `p` is a proof object for the goal, or fails if no proof is found. The search phase applies level‑1 and level‑3 rules of the algorithm, including the key rule that from `Γ, P, P → A` we can derive `Γ, P, A`.

**Informal name**  
Search phase of the G4ip intuitionistic proof procedure

### Result 2
- **Name**: `Mathlib.Tactic.Propose.propose'`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 95.73/100 (distance: 0.0427)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Forward reasoning lemma search tactic - The tactic `have? using a, b, c` searches for lemmas that utilize each of the local hypotheses `a`, `b`, and `c`, reporting any matches via trace messages. The variant `have? : t using a, b, c` restricts the search to lemmas whose type matches `t` (which may contain placeholders `_`). Additionally, `have?! using a, b, c` not only reports matches but also applies them to the local goal state using the `have` tactic. Unlike `apply?`, this tactic does not consider the current goal, focusing solely on the types of the provided hypotheses.

### Result 3
- **Name**: `Mathlib.Tactic.ITauto.prove`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 94.97/100 (distance: 0.0503)
- **Signature**: `(Γ : Context) (B : IProp) : StateM Nat (Bool`
- **Type Signature**: `Mathlib.Tactic.ITauto.Context → Mathlib.Tactic.ITauto.IProp → StateM Nat (Prod Bool Mathlib.Tactic.ITauto.Proof)`
- **Description**: Proof Search in Intuitionistic Propositional Logic - The function `prove` takes a proof context $\Gamma$ and a propositional formula $B$ in intuitionistic logic, and returns a state monad computation that produces a pair of a Boolean value and a proof term. The Boolean indicates whether the proof search was successful, and the proof term is a valid derivation of $B$ from $\Gamma$ if successful. The algorithm applies intuitionistic proof rules in three levels:  
- Level 1: Validity-preserving rules without splitting (e.g., handling $\top$, $\bot$, $\to$).  
- Level 2: Validity-preserving splitting rules (e.g., splitting conjunctions in goals and disjunctions in hypotheses).  
- Level 3: Non-validity-preserving splitting rules (e.g., case splitting on disjunctions in goals) applied only as a last resort.

### Result 4
- **Name**: `Mathlib.Tactic.Find.tacticFind`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Find`
- **Relevance Score**: 87.06/100 (distance: 0.1294)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Find tactic for applicable lemmas - The `find` tactic searches for lemmas that can be applied to the current goal in a proof context.

### Result 5
- **Name**: `Mathlib.Tactic.TFAE.proveImpl`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.TFAE`
- **Relevance Score**: 85.68/100 (distance: 0.1432)
- **Signature**: `(i j : ℕ) (P P' : Q`
- **Type Signature**: `Array (Prod Nat (Prod Nat Lean.Expr)) →
  Array (Qq.Quoted (Lean.Expr.sort Lean.Level.zero)) →
    Nat →
      Nat →
        (P P' : Qq.Quoted (Lean.Expr.sort Lean.Level.zero)) →
          Lean.Meta.MetaM (Qq.Quoted (Lean.Expr.forallE Lean.Name.anonymous P P' Lean.BinderInfo.default))`
- **Description**: Implication proof in TFAE via depth-first search - The function `proveImpl` attempts to prove the implication \( P_i \to P_j \) between two propositions \( P_i \) and \( P_j \) in a TFAE (The Following Are Equivalent) list, where \( i \) and \( j \) are indices into the list. It uses depth-first search to find a chain of implications connecting \( P_i \) to \( P_j \).

### Result 6
- **Name**: `Mathlib.Tactic.GeneralizeProofs.MAbs.findProof?`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.GeneralizeProofs`
- **Relevance Score**: 84.59/100 (distance: 0.1541)
- **Signature**: ` (prop : Expr) : MAbs (Option Expr)`
- **Type Signature**: `Lean.Expr → Mathlib.Tactic.GeneralizeProofs.MAbs (Option Lean.Expr)`
- **Description**: Proof lookup in generalization context - The function searches for a proof of a proposition `prop` by first checking if it exists in the context of local hypotheses (`propToFVar`), and if not, by looking it up in the stored proof terms (`propToProof`). It returns an optional proof if found.

### Result 7
- **Name**: `Mathlib.Tactic.ITauto.itauto`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 82.78/100 (distance: 0.1722)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Intuitionistic tautology prover (`itauto`) - The `itauto` tactic is a decision procedure for intuitionistic propositional logic. It proves intuitionistic tautologies without using the law of excluded middle (unless the `!` variant is used). The tactic supports all built-in propositional connectives (`True`, `False`, `And`, `Or`, `→`, `Not`, `Iff`, `Xor'`) as well as equality and inequality on propositions (`Eq` and `Ne`). Definitions and quantifiers (`∀`, `∃`) are not supported and must be simplified or instantiated before using the tactic.

The tactic can optionally perform case analysis on specified decidable propositions (via `itauto [a, b]`) or all decidable propositions (via `itauto *`). The `itauto!` variant enables classical reasoning by allowing case splitting on arbitrary propositions.

### Result 8
- **Name**: `Mathlib.Tactic.Find.command#find_`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Find`
- **Relevance Score**: 75.64/100 (distance: 0.2436)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Find command for definitions and lemmas - The `#find` command in Lean is used to search for definitions and lemmas by pattern matching on their types. For example, it can find expressions matching patterns like `_ + _ = _ + _` or `Nat → Nat`.

### Result 9
- **Name**: `Mathlib.Tactic.Find.tactic#find_`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Find`
- **Relevance Score**: 75.35/100 (distance: 0.2465)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Find command for definitions and lemmas - The `#find` command searches for definitions and lemmas in the library by pattern matching on their types. It can be used with various patterns, such as `_ + _ = _ + _` to find commutativity lemmas or `Nat → Nat` to find functions between natural numbers. The command is also available as a tactic within proofs to find applicable lemmas for the current goal.

### Result 10
- **Name**: `Mathlib.Tactic.ITauto.Proof`
- **Type**: inductive
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 73.72/100 (distance: 0.2628)
- **Type Signature**: `Type`
- **Description**: Intuitionistic Propositional Proof - The inductive type `Proof` represents reified proofs in intuitionistic propositional logic, used by the `itauto` decision procedure. It captures valid proof steps according to the G4ip algorithm for intuitionistic tautologies.

### Result 11
- **Name**: `Mathlib.Tactic.ITauto.Proof.recOn`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 73.26/100 (distance: 0.2674)
- **Description**: Recursor for Intuitionistic Propositional Proofs - The `Proof.recOn` function is a recursor for the `Proof` inductive type, which represents reified proofs in intuitionistic propositional logic. Given a proof term `p : Proof`, a motive `m : Proof → Sort u`, and case handlers for each constructor of `Proof`, it constructs a term of type `m p` by pattern‑matching on the structure of `p`.

**Informal name**  
Recursor for Intuitionistic Propositional Proofs

### Result 12
- **Name**: `Mathlib.Tactic.ITauto.Proof.rec`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 68.93/100 (distance: 0.3107)
- **Description**: Recursor for Intuitionistic Propositional Proofs - The `Proof.rec` function is the recursor for the `Proof` type, which represents reified proofs in intuitionistic propositional logic. It allows structural recursion over proofs, enabling the definition of functions or proofs by case analysis on the structure of a `Proof` term.

**Informal name**  
Recursor for Intuitionistic Propositional Proofs

### Result 13
- **Name**: `Mathlib.Tactic.Propose.tacticHave?!:_Using__`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 67.58/100 (distance: 0.3242)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Forward reasoning tactic with lemma suggestion - The tactic `have?!` attempts to find a lemma that utilizes each of the provided local hypotheses `a, b, c`. The variant `have?! : t using a, b, c` restricts the search to lemmas with type `t` (which may contain placeholders `_`). Unlike `apply?`, which performs backward reasoning by looking at the goal, `have?!` focuses on forward reasoning by examining the given hypotheses.

### Result 14
- **Name**: `Mathlib.Meta.FunProp.LambdaTheorem.getProof`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.FunProp.Theorems`
- **Relevance Score**: 65.49/100 (distance: 0.3451)
- **Signature**: ` (thm : LambdaTheorem) : MetaM Expr`
- **Type Signature**: `Mathlib.Meta.FunProp.LambdaTheorem → Lean.Meta.MetaM Lean.Expr`
- **Description**: Proof retrieval for lambda theorem - Given a lambda theorem `thm`, this function returns its proof as a metaprogram expression in the Lean meta-programming context.

### Result 15
- **Name**: `Mathlib.Meta.FunProp.GeneralTheorem.getProof`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.FunProp.Theorems`
- **Relevance Score**: 64.42/100 (distance: 0.3558)
- **Signature**: ` (thm : GeneralTheorem) : MetaM Expr`
- **Type Signature**: `Mathlib.Meta.FunProp.GeneralTheorem → Lean.Meta.MetaM Lean.Expr`
- **Description**: Proof retrieval for function property theorems - Given a general theorem `thm` about function properties, this function retrieves its proof as a metaprogram expression.

---

## Query 6: tableau proof search
**Results Found**: 15

### Result 1
- **Name**: `Mathlib.Tactic.ITauto.search`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 98.79/100 (distance: 0.0121)
- **Type Signature**: `Mathlib.Tactic.ITauto.Context → Mathlib.Tactic.ITauto.IProp → StateM Nat (Prod Bool Mathlib.Tactic.ITauto.Proof)`
- **Description**: Search phase of the G4ip intuitionistic proof procedure - The function `search` implements the search phase of the `G4ip` algorithm for intuitionistic propositional logic. Given a proof context `Γ` (a set of assumptions with their proofs) and a goal proposition `A`, it returns a pair `(b, p)` where `b` is a Boolean indicating success and `p` is a proof object for the goal, or fails if no proof is found. The search phase applies level‑1 and level‑3 rules of the algorithm, including the key rule that from `Γ, P, P → A` we can derive `Γ, P, A`.

**Informal name**  
Search phase of the G4ip intuitionistic proof procedure

### Result 2
- **Name**: `Mathlib.Tactic.Propose.propose'`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 96.91/100 (distance: 0.0309)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Forward reasoning lemma search tactic - The tactic `have? using a, b, c` searches for lemmas that utilize each of the local hypotheses `a`, `b`, and `c`, reporting any matches via trace messages. The variant `have? : t using a, b, c` restricts the search to lemmas whose type matches `t` (which may contain placeholders `_`). Additionally, `have?! using a, b, c` not only reports matches but also applies them to the local goal state using the `have` tactic. Unlike `apply?`, this tactic does not consider the current goal, focusing solely on the types of the provided hypotheses.

### Result 3
- **Name**: `Mathlib.Tactic.ITauto.prove`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 96.62/100 (distance: 0.0338)
- **Signature**: `(Γ : Context) (B : IProp) : StateM Nat (Bool`
- **Type Signature**: `Mathlib.Tactic.ITauto.Context → Mathlib.Tactic.ITauto.IProp → StateM Nat (Prod Bool Mathlib.Tactic.ITauto.Proof)`
- **Description**: Proof Search in Intuitionistic Propositional Logic - The function `prove` takes a proof context $\Gamma$ and a propositional formula $B$ in intuitionistic logic, and returns a state monad computation that produces a pair of a Boolean value and a proof term. The Boolean indicates whether the proof search was successful, and the proof term is a valid derivation of $B$ from $\Gamma$ if successful. The algorithm applies intuitionistic proof rules in three levels:  
- Level 1: Validity-preserving rules without splitting (e.g., handling $\top$, $\bot$, $\to$).  
- Level 2: Validity-preserving splitting rules (e.g., splitting conjunctions in goals and disjunctions in hypotheses).  
- Level 3: Non-validity-preserving splitting rules (e.g., case splitting on disjunctions in goals) applied only as a last resort.

### Result 4
- **Name**: `Mathlib.Tactic.Find.tactic#find_`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Find`
- **Relevance Score**: 92.89/100 (distance: 0.0711)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Find command for definitions and lemmas - The `#find` command searches for definitions and lemmas in the library by pattern matching on their types. It can be used with various patterns, such as `_ + _ = _ + _` to find commutativity lemmas or `Nat → Nat` to find functions between natural numbers. The command is also available as a tactic within proofs to find applicable lemmas for the current goal.

### Result 5
- **Name**: `Mathlib.Tactic.Find.command#find_`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Find`
- **Relevance Score**: 92.58/100 (distance: 0.0742)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Find command for definitions and lemmas - The `#find` command in Lean is used to search for definitions and lemmas by pattern matching on their types. For example, it can find expressions matching patterns like `_ + _ = _ + _` or `Nat → Nat`.

### Result 6
- **Name**: `Mathlib.Tactic.Find.tacticFind`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Find`
- **Relevance Score**: 90.99/100 (distance: 0.0901)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Find tactic for applicable lemmas - The `find` tactic searches for lemmas that can be applied to the current goal in a proof context.

### Result 7
- **Name**: `Mathlib.Tactic.TFAE.dfs`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.TFAE`
- **Relevance Score**: 90.19/100 (distance: 0.0981)
- **Signature**: `(i j : ℕ) (P P' : Q`
- **Type Signature**: `Array (Prod Nat (Prod Nat Lean.Expr)) →
  Array (Qq.Quoted (Lean.Expr.sort Lean.Level.zero)) →
    Nat →
      Nat →
        (P P' : Qq.Quoted (Lean.Expr.sort Lean.Level.zero)) →
          Qq.Quoted P → StateT (Std.HashSet Nat) Lean.Meta.MetaM (Qq.Quoted P')`
- **Description**: Depth-first search for TFAE implications - The function `dfs` uses depth-first search to find a path from proposition `P` to proposition `P'` in a directed graph where nodes correspond to propositions in a TFAE (The Following Are Equivalent) list and edges correspond to known implications between them.

### Result 8
- **Name**: `Mathlib.Explode.explode`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Explode`
- **Relevance Score**: 89.98/100 (distance: 0.1002)
- **Type Signature**: `Lean.Expr → optParam Bool Bool.true → Lean.Meta.MetaM Mathlib.Explode.Entries`
- **Description**: Fitch‑style Proof Table Display Command (`#explode`) - The `#explode` command in Lean displays a Fitch‑style proof table for a given theorem or definition.  

**Informal name**  
Fitch‑style Proof Table Display Command (`#explode`)

### Result 9
- **Name**: `Mathlib.Tactic.ITauto.itauto`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 88.32/100 (distance: 0.1168)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Intuitionistic tautology prover (`itauto`) - The `itauto` tactic is a decision procedure for intuitionistic propositional logic. It proves intuitionistic tautologies without using the law of excluded middle (unless the `!` variant is used). The tactic supports all built-in propositional connectives (`True`, `False`, `And`, `Or`, `→`, `Not`, `Iff`, `Xor'`) as well as equality and inequality on propositions (`Eq` and `Ne`). Definitions and quantifiers (`∀`, `∃`) are not supported and must be simplified or instantiated before using the tactic.

The tactic can optionally perform case analysis on specified decidable propositions (via `itauto [a, b]`) or all decidable propositions (via `itauto *`). The `itauto!` variant enables classical reasoning by allowing case splitting on arbitrary propositions.

### Result 10
- **Name**: `Mathlib.Tactic.Tauto.tautoCore`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Tauto`
- **Relevance Score**: 87.66/100 (distance: 0.1234)
- **Signature**: ` : TacticM Unit`
- **Type Signature**: `Lean.Elab.Tactic.TacticM Unit`
- **Description**: Core loop of the `tauto` tactic - The core loop of the `tauto` tactic repeatedly breaks down propositions until no further progress is made. At each step, it attempts to use `assumption` and `contradiction` to discharge goals immediately. The loop applies introduction of variables, distributes negations in hypotheses using de Morgan’s laws, performs case analysis on conjunctions, disjunctions, existentials, and `False`, and refines disjunctions into implications. It also applies constructors for conjunctions, bi-implications, and `True`. The loop terminates when no subgoals change.

### Result 11
- **Name**: `Mathlib.Tactic.GeneralizeProofs.MAbs.findProof?`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.GeneralizeProofs`
- **Relevance Score**: 86.25/100 (distance: 0.1375)
- **Signature**: ` (prop : Expr) : MAbs (Option Expr)`
- **Type Signature**: `Lean.Expr → Mathlib.Tactic.GeneralizeProofs.MAbs (Option Lean.Expr)`
- **Description**: Proof lookup in generalization context - The function searches for a proof of a proposition `prop` by first checking if it exists in the context of local hypotheses (`propToFVar`), and if not, by looking it up in the stored proof terms (`propToProof`). It returns an optional proof if found.

### Result 12
- **Name**: `Mathlib.Tactic.TFAE.proveImpl`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.TFAE`
- **Relevance Score**: 85.0/100 (distance: 0.1500)
- **Signature**: `(i j : ℕ) (P P' : Q`
- **Type Signature**: `Array (Prod Nat (Prod Nat Lean.Expr)) →
  Array (Qq.Quoted (Lean.Expr.sort Lean.Level.zero)) →
    Nat →
      Nat →
        (P P' : Qq.Quoted (Lean.Expr.sort Lean.Level.zero)) →
          Lean.Meta.MetaM (Qq.Quoted (Lean.Expr.forallE Lean.Name.anonymous P P' Lean.BinderInfo.default))`
- **Description**: Implication proof in TFAE via depth-first search - The function `proveImpl` attempts to prove the implication \( P_i \to P_j \) between two propositions \( P_i \) and \( P_j \) in a TFAE (The Following Are Equivalent) list, where \( i \) and \( j \) are indices into the list. It uses depth-first search to find a chain of implications connecting \( P_i \) to \( P_j \).

### Result 13
- **Name**: `Mathlib.Tactic.Linarith.SimplexAlgorithm.Tableau.mk.inj`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Linarith.Oracle.SimplexAlgorithm.Datatypes`
- **Relevance Score**: 81.52/100 (distance: 0.1848)
- **Type Signature**: `∀ {matType : Nat → Nat → Type} {inst : Mathlib.Tactic.Linarith.SimplexAlgorithm.UsableInSimplexAlgorithm matType}
  {basic free : Array Nat} {mat : matType basic.size free.size} {basic_1 free_1 : Array Nat}
  {mat_1 : matType basic_1.size free_1.size},
  Eq { basic := basic, free := free, mat := mat } { basic := basic_1, free := free_1, mat := mat_1 } →
    And (Eq basic basic_1) (And (Eq free free_1) (HEq mat mat_1))`
- **Description**: Injectivity of Tableau Construction - If two tableaux constructed via `Tableau.mk` are equal, then their corresponding data fields are equal.  

**Informal name**  
Injectivity of Tableau Construction

### Result 14
- **Name**: `Mathlib.Tactic.Tauto.Config.recOn`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Tauto`
- **Relevance Score**: 81.41/100 (distance: 0.1859)
- **Type Signature**: `{motive : Mathlib.Tactic.Tauto.Config → Sort u} → (t : Mathlib.Tactic.Tauto.Config) → motive { } → motive t`
- **Description**: Tauto Tactic for Propositional Logic - The `tauto` tactic is a decision procedure for propositional logic (including intuitionistic logic) that handles logical connectives and quantifiers. It automatically proves tautologies and valid implications by performing a truth-table-like search, without requiring user guidance.

**Informal name**  
Tauto Tactic for Propositional Logic

### Result 15
- **Name**: `Mathlib.Tactic.Linarith.SimplexAlgorithm.Tableau.casesOn`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Linarith.Oracle.SimplexAlgorithm.Datatypes`
- **Relevance Score**: 78.27/100 (distance: 0.2173)
- **Type Signature**: `{matType : Nat → Nat → Type} →
  [inst : Mathlib.Tactic.Linarith.SimplexAlgorithm.UsableInSimplexAlgorithm matType] →
    {motive : Mathlib.Tactic.Linarith.SimplexAlgorithm.Tableau matType → Sort u} →
      (t : Mathlib.Tactic.Linarith.SimplexAlgorithm.Tableau matType) →
        ((basic free : Array Nat) →
            (mat : matType basic.size free.size) → motive { basic := basic, free := free, mat := mat }) →
          motive t`
- **Description**: Case Analysis on Simplex Tableau States - Let `T` be a tableau in the simplex algorithm. For any proposition `P`, if `P` holds for both the case where `T` is `dead` and the case where `T` is `alive` (with its associated data), then `P` holds for `T`.

**Informal name**  
Case Analysis on Simplex Tableau States

---

## Query 7: backward chaining proof search
**Results Found**: 15

### Result 1
- **Name**: `Mathlib.Tactic.Propose.propose'`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 95.26/100 (distance: 0.0474)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Forward reasoning lemma search tactic - The tactic `have? using a, b, c` searches for lemmas that utilize each of the local hypotheses `a`, `b`, and `c`, reporting any matches via trace messages. The variant `have? : t using a, b, c` restricts the search to lemmas whose type matches `t` (which may contain placeholders `_`). Additionally, `have?! using a, b, c` not only reports matches but also applies them to the local goal state using the `have` tactic. Unlike `apply?`, this tactic does not consider the current goal, focusing solely on the types of the provided hypotheses.

### Result 2
- **Name**: `Mathlib.Tactic.Propose.propose`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 93.99/100 (distance: 0.0601)
- **Type Signature**: `Lean.Meta.DiscrTree Lean.Name →
  Lean.Expr → Array Lean.Expr → optParam Nat 15 → Lean.Meta.MetaM (Array (Prod Lean.Name Lean.Expr))`
- **Description**: Forward Reasoning Lemma Suggestion: `have? using` - The tactic `propose` (invoked as `have? using a, b, c`) attempts to find a lemma that uses all the specified local hypotheses `a, b, c`. The variant `have? : t using a, b, c` restricts the search to lemmas whose type matches `t` (which may contain placeholders `_`). Unlike `apply?`, which performs backward reasoning by matching the goal, `propose` focuses on forward reasoning by analyzing the hypotheses.

**Informal name**  
Forward Reasoning Lemma Suggestion: `have? using`

### Result 3
- **Name**: `List.Chain.backwards_induction_head`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Data.List.Chain`
- **Relevance Score**: 93.81/100 (distance: 0.0619)
- **Type Signature**: `∀ {α : Type u} {r : α → α → Prop} {a b : α} (p : α → Prop) (l : List α),
  List.IsChain r (List.cons a l) → Eq ((List.cons a l).getLast ⋯) b → (∀ ⦃x y : α⦄, r x y → p y → p x) → p b → p a`
- **Description**: Backward Induction on Chain Head: $p(a_1)$ from $p(b)$ via Relation $r$ - Let $r$ be a relation on a type $\alpha$, and let $[a_2, \ldots, a_n]$ be a list forming a chain starting at $a_1$ with respect to $r$ (i.e., $r a_1 a_2$, $r a_2 a_3$, $\ldots$, $r a_{n-1} a_n$ hold). Let $b$ be the last element of the chain $a_1 :: [a_2, \ldots, a_n]$. Given a predicate $p : \alpha \to \mathrm{Prop}$ that holds at $b$ and satisfies the backward propagation property that for any $x, y \in \alpha$, if $r x y$ and $p y$ hold, then $p x$ holds, then $p$ holds at the head element $a_1$ of the chain.

### Result 4
- **Name**: `List.IsChain.backwards_induction`
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.List.Chain`
- **Relevance Score**: 93.67/100 (distance: 0.0633)
- **Signature**: ` (p : α → Prop) (l : List α) (h : IsChain r l) (carries : ∀ ⦃x y : α⦄, r x y → p y → p x)
  (final : (lne : l ≠ []) → p (getLast l lne)) : ∀ i ∈ l, p i`
- **Type Signature**: `∀ {α : Type u} {r : α → α → Prop} (p : α → Prop) (l : List α),
  List.IsChain r l →
    (∀ ⦃x y : α⦄, r x y → p y → p x) →
      (∀ (lne : Ne l List.nil), p (l.getLast lne)) → ∀ (i : α), List.instMembership.mem l i → p i`
- **Description**: Backward Induction along a Chain - Let $r$ be a binary relation on a type $\alpha$, and let $l$ be a list of elements of $\alpha$ that forms an $r$-chain. Suppose a predicate $p$ on $\alpha$ satisfies:  
- For any $x, y \in \alpha$, if $r(x, y)$ holds, then $p(y)$ implies $p(x)$.  
- If $l$ is nonempty, then $p$ holds for the last element of $l$.  

Then $p$ holds for every element $i$ in $l$.

### Result 5
- **Name**: `List.IsChain.backwards_cons_induction_head`
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.List.Chain`
- **Relevance Score**: 93.39/100 (distance: 0.0661)
- **Signature**: ` (p : α → Prop) (l : List α) (h : IsChain r (a :: l)) (hb : getLast (a :: l) (cons_ne_nil _ _) = b)
  (carries : ∀ ⦃x y : α⦄, r x y → p y → p x) (final : p b) : p a`
- **Type Signature**: `∀ {α : Type u} {r : α → α → Prop} {a b : α} (p : α → Prop) (l : List α),
  List.IsChain r (List.cons a l) → Eq ((List.cons a l).getLast ⋯) b → (∀ ⦃x y : α⦄, r x y → p y → p x) → p b → p a`
- **Description**: Backward Induction along a Chain: Base Case - Let $r$ be a binary relation on a type $\alpha$, and let $a$ be an element of $\alpha$ and $l$ a list of elements of $\alpha$ such that the list $a :: l$ (i.e., the list starting with $a$ and followed by $l$) forms an $r$-chain. Suppose $b$ is the last element of $a :: l$, and let $p$ be a predicate on $\alpha$ satisfying:  
- For any $x, y \in \alpha$, if $r(x, y)$ holds, then $p(y)$ implies $p(x)$.  
- The predicate $p$ holds for $b$.  

Then $p$ holds for $a$.

### Result 6
- **Name**: `List.Chain.backwards_induction`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Data.List.Chain`
- **Relevance Score**: 91.55/100 (distance: 0.0845)
- **Type Signature**: `∀ {α : Type u} {r : α → α → Prop} {a b : α} (p : α → Prop) (l : List α),
  List.IsChain r (List.cons a l) →
    Eq ((List.cons a l).getLast ⋯) b →
      (∀ ⦃x y : α⦄, r x y → p y → p x) → p b → ∀ (i : α), List.instMembership.mem (List.cons a l) i → p i`
- **Description**: Backward Induction Principle for Chain Propagation - Let $r$ be a relation on a type $\alpha$, and let $[a_2, \ldots, a_n]$ be a list forming a chain starting at $a_1$ with respect to $r$ (i.e., $r a_1 a_2$, $r a_2 a_3$, $\ldots$, $r a_{n-1} a_n$ hold). Let $b$ be the last element of the chain $a_1 :: [a_2, \ldots, a_n]$. Given a predicate $p : \alpha \to \mathrm{Prop}$ that holds at $b$ and satisfies the backward propagation property that for any $x, y \in \alpha$, if $r x y$ and $p y$ hold, then $p x$ holds, then $p$ holds for every element in the chain $a_1 :: [a_2, \ldots, a_n]$.

### Result 7
- **Name**: `Mathlib.Tactic.ITauto.prove`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 91.49/100 (distance: 0.0851)
- **Signature**: `(Γ : Context) (B : IProp) : StateM Nat (Bool`
- **Type Signature**: `Mathlib.Tactic.ITauto.Context → Mathlib.Tactic.ITauto.IProp → StateM Nat (Prod Bool Mathlib.Tactic.ITauto.Proof)`
- **Description**: Proof Search in Intuitionistic Propositional Logic - The function `prove` takes a proof context $\Gamma$ and a propositional formula $B$ in intuitionistic logic, and returns a state monad computation that produces a pair of a Boolean value and a proof term. The Boolean indicates whether the proof search was successful, and the proof term is a valid derivation of $B$ from $\Gamma$ if successful. The algorithm applies intuitionistic proof rules in three levels:  
- Level 1: Validity-preserving rules without splitting (e.g., handling $\top$, $\bot$, $\to$).  
- Level 2: Validity-preserving splitting rules (e.g., splitting conjunctions in goals and disjunctions in hypotheses).  
- Level 3: Non-validity-preserving splitting rules (e.g., case splitting on disjunctions in goals) applied only as a last resort.

### Result 8
- **Name**: `Mathlib.Tactic.ITauto.search`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 91.05/100 (distance: 0.0895)
- **Type Signature**: `Mathlib.Tactic.ITauto.Context → Mathlib.Tactic.ITauto.IProp → StateM Nat (Prod Bool Mathlib.Tactic.ITauto.Proof)`
- **Description**: Search phase of the G4ip intuitionistic proof procedure - The function `search` implements the search phase of the `G4ip` algorithm for intuitionistic propositional logic. Given a proof context `Γ` (a set of assumptions with their proofs) and a goal proposition `A`, it returns a pair `(b, p)` where `b` is a Boolean indicating success and `p` is a proof object for the goal, or fails if no proof is found. The search phase applies level‑1 and level‑3 rules of the algorithm, including the key rule that from `Γ, P, P → A` we can derive `Γ, P, A`.

**Informal name**  
Search phase of the G4ip intuitionistic proof procedure

### Result 9
- **Name**: `List.IsChain.backwards_cons_induction`
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.List.Chain`
- **Relevance Score**: 90.93/100 (distance: 0.0907)
- **Signature**: ` (p : α → Prop) (l : List α) (h : IsChain r (a :: l)) (hb : getLast (a :: l) (cons_ne_nil _ _) = b)
  (carries : ∀ ⦃x y : α⦄, r x y → p y → p x) (final : p b) : ∀ i ∈ a :: l, p i`
- **Type Signature**: `∀ {α : Type u} {r : α → α → Prop} {a b : α} (p : α → Prop) (l : List α),
  List.IsChain r (List.cons a l) →
    Eq ((List.cons a l).getLast ⋯) b →
      (∀ ⦃x y : α⦄, r x y → p y → p x) → p b → ∀ (i : α), List.instMembership.mem (List.cons a l) i → p i`
- **Description**: Backward Induction along a Chain Starting with a Cons - Let $r$ be a binary relation on a type $\alpha$, and let $a$ be an element of $\alpha$ and $l$ a list of elements of $\alpha$ such that the list $a :: l$ (i.e., the list starting with $a$ and followed by $l$) forms an $r$-chain. Suppose $b$ is the last element of $a :: l$, and let $p$ be a predicate on $\alpha$ satisfying:  
- For any $x, y \in \alpha$, if $r(x, y)$ holds, then $p(y)$ implies $p(x)$.  
- The predicate $p$ holds for $b$.  

Then $p$ holds for every element $i$ in $a :: l$.

### Result 10
- **Name**: `List.IsChain.backwards_concat_induction`
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.List.Chain`
- **Relevance Score**: 89.48/100 (distance: 0.1052)
- **Signature**: ` (p : α → Prop) (l : List α) (h : IsChain r (l ++ [b])) (carries : ∀ ⦃x y : α⦄, r x y → p y → p x) (final : p b) :
  ∀ i ∈ l, p i`
- **Type Signature**: `∀ {α : Type u} {r : α → α → Prop} {b : α} (p : α → Prop) (l : List α),
  List.IsChain r (instHAppendOfAppend.hAppend l (List.cons b List.nil)) →
    (∀ ⦃x y : α⦄, r x y → p y → p x) → p b → ∀ (i : α), List.instMembership.mem l i → p i`
- **Description**: Backward Induction along a Chain via Concatenation - Let $r$ be a binary relation on a type $\alpha$, and let $l$ be a list of elements of $\alpha$ such that the concatenated list $l \mathbin{+\!\!+} [b]$ forms an $r$-chain. Suppose a predicate $p$ on $\alpha$ satisfies:  
- For any $x, y \in \alpha$, if $r(x, y)$ holds, then $p(y)$ implies $p(x)$.  
- The predicate $p$ holds for $b$.  

Then $p$ holds for every element $i$ in $l$.

### Result 11
- **Name**: `Mathlib.Tactic.TFAE.dfs`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.TFAE`
- **Relevance Score**: 85.59/100 (distance: 0.1441)
- **Signature**: `(i j : ℕ) (P P' : Q`
- **Type Signature**: `Array (Prod Nat (Prod Nat Lean.Expr)) →
  Array (Qq.Quoted (Lean.Expr.sort Lean.Level.zero)) →
    Nat →
      Nat →
        (P P' : Qq.Quoted (Lean.Expr.sort Lean.Level.zero)) →
          Qq.Quoted P → StateT (Std.HashSet Nat) Lean.Meta.MetaM (Qq.Quoted P')`
- **Description**: Depth-first search for TFAE implications - The function `dfs` uses depth-first search to find a path from proposition `P` to proposition `P'` in a directed graph where nodes correspond to propositions in a TFAE (The Following Are Equivalent) list and edges correspond to known implications between them.

### Result 12
- **Name**: `Mathlib.Tactic.TFAE.proveImpl`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.TFAE`
- **Relevance Score**: 85.1/100 (distance: 0.1490)
- **Signature**: `(i j : ℕ) (P P' : Q`
- **Type Signature**: `Array (Prod Nat (Prod Nat Lean.Expr)) →
  Array (Qq.Quoted (Lean.Expr.sort Lean.Level.zero)) →
    Nat →
      Nat →
        (P P' : Qq.Quoted (Lean.Expr.sort Lean.Level.zero)) →
          Lean.Meta.MetaM (Qq.Quoted (Lean.Expr.forallE Lean.Name.anonymous P P' Lean.BinderInfo.default))`
- **Description**: Implication proof in TFAE via depth-first search - The function `proveImpl` attempts to prove the implication \( P_i \to P_j \) between two propositions \( P_i \) and \( P_j \) in a TFAE (The Following Are Equivalent) list, where \( i \) and \( j \) are indices into the list. It uses depth-first search to find a chain of implications connecting \( P_i \) to \( P_j \).

### Result 13
- **Name**: `Mathlib.Tactic.Propose.tacticHave!?:_Using__`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 83.22/100 (distance: 0.1678)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Forward reasoning lemma suggestion tactic - The tactic `have!? : t using a, b, c` attempts to find and apply a lemma that uses all of the local hypotheses `a`, `b`, and `c`, optionally restricted to lemmas whose type matches `t` (which may contain placeholders `_`). Unlike `apply?`, this tactic focuses on forward reasoning by examining the available hypotheses rather than working backward from the current goal.

### Result 14
- **Name**: `Mathlib.Tactic.Tauto.tautoCore`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Tauto`
- **Relevance Score**: 80.44/100 (distance: 0.1956)
- **Signature**: ` : TacticM Unit`
- **Type Signature**: `Lean.Elab.Tactic.TacticM Unit`
- **Description**: Core loop of the `tauto` tactic - The core loop of the `tauto` tactic repeatedly breaks down propositions until no further progress is made. At each step, it attempts to use `assumption` and `contradiction` to discharge goals immediately. The loop applies introduction of variables, distributes negations in hypotheses using de Morgan’s laws, performs case analysis on conjunctions, disjunctions, existentials, and `False`, and refines disjunctions into implications. It also applies constructors for conjunctions, bi-implications, and `True`. The loop terminates when no subgoals change.

### Result 15
- **Name**: `Mathlib.Tactic.Propose.tacticHave?!:_Using__`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 77.18/100 (distance: 0.2282)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Forward reasoning tactic with lemma suggestion - The tactic `have?!` attempts to find a lemma that utilizes each of the provided local hypotheses `a, b, c`. The variant `have?! : t using a, b, c` restricts the search to lemmas with type `t` (which may contain placeholders `_`). Unlike `apply?`, which performs backward reasoning by looking at the goal, `have?!` focuses on forward reasoning by examining the given hypotheses.

---

## Query 8: proof state evaluation heuristics
**Results Found**: 15

### Result 1
- **Name**: `Mathlib.Tactic.Hint.hint`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Hint`
- **Relevance Score**: 78.92/100 (distance: 0.2108)
- **Signature**: ` (stx : Syntax) : TacticM Unit`
- **Type Signature**: `Lean.Syntax → Lean.Elab.Tactic.TacticM Unit`
- **Description**: Hint Tactic - The `hint` tactic runs all tactics registered via `register_hint` on the current goal, reporting successful ones with a "Try these:" suggestion. If a tactic succeeds and closes the goal, subsequent tactics are not executed.

### Result 2
- **Name**: `Mathlib.Tactic.ITauto.prove`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 76.21/100 (distance: 0.2379)
- **Signature**: `(Γ : Context) (B : IProp) : StateM Nat (Bool`
- **Type Signature**: `Mathlib.Tactic.ITauto.Context → Mathlib.Tactic.ITauto.IProp → StateM Nat (Prod Bool Mathlib.Tactic.ITauto.Proof)`
- **Description**: Proof Search in Intuitionistic Propositional Logic - The function `prove` takes a proof context $\Gamma$ and a propositional formula $B$ in intuitionistic logic, and returns a state monad computation that produces a pair of a Boolean value and a proof term. The Boolean indicates whether the proof search was successful, and the proof term is a valid derivation of $B$ from $\Gamma$ if successful. The algorithm applies intuitionistic proof rules in three levels:  
- Level 1: Validity-preserving rules without splitting (e.g., handling $\top$, $\bot$, $\to$).  
- Level 2: Validity-preserving splitting rules (e.g., splitting conjunctions in goals and disjunctions in hypotheses).  
- Level 3: Non-validity-preserving splitting rules (e.g., case splitting on disjunctions in goals) applied only as a last resort.

### Result 3
- **Name**: `Lean.Elab.runTactic'`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Lean.Elab.Tactic.Meta`
- **Relevance Score**: 72.02/100 (distance: 0.2798)
- **Type Signature**: `Lean.MVarId →
  Lean.Syntax →
    optParam Lean.Elab.Term.Context { } → optParam Lean.Elab.Term.State { } → Lean.Meta.MetaM (List Lean.MVarId)`
- **Description**: *Cannot be determined - this appears to be a Lean implementation detail rather than a mathematical theorem.* - *Cannot be determined - this appears to be a Lean implementation detail rather than a mathematical theorem.*

**Informal name**
*Cannot be determined - this appears to be a Lean implementation detail rather than a mathematical theorem.*

### Result 4
- **Name**: `Mathlib.Tactic.GeneralizeProofs.GState`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.GeneralizeProofs`
- **Relevance Score**: 69.6/100 (distance: 0.3040)
- **Type Signature**: `Type`
- **Description**: Generalize Proofs State - The structure representing the internal state used by the `generalize_proofs` tactic's monad. This state tracks information needed during the process of generalizing proof terms in the goal or hypotheses, replacing them with named local hypotheses.

### Result 5
- **Name**: `Mathlib.PrintSorries.State.sorries`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Util.PrintSorries`
- **Relevance Score**: 62.25/100 (distance: 0.3775)
- **Type Signature**: `Mathlib.PrintSorries.State → Std.HashSet Lean.Expr`
- **Description**: Tracking Unfinished Proofs in Lean - (No mathematical content to translate; this is a Lean metaprogramming definition for tracking unfinished proofs.)

**Informal name**  
Tracking Unfinished Proofs in Lean

### Result 6
- **Name**: `Mathlib.Meta.FunProp.tryTheoremWithHint?`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.FunProp.Core`
- **Relevance Score**: 59.27/100 (distance: 0.4073)
- **Signature**: `(e : Expr) (thmOrigin : Origin)
    (hint : Array (Nat`
- **Type Signature**: `Lean.Expr →
  Mathlib.Meta.FunProp.Origin →
    Array (Prod Nat Lean.Expr) →
      (Lean.Expr → Mathlib.Meta.FunProp.FunPropM (Option Mathlib.Meta.FunProp.Result)) →
        optParam Bool Bool.false → Mathlib.Meta.FunProp.FunPropM (Option Mathlib.Meta.FunProp.Result)`
- **Description**: Theorem application with hints for function properties - The function `tryTheoremWithHint?` takes an expression `e`, a theorem identifier `thmOrigin` (classifying the source of the theorem), and an array of natural numbers `hint` (indicating which arguments to prioritize during synthesis). It attempts to apply the theorem specified by `thmOrigin` to prove a function property for `e`, using the hints to guide argument synthesis.

### Result 7
- **Name**: `Mathlib.Tactic.GeneralizeProofs.AState`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.GeneralizeProofs`
- **Relevance Score**: 56.99/100 (distance: 0.4301)
- **Type Signature**: `Type`
- **Description**: Generalize Proofs State - The structure representing the state used in the `generalize_proofs` tactic's monadic context, which tracks information needed for generalizing proof terms in the goal or hypotheses. This state is used internally by the tactic to manage the process of replacing proof terms with named hypotheses.

### Result 8
- **Name**: `Mathlib.Tactic.GeneralizeProofs.GState.casesOn`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.GeneralizeProofs`
- **Relevance Score**: 56.03/100 (distance: 0.4397)
- **Type Signature**: `{motive : Mathlib.Tactic.GeneralizeProofs.GState → Sort u} →
  (t : Mathlib.Tactic.GeneralizeProofs.GState) →
    ((propToFVar : Lean.ExprMap Lean.Expr) → motive { propToFVar := propToFVar }) → motive t`
- **Description**: Dependent Case Analysis for Generalized Proof State - The function `casesOn` for the generalized proof state `GState` is defined as follows:  
Given a `GState` term `g` and a function `f` that maps each constructor of `GState` to a value in a type `motive`, the expression `g.casesOn f` returns the result of applying `f` to the appropriate constructor of `g`. This is a dependent elimination principle that allows pattern-matching on `GState` while specifying the motive for each case.

**Informal name**  
Dependent Case Analysis for Generalized Proof State

### Result 9
- **Name**: `Mathlib.Meta.FunProp.State.rec`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.FunProp.Types`
- **Relevance Score**: 54.29/100 (distance: 0.4571)
- **Description**: Recursive Definition of the `fun_prop` Tactic State - The structure `State` is defined recursively to store the state of the `fun_prop` tactic during its operation.

**Informal name**  
Recursive Definition of the `fun_prop` Tactic State

### Result 10
- **Name**: `Mathlib.Tactic.Find.tacticFind`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Find`
- **Relevance Score**: 46.88/100 (distance: 0.5312)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Find tactic for applicable lemmas - The `find` tactic searches for lemmas that can be applied to the current goal in a proof context.

### Result 11
- **Name**: `Mathlib.Tactic.GeneralizeProofs.GState.rec`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.GeneralizeProofs`
- **Relevance Score**: 46.49/100 (distance: 0.5351)
- **Type Signature**: `{motive : Mathlib.Tactic.GeneralizeProofs.GState → Sort u} →
  ((propToFVar : Lean.ExprMap Lean.Expr) → motive { propToFVar := propToFVar }) →
    (t : Mathlib.Tactic.GeneralizeProofs.GState) → motive t`
- **Description**: Recursive constructor for the internal state of the `generalize_proofs` tactic - This is a recursive constructor for the internal state used by the `generalize_proofs` tactic. It does not correspond to a mathematical theorem but to a Lean‑specific data structure that tracks the hypotheses introduced during the execution of the tactic.

**Informal name**  
Recursive constructor for the internal state of the `generalize_proofs` tactic

### Result 12
- **Name**: `Mathlib.Tactic.GeneralizeProofs.AState.noConfusion`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.GeneralizeProofs`
- **Relevance Score**: 46.1/100 (distance: 0.5390)
- **Type Signature**: `{P : Sort u} →
  {x1 x2 : Mathlib.Tactic.GeneralizeProofs.AState} →
    Eq x1 x2 → Mathlib.Tactic.GeneralizeProofs.AState.noConfusionType P x1 x2`
- **Description**: No‑Confusion for Proofs in the `generalize_proofs` Tactic State - The `noConfusion` property for the `AState` structure in the `generalize_proofs` tactic ensures that distinct proofs of the same proposition are treated as equal when they appear in the state. Specifically, if two proofs of a proposition `P` are used in the same context, they are identified to avoid issues with dependent types.

**Informal name**  
No‑Confusion for Proofs in the `generalize_proofs` Tactic State

### Result 13
- **Name**: `Mathlib.PrintSorries.State.recOn`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Util.PrintSorries`
- **Relevance Score**: 42.25/100 (distance: 0.5775)
- **Type Signature**: `{motive : Mathlib.PrintSorries.State → Sort u} →
  (t : Mathlib.PrintSorries.State) →
    ((visited : Lean.NameSet) →
        (sorries : Std.HashSet Lean.Expr) →
          (sorryMsgs : Array Lean.MessageData) →
            motive { visited := visited, sorries := sorries, sorryMsgs := sorryMsgs }) →
      motive t`
- **Description**: Recursor for the `State` Structure in the `PrintSorries` Module - This is a Lean internal recursive elimination rule for the `State` structure used in tracking unfinished proofs (`sorry`s). It is not a mathematical theorem but a technical tool for programmatically analyzing dependencies on incomplete parts of a formalization.

**Informal name**  
Recursor for the `State` Structure in the `PrintSorries` Module

### Result 14
- **Name**: `Mathlib.Tactic.GeneralizeProofs.AState.casesOn`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.GeneralizeProofs`
- **Relevance Score**: 40.36/100 (distance: 0.5964)
- **Type Signature**: `{motive : Mathlib.Tactic.GeneralizeProofs.AState → Sort u} →
  (t : Mathlib.Tactic.GeneralizeProofs.AState) →
    ((generalizations : Array (Prod Lean.Expr Lean.Expr)) →
        (propToProof : Lean.ExprMap Lean.Expr) →
          motive { generalizations := generalizations, propToProof := propToProof }) →
      motive t`
- **Description**: Case Analysis Principle for `AState` - Given a state `s` in the `AState` structure, the `casesOn` method provides a way to perform case analysis on `s`. Specifically, it allows one to prove a proposition `motive s` by considering each constructor of `AState` separately, assuming that the proposition holds for each possible form of `s`.

**Informal name**  
Case Analysis Principle for `AState`

### Result 15
- **Name**: `Mathlib.PrintSorries.State.casesOn`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Util.PrintSorries`
- **Relevance Score**: 37.75/100 (distance: 0.6225)
- **Type Signature**: `{motive : Mathlib.PrintSorries.State → Sort u} →
  (t : Mathlib.PrintSorries.State) →
    ((visited : Lean.NameSet) →
        (sorries : Std.HashSet Lean.Expr) →
          (sorryMsgs : Array Lean.MessageData) →
            motive { visited := visited, sorries := sorries, sorryMsgs := sorryMsgs }) →
      motive t`
- **Description**: Case‑analysis lemma for the internal state of the `#print sorries` command - This is a technical lemma used in the implementation of the `#print sorries` command, which tracks unfinished proofs (`sorry`) in Lean declarations. It is not a mathematical theorem but a helper for meta‑programming.

**Informal name**  
Case‑analysis lemma for the internal state of the `#print sorries` command

---

## Query 9: automated theorem proving tactics
**Results Found**: 15

### Result 1
- **Name**: `Mathlib.Tactic.Tauto.tautoCore`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Tauto`
- **Relevance Score**: 96.54/100 (distance: 0.0346)
- **Signature**: ` : TacticM Unit`
- **Type Signature**: `Lean.Elab.Tactic.TacticM Unit`
- **Description**: Core loop of the `tauto` tactic - The core loop of the `tauto` tactic repeatedly breaks down propositions until no further progress is made. At each step, it attempts to use `assumption` and `contradiction` to discharge goals immediately. The loop applies introduction of variables, distributes negations in hypotheses using de Morgan’s laws, performs case analysis on conjunctions, disjunctions, existentials, and `False`, and refines disjunctions into implications. It also applies constructors for conjunctions, bi-implications, and `True`. The loop terminates when no subgoals change.

### Result 2
- **Name**: `Mathlib.Linter.Flexible.flexible`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Linter.FlexibleLinter`
- **Relevance Score**: 96.38/100 (distance: 0.0362)
- **Signature**: ` : Std.HashSet Name`
- **Type Signature**: `Std.HashSet Lean.Name`
- **Description**: Flexible Tactics - The set of tactic syntax node kinds that are considered "flexible", meaning they are allowed to follow another flexible tactic. These include simplification tactics (e.g., `simp`, `dsimp`), arithmetic tactics (e.g., `abel`, `linarith`), normalization tactics (e.g., `norm_num`, `norm_cast`), and others such as `split`, `constructor`, and `aesop`.

### Result 3
- **Name**: `Mathlib.Tactic.Tauto.DistribNotState.recOn`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Tauto`
- **Relevance Score**: 95.0/100 (distance: 0.0500)
- **Type Signature**: `{motive : Mathlib.Tactic.Tauto.DistribNotState → Sort u} →
  (t : Mathlib.Tactic.Tauto.DistribNotState) →
    ((fvars : List Lean.Expr) → (currentGoal : Lean.MVarId) → motive { fvars := fvars, currentGoal := currentGoal }) →
      motive t`
- **Description**: Tactic for Propositional Tautologies (`tauto`) - This is a Lean tactic for propositional logic, not a mathematical theorem. The `tauto` tactic automatically proves propositional tautologies using a truth table approach. It handles logical connectives such as `∧`, `∨`, `→`, `¬`, `↔`, and the constants `True` and `False`.  

**Informal name**  
Tactic for Propositional Tautologies (`tauto`)

### Result 4
- **Name**: `commandLibrary_note2____1`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Basic`
- **Relevance Score**: 94.7/100 (distance: 0.0530)
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Lean 4 Tactic Writing Utilities Documentation - This is a library note describing basic utilities and tactics for writing tactics in Lean 4, including:
- A dummy `variables` macro that warns the user to use `variable` instead
- The `introv` tactic for automatically introducing theorem variables and naming non-dependent hypotheses
- An `assumption` macro that applies the `assumption` tactic to all goals
- The `match_target` and `clear_aux_decl` tactics for matching targets and clearing auxiliary declarations

**Informal name**
Lean 4 Tactic Writing Utilities Documentation

### Result 5
- **Name**: `Mathlib.Tactic.Tauto.tauto`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Tauto`
- **Relevance Score**: 94.42/100 (distance: 0.0558)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Tautology tactic (`tauto`) - The `tauto` tactic is a finishing tactic that decomposes assumptions and goals involving logical connectives (`∧`, `∨`, `↔`, `∃`) until the goal can be resolved using `reflexivity` or `solve_by_elim`. Unlike its Lean 3 counterpart, it does not avoid classical reasoning by default.

### Result 6
- **Name**: `Mathlib.Tactic.Tauto.Config.mk`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Tauto`
- **Relevance Score**: 94.29/100 (distance: 0.0571)
- **Type Signature**: `Mathlib.Tactic.Tauto.Config`
- **Description**: Tauto Tactic for Propositional Logic - The `tauto` tactic is an automated reasoning procedure that proves propositional tautologies and handles basic logical reasoning in Lean.

**Informal name**
Tauto Tactic for Propositional Logic

**Explanation:**
The `tauto` tactic is commonly used in proof assistants to automatically prove tautologies and handle propositional logic reasoning. It typically works on formulas involving logical connectives like ∧, ∨, →, ¬, and ↔, and can handle quantifier-free first-order logic in some implementations. Since this appears to be a configuration structure for the tactic rather than a mathematical theorem, the description focuses on explaining what the tactic does rather than proving a mathematical result.

### Result 7
- **Name**: `Mathlib.Tactic.Polyrith.tacticPolyrithOnly[_]`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Polyrith`
- **Relevance Score**: 93.63/100 (distance: 0.0637)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: `polyrith` Tactic - The `polyrith` tactic is no longer supported in Mathlib, as it relied on a defunct external service.

### Result 8
- **Name**: `Mathlib.Tactic.ITauto.itauto`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 93.53/100 (distance: 0.0647)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Intuitionistic tautology prover (`itauto`) - The `itauto` tactic is a decision procedure for intuitionistic propositional logic. It proves intuitionistic tautologies without using the law of excluded middle (unless the `!` variant is used). The tactic supports all built-in propositional connectives (`True`, `False`, `And`, `Or`, `→`, `Not`, `Iff`, `Xor'`) as well as equality and inequality on propositions (`Eq` and `Ne`). Definitions and quantifiers (`∀`, `∃`) are not supported and must be simplified or instantiated before using the tactic.

The tactic can optionally perform case analysis on specified decidable propositions (via `itauto [a, b]`) or all decidable propositions (via `itauto *`). The `itauto!` variant enables classical reasoning by allowing case splitting on arbitrary propositions.

### Result 9
- **Name**: `Mathlib.Tactic.Tauto.Config.recOn`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Tauto`
- **Relevance Score**: 91.12/100 (distance: 0.0888)
- **Type Signature**: `{motive : Mathlib.Tactic.Tauto.Config → Sort u} → (t : Mathlib.Tactic.Tauto.Config) → motive { } → motive t`
- **Description**: Tauto Tactic for Propositional Logic - The `tauto` tactic is a decision procedure for propositional logic (including intuitionistic logic) that handles logical connectives and quantifiers. It automatically proves tautologies and valid implications by performing a truth-table-like search, without requiring user guidance.

**Informal name**  
Tauto Tactic for Propositional Logic

### Result 10
- **Name**: `Mathlib.Tactic.Tauto.Config.ctorIdx`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Tauto`
- **Relevance Score**: 90.99/100 (distance: 0.0901)
- **Type Signature**: `Mathlib.Tactic.Tauto.Config → Nat`
- **Description**: Tauto Tactic for Propositional Logic - The `tauto` tactic is a propositional logic solver that automatically proves tautologies in Lean.  

**Informal name**  
Tauto Tactic for Propositional Logic

### Result 11
- **Name**: `Mathlib.Tactic.Tauto.tautology`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Tauto`
- **Relevance Score**: 89.63/100 (distance: 0.1037)
- **Signature**: ` : TacticM Unit`
- **Type Signature**: `Lean.Elab.Tactic.TacticM Unit`
- **Description**: Tautology tactic (`tautology`) - The `tautology` tactic is a finishing tactic that decomposes logical connectives in assumptions and goals, then attempts to solve the goal using reflexivity, automated elimination, or logical constructors. It operates classically and ensures all subgoals are resolved within a focused scope.

### Result 12
- **Name**: `Mathlib.Tactic.ITauto.itauto!`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 89.41/100 (distance: 0.1059)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Enhanced intuitionistic tautology prover with selective LEM - The `itauto!` tactic is a variant of the `itauto` decision procedure for intuitionistic propositional logic that allows selective use of the law of excluded middle (LEM) for case splitting on specified propositions. It implements the `G4ip` algorithm and supports built-in propositional connectives (`True`, `False`, `And`, `Or`, `→`, `Not`, `Iff`, `Xor'`) as well as equality and inequality on propositions (`Eq` and `Ne`).

### Result 13
- **Name**: `Mathlib.Tactic.ITauto.itautoCore`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 89.26/100 (distance: 0.1074)
- **Signature**: ` (g : MVarId) (useDec useClassical : Bool) (extraDec : Array Expr) : MetaM Unit`
- **Type Signature**: `Lean.MVarId → Bool → Bool → Array Lean.Expr → Lean.Meta.MetaM Unit`
- **Description**: Core Intuitionistic Tautology Prover - The core procedure of the `itauto` tactic for intuitionistic propositional logic. Given a goal `g` and configuration parameters `useDec`, `useClassical`, and `extraDec`, it attempts to prove the goal using the G4ip algorithm. The parameters control whether to use decidability information (`useDec`), allow classical case splitting on arbitrary propositions (`useClassical`), or add specific propositions to the case-splitting set (`extraDec`). The procedure operates in the `MetaM` monad and modifies the goal state if successful.

### Result 14
- **Name**: `Mathlib.Tactic.Find.tacticFind`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Find`
- **Relevance Score**: 82.78/100 (distance: 0.1722)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Find tactic for applicable lemmas - The `find` tactic searches for lemmas that can be applied to the current goal in a proof context.

### Result 15
- **Name**: `Mathlib.Tactic.linarith`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Linarith.Frontend`
- **Relevance Score**: 81.41/100 (distance: 0.1859)
- **Signature**: ` : Lean.ParserDescr✝`
- **Type Signature**: `Lean.ParserDescr`
- **Description**: Linear Arithmetic Tactic (`linarith`) - The `linarith` tactic attempts to prove a goal by finding a contradiction among the linear inequalities in the context, or by assuming the negation of a linear inequality goal and deriving `False`. It operates over types that are commutative rings with a linear order and a strictly ordered ring structure, such as `ℕ`, `ℤ`, `ℚ`, or `ℝ`. The tactic may also be configured to handle disequalities via case splitting, to use a stronger definitional transparency, or to restrict the hypotheses considered.

---

## Query 10: proof search termination
**Results Found**: 15

### Result 1
- **Name**: `Computation.Results.terminates`
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.Seq.Computation`
- **Relevance Score**: 96.32/100 (distance: 0.0368)
- **Signature**: ` {s : Computation α} {a n} (h : Results s a n) : Terminates s`
- **Type Signature**: `∀ {α : Type u} {s : Computation α} {a : α} {n : Nat}, s.Results a n → s.Terminates`
- **Description**: Termination from Results in Unbounded Computation - For any computation $s : \text{Computation} \alpha$, result $a : \alpha$, and natural number $n : \mathbb{N}$, if $s$ terminates with result $a$ in exactly $n$ steps (i.e., $\text{Results}(s, a, n)$ holds), then $s$ terminates (i.e., $\text{Terminates}(s)$ holds).

### Result 2
- **Name**: `Computation.terminates_iff`
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.Seq.Computation`
- **Relevance Score**: 94.17/100 (distance: 0.0583)
- **Signature**: ` (s : Computation α) : Terminates s ↔ ∃ a, a ∈ s`
- **Type Signature**: `∀ {α : Type u} (s : Computation α), Iff s.Terminates (Exists fun a => Computation.instMembership.mem s a)`
- **Description**: Termination Criterion for Unbounded Computations: $\text{Terminates}(s) \leftrightarrow \exists a, a \in s$ - For any unbounded computation $s : \text{Computation} \alpha$, the computation terminates if and only if there exists some element $a \in \alpha$ that is eventually produced by $s$.

### Result 3
- **Name**: `Mathlib.Tactic.ITauto.Proof.ctorElimType`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 93.72/100 (distance: 0.0628)
- **Type Signature**: `{motive : Mathlib.Tactic.ITauto.Proof → Sort u} → Nat → Sort (max 1 u)`
- **Description**: Structural Recursion Principle for Intuitionistic Proof Terms - This is a technical lemma used in the `itauto` intuitionistic tautology decision procedure. It states that the `Proof` inductive type is well-founded with respect to its constructors, ensuring that recursive definitions over `Proof` terminate. Specifically, it provides an elimination principle that allows case analysis on `Proof` while preserving the property that all recursive occurrences in the resulting term are applied to structurally smaller arguments.

**Informal name**  
Structural Recursion Principle for Intuitionistic Proof Terms

### Result 4
- **Name**: `Computation.Terminates.casesOn`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Data.Seq.Computation`
- **Relevance Score**: 93.34/100 (distance: 0.0666)
- **Type Signature**: `{α : Type u} →
  {s : Computation α} →
    {motive : s.Terminates → Sort u_1} →
      (t : s.Terminates) → ((term : Exists fun a => Computation.instMembership.mem s a) → motive ⋯) → motive t`
- **Description**: Case Analysis on a Termination Proof of a Computation - Let \( \alpha \) be a type, let \( s : \text{Computation } \alpha \) be a computation, and assume that \( s \) terminates (i.e., eventually produces a value).  
If \( h : s \text{ terminates} \) is a proof of termination, then for any proposition \( C \) and any function \( f \) that, given a value \( a : \alpha \) and a proof that \( s \) yields \( a \), produces a term of type \( C \), we can construct a term of type \( C \).

**Informal name**  
Case Analysis on a Termination Proof of a Computation

### Result 5
- **Name**: `Computation.terminates_def`
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.Seq.Computation`
- **Relevance Score**: 93.25/100 (distance: 0.0675)
- **Signature**: ` (s : Computation α) : Terminates s ↔ ∃ n, (s.1 n).isSome`
- **Type Signature**: `∀ {α : Type u} (s : Computation α), Iff s.Terminates (Exists fun n => Eq (s.val n).isSome Bool.true)`
- **Description**: Termination Criterion for Unbounded Computations: $\text{Terminates}(s) \leftrightarrow \exists n, s_n \text{ is defined}$ - A computation $s : \text{Computation } \alpha$ terminates if and only if there exists a natural number $n$ such that the $n$-th step of the underlying stream of $s$ is of the form $\text{some } a$ for some $a : \alpha$.

### Result 6
- **Name**: `Mathlib.Tactic.ITauto.prove`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 92.52/100 (distance: 0.0748)
- **Signature**: `(Γ : Context) (B : IProp) : StateM Nat (Bool`
- **Type Signature**: `Mathlib.Tactic.ITauto.Context → Mathlib.Tactic.ITauto.IProp → StateM Nat (Prod Bool Mathlib.Tactic.ITauto.Proof)`
- **Description**: Proof Search in Intuitionistic Propositional Logic - The function `prove` takes a proof context $\Gamma$ and a propositional formula $B$ in intuitionistic logic, and returns a state monad computation that produces a pair of a Boolean value and a proof term. The Boolean indicates whether the proof search was successful, and the proof term is a valid derivation of $B$ from $\Gamma$ if successful. The algorithm applies intuitionistic proof rules in three levels:  
- Level 1: Validity-preserving rules without splitting (e.g., handling $\top$, $\bot$, $\to$).  
- Level 2: Validity-preserving splitting rules (e.g., splitting conjunctions in goals and disjunctions in hypotheses).  
- Level 3: Non-validity-preserving splitting rules (e.g., case splitting on disjunctions in goals) applied only as a last resort.

### Result 7
- **Name**: `Computation.terminates_congr`
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.Seq.Computation`
- **Relevance Score**: 92.08/100 (distance: 0.0792)
- **Signature**: ` {c₁ c₂ : Computation α} (h : c₁ ~ c₂) : Terminates c₁ ↔ Terminates c₂`
- **Type Signature**: `∀ {α : Type u} {c₁ c₂ : Computation α}, c₁.Equiv c₂ → Iff c₁.Terminates c₂.Terminates`
- **Description**: Termination Preservation under Computation Equivalence - For any two computations $c_1$ and $c_2$ of type $\text{Computation} \alpha$, if $c_1$ is equivalent to $c_2$ (written $c_1 \sim c_2$), then $c_1$ terminates if and only if $c_2$ terminates.

### Result 8
- **Name**: `Computation.results_of_terminates'`
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.Seq.Computation`
- **Relevance Score**: 91.49/100 (distance: 0.0851)
- **Signature**: ` (s : Computation α) [T : Terminates s] {a} (h : a ∈ s) : Results s a (length s)`
- **Type Signature**: `∀ {α : Type u} (s : Computation α) [T : s.Terminates] {a : α}, Computation.instMembership.mem s a → s.Results a s.length`
- **Description**: Terminating Computation Yields Result in Minimal Steps - For any terminating computation $s : \text{Computation} \alpha$ and any result $a \in \alpha$ such that $a$ is produced by $s$ (i.e., $a \in s$), the computation $s$ terminates with result $a$ in exactly $\text{length } s$ steps.

### Result 9
- **Name**: `Computation.results_of_terminates`
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.Seq.Computation`
- **Relevance Score**: 91.49/100 (distance: 0.0851)
- **Signature**: ` (s : Computation α) [_T : Terminates s] : Results s (get s) (length s)`
- **Type Signature**: `∀ {α : Type u} (s : Computation α) [_T : s.Terminates], s.Results s.get s.length`
- **Description**: Terminating Computation Results in Minimal Steps - For any terminating computation $s : \text{Computation} \alpha$, the computation $s$ terminates after exactly $\text{length } s$ steps with result $\text{get } s$. In other words, the predicate $\text{Results } s (\text{get } s) (\text{length } s)$ holds.

### Result 10
- **Name**: `Computation.terminates_of_mem`
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.Seq.Computation`
- **Relevance Score**: 91.37/100 (distance: 0.0863)
- **Signature**: ` {s : Computation α} {a : α} (h : a ∈ s) : Terminates s`
- **Type Signature**: `∀ {α : Type u} {s : Computation α} {a : α}, Computation.instMembership.mem s a → s.Terminates`
- **Description**: Termination from Membership in Unbounded Computation - For any unbounded computation $s : \text{Computation} \alpha$ and any element $a \in \alpha$, if $a$ is a member of $s$ (i.e., $s$ eventually produces $a$ as its result), then $s$ terminates.

### Result 11
- **Name**: `Computation.terminates_map_iff`
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.Seq.Computation`
- **Relevance Score**: 88.88/100 (distance: 0.1112)
- **Signature**: ` (f : α → β) (s : Computation α) : Terminates (map f s) ↔ Terminates s`
- **Type Signature**: `∀ {α : Type u} {β : Type v} (f : α → β) (s : Computation α), Iff (Computation.map f s).Terminates s.Terminates`
- **Description**: Termination Equivalence under Mapping of Computations: $\text{Terminates}\,(\text{map}\,f\,s) \leftrightarrow \text{Terminates}\,s$ - For any function $f : \alpha \to \beta$ and any computation $s : \text{Computation}\,\alpha$, the mapped computation $\text{map}\,f\,s$ terminates if and only if $s$ terminates.

### Result 12
- **Name**: `Mathlib.LibraryNote.fact non-instances`
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Logic.Basic`
- **Relevance Score**: 88.24/100 (distance: 0.1176)
- **Signature**: ` : LibraryNote✝`
- **Type Signature**: `LibraryNote`
- **Description**: Library Note on Fact Non-Instances - A library note in Mathlib: "In most cases, we should not have global instances of `Fact`; typeclass search is not an advanced proof search engine, and adding any such instance has the potential to cause slowdowns everywhere. We instead declare them as lemmata and make them local instances as required."

### Result 13
- **Name**: `Computation.of_think_terminates`
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.Seq.Computation`
- **Relevance Score**: 87.75/100 (distance: 0.1225)
- **Signature**: ` {s : Computation α} : Terminates (think s) → Terminates s`
- **Type Signature**: `∀ {α : Type u} {s : Computation α}, s.think.Terminates → s.Terminates`
- **Description**: Termination Preservation Under Delay in Computations - For any computation $s$ of type $\text{Computation} \alpha$, if the delayed computation $\text{think } s$ terminates, then $s$ also terminates.

### Result 14
- **Name**: `Stream'.Seq.length_le_iff'`
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.Seq.Basic`
- **Relevance Score**: 87.49/100 (distance: 0.1251)
- **Signature**: ` {s : Seq α} {n : ℕ} : (∃ h, s.length h ≤ n) ↔ s.TerminatedAt n`
- **Type Signature**: `∀ {α : Type u} {s : Stream'.Seq α} {n : Nat}, Iff (Exists fun h => instLENat.le (s.length h) n) (s.TerminatedAt n)`
- **Description**: Termination Criterion for Sequences: $\exists h, \text{length}(s, h) \leq n \leftrightarrow s_n = \text{none}$ - For any sequence $s$ of type $\text{Seq}\,\alpha$ and natural number $n$, there exists a termination proof $h$ such that the length of $s$ under $h$ is at most $n$ if and only if $s$ has terminated at position $n$ (i.e., the $n$-th element of $s$ is $\text{none}$).

### Result 15
- **Name**: `Computation.terminates_of_liftRel`
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.Seq.Computation`
- **Relevance Score**: 86.97/100 (distance: 0.1303)
- **Signature**: ` {R : α → β → Prop} {s t} : LiftRel R s t → (Terminates s ↔ Terminates t)`
- **Type Signature**: `∀ {α : Type u} {β : Type v} {R : α → β → Prop} {s : Computation α} {t : Computation β},
  Computation.LiftRel R s t → Iff s.Terminates t.Terminates`
- **Description**: Termination Equivalence under Lifted Relation - For any relation $R$ between types $\alpha$ and $\beta$, and for any computations $s : \text{Computation}\, \alpha$ and $t : \text{Computation}\, \beta$, if $\text{LiftRel}\, R\, s\, t$ holds, then $s$ terminates if and only if $t$ terminates.

---

## Cross-References

### Frequently Appearing Modules

- `Mathlib.Tactic.ITauto`: 21 results
- `Mathlib.Tactic.Propose`: 14 results
- `Mathlib.Tactic.Find`: 14 results
- `Mathlib.Tactic.GeneralizeProofs`: 13 results
- `Mathlib.Data.Seq`: 12 results
- `Mathlib.Tactic.Tauto`: 11 results
- `Mathlib.Tactic.FunProp`: 10 results
- `Mathlib.Tactic.Order`: 9 results
- `Mathlib.Tactic.TFAE`: 8 results
- `Mathlib.Data.List`: 6 results

### Frequently Appearing Names

- `Mathlib.Tactic.ITauto.prove`: appears in 7 queries
- `Mathlib.Tactic.Find.tacticFind`: appears in 6 queries
- `Mathlib.Tactic.TFAE.proveImpl`: appears in 5 queries
- `Mathlib.Tactic.Propose.propose'`: appears in 5 queries
- `Mathlib.Tactic.ITauto.search`: appears in 5 queries
- `Mathlib.Tactic.Find.tactic#find_`: appears in 4 queries
- `Mathlib.Tactic.Find.command#find_`: appears in 4 queries
- `Mathlib.Tactic.Tauto.tautoCore`: appears in 4 queries
- `Mathlib.Tactic.TFAE.dfs`: appears in 3 queries
- `Mathlib.LibraryNote.fact non-instances`: appears in 3 queries

---

## Summary of Key Findings

### Result Types Distribution

- **definition**: 128 results
- **theorem**: 17 results
- **opaque**: 2 results
- **abbrev**: 2 results
- **inductive**: 1 results

### Key Categories

- **Tactic-related results**: 121 found
- **Search-related results**: 65 found
- **Automation-related results**: 32 found

### Notable Patterns

- **Mathlib results**: 150/150 (100%)
- **Std library results**: 0/150 (0%)
- **Depth-first search related**: 21 results

---

## Most Relevant Results (Top 20 Overall)

### 1. `Mathlib.Tactic.ITauto.search`
- **Source Query**: "tableau proof search"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 98.79/100
- **Description**: Search phase of the G4ip intuitionistic proof procedure

### 2. `Mathlib.Tactic.ITauto.prove`
- **Source Query**: "proof search tactic implementation"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 98.53/100
- **Description**: Proof Search in Intuitionistic Propositional Logic

### 3. `Mathlib.Tactic.Order.Graph.buildTransitiveLeProofDFS`
- **Source Query**: "bounded depth first search proof automation"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Order.Graph.Basic`
- **Relevance Score**: 98.16/100
- **Description**: Depth-first search for constructing transitive order proofs

### 4. `Mathlib.Tactic.Propose.propose'`
- **Source Query**: "proof search tactic implementation"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 97.87/100
- **Description**: Forward reasoning lemma search tactic

### 5. `Mathlib.Tactic.Order.Graph.DFSState`
- **Source Query**: "bounded depth first search proof automation"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Order.Graph.Basic`
- **Relevance Score**: 97.2/100
- **Description**: DFS state for order tactic graphs

### 6. `implMaxDepth`
- **Source Query**: "bounded depth first search proof automation"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Deprecated.MLList.BestFirst`
- **Relevance Score**: 97.16/100
- **Description**: Best-First Search with Maximum Depth

### 7. `Mathlib.Tactic.Propose.propose'`
- **Source Query**: "heuristic guided proof search"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 97.07/100
- **Description**: Forward reasoning lemma search tactic

### 8. `Mathlib.Tactic.Propose.propose'`
- **Source Query**: "tableau proof search"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 96.91/100
- **Description**: Forward reasoning lemma search tactic

### 9. `Mathlib.Tactic.TFAE.dfs`
- **Source Query**: "bounded depth first search proof automation"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.TFAE`
- **Relevance Score**: 96.64/100
- **Description**: Depth-first search for TFAE implications

### 10. `Mathlib.Tactic.ITauto.prove`
- **Source Query**: "tableau proof search"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 96.62/100
- **Description**: Proof Search in Intuitionistic Propositional Logic

### 11. `Mathlib.Tactic.Tauto.tautoCore`
- **Source Query**: "automated theorem proving tactics"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Tauto`
- **Relevance Score**: 96.54/100
- **Description**: Core loop of the `tauto` tactic

### 12. `Mathlib.Meta.FunProp.cacheResult`
- **Source Query**: "proof caching memoization"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.FunProp.Core`
- **Relevance Score**: 96.46/100
- **Description**: Caching a result without subgoals in the `fun_prop` tactic

### 13. `Mathlib.Linter.Flexible.flexible`
- **Source Query**: "automated theorem proving tactics"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Linter.FlexibleLinter`
- **Relevance Score**: 96.38/100
- **Description**: Flexible Tactics

### 14. `Mathlib.Tactic.ITauto.search`
- **Source Query**: "modal logic proof search"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 96.32/100
- **Description**: Search phase of the G4ip intuitionistic proof procedure

### 15. `Computation.Results.terminates`
- **Source Query**: "proof search termination"
- **Type**: theorem
- **Library**: Mathlib
- **Module**: `Mathlib.Data.Seq.Computation`
- **Relevance Score**: 96.32/100
- **Description**: Termination from Results in Unbounded Computation

### 16. `Mathlib.Tactic.ITauto.prove`
- **Source Query**: "heuristic guided proof search"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.ITauto`
- **Relevance Score**: 96.24/100
- **Description**: Proof Search in Intuitionistic Propositional Logic

### 17. `Mathlib.Tactic.Order.Graph.buildTransitiveLeProof`
- **Source Query**: "bounded depth first search proof automation"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Order.Graph.Basic`
- **Relevance Score**: 96.24/100
- **Description**: Transitive proof construction for order relations via DFS

### 18. `bestFirstSearch`
- **Source Query**: "bounded depth first search proof automation"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Deprecated.MLList.BestFirst`
- **Relevance Score**: 96.12/100
- **Description**: Best‑First Graph Search with Configurable Bounds and Deduplication

### 19. `Mathlib.Tactic.Propose.tacticHave?!:_Using__`
- **Source Query**: "heuristic guided proof search"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 95.85/100
- **Description**: Forward reasoning tactic with lemma suggestion

### 20. `Mathlib.Tactic.Propose.propose'`
- **Source Query**: "modal logic proof search"
- **Type**: definition
- **Library**: Mathlib
- **Module**: `Mathlib.Tactic.Propose`
- **Relevance Score**: 95.73/100
- **Description**: Forward reasoning lemma search tactic

---

## Implementation Insights

### Proof Search Strategies Found

- **Depth-First Search**: 21 results
- **Backward Chaining**: 14 results
- **Forward Chaining**: 8 results
- **Decision Procedures**: 8 results
- **Best-First Search**: 2 results
- **Tableau Methods**: 2 results
- **Simplification**: 2 results

### Key Automation Tools Identified

- `Mathlib.Tactic.Basic`
- `Mathlib.Tactic.CC`
- `Mathlib.Tactic.Elab`
- `Mathlib.Tactic.Explode`
- `Mathlib.Tactic.Find`
- `Mathlib.Tactic.FunProp`
- `Mathlib.Tactic.GeneralizeProofs`
- `Mathlib.Tactic.Hint`
- `Mathlib.Tactic.ITauto`
- `Mathlib.Tactic.Linarith`
- `Mathlib.Tactic.Linter`
- `Mathlib.Tactic.Order`
- `Mathlib.Tactic.Polyrith`
- `Mathlib.Tactic.Propose`
- `Mathlib.Tactic.RewriteSearch`
- `Mathlib.Tactic.Ring`
- `Mathlib.Tactic.TFAE`
- `Mathlib.Tactic.Tauto`
- `Mathlib.Tactic.TermCongr`
- `Mathlib.Tactic.Widget`

