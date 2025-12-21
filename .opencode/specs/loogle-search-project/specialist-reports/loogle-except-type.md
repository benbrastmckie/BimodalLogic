# Loogle Search Report: Except Type Pattern

## Search Query
**Pattern:** `Except _ _`

## Summary
- **Total matches found:** 583
- **Matches retrieved:** 200 (API limit: 200)
- **Libraries covered:** 3

Found 599 declarations mentioning Except.
Of these, 583 match your pattern(s).
Of these, only the first 200 are shown.

## Overview

This report catalogs 200 functions and theorems matching the `Except _ _` type pattern.
The `Except` type is Lean's built-in error handling monad, representing computations that may fail.

### Libraries Distribution

- **Init:** 76 declarations
- **Lean:** 38 declarations
- **Std:** 86 declarations

### Categories

- **Constructors:** 10 items
- **Conversions:** 63 items
- **Control Flow:** 11 items
- **Monad Operations:** 31 items
- **Instances:** 3 items
- **Theorems:** 45 items
- **Other:** 37 items

---

## Detailed Listings

## 1. Constructors

Core constructors for creating `Except` values.

### `Except.error`
**Module:** `Init.Prelude`

**Type:**
```lean
 {ε : Type u} {α : Type v} : ε → Except ε α
```

**Description:**
A failure value of type `ε` 

### `Except.ok`
**Module:** `Init.Prelude`

**Type:**
```lean
 {ε : Type u} {α : Type v} : α → Except ε α
```

**Description:**
A success value of type `α` 

### `Except.error.sizeOf_spec`
**Module:** `Init.SizeOf`

**Type:**
```lean
 {ε : Type u} {α : Type v} [SizeOf ε] [SizeOf α] (a✝ : ε) : sizeOf (Except.error a✝) = 1 + sizeOf a✝
```

### `Except.ok.sizeOf_spec`
**Module:** `Init.SizeOf`

**Type:**
```lean
 {ε : Type u} {α : Type v} [SizeOf ε] [SizeOf α] (a✝ : α) : sizeOf (Except.ok a✝) = 1 + sizeOf a✝
```

### `Except.error.injEq`
**Module:** `Init.Core`

**Type:**
```lean
 {ε : Type u} {α : Type v} (a✝ a✝¹ : ε) : (Except.error a✝ = Except.error a✝¹) = (a✝ = a✝¹)
```

### `Except.ok.injEq`
**Module:** `Init.Core`

**Type:**
```lean
 {ε : Type u} {α : Type v} (a✝ a✝¹ : α) : (Except.ok a✝ = Except.ok a✝¹) = (a✝ = a✝¹)
```

### `Except.isOk`
**Module:** `Init.Control.Except`

**Type:**
```lean
 {ε : Type u} {α : Type u_1} : Except ε α → Bool
```

**Description:**
Returns `true` if the value is `Except.ok`, `false` otherwise. 

### `Except.mapError`
**Module:** `Init.Control.Except`

**Type:**
```lean
 {ε : Type u} {ε' : Type u_1} {α : Type u_2} (f : ε → ε') : Except ε α → Except ε' α
```

**Description:**
Transforms exceptions with a function, doing nothing on successful results.

Examples:
* `(pure 2 : Except String Nat).mapError (·.length) = pure 2`
* `(throw "Error" : Except String Nat).mapError (·.length) = throw 5`


### `Except.mapError.eq_2`
**Module:** `Std.Do.WP.SimpLemmas`

**Type:**
```lean
 {ε : Type u} {ε' : Type u_1} {α : Type u_2} (f : ε → ε') (v : α) : Except.mapError f (Except.ok v) = Except.ok v
```

### `Except.mapError.eq_1`
**Module:** `Std.Do.WP.SimpLemmas`

**Type:**
```lean
 {ε : Type u} {ε' : Type u_1} {α : Type u_2} (f : ε → ε') (err : ε) : Except.mapError f (Except.error err) = Except.error (f err)
```

## 2. Conversions

Functions for converting between `Except` and other types.

### `Except.ctorElimType`
**Module:** `Init.Prelude`

**Type:**
```lean
 {ε : Type u} {α : Type v} {motive : Except ε α → Sort u_1} (ctorIdx : ℕ) : Sort (max 1 (imax (u + 1) u_1) (imax (v + 1) u_1))
```

### `MonadExcept.ofExcept`
**Module:** `Init.Prelude`

**Type:**
```lean
 {m : Type u_1 → Type u_2} {ε : Type u_3} {α : Type u_1} [Monad m] [MonadExcept ε m] : Except ε α → m α
```

**Description:**
Re-interprets an `Except ε` action in an exception monad `m`, succeeding if it succeeds and throwing
an exception if it throws an exception.


### `Except.toBool`
**Module:** `Init.Control.Except`

**Type:**
```lean
 {ε : Type u} {α : Type u_1} : Except ε α → Bool
```

**Description:**
Returns `true` if the value is `Except.ok`, `false` otherwise. 

### `Except.toOption`
**Module:** `Init.Control.Except`

**Type:**
```lean
 {ε : Type u} {α : Type u_1} : Except ε α → Option α
```

**Description:**
Returns `none` if an exception was thrown, or `some` around the value on success.

Examples:
* `(pure 10 : Except String Nat).toOption = some 10`
* `(throw "Failure" : Except String Nat).toOption = none`


### `instToStringExcept`
**Module:** `Init.Data.ToString.Basic`

**Type:**
```lean
 {ε : Type u_1} {α : Type u_2} [ToString ε] [ToString α] : ToString (Except ε α)
```

### `ExceptT.run_restoreM`
**Module:** `Init.Control.Lawful.Instances`

**Type:**
```lean
 {m : Type u_1 → Type u_2} {ε α : Type u_1} [Monad m] (x : stM m (ExceptT ε m) α) : (restoreM x).run = pure x
```

### `EIO.ofExcept`
**Module:** `Init.System.IO`

**Type:**
```lean
 {ε α : Type} (e : Except ε α) : EIO ε α
```

**Description:**
Converts an `Except ε` action into an `EIO ε` action.

If the `Except ε` action throws an exception, then the resulting `EIO ε` action throws the same
exception. Otherwise, the value is returned.


### `EIO.toBaseIO`
**Module:** `Init.System.IO`

**Type:**
```lean
 {ε α : Type} (act : EIO ε α) : BaseIO (Except ε α)
```

**Description:**
Converts an `EIO ε` action that might throw an exception of type `ε` into an exception-free `BaseIO`
action that returns an `Except` value.


### `EIO.toIO'`
**Module:** `Init.System.IO`

**Type:**
```lean
 {ε α : Type} (act : EIO ε α) : IO (Except ε α)
```

**Description:**
Converts an `EIO ε` action that might throw an exception of type `ε` into an exception-free `IO`
action that returns an `Except` value.


### `IO.ofExcept`
**Module:** `Init.System.IO`

**Type:**
```lean
 {ε : Type u_1} {α : Type} [ToString ε] (e : Except ε α) : IO α
```

**Description:**
Converts an `Except ε` action into an `IO` action.

If the `Except ε` action throws an exception, then the exception type's `ToString` instance is used
to convert it into an `IO.Error`, which is thrown. Otherwise, the value is returned.


### `Lean.Order.monotone_exceptTRun`
**Module:** `Init.Internal.Order.Basic`

**Type:**
```lean
 {γ : Sort u_1} {m : Type u_2 → Type u_3} {ε α : Type u_2} [Lean.Order.PartialOrder γ] [Monad m] [(α : Type u_2) → Lean.Order.PartialOrder (m α)] (f : γ → ExceptT ε m α) (hmono : Lean.Order.monotone f) : Lean.Order.monotone fun x => (f x).run
```

### `Std.Do.Except.of_wp`
**Module:** `Std.Do.WP.Basic`

**Type:**
```lean
 {ε α : Type} {prog : Except ε α} (P : Except ε α → Prop) : (⊢ₛ (Std.Do.wp prog).apply (fun a => ⌜P (Except.ok a)⌝, fun e => ⌜P (Except.error e)⌝, ())) → P prog
```

**Description:**
Adequacy lemma for `Except`.
Useful if you want to prove a property about an expression `prog : Except ε α` and you want to use
`mvcgen` to reason about `prog`.


### `Std.Do.WP.restoreM_ExceptT`
**Module:** `Std.Do.WP.SimpLemmas`

**Type:**
```lean
 {m : Type u → Type v} {ps : Std.Do.PostShape} {ε α : Type u} {Q : Std.Do.PostCond α (Std.Do.PostShape.except ε ps)} [Monad m] [Std.Do.WPMonad m ps] (x : m (Except ε α)) : (Std.Do.wp (MonadControl.restoreM x)).apply Q = (Std.Do.wp x).apply (fun e => Except.casesOn e Q.2.1 Q.1, Q.2.2)
```

### `Std.Do.Spec.restoreM_ExceptT`
**Module:** `Std.Do.Triple.SpecLemmas`

**Type:**
```lean
 {m : Type u → Type v} {ps : Std.Do.PostShape} {ε α : Type u} {Q : Std.Do.PostCond α (Std.Do.PostShape.except ε ps)} [Monad m] [Std.Do.WPMonad m ps] (x : m (Except ε α)) :
  ⦃(Std.Do.wp x).apply (fun e => Except.casesOn e Q.2.1 Q.1, Q.2.2)⦄
    MonadControl.restoreM do
      let a ← x
      pure a ⦃Q⦄
```

### `Std.Internal.IO.Async.Async.ofExcept`
**Module:** `Std.Internal.Async.Basic`

**Type:**
```lean
 {α : Type} (except : Except IO.Error α) : Std.Internal.IO.Async.Async α
```

**Description:**
Converts `Except` to `Async`.


### `Std.Internal.IO.Async.BaseAsync.ofExcept`
**Module:** `Std.Internal.Async.Basic`

**Type:**
```lean
 {α : Type} (except : Except Empty α) : Std.Internal.IO.Async.BaseAsync α
```

**Description:**
Converts `Except` to `BaseAsync`.


### `Std.Internal.IO.Async.EAsync.ofExcept`
**Module:** `Std.Internal.Async.Basic`

**Type:**
```lean
 {ε α : Type} (except : Except ε α) : Std.Internal.IO.Async.EAsync ε α
```

**Description:**
Converts `Except` to `EAsync`.


### `Std.Internal.IO.Async.ETask.ofPromise!`
**Module:** `Std.Internal.Async.Basic`

**Type:**
```lean
 {ε α : Type} (x : IO.Promise (Except ε α)) : Std.Internal.IO.Async.ETask ε α
```

**Description:**
Create an `ETask` that resolves to the value of the promise `x`. If the promise gets dropped then it
panics.


### `Std.Internal.IO.Async.AsyncTask.ofPromise`
**Module:** `Std.Internal.Async.Basic`

**Type:**
```lean
 {α : Type} (x : IO.Promise (Except IO.Error α)) (error : String := "the promise linked to the Async Task was dropped") : Std.Internal.IO.Async.AsyncTask α
```

**Description:**
Create an `AsyncTask` that resolves to the value of `x`.


### `Std.Internal.IO.Async.Async.ofPromise`
**Module:** `Std.Internal.Async.Basic`

**Type:**
```lean
 {α : Type} (task : IO (IO.Promise (Except IO.Error α))) (error : String := "the promise linked to the Async was dropped") : Std.Internal.IO.Async.Async α
```

**Description:**
Converts `Promise` into `Async`.


## 3. Control Flow

Exception handling and recovery operations.

### `Except.orElseLazy`
**Module:** `Init.Control.Except`

**Type:**
```lean
 {ε : Type u} {α : Type u_1} (x : Except ε α) (y : Unit → Except ε α) : Except ε α
```

**Description:**
Recovers from exceptions thrown in the `Except ε` monad. Typically used via the `<|>` operator.

`Except.tryCatch` is a related operator that allows the recovery procedure to depend on _which_
exception was thrown.


### `Except.tryCatch`
**Module:** `Init.Control.Except`

**Type:**
```lean
 {ε : Type u} {α : Type u_1} (ma : Except ε α) (handle : ε → Except ε α) : Except ε α
```

**Description:**
Handles exceptions thrown in the `Except ε` monad.

If `ma` is successful, its result is returned. If it throws an exception, then `handle` is invoked
on the exception's value.

Examples:
 * `(pure 2 : Except String Nat).tryCatch (pure ·.length) = pure 2`
 * `(throw "Error" : Except String Nat).tryCatch (pure ·.length) = pure 5`
 * `(throw "Error" : Except String Nat).tryCatch (fun x => throw ("E: " ++ x)) = throw "E: Error"`


### `Except.tryCatch.eq_2`
**Module:** `Std.Do.WP.SimpLemmas`

**Type:**
```lean
 {ε : Type u} {α : Type u_1} (handle : ε → Except ε α) (a : ε) : (Except.error a).tryCatch handle = handle a
```

### `Except.tryCatch.eq_1`
**Module:** `Std.Do.WP.SimpLemmas`

**Type:**
```lean
 {ε : Type u} {α : Type u_1} (handle : ε → Except ε α) (a : α) : (Except.ok a).tryCatch handle = Except.ok a
```

### `ExceptT.tryCatch.eq_1`
**Module:** `Std.Do.WP.SimpLemmas`

**Type:**
```lean
 {ε : Type u} {m : Type u → Type v} [Monad m] {α : Type u} (ma : ExceptT ε m α) (handle : ε → ExceptT ε m α) :
  ma.tryCatch handle =
    ExceptT.mk do
      let res ← ma
      match res with
        | Except.ok a => pure (Except.ok a)
        | Except.error e => handle e
```

### `Std.Do.WP.tryCatch_Except`
**Module:** `Std.Do.WP.SimpLemmas`

**Type:**
```lean
 {ε α : Type u_1} {x : Except ε α} {h : ε → Except ε α} {Q : Std.Do.PostCond α (Std.Do.PostShape.except ε Std.Do.PostShape.pure)} : (Std.Do.wp (MonadExceptOf.tryCatch x h)).apply Q = (Std.Do.wp x).apply (Q.1, fun e => (Std.Do.wp (h e)).apply Q, Q.2.2)
```

### `Std.Do.WP.orElse_Except`
**Module:** `Std.Do.WP.SimpLemmas`

**Type:**
```lean
 {ε α : Type u_1} {x : Except ε α} {h : Unit → Except ε α} {Q : Std.Do.PostCond α (Std.Do.PostShape.except ε Std.Do.PostShape.pure)} : (Std.Do.wp (OrElse.orElse x h)).apply Q = (Std.Do.wp x).apply (Q.1, fun x => (Std.Do.wp (h ())).apply Q, Q.2.2)
```

### `Std.Do.WP.tryCatch_lift_ExceptT`
**Module:** `Std.Do.WP.SimpLemmas`

**Type:**
```lean
 {m : Type u → Type v} {sh : Std.Do.PostShape} {ε ε' α : Type u} {x : ExceptT ε' m α} {h : ε → ExceptT ε' m α} {Q : Std.Do.PostCond α (Std.Do.PostShape.except ε' sh)} [Std.Do.WP m sh] [Monad m] [MonadExceptOf ε m] : (Std.Do.wp (MonadExceptOf.tryCatch x h)).apply Q = (Std.Do.wp (MonadExceptOf.tryCatch x h)).apply (fun e => Except.casesOn e Q.2.1 Q.1, Q.2.2)
```

### `Std.Do.Spec.tryCatch_Except`
**Module:** `Std.Do.Triple.SpecLemmas`

**Type:**
```lean
 {α ε : Type u_1} {x : Except ε α} {h : ε → Except ε α} (Q : Std.Do.PostCond α (Std.Do.PostShape.except ε Std.Do.PostShape.pure)) : ⦃(Std.Do.wp x).apply (Q.1, fun e => (Std.Do.wp (h e)).apply Q, Q.2.2)⦄ MonadExceptOf.tryCatch x h ⦃Q⦄
```

### `Std.Do.Spec.orElse_Except`
**Module:** `Std.Do.Triple.SpecLemmas`

**Type:**
```lean
 {α ε : Type u_1} {x : Except ε α} {h : Unit → Except ε α} (Q : Std.Do.PostCond α (Std.Do.PostShape.except ε Std.Do.PostShape.pure)) : ⦃(Std.Do.wp x).apply (Q.1, fun x => (Std.Do.wp (h ())).apply Q, Q.2.2)⦄ OrElse.orElse x h ⦃Q⦄
```

### `Std.Do.Spec.tryCatch_ExceptT_lift`
**Module:** `Std.Do.Triple.SpecLemmas`

**Type:**
```lean
 {m : Type u → Type v} {ps : Std.Do.PostShape} {ε α ε' : Type u} {x : ExceptT ε' m α} {h : ε → ExceptT ε' m α} [Std.Do.WP m ps] [MonadExceptOf ε m] (Q : Std.Do.PostCond α (Std.Do.PostShape.except ε' ps)) : ⦃(Std.Do.wp (MonadExceptOf.tryCatch x h)).apply (fun e => Except.casesOn e Q.2.1 Q.1, Q.2.2)⦄ MonadExceptOf.tryCatch x h ⦃Q⦄
```

## 4. Monad Operations

Monadic operations for `Except` and `ExceptT`.

### `Except.pure`
**Module:** `Init.Control.Except`

**Type:**
```lean
 {ε : Type u} {α : Type u_1} (a : α) : Except ε α
```

**Description:**
A successful computation in the `Except ε` monad: `a` is returned, and no exception is thrown.


### `Except.map`
**Module:** `Init.Control.Except`

**Type:**
```lean
 {ε : Type u} {α : Type u_1} {β : Type u_2} (f : α → β) : Except ε α → Except ε β
```

**Description:**
Transforms a successful result with a function, doing nothing when an exception is thrown.

Examples:
* `(pure 2 : Except String Nat).map toString = pure 2`
* `(throw "Error" : Except String Nat).map toString = throw "Error"`


### `Except.bind`
**Module:** `Init.Control.Except`

**Type:**
```lean
 {ε : Type u} {α : Type u_1} {β : Type u_2} (ma : Except ε α) (f : α → Except ε β) : Except ε β
```

**Description:**
Sequences two operations that may throw exceptions, allowing the second to depend on the value
returned by the first.

If the first operation throws an exception, then it is the result of the computation. If the first
succeeds but the second throws an exception, then that exception is the result. If both succeed,
then the result is the result of the second computation.

This is the implementation of the `>>=` operator for `Except ε`.


### `Except.map_id`
**Module:** `Init.Control.Except`

**Type:**
```lean
 {ε : Type u} {α : Type u_1} : Except.map id = id
```

### `ExceptT.bindCont`
**Module:** `Init.Control.Except`

**Type:**
```lean
 {ε : Type u} {m : Type u → Type v} [Monad m] {α β : Type u} (f : α → ExceptT ε m β) : Except ε α → m (Except ε β)
```

**Description:**
Handles exceptions thrown by an action that can have no effects _other_ than throwing exceptions.


### `Except.map.eq_1`
**Module:** `Init.Control.Except`

**Type:**
```lean
 {ε : Type u} {α : Type u_1} {β : Type u_2} (f : α → β) (err : ε) : Except.map f (Except.error err) = Except.error err
```

### `Except.map.eq_2`
**Module:** `Init.Control.Except`

**Type:**
```lean
 {ε : Type u} {α : Type u_1} {β : Type u_2} (f : α → β) (v : α) : Except.map f (Except.ok v) = Except.ok (f v)
```

### `ExceptT.bindCont.eq_1`
**Module:** `Init.Control.Lawful.Instances`

**Type:**
```lean
 {ε : Type u} {m : Type u → Type v} [Monad m] {α β : Type u} (f : α → ExceptT ε m β) (a : α) : ExceptT.bindCont f (Except.ok a) = f a
```

### `ExceptT.pure.eq_1`
**Module:** `Init.Control.Lawful.Instances`

**Type:**
```lean
 {ε : Type u} {m : Type u → Type v} [Monad m] {α : Type u} (a : α) : ExceptT.pure a = ExceptT.mk (pure (Except.ok a))
```

### `ExceptT.bindCont.eq_2`
**Module:** `Init.Control.Lawful.Instances`

**Type:**
```lean
 {ε : Type u} {m : Type u → Type v} [Monad m] {α β : Type u} (f : α → ExceptT ε m β) (e : ε) : ExceptT.bindCont f (Except.error e) = pure (Except.error e)
```

### `ExceptT.run_pure`
**Module:** `Init.Control.Lawful.Instances`

**Type:**
```lean
 {m : Type u_1 → Type u_2} {α ε : Type u_1} [Monad m] (x : α) : (pure x).run = pure (Except.ok x)
```

### `ExceptT.bind.eq_1`
**Module:** `Init.Control.Lawful.Instances`

**Type:**
```lean
 {ε : Type u} {m : Type u → Type v} [Monad m] {α β : Type u} (ma : ExceptT ε m α) (f : α → ExceptT ε m β) : ma.bind f = ExceptT.mk (ma >>= ExceptT.bindCont f)
```

### `ExceptT.run_monadMap`
**Module:** `Init.Control.Lawful.Instances`

**Type:**
```lean
 {n : Type u → Type u_1} {m : Type u → Type u_2} {ε α : Type u} [MonadFunctorT n m] (f : {β : Type u} → n β → n β) (x : ExceptT ε m α) : (monadMap f x).run = monadMap f x.run
```

### `ExceptT.run_bind_lift`
**Module:** `Init.Control.Lawful.Instances`

**Type:**
```lean
 {m : Type u_1 → Type u_2} {α ε β : Type u_1} [Monad m] [LawfulMonad m] (x : m α) (f : α → ExceptT ε m β) :
  (ExceptT.lift x >>= f).run = do
    let a ← x
    (f a).run
```

### `ExceptT.run_map`
**Module:** `Init.Control.Lawful.Instances`

**Type:**
```lean
 {m : Type u_1 → Type u_2} {α β ε : Type u_1} [Monad m] [LawfulMonad m] (f : α → β) (x : ExceptT ε m α) : (f <$> x).run = Except.map f <$> x.run
```

### `ExceptT.map.eq_1`
**Module:** `Init.Control.Lawful.Instances`

**Type:**
```lean
 {ε : Type u} {m : Type u → Type v} [Monad m] {α β : Type u} (f : α → β) (x : ExceptT ε m α) :
  ExceptT.map f x =
    ExceptT.mk do
      let a ← x
      match a with
        | Except.ok a => pure (Except.ok (f a))
        | Except.error e => pure (Except.error e)
```

### `ExceptT.run_bind`
**Module:** `Init.Control.Lawful.Instances`

**Type:**
```lean
 {m : Type u_1 → Type u_2} {ε α β : Type u_1} [Monad m] (x : ExceptT ε m α) (f : α → ExceptT ε m β) :
  (x >>= f).run = do
    let x ← x.run
    match x with
      | Except.ok x => (f x).run
      | Except.error e => pure (Except.error e)
```

### `ExceptCpsT.run_pure`
**Module:** `Init.Control.ExceptCps`

**Type:**
```lean
 {m : Type u_1 → Type u_2} {ε α : Type u_1} {x : α} [Monad m] : (pure x).run = pure (Except.ok x)
```

### `ExceptCpsT.run_bind_lift`
**Module:** `Init.Control.ExceptCps`

**Type:**
```lean
 {m : Type u_1 → Type u_2} {α ε β : Type u_1} [Monad m] (x : m α) (f : α → ExceptCpsT ε m β) :
  (ExceptCpsT.lift x >>= f).run = do
    let a ← x
    (f a).run
```

### `ExceptCpsT.run_bind_throw`
**Module:** `Init.Control.ExceptCps`

**Type:**
```lean
 {m : Type u_1 → Type u_2} {ε α β : Type u_1} [Monad m] (e : ε) (f : α → ExceptCpsT ε m β) : (throw e >>= f).run = (throw e).run
```

### `Except.pure.eq_1`
**Module:** `Init.Control.Lawful.MonadLift.Instances`

**Type:**
```lean
 {ε : Type u} {α : Type u_1} (a : α) : Except.pure a = Except.ok a
```

### `Except.bind.eq_2`
**Module:** `Init.Control.Lawful.MonadLift.Instances`

**Type:**
```lean
 {ε : Type u} {α : Type u_1} {β : Type u_2} (f : α → Except ε β) (v : α) : (Except.ok v).bind f = f v
```

### `Except.bind.eq_1`
**Module:** `Init.Control.Lawful.MonadLift.Instances`

**Type:**
```lean
 {ε : Type u} {α : Type u_1} {β : Type u_2} (f : α → Except ε β) (err : ε) : (Except.error err).bind f = Except.error err
```

### `IO.mapTask`
**Module:** `Init.System.IO`

**Type:**
```lean
 {α : Type u_1} {β : Type} (f : α → IO β) (t : Task α) (prio : Task.Priority := Task.Priority.default) (sync : Bool := false) : BaseIO (Task (Except IO.Error β))
```

**Description:**
Creates a new task that waits for `t` to complete and then runs the `IO` action `f` on its result.
This new task has priority `prio`.

Running the resulting `BaseIO` action causes the task to be started eagerly. Unlike pure tasks
created by `Task.spawn`, tasks created by this function will run even if the last reference to the
task is dropped. The `act` should explicitly check for cancellation via `IO.checkCanceled` if it
should be terminated or otherwise react to the last reference being dropped. Because `IO` actions
may throw an exception of type `IO.Error`, the result of the task is an `Except IO.Error α`.


### `EIO.mapTask`
**Module:** `Init.System.IO`

**Type:**
```lean
 {α : Type u_1} {ε β : Type} (f : α → EIO ε β) (t : Task α) (prio : Task.Priority := Task.Priority.default) (sync : Bool := false) : BaseIO (Task (Except ε β))
```

**Description:**
Creates a new task that waits for `t` to complete and then runs the `IO` action `f` on its result.
This new task has priority `prio`.

Running the resulting `BaseIO` action causes the task to be started eagerly. Unlike pure tasks
created by `Task.spawn`, tasks created by this function will run even if the last reference to the
task is dropped. The `act` should explicitly check for cancellation via `IO.checkCanceled` if it
should be terminated or otherwise react to the last reference being dropped. Because `EIO ε` actions
may throw an exception of type `ε`, the result of the task is an `Except ε α`.


### `IO.mapTasks`
**Module:** `Init.System.IO`

**Type:**
```lean
 {α : Type u_1} {β : Type} (f : List α → IO β) (tasks : List (Task α)) (prio : Task.Priority := Task.Priority.default) (sync : Bool := false) : BaseIO (Task (Except IO.Error β))
```

**Description:**
`IO` specialization of `EIO.mapTasks`. 

### `IO.bindTask`
**Module:** `Init.System.IO`

**Type:**
```lean
 {α : Type u_1} {β : Type} (t : Task α) (f : α → IO (Task (Except IO.Error β))) (prio : Task.Priority := Task.Priority.default) (sync : Bool := false) : BaseIO (Task (Except IO.Error β))
```

**Description:**
Creates a new task that waits for `t` to complete, runs the `IO` action `f` on its result, and then
continues as the resulting task. This new task has priority `prio`.

Running the resulting `BaseIO` action causes this new task to be started eagerly. Unlike pure tasks
created by `Task.spawn`, tasks created by this function will run even if the last reference to the
task is dropped. The `act` should explicitly check for cancellation via `IO.checkCanceled` if it
should be terminated or otherwise react to the last reference being dropped. Because `IO` actions
may throw an exception of type `IO.Error`, the result of the task is an `Except IO.Error α`.


### `EIO.mapTasks`
**Module:** `Init.System.IO`

**Type:**
```lean
 {α : Type u_1} {ε β : Type} (f : List α → EIO ε β) (tasks : List (Task α)) (prio : Task.Priority := Task.Priority.default) (sync : Bool := false) : BaseIO (Task (Except ε β))
```

**Description:**
Creates a new task that waits for all the tasks in the list `tasks` to complete, and then runs the
`EIO ε` action `f` on their results. This new task has priority `prio`.

Running the resulting `BaseIO` action causes the task to be started eagerly. Unlike pure tasks
created by `Task.spawn`, tasks created by this function will run even if the last reference to the
task is dropped. The `act` should explicitly check for cancellation via `IO.checkCanceled` if it
should be terminated or otherwise react to the last reference being dropped.


### `EIO.bindTask`
**Module:** `Init.System.IO`

**Type:**
```lean
 {α : Type u_1} {ε β : Type} (t : Task α) (f : α → EIO ε (Task (Except ε β))) (prio : Task.Priority := Task.Priority.default) (sync : Bool := false) : BaseIO (Task (Except ε β))
```

**Description:**
Creates a new task that waits for `t` to complete, runs the `EIO ε` action `f` on its result, and
then continues as the resulting task. This new task has priority `prio`.

Running the resulting `BaseIO` action causes this new task to be started eagerly. Unlike pure tasks
created by `Task.spawn`, tasks created by this function will run even if the last reference to the
task is dropped. The `act` should explicitly check for cancellation via `IO.checkCanceled` if it
should be terminated or otherwise react to the last reference being dropped. Because `EIO ε` actions
may throw an exception of type `ε`, the result of the task is an `Except ε α`.


### `Std.Do.WP.monadMap_ExceptT`
**Module:** `Std.Do.WP.SimpLemmas`

**Type:**
```lean
 {m : Type u → Type v} {ps : Std.Do.PostShape} {ε : Type u} [Monad m] [Std.Do.WP m ps] (f : {β : Type u} → m β → m β) {α : Type u} (x : ExceptT ε m α) (Q : Std.Do.PostCond α (Std.Do.PostShape.except ε ps)) : (Std.Do.wp (MonadFunctor.monadMap (fun {β} => f) x)).apply Q = (Std.Do.wp (f x.run)).apply (fun e => Except.casesOn e Q.2.1 Q.1, Q.2.2)
```

## 5. Type Class Instances

Type class instances for `Except`.

### `instInhabitedExcept`
**Module:** `Init.Prelude`

**Type:**
```lean
 {ε : Type u} {α : Type v} [Inhabited ε] : Inhabited (Except ε α)
```

### `instReprExcept`
**Module:** `Init.Data.ToString.Basic`

**Type:**
```lean
 {ε : Type u_1} {α : Type u_2} [Repr ε] [Repr α] : Repr (Except ε α)
```

### `Except.instMonad.eq_1`
**Module:** `Init.Control.Lawful.MonadLift.Instances`

**Type:**
```lean
 {ε : Type u} : Except.instMonad = { map := fun {α β} => Except.map, pure := fun {α} => Except.pure, seq := fun {α β} f x => (fun {α β} => Except.bind) f fun y => (fun {α β} => Except.map) y (x ()), seqLeft := fun {α β} x y => (fun {α β} => Except.bind) x fun a => (fun {α β} => Except.bind) (y ()) fun x => (fun {α} => Except.pure) a, seqRight := fun {α β} x y => (fun {α β} => Except.bind) x fun x => y (), bind := fun {α β} => Except.bind }
```

## Complete Index

All retrieved matches organized by library:

### Init

| Name | Module |
|------|--------|
| `Except.error` | `Init.Prelude` |
| `Except.ok` | `Init.Prelude` |
| `instInhabitedExcept` | `Init.Prelude` |
| `Except.ctorElimType` | `Init.Prelude` |
| `MonadExcept.ofExcept` | `Init.Prelude` |
| `Except.error.sizeOf_spec` | `Init.SizeOf` |
| `Except.ok.sizeOf_spec` | `Init.SizeOf` |
| `Except.error.injEq` | `Init.Core` |
| `Except.ok.injEq` | `Init.Core` |
| `Except.isOk` | `Init.Control.Except` |
| `Except.pure` | `Init.Control.Except` |
| `Except.toBool` | `Init.Control.Except` |
| `Except.toOption` | `Init.Control.Except` |
| `Except.map` | `Init.Control.Except` |
| `Except.mapError` | `Init.Control.Except` |
| `Except.orElseLazy` | `Init.Control.Except` |
| `Except.tryCatch` | `Init.Control.Except` |
| `ExceptT.mk` | `Init.Control.Except` |
| `ExceptT.run` | `Init.Control.Except` |
| `Except.bind` | `Init.Control.Except` |
| `liftExcept` | `Init.Control.Except` |
| `observing` | `Init.Control.Except` |
| `Except.map_id` | `Init.Control.Except` |
| `ExceptT.bindCont` | `Init.Control.Except` |
| `Except.map.eq_1` | `Init.Control.Except` |
| `Except.map.eq_2` | `Init.Control.Except` |
| `instReprExcept` | `Init.Data.ToString.Basic` |
| `instToStringExcept` | `Init.Data.ToString.Basic` |
| `runEST` | `Init.System.ST` |
| `ExceptT.mk.eq_1` | `Init.Control.Lawful.Instances` |
| `ExceptT.run.eq_1` | `Init.Control.Lawful.Instances` |
| `ExceptT.run_mk` | `Init.Control.Lawful.Instances` |
| `ExceptT.bindCont.eq_1` | `Init.Control.Lawful.Instances` |
| `ExceptT.ext` | `Init.Control.Lawful.Instances` |
| `ExceptT.ext_iff` | `Init.Control.Lawful.Instances` |
| `ExceptT.pure.eq_1` | `Init.Control.Lawful.Instances` |
| `ExceptT.run_lift` | `Init.Control.Lawful.Instances` |
| `ExceptT.lift.eq_1` | `Init.Control.Lawful.Instances` |
| `ExceptT.bindCont.eq_2` | `Init.Control.Lawful.Instances` |
| `ExceptT.run_throw` | `Init.Control.Lawful.Instances` |
| `ExceptT.run_pure` | `Init.Control.Lawful.Instances` |
| `ExceptT.bind.eq_1` | `Init.Control.Lawful.Instances` |
| `ExceptT.run_monadMap` | `Init.Control.Lawful.Instances` |
| `ExceptT.run_bind_lift` | `Init.Control.Lawful.Instances` |
| `ExceptT.run_map` | `Init.Control.Lawful.Instances` |
| `ExceptT.map.eq_1` | `Init.Control.Lawful.Instances` |
| `ExceptT.run_bind` | `Init.Control.Lawful.Instances` |
| `ExceptT.run_restoreM` | `Init.Control.Lawful.Instances` |
| `ExceptT.run_liftWith` | `Init.Control.Lawful.Instances` |
| `ExceptT.run_control` | `Init.Control.Lawful.Instances` |
| `ExceptT.run_controlAt` | `Init.Control.Lawful.Instances` |
| `ExceptCpsT.run` | `Init.Control.ExceptCps` |
| `ExceptCpsT.run_throw` | `Init.Control.ExceptCps` |
| `ExceptCpsT.run_pure` | `Init.Control.ExceptCps` |
| `ExceptCpsT.run_lift` | `Init.Control.ExceptCps` |
| `ExceptCpsT.run_bind_lift` | `Init.Control.ExceptCps` |
| `ExceptCpsT.run_bind_throw` | `Init.Control.ExceptCps` |
| `Except.pure.eq_1` | `Init.Control.Lawful.MonadLift.Instances` |
| `Except.bind.eq_2` | `Init.Control.Lawful.MonadLift.Instances` |
| `Except.bind.eq_1` | `Init.Control.Lawful.MonadLift.Instances` |
| `Except.instMonad.eq_1` | `Init.Control.Lawful.MonadLift.Instances` |
| `unsafeIO` | `Init.System.IO` |
| `unsafeEIO` | `Init.System.IO` |
| `EIO.ofExcept` | `Init.System.IO` |
| `EIO.toBaseIO` | `Init.System.IO` |
| `EIO.toIO'` | `Init.System.IO` |
| `IO.ofExcept` | `Init.System.IO` |
| `IO.asTask` | `Init.System.IO` |
| `EIO.asTask` | `Init.System.IO` |
| `IO.mapTask` | `Init.System.IO` |
| `EIO.mapTask` | `Init.System.IO` |
| `IO.mapTasks` | `Init.System.IO` |
| `IO.bindTask` | `Init.System.IO` |
| `EIO.mapTasks` | `Init.System.IO` |
| `EIO.bindTask` | `Init.System.IO` |
| `Lean.Order.monotone_exceptTRun` | `Init.Internal.Order.Basic` |

### Lean

| Name | Module |
|------|--------|
| `Lean.Json.getBool?` | `Lean.Data.Json.Basic` |
| `Lean.Json.getInt?` | `Lean.Data.Json.Basic` |
| `Lean.Json.getNat?` | `Lean.Data.Json.Basic` |
| `Lean.Json.getNum?` | `Lean.Data.Json.Basic` |
| `Lean.Json.getStr?` | `Lean.Data.Json.Basic` |
| `Lean.Json.getArr?` | `Lean.Data.Json.Basic` |
| `Lean.Json.getArrVal?` | `Lean.Data.Json.Basic` |
| `Lean.Json.getObjVal?` | `Lean.Data.Json.Basic` |
| `Lean.Json.getObj?` | `Lean.Data.Json.Basic` |
| `Lean.Json.parse` | `Lean.Data.Json.Parser` |
| `Float.fromJson?` | `Lean.Data.Json.FromToJson.Basic` |
| `Lean.bignumFromJson?` | `Lean.Data.Json.FromToJson.Basic` |
| `UInt64.fromJson?` | `Lean.Data.Json.FromToJson.Basic` |
| `USize.fromJson?` | `Lean.Data.Json.FromToJson.Basic` |
| `Lean.Name.fromJson?` | `Lean.Data.Json.FromToJson.Basic` |
| `Lean.Json.Structured.fromJson?` | `Lean.Data.Json.FromToJson.Basic` |
| `Lean.FromJson.fromJson?` | `Lean.Data.Json.FromToJson.Basic` |
| `Lean.FromJson.mk` | `Lean.Data.Json.FromToJson.Basic` |
| `Lean.Json.toStructured?` | `Lean.Data.Json.FromToJson.Basic` |
| `Array.fromJson?` | `Lean.Data.Json.FromToJson.Basic` |
| `List.fromJson?` | `Lean.Data.Json.FromToJson.Basic` |
| `Option.fromJson?` | `Lean.Data.Json.FromToJson.Basic` |
| `Lean.Json.getObjValAs?` | `Lean.Data.Json.FromToJson.Basic` |
| `Lean.NameMap.fromJson?` | `Lean.Data.Json.FromToJson.Basic` |
| `Lean.Json.parseTagged` | `Lean.Data.Json.FromToJson.Basic` |
| `Prod.fromJson?` | `Lean.Data.Json.FromToJson.Basic` |
| `Lean.instFromJsonImport.fromJson` | `Lean.Setup` |
| `Lean.instFromJsonModuleArtifacts.fromJson` | `Lean.Setup` |
| `Lean.instFromJsonModuleHeader.fromJson` | `Lean.Setup` |
| `Lean.instFromJsonModuleSetup.fromJson` | `Lean.Setup` |
| `Lean.Kernel.Environment.addDeclWithoutChecking` | `Lean.Environment` |
| `Lean.Kernel.check` | `Lean.Environment` |
| `Lean.Kernel.whnf` | `Lean.Environment` |
| `Lean.Kernel.isDefEq` | `Lean.Environment` |
| `Lean.Kernel.Environment.addDeclCore` | `Lean.Environment` |
| `Lean.Environment.evalConst` | `Lean.Environment` |
| `Lean.Environment.addDeclCore` | `Lean.Environment` |
| `Lean.instFromJsonPosition.fromJson` | `Lean.Data.Position` |

### Std

| Name | Module |
|------|--------|
| `Std.Do.PredTrans.pushExcept_apply` | `Std.Do.PredTrans` |
| `Std.Do.Except.of_wp` | `Std.Do.WP.Basic` |
| `Except.tryCatch.eq_2` | `Std.Do.WP.SimpLemmas` |
| `Except.mapError.eq_2` | `Std.Do.WP.SimpLemmas` |
| `Except.tryCatch.eq_1` | `Std.Do.WP.SimpLemmas` |
| `Except.mapError.eq_1` | `Std.Do.WP.SimpLemmas` |
| `ExceptT.adapt.eq_1` | `Std.Do.WP.SimpLemmas` |
| `ExceptT.tryCatch.eq_1` | `Std.Do.WP.SimpLemmas` |
| `Std.Do.WP.ExceptT_run` | `Std.Do.WP.SimpLemmas` |
| `Std.Do.WP.tryCatch_Except` | `Std.Do.WP.SimpLemmas` |
| `Std.Do.WP.liftWith_ExceptT` | `Std.Do.WP.SimpLemmas` |
| `Std.Do.WP.orElse_Except` | `Std.Do.WP.SimpLemmas` |
| `Std.Do.WP.restoreM_ExceptT` | `Std.Do.WP.SimpLemmas` |
| `Std.Do.WP.throw_lift_ExceptT` | `Std.Do.WP.SimpLemmas` |
| `Std.Do.WP.monadMap_ExceptT` | `Std.Do.WP.SimpLemmas` |
| `Std.Do.WP.tryCatch_lift_ExceptT` | `Std.Do.WP.SimpLemmas` |
| `Std.Do.Spec.run_ExceptT` | `Std.Do.Triple.SpecLemmas` |
| `Std.Do.Spec.tryCatch_Except` | `Std.Do.Triple.SpecLemmas` |
| `Std.Do.Spec.liftWith_ExceptT` | `Std.Do.Triple.SpecLemmas` |
| `Std.Do.Spec.orElse_Except` | `Std.Do.Triple.SpecLemmas` |
| `Std.Do.Spec.throw_ExceptT_lift` | `Std.Do.Triple.SpecLemmas` |
| `Std.Do.Spec.monadMap_ExceptT` | `Std.Do.Triple.SpecLemmas` |
| `Std.Do.Spec.tryCatch_ExceptT_lift` | `Std.Do.Triple.SpecLemmas` |
| `Std.Do.Spec.restoreM_ExceptT` | `Std.Do.Triple.SpecLemmas` |
| `Std.Internal.IO.Async.Async.ofExcept` | `Std.Internal.Async.Basic` |
| `Std.Internal.IO.Async.BaseAsync.ofExcept` | `Std.Internal.Async.Basic` |
| `Std.Internal.IO.Async.EAsync.ofExcept` | `Std.Internal.Async.Basic` |
| `Std.Internal.IO.Async.ETask.ofPromise!` | `Std.Internal.Async.Basic` |
| `Std.Internal.IO.Async.AsyncTask.ofPromise` | `Std.Internal.Async.Basic` |
| `Std.Internal.IO.Async.Async.ofPromise` | `Std.Internal.Async.Basic` |
| `Std.Internal.IO.Async.Waiter.promise` | `Std.Internal.Async.Select` |
| `Std.Internal.IO.Async.Waiter.withPromise` | `Std.Internal.Async.Select` |
| `Std.Internal.IO.Async.Waiter.race` | `Std.Internal.Async.Select` |
| `Std.CloseableChannel.send` | `Std.Sync.Channel` |
| `Std.Broadcast.send` | `Std.Sync.Broadcast` |
| `Std.Time.TimeZone.Transition.timezoneAt` | `Std.Time.Zoned.ZoneRules` |
| `Std.Internal.Parsec.String.Parser.run` | `Std.Internal.Parsec.String` |
| `Std.Internal.Parsec.ByteArray.Parser.run` | `Std.Internal.Parsec.ByteArray` |
| `Std.Time.TimeZone.convertTZif` | `Std.Time.Zoned.Database.Basic` |
| `Std.Time.TimeZone.convertTZifV1` | `Std.Time.Zoned.Database.Basic` |
| `Std.Time.TimeZone.convertTZifV2` | `Std.Time.Zoned.Database.Basic` |
| `Std.Time.Database.TZdb.parseTZif` | `Std.Time.Zoned.Database.TZdb` |
| `Std.Time.GenericFormat.parse` | `Std.Time.Format.Basic` |
| `Std.Time.GenericFormat.spec` | `Std.Time.Format.Basic` |
| `Std.Time.GenericFormat.parseBuilder` | `Std.Time.Format.Basic` |
| `Std.Time.Format.parse` | `Std.Time.Format.Basic` |
| `Std.Time.Format.mk` | `Std.Time.Format.Basic` |
| `Std.Time.PlainDate.fromAmericanDateString` | `Std.Time.Format` |
| `Std.Time.PlainDate.fromLeanDateString` | `Std.Time.Format` |
| `Std.Time.PlainDate.fromSQLDateString` | `Std.Time.Format` |
| `Std.Time.PlainDate.parse` | `Std.Time.Format` |
| `Std.Time.PlainDateTime.fromAscTimeString` | `Std.Time.Format` |
| `Std.Time.PlainDateTime.fromDateTimeString` | `Std.Time.Format` |
| `Std.Time.PlainDateTime.fromLeanDateTimeString` | `Std.Time.Format` |
| `Std.Time.PlainDateTime.fromLongDateFormatString` | `Std.Time.Format` |
| `Std.Time.PlainDateTime.parse` | `Std.Time.Format` |
| `Std.Time.PlainTime.fromLeanTime24Hour` | `Std.Time.Format` |
| `Std.Time.PlainTime.fromTime12Hour` | `Std.Time.Format` |
| `Std.Time.PlainTime.fromTime24Hour` | `Std.Time.Format` |
| `Std.Time.PlainTime.parse` | `Std.Time.Format` |
| `Std.Time.TimeZone.fromTimeZone` | `Std.Time.Format` |
| `Std.Time.ZonedDateTime.fromDateTimeWithZoneString` | `Std.Time.Format` |
| `Std.Time.ZonedDateTime.fromISO8601String` | `Std.Time.Format` |
| `Std.Time.ZonedDateTime.fromLeanDateTimeWithIdentifierString` | `Std.Time.Format` |
| `Std.Time.ZonedDateTime.fromLeanDateTimeWithZoneString` | `Std.Time.Format` |
| `Std.Time.ZonedDateTime.fromRFC822String` | `Std.Time.Format` |
| `Std.Time.ZonedDateTime.fromRFC850String` | `Std.Time.Format` |
| `Std.Time.ZonedDateTime.parse` | `Std.Time.Format` |
| `Std.Time.TimeZone.Offset.fromOffset` | `Std.Time.Format` |
| `Std.Time.DateTime.fromAscTimeString` | `Std.Time.Format` |
| `Std.Time.DateTime.fromLongDateFormatString` | `Std.Time.Format` |
| `Std.Time.DateTime.parse` | `Std.Time.Format` |
| `Std.Tactic.BVDecide.LRAT.parseLRATProof` | `Std.Tactic.BVDecide.LRAT.Parser` |
| `Std.Internal.UV.TCP.Socket.accept` | `Std.Internal.UV.TCP` |
| `Std.Internal.UV.TCP.Socket.shutdown` | `Std.Internal.UV.TCP` |
| `Std.Internal.UV.TCP.Socket.tryAccept` | `Std.Internal.UV.TCP` |
| `Std.Internal.UV.TCP.Socket.waitReadable` | `Std.Internal.UV.TCP` |
| `Std.Internal.UV.TCP.Socket.connect` | `Std.Internal.UV.TCP` |
| `Std.Internal.UV.TCP.Socket.recv?` | `Std.Internal.UV.TCP` |
| `Std.Internal.UV.TCP.Socket.send` | `Std.Internal.UV.TCP` |
| `Std.Internal.UV.UDP.Socket.waitReadable` | `Std.Internal.UV.UDP` |
| `Std.Internal.UV.UDP.Socket.recv` | `Std.Internal.UV.UDP` |
| `Std.Internal.UV.UDP.Socket.send` | `Std.Internal.UV.UDP` |
| `Std.Internal.UV.System.random` | `Std.Internal.UV.System` |
| `Std.Internal.UV.DNS.getNameInfo` | `Std.Internal.UV.DNS` |
| `Std.Internal.UV.DNS.getAddrInfo` | `Std.Internal.UV.DNS` |

## Usage Recommendations

### Core Functions

1. **Creating Except values:**
   - `Except.ok` - Wrap a success value
   - `Except.error` - Wrap an error value

2. **Working with Except:**
   - `Except.map` - Transform success values
   - `Except.mapError` - Transform error values
   - `Except.bind` - Chain operations
   - `Except.tryCatch` - Handle errors

3. **Conversions:**
   - `Except.toOption` - Convert to Option (loses error info)
   - `EIO.ofExcept` - Lift to IO
   - `IO.ofExcept` - Lift to IO with ToString constraint

4. **Monad Transformer:**
   - `ExceptT.mk` - Wrap monadic Except
   - `ExceptT.run` - Unwrap to monadic Except
   - `ExceptT.lift` - Lift base monad

### Integration with Logos Project

For the Logos proof system, `Except` could be useful for:

- **Proof validation:** Return errors when proofs are invalid
- **Tactic execution:** Handle failures in automated tactics
- **Formula parsing:** Report syntax errors
- **Derivation checking:** Validate proof steps with error reporting

---

**Report generated:** 551 heartbeats
**Note:** This report shows the first 200 of 583 total matches due to API limitations.
