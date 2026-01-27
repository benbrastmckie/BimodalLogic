# Web Research — Lean 4 memoization and context transforms for proof search

## Scope
- Memoization patterns for DFS proof search using `StateT`, `ReaderT`, `HashMap`/`HashSet`.
- Handling modal/temporal contexts via mapped or layered reader environments.
- Caching successes/failures and visited sets.
- Test patterns for cache correctness and visit limits.

## Key techniques
1) **State + Reader layering for search**  
   - Use `ReaderT` for immutable context/environment (e.g., modal/temporal parameters) and `StateT` for mutable search state (caches, fuel, stats).  
   - FPiL shows building effects with `ReaderT`/`StateT` and lifting IO (`MonadLift`) so DFS code can be pure except for state/env effects.  
   - A typical stack: `abbrev SearchM := ReaderT Ctx <| StateT SearchState <| ExceptT Err Id`.

2) **Context transforms for modal/temporal search**  
   - `ReaderT` supports local overrides (`withReader`) to map a parent context to a child (e.g., entering ◻/◇ or temporal step).  
   - Keep context as a structured record; use small functions `enterBox`, `enterDiamond`, `advance` to transform it.  
   - `withReader (· |> enterBox)` delimits the override to the recursive call—safer than threading context manually.

3) **Memoization with `HashMap`**  
   - `Std.HashMap` operations relevant for caches: `get?`, `insert`, `alter`, `modify`, `getThenInsertIfNew?`, `containsThenInsertIfNew`.  
   - Store goal → result (`Option Proof` or `Except Err Proof`) to memoize both success and failure.  
   - Prefer `containsThenInsertIfNew`/`getThenInsertIfNew?` to avoid double hashing and to distinguish “already cached” vs “newly inserted”.

4) **Visited sets & cutoffs with `HashSet`**  
   - `Std.HashSet` (`insert`, `contains`, `erase`, `size`) for loop prevention and visit limits.  
   - Use `containsThenInsert` to atomically test+add; returns `(found?, newSet)` for O(1) guard against cycles in DFS.  
   - For layered contexts, key can be `(ctxHash, goalHash)` tuple to prevent revisiting the same goal under the same context mapping.

5) **State helpers for efficient updates**  
   - `StateT.modifyGet` lets you compute a result and the new state in one pass (avoids extra references/copies).  
   - For counters/fuel, keep them in state and decrement via `modify`/`modifyGet`; failure when fuel is 0.

6) **Minimal DFS skeleton (pure, cache-aware)**
```lean
structure Ctx where world : WorldId := 0 -- modal/temporal context
structure CacheEntry where result : Except Err Proof
structure SearchState where
  memo   : HashMap Goal CacheEntry := ∅
  seen   : HashSet (WorldId × Goal) := ∅
  fuel   : Nat := 1000

def SearchM := ReaderT Ctx <| StateT SearchState <| ExceptT Err Id

def markVisited (g : Goal) : SearchM Bool := do
  let ctx ← read
  let key := (ctx.world, g)
  let st ← get
  let (found, seen') := st.seen.containsThenInsert key
  set { st with seen := seen' }
  pure found

def withCached (g : Goal) (k : SearchM Proof) : SearchM Proof := do
  let st ← get
  match st.memo.get? g with
  | some e => pure <| (← e.result).merge id
  | none   => do
      let res ← k
      modify fun s => { s with memo := s.memo.insert g ⟨.ok res⟩ }
      pure res

def dfs (g : Goal) : SearchM Proof := do
  if (← markVisited g) then throw (.cycle g)
  modify fun s => { s with fuel := s.fuel - 1 }
  if (← get).fuel = 0 then throw .outOfFuel
  withCached g <| do
    -- branch/search steps here, possibly under transformed contexts
    sorry
```

7) **Context mapping for modal/temporal rules**
```lean
abbrev ModalM := ReaderT ModalCtx <| StateT SearchState <| ExceptT Err Id

def enterBox : ModalCtx → ModalCtx := fun c => { c with depth := c.depth + 1 }

def handleBox (g : Goal) : ModalM Proof :=
  withReader enterBox (dfs g)
```

8) **Caching failures as well as successes**  
   - Cache type `Goal → Result := Except Err Proof`; store both `.ok` and `.error` so repeated failing branches short-circuit.  
   - Use `HashMap.alter` to memoize in one pass, or `getThenInsertIfNew?` to avoid recomputation in concurrent calls.

9) **Testing patterns**
   - **Cache hit:** run the same goal twice; assert second run leaves `fuel` unchanged and does not grow memo size.  
   - **Failure memoization:** run a known-unsolvable goal twice; assert second run returns the same failure without exploring children (no `visited` growth).  
   - **Visited cutoff:** construct a cyclic goal graph; ensure `markVisited` triggers `cycle` after first visit.  
   - **Context-sensitive visited keys:** same propositional goal under two different contexts should not collide; verify by different `world` in key.  
   - **Fuel limit:** start with small fuel; ensure `outOfFuel` is cached and reused.

## References
- Lean Std `HashMap` implementation & ops (insert, get?, containsThenInsert…): https://raw.githubusercontent.com/leanprover/lean4/master/src/Std/Data/HashMap/Basic.lean
- Lean Std `HashSet` implementation & ops (containsThenInsert, erase, size): https://raw.githubusercontent.com/leanprover/lean4/master/src/Std/Data/HashSet/Basic.lean
- Lean `StateT` (state transformer: `run`, `modifyGet`, `get`, `set`): https://raw.githubusercontent.com/leanprover/lean4/master/src/Init/Control/State.lean
- FPiL — Reader/State transformers and `withReader` patterns for localized context changes: https://lean-lang.org/functional_programming_in_lean/Monad-Transformers/Combining-IO-and-Reader.html
- FPiL — Monad transformer construction kit (OptionT/ExceptT/StateT patterns and `MonadLift`): https://lean-lang.org/functional_programming_in_lean/Monad-Transformers/A-Monad-Construction-Kit.html
