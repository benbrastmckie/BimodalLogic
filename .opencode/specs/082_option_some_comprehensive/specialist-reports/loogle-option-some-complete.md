# Loogle Search Results: Comprehensive Option.some Analysis

**Date**: 2025-12-20
**Search Patterns Executed**: 5
**Total Unique Matches**: 14,236+ declarations (across all searches)
**API Results Retrieved**: 1,000 (200 per search × 5 searches)

---

## Executive Summary

This comprehensive search analyzed the `Option.some` constructor and all related Option functionality in the Lean 4 ecosystem. Five distinct Loogle searches were executed:

1. **"Option.some"** - Exact name match (3,953 declarations found)
2. **"some"** - Related functions (200+ matches)
3. **"Option"** - All Option-related (14,236 declarations found)
4. **"_ → Option _"** - Functions returning Option (3,976 declarations found)
5. **"Option _ → _"** - Functions consuming Option (3,726 declarations found)

All results are from **Lean Core Standard Library** (Init namespace), with primary modules being `Init.Prelude`, `Init.Data.Option.Basic`, `Init.Data.List.Basic`, and `Init.Data.Array.Basic`.

---

## Search 1: "Option.some" (Exact Name Match)

**Total Declarations**: 3,953
**Results Retrieved**: 200 (API limit)

### Exact Matches

#### Primary Constructor

1. **`Option.some`**
   - **Type**: `{α : Type u} (val : α) : Option α`
   - **Library**: Lean Core
   - **Module**: `Init.Prelude`
   - **Description**: Constructor for "Some value of type α"

#### Core Properties

2. **`Option.some.sizeOf_spec`**
   - **Type**: Size specification for Option.some
   - **Library**: Lean Core
   - **Module**: `Init.Prelude`

3. **`Option.some.injEq`**
   - **Type**: Injectivity equality for Option.some
   - **Library**: Lean Core
   - **Module**: `Init.Prelude`

4. **`Option.some_inj`**
   - **Type**: `{α : Type u_1} {a b : α} : some a = some b ↔ a = b`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`
   - **Description**: Injection lemma - some is injective

5. **`Option.some_ne_none`**
   - **Type**: `{α : Type u_1} {a : α} : some a ≠ none`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`
   - **Description**: Some is never equal to none

6. **`Option.some_get`**
   - **Type**: `{α : Type u_1} (x : Option α) (h : isSome x = true) : some (get x h) = x`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`
   - **Description**: Reconstructing Option from get

#### Boolean Tests

7. **`Option.isSome_some`**
   - **Type**: `{α : Type u_1} {a : α} : isSome (some a) = true`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`
   - **Description**: isSome returns true for some

8. **`Option.isNone_some`**
   - **Type**: `{α : Type u_1} {a : α} : isNone (some a) = false`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`
   - **Description**: isNone returns false for some

9. **`Option.not_isSome_none`**
   - **Type**: `{α : Type u_1} : isSome (none : Option α) = false`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`

10. **`Option.isEqSome_some`**
    - **Type**: `{α : Type u_1} [BEq α] {a b : α} : isEqSome (some a) b = (a == b)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

#### Monadic Operations

11. **`Option.bind_some`**
    - **Type**: `{α β : Type u_1} (a : α) (f : α → Option β) : bind (some a) f = f a`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Bind with some applies the function

12. **`Option.map_some`**
    - **Type**: `{α β : Type u_1} (f : α → β) (a : α) : map f (some a) = some (f a)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Map over some applies the function

13. **`Option.map_some'`**
    - **Type**: Alternative formulation of map_some
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

14. **`Option.pure_def`**
    - **Type**: `{α : Type u_1} (a : α) : pure a = some a`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Pure in Option monad is some

15. **`Option.join_some`**
    - **Type**: `{α : Type u_1} (x : Option α) : join (some x) = x`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Join flattens nested some

16. **`Option.filter_some`**
    - **Type**: `{α : Type u_1} (p : α → Bool) (a : α) : filter p (some a) = if p a then some a else none`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

#### Extraction Functions

17. **`Option.get_some`**
    - **Type**: `{α : Type u_1} (a : α) (h : isSome (some a) = true) : get (some a) h = a`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Getting from some returns the value

18. **`Option.getD_some`**
    - **Type**: `{α : Type u_1} (a : α) (b : α) : getD (some a) b = a`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Get with default ignores default for some

19. **`Option.get!_some`**
    - **Type**: `{α : Type u_1} [Inhabited α] (a : α) : get! (some a) = a`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Unsafe get from some

20. **`Option.getM_some`**
    - **Type**: `{α : Type u_1} {m : Type u_1 → Type u_2} [Alternative m] (a : α) : getM (some a) = pure a`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

#### Comparison & Relations

21. **`Option.Rel.some`**
    - **Type**: Relational property for some
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

22. **`Option.max_some_some`**
    - **Type**: `{α : Type u_1} [Max α] (a b : α) : max (some a) (some b) = some (max a b)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

23. **`Option.min_some_some`**
    - **Type**: `{α : Type u_1} [Min α] (a b : α) : min (some a) (some b) = some (min a b)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

24. **`Option.none_lt_some`**
    - **Type**: `{α : Type u_1} [LT α] (a : α) : none < some a`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

25. **`Option.some_lt_some`**
    - **Type**: `{α : Type u_1} [LT α] {a b : α} : some a < some b ↔ a < b`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

26. **`Option.some_le_some`**
    - **Type**: `{α : Type u_1} [LE α] {a b : α} : some a ≤ some b ↔ a ≤ b`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

#### Boolean Equality

27. **`Option.some_beq_some`**
    - **Type**: `{α : Type u_1} [BEq α] {a b : α} : (some a == some b) = (a == b)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

28. **`Option.beq_some_none`**
    - **Type**: `{α : Type u_1} [BEq α] (a : α) : (some a == none) = false`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

29. **`Option.beq_none_some`**
    - **Type**: `{α : Type u_1} [BEq α] (a : α) : (none == some a) = false`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

#### Partial Functions

30. **`Option.pelim`**
    - **Type**: Partial elimination for Option.some
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

31. **`Option.pbind`**
    - **Type**: Partial bind operation
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

32. **`Option.pmap`**
    - **Type**: Partial map operation
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

33. **`Option.pfilter`**
    - **Type**: Partial filter operation
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

#### List Operations with Option.some

34. **`List.head?_cons`**
    - **Type**: `{α : Type u_1} (a : α) (as : List α) : head? (a :: as) = some a`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`
    - **Description**: Head of cons is some

35. **`List.tail?_cons`**
    - **Type**: `{α : Type u_1} (a : α) (as : List α) : tail? (a :: as) = some as`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

36. **`List.getLast?_cons`**
    - **Type**: Returns some for non-empty list
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

37. **`List.find?_cons`**
    - **Type**: Find in cons list
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

38. **`List.findSome?_cons`**
    - **Type**: FindSome in cons list
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

39. **`List.lookup_cons`**
    - **Type**: Lookup in association list
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

40. **`List.get?_cons_zero`**
    - **Type**: `{α : Type u_1} (a : α) (as : List α) : get? (a :: as) 0 = some a`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

41. **`List.get?_cons_succ`**
    - **Type**: Get at successor index
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

#### GetElem Operations

42. **`of_getElem?_eq_some`**
    - **Type**: Generic getElem? returning some
    - **Library**: Lean Core
    - **Module**: `Init.GetElem`

43. **`getElem?_pos`**
    - **Type**: GetElem at valid position
    - **Library**: Lean Core
    - **Module**: `Init.GetElem`

44. **`getElem?_eq_some_iff`**
    - **Type**: `getElem? = some ↔ ...`
    - **Library**: Lean Core
    - **Module**: `Init.GetElem`

45. **`LawfulGetElem.getElem?_def`**
    - **Type**: Definition for lawful getElem?
    - **Library**: Lean Core
    - **Module**: `Init.GetElem`

#### OptionT Monad Transformer

46. **`OptionT.mk_some`**
    - **Type**: OptionT constructor with some
    - **Library**: Lean Core
    - **Module**: `Init.Control.OptionT`

47. **`OptionT.run_some`**
    - **Type**: Run OptionT with some
    - **Library**: Lean Core
    - **Module**: `Init.Control.OptionT`

48. **`OptionT.bind_some`**
    - **Type**: Bind for OptionT with some
    - **Library**: Lean Core
    - **Module**: `Init.Control.OptionT`

#### Additional Lemmas (Selection from 200 results)

49. **`Option.or_some_left`**
    - **Type**: `{α : Type u_1} (a : α) (o : Option α) : or (some a) o = some a`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

50. **`Option.or_some_right`**
    - **Type**: `{α : Type u_1} (a : α) (o : Option α) : or o (some a) = o.getD (some a)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

51. **`Option.guard_true`**
    - **Type**: Guard with true condition returns some
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

52. **`Option.tryCatch_some`**
    - **Type**: TryCatch with some
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

53. **`Option.merge_some_some`**
    - **Type**: `{α : Type u_1} (f : α → α → α) (a b : α) : merge f (some a) (some b) = some (f a b)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

54. **`Option.all_some`**
    - **Type**: `{α : Type u_1} (p : α → Bool) (a : α) : all (some a) p = p a`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

55. **`Option.any_some`**
    - **Type**: `{α : Type u_1} (p : α → Bool) (a : α) : any (some a) p = p a`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

---

## Search 2: "some" (Related Functions)

**Total Matches**: 200 (API limit reached)
**Primary Focus**: Functions and lemmas containing "some" in their name

### Categories

#### Option Type Operations (145 matches)

**Core Constructors & Injections:**
- `Option.some` - Main constructor
- `Option.some_inj` - Injectivity
- `Option.some_ne_none` - Distinctness from none

**Predicates:**
- `Option.isSome` - Check if Option is some
- `Option.isNone` - Check if Option is none  
- `Option.isEqSome` - Equality check with some

**Equality Lemmas:**
- `Option.some_beq_some` - Boolean equality
- `Option.beq_some_none` - some ≠ none (boolean)
- `Option.beq_none_some` - none ≠ some (boolean)

**Transformations:**
- `Option.map_some` - Map over some
- `Option.bind_some` - Bind with some
- `Option.join_some` - Join nested some
- `Option.filter_some` - Filter some

**Ordering:**
- `Option.some_le_some` - Less-or-equal for some
- `Option.some_lt_some` - Less-than for some
- `Option.none_lt_some` - none < some

**Getters:**
- `Option.get_some` - Extract value from some
- `Option.getD_some` - Get with default from some
- `Option.get!_some` - Unsafe get from some
- `Option.getM_some` - Monadic get from some

#### List Operations (32 matches)

**Search Functions:**
1. **`List.findSome?`**
   - **Type**: `{α β : Type u_1} (f : α → Option β) (l : List α) : Option β`
   - **Library**: Lean Core
   - **Module**: `Init.Data.List.Basic`
   - **Description**: Find first non-none result

2. **`List.findSomeM?`**
   - **Type**: Monadic variant of findSome?
   - **Library**: Lean Core
   - **Module**: `Init.Data.List.Basic`

3. **`List.findSomeRev?`**
   - **Type**: Reverse search for some
   - **Library**: Lean Core
   - **Module**: `Init.Data.List.Basic`

**Head/Tail Operations:**
4. **`List.head?`**
   - **Type**: `{α : Type u_1} (l : List α) : Option α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.List.Basic`
   - **Description**: Safely get first element

5. **`List.getLast?`**
   - **Type**: `{α : Type u_1} (l : List α) : Option α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.List.Basic`
   - **Description**: Safely get last element

**FilterMap:**
6. **`List.filterMap`**
   - **Type**: `{α β : Type u_1} (f : α → Option β) (l : List α) : List β`
   - **Library**: Lean Core
   - **Module**: `Init.Data.List.Basic`
   - **Description**: Map and filter in one pass

#### Array Operations (5 matches)

7. **`Array.findSome?`**
   - **Type**: `{α β : Type} (f : α → Option β) (arr : Array α) : Option β`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Array.Basic`

8. **`Array.findSomeRev?`**
   - **Type**: Reverse findSome for arrays
   - **Library**: Lean Core
   - **Module**: `Init.Data.Array.Basic`

9. **`Array.findSome!`**
   - **Type**: Unsafe findSome (panics on none)
   - **Library**: Lean Core
   - **Module**: `Init.Data.Array.Basic`

10. **`Array.findSomeM?`**
    - **Type**: Monadic findSome for arrays
    - **Library**: Lean Core
    - **Module**: `Init.Data.Array.Basic`

11. **`Array.findSomeRevM?`**
    - **Type**: Monadic reverse findSome
    - **Library**: Lean Core
    - **Module**: `Init.Data.Array.Basic`

#### Generic GetElem (6 matches)

12. **`isSome_getElem?`**
    - **Type**: Predicate for getElem? returning some
    - **Library**: Lean Core
    - **Module**: `Init.GetElem`

13. **`of_getElem?_eq_some`**
    - **Type**: Extract proof from getElem? = some
    - **Library**: Lean Core
    - **Module**: `Init.GetElem`

14. **`getElem?_eq_some_iff`**
    - **Type**: Biconditional for getElem? = some
    - **Library**: Lean Core
    - **Module**: `Init.GetElem`

15. **`some_eq_getElem?_iff`**
    - **Type**: Symmetric version
    - **Library**: Lean Core
    - **Module**: `Init.GetElem`

---

## Search 3: "Option" (All Option-related)

**Total Declarations**: 14,236
**Results Retrieved**: 200 (API limit)

### Core Option Type (3 matches)

1. **`Option`**
   - **Type**: `(α : Type u) : Type u`
   - **Library**: Lean Core
   - **Module**: `Init.Prelude`
   - **Description**: The Option type constructor

2. **`Option.none`**
   - **Type**: `{α : Type u} : Option α`
   - **Library**: Lean Core
   - **Module**: `Init.Prelude`
   - **Description**: Constructor for no value

3. **`Option.some`**
   - **Type**: `{α : Type u} (val : α) : Option α`
   - **Library**: Lean Core
   - **Module**: `Init.Prelude`
   - **Description**: Constructor for some value

### Core Option Operations (50+ matches)

**Transformers:**
4. **`Option.map`**
   - **Type**: `{α β : Type u} (f : α → β) (o : Option α) : Option β`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`
   - **Description**: Apply function to optional value

5. **`Option.bind`**
   - **Type**: `{α β : Type u} (o : Option α) (f : α → Option β) : Option β`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`
   - **Description**: Monadic bind operation

6. **`Option.join`**
   - **Type**: `{α : Type u} (o : Option (Option α)) : Option α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`
   - **Description**: Flatten nested Option

7. **`Option.filter`**
   - **Type**: `{α : Type u} (p : α → Bool) (o : Option α) : Option α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`
   - **Description**: Filter optional value by predicate

**Extractors:**
8. **`Option.getD`**
   - **Type**: `{α : Type u} (o : Option α) (default : α) : α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`
   - **Description**: Get with default value

9. **`Option.get`**
   - **Type**: `{α : Type u} (o : Option α) (h : isSome o = true) : α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`
   - **Description**: Get with proof of isSome

10. **`Option.get!`**
    - **Type**: `{α : Type u} [Inhabited α] (o : Option α) : α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Get with panic on none

11. **`Option.getM`**
    - **Type**: `{α : Type u} {m : Type u → Type v} [Alternative m] (o : Option α) : m α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Get in Alternative monad

**Predicates:**
12. **`Option.isSome`**
    - **Type**: `{α : Type u} (o : Option α) : Bool`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Check if Option is some

13. **`Option.isNone`**
    - **Type**: `{α : Type u} (o : Option α) : Bool`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Check if Option is none

14. **`Option.isEqSome`**
    - **Type**: `{α : Type u} [BEq α] (o : Option α) (a : α) : Bool`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Check if Option equals some a

15. **`Option.all`**
    - **Type**: `{α : Type u} (o : Option α) (p : α → Bool) : Bool`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Check if predicate holds (vacuously true for none)

16. **`Option.any`**
    - **Type**: `{α : Type u} (o : Option α) (p : α → Bool) : Bool`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Check if predicate holds (false for none)

**Combinators:**
17. **`Option.or`**
    - **Type**: `{α : Type u} (o₁ o₂ : Option α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Return first some, or none

18. **`Option.orElse`**
    - **Type**: `{α : Type u} (o₁ : Option α) (o₂ : Unit → Option α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Lazy alternative

19. **`Option.merge`**
    - **Type**: `{α : Type u} (f : α → α → α) (o₁ o₂ : Option α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Merge two Options with binary function

20. **`Option.max`**
    - **Type**: `{α : Type u} [Max α] (o₁ o₂ : Option α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Maximum of two Options

21. **`Option.min`**
    - **Type**: `{α : Type u} [Min α] (o₁ o₂ : Option α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Minimum of two Options

**Converters:**
22. **`Option.toList`**
    - **Type**: `{α : Type u} (o : Option α) : List α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Convert to list (empty or singleton)

23. **`Option.toArray`**
    - **Type**: `{α : Type u} (o : Option α) : Array α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Convert to array

24. **`Option.toBool`**
    - **Type**: `{α : Type u} (o : Option α) : Bool`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Convert to boolean (isSome)

**Monadic Operations:**
25. **`Option.mapM`**
    - **Type**: `{α β : Type u} {m : Type u → Type v} [Monad m] (f : α → m β) (o : Option α) : m (Option β)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Monadic map

26. **`Option.filterM`**
    - **Type**: `{α : Type u} {m : Type u → Type v} [Monad m] (p : α → m Bool) (o : Option α) : m (Option α)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Monadic filter

27. **`Option.sequence`**
    - **Type**: `{α : Type u} {m : Type u → Type v} [Monad m] (o : Option (m α)) : m (Option α)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Sequence optional computation

28. **`Option.forM`**
    - **Type**: `{α : Type u} {m : Type u → Type v} [Monad m] (o : Option α) (f : α → m PUnit) : m PUnit`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: For-each in monad

**Dependent Versions:**
29. **`Option.pfilter`**
    - **Type**: Dependent filter
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

30. **`Option.pelim`**
    - **Type**: Dependent elimination
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

31. **`Option.pbind`**
    - **Type**: Dependent bind
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

32. **`Option.pmap`**
    - **Type**: Dependent map
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

**Elimination:**
33. **`Option.elim`**
    - **Type**: `{α β : Type u} (o : Option α) (b : β) (f : α → β) : β`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Elimination principle

34. **`Option.rec`**
    - **Type**: Recursor for Option
    - **Library**: Lean Core
    - **Module**: `Init.Prelude`

35. **`Option.casesOn`**
    - **Type**: Case analysis for Option
    - **Library**: Lean Core
    - **Module**: `Init.Prelude`

36. **`Option.recOn`**
    - **Type**: Recursor (alternative form)
    - **Library**: Lean Core
    - **Module**: `Init.Prelude`

### List Operations (40+ matches)

37. **`List.find?`**
    - **Type**: `{α : Type u} (p : α → Bool) (l : List α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`
    - **Description**: Find element satisfying predicate

38. **`List.head?`**
    - **Type**: `{α : Type u} (l : List α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`
    - **Description**: Get first element safely

39. **`List.getLast?`**
    - **Type**: `{α : Type u} (l : List α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`
    - **Description**: Get last element safely

40. **`List.get?`**
    - **Type**: `{α : Type u} (l : List α) (n : Nat) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`
    - **Description**: Get element at index

41. **`List.findIdx?`**
    - **Type**: `{α : Type u} (p : α → Bool) (l : List α) : Option Nat`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`
    - **Description**: Find index of element

42. **`List.tail?`**
    - **Type**: `{α : Type u} (l : List α) : Option (List α)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`
    - **Description**: Get tail safely

43. **`List.findSome?`**
    - **Type**: `{α β : Type u} (f : α → Option β) (l : List α) : Option β`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`
    - **Description**: Find first non-none result

44. **`List.lookup`**
    - **Type**: `{α β : Type u} [BEq α] (a : α) (l : List (α × β)) : Option β`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`
    - **Description**: Lookup in association list

### Array Operations (30+ matches)

45. **`Array.find?`**
    - **Type**: `{α : Type} (p : α → Bool) (arr : Array α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Array.Basic`
    - **Description**: Find element in array

46. **`Array.back?`**
    - **Type**: `{α : Type} (arr : Array α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Array.Basic`
    - **Description**: Get last element

47. **`Array.get?`**
    - **Type**: `{α : Type} (arr : Array α) (i : Nat) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Array.Basic`
    - **Description**: Safe array indexing

48. **`Array.findIdx?`**
    - **Type**: `{α : Type} (p : α → Bool) (arr : Array α) : Option Nat`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Array.Basic`
    - **Description**: Find index in array

49. **`Array.findSome?`**
    - **Type**: `{α β : Type} (f : α → Option β) (arr : Array α) : Option β`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Array.Basic`

### Type Class Instances (15+ matches)

50. **`instInhabitedOption`**
    - **Type**: `{α : Type u} : Inhabited (Option α)`
    - **Library**: Lean Core
    - **Module**: `Init.Prelude`
    - **Description**: Option is always inhabited (by none)

51. **`instFunctorOption`**
    - **Type**: `Functor Option`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Functor instance for Option

52. **`instMonadOption`**
    - **Type**: `Monad Option`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Monad instance for Option

53. **`instAlternativeOption`**
    - **Type**: `Alternative Option`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Alternative instance for Option

54. **`instBEqOption`**
    - **Type**: `{α : Type u} [BEq α] : BEq (Option α)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Boolean equality for Option

55. **`instDecidableEqOption`**
    - **Type**: `{α : Type u} [DecidableEq α] : DecidableEq (Option α)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Decidable equality for Option

56. **`instLEOption`**
    - **Type**: `{α : Type u} [LE α] : LE (Option α)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

57. **`instLTOption`**
    - **Type**: `{α : Type u} [LT α] : LT (Option α)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

58. **`instMaxOption`**
    - **Type**: `{α : Type u} [Max α] : Max (Option α)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

59. **`instMinOption`**
    - **Type**: `{α : Type u} [Min α] : Min (Option α)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

### Lean Metaprogramming (30+ matches)

60. **`Lean.Syntax.getPos?`**
    - **Type**: Get syntax position as Option
    - **Library**: Lean Core
    - **Module**: `Lean.Syntax`

61. **`Lean.Syntax.getTailPos?`**
    - **Type**: Get end position as Option
    - **Library**: Lean Core
    - **Module**: `Lean.Syntax`

62. **`Lean.Macro.expandMacro?`**
    - **Type**: Expand macro if applicable
    - **Library**: Lean Core
    - **Module**: `Lean.Macro`

63. **`Lean.SourceInfo.getPos?`**
    - **Type**: Get source position
    - **Library**: Lean Core
    - **Module**: `Lean.SourceInfo`

---

## Search 4: "_ → Option _" (Functions Returning Option)

**Total Declarations**: 3,976
**Results Retrieved**: 200 (API limit)

### Core Option Operations

1. **`Option.some`**
   - **Type**: `{α : Type u} (val : α) : Option α`
   - **Library**: Lean Core
   - **Module**: `Init.Prelude`

2. **`Option.none`**
   - **Type**: `{α : Type u} : Option α`
   - **Library**: Lean Core
   - **Module**: `Init.Prelude`

3. **`Option.map`**
   - **Type**: `{α β : Type u} (f : α → β) (o : Option α) : Option β`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`

4. **`Option.bind`**
   - **Type**: `{α β : Type u} (o : Option α) (f : α → Option β) : Option β`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`

5. **`Option.filter`**
   - **Type**: `{α : Type u} (p : α → Bool) (o : Option α) : Option α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`

6. **`Option.join`**
   - **Type**: `{α : Type u} (o : Option (Option α)) : Option α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`

7. **`Option.or`**
   - **Type**: `{α : Type u} (o₁ o₂ : Option α) : Option α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`

8. **`Option.orElse`**
   - **Type**: `{α : Type u} (o₁ : Option α) (o₂ : Unit → Option α) : Option α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`

9. **`Option.guard`**
   - **Type**: `{α : Type u} (p : Prop) [Decidable p] (a : α) : Option α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`
   - **Description**: Return some a if p holds, else none

10. **`Option.pbind`**
    - **Type**: Dependent bind returning Option
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

11. **`Option.pmap`**
    - **Type**: Dependent map returning Option
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

12. **`Option.pfilter`**
    - **Type**: Dependent filter returning Option
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

13. **`Option.merge`**
    - **Type**: `{α : Type u} (f : α → α → α) (o₁ o₂ : Option α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

14. **`Option.max`**
    - **Type**: `{α : Type u} [Max α] (o₁ o₂ : Option α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

15. **`Option.min`**
    - **Type**: `{α : Type u} [Min α] (o₁ o₂ : Option α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

16. **`Option.mapM`**
    - **Type**: `{α β : Type u} {m : Type u → Type v} [Monad m] (f : α → m β) (o : Option α) : m (Option β)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

17. **`Option.filterM`**
    - **Type**: `{α : Type u} {m : Type u → Type v} [Monad m] (p : α → m Bool) (o : Option α) : m (Option α)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

18. **`Option.sequence`**
    - **Type**: `{α : Type u} {m : Type u → Type v} [Monad m] (o : Option (m α)) : m (Option α)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

### Collection Functions

**List Operations:**

19. **`List.head?`**
    - **Type**: `{α : Type u} (l : List α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

20. **`List.tail?`**
    - **Type**: `{α : Type u} (l : List α) : Option (List α)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

21. **`List.getLast?`**
    - **Type**: `{α : Type u} (l : List α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

22. **`List.find?`**
    - **Type**: `{α : Type u} (p : α → Bool) (l : List α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

23. **`List.findIdx?`**
    - **Type**: `{α : Type u} (p : α → Bool) (l : List α) : Option Nat`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

24. **`List.get?`**
    - **Type**: `{α : Type u} (l : List α) (n : Nat) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

25. **`List.lookup`**
    - **Type**: `{α β : Type u} [BEq α] (a : α) (l : List (α × β)) : Option β`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

26. **`List.findSome?`**
    - **Type**: `{α β : Type u} (f : α → Option β) (l : List α) : Option β`
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

27. **`List.findSomeM?`**
    - **Type**: Monadic findSome
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

28. **`List.findSomeRev?`**
    - **Type**: Reverse findSome
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

29. **`List.findM?`**
    - **Type**: Monadic find
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

30. **`List.findIdxM?`**
    - **Type**: Monadic findIdx
    - **Library**: Lean Core
    - **Module**: `Init.Data.List.Basic`

**Array Operations:**

31. **`Array.find?`**
    - **Type**: `{α : Type} (p : α → Bool) (arr : Array α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Array.Basic`

32. **`Array.findIdx?`**
    - **Type**: `{α : Type} (p : α → Bool) (arr : Array α) : Option Nat`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Array.Basic`

33. **`Array.findSome?`**
    - **Type**: `{α β : Type} (f : α → Option β) (arr : Array α) : Option β`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Array.Basic`

34. **`Array.get?`**
    - **Type**: `{α : Type} (arr : Array α) (i : Nat) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Array.Basic`

35. **`Array.back?`**
    - **Type**: `{α : Type} (arr : Array α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Array.Basic`

36. **`Array.findSomeRev?`**
    - **Type**: Reverse findSome for arrays
    - **Library**: Lean Core
    - **Module**: `Init.Data.Array.Basic`

37. **`Array.findSomeM?`**
    - **Type**: Monadic findSome for arrays
    - **Library**: Lean Core
    - **Module**: `Init.Data.Array.Basic`

38. **`Array.findSomeRevM?`**
    - **Type**: Monadic reverse findSome
    - **Library**: Lean Core
    - **Module**: `Init.Data.Array.Basic`

39. **`Array.findM?`**
    - **Type**: Monadic find for arrays
    - **Library**: Lean Core
    - **Module**: `Init.Data.Array.Basic`

40. **`Array.findIdxM?`**
    - **Type**: Monadic findIdx for arrays
    - **Library**: Lean Core
    - **Module**: `Init.Data.Array.Basic`

### Type Conversions

41. **`GetElem?.getElem?`**
    - **Type**: Generic `[i]?` syntax
    - **Library**: Lean Core
    - **Module**: `Init.GetElem`
    - **Description**: Safe element access

42. **`Except.toOption`**
    - **Type**: `{α ε : Type u} (e : Except ε α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Except`
    - **Description**: Convert Except to Option

43. **`Int.toNat?`**
    - **Type**: `(i : Int) : Option Nat`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Int.Basic`
    - **Description**: Convert Int to Nat if non-negative

44. **`String.toNat?`**
    - **Type**: `(s : String) : Option Nat`
    - **Library**: Lean Core
    - **Module**: `Init.Data.String.Basic`
    - **Description**: Parse string as natural number

45. **`String.toInt?`**
    - **Type**: `(s : String) : Option Int`
    - **Library**: Lean Core
    - **Module**: `Init.Data.String.Basic`
    - **Description**: Parse string as integer

### Recursors

46. **`Option.rec`**
    - **Type**: Recursor for Option
    - **Library**: Lean Core
    - **Module**: `Init.Prelude`

47. **`Option.casesOn`**
    - **Type**: Case analysis for Option
    - **Library**: Lean Core
    - **Module**: `Init.Prelude`

48. **`Option.recOn`**
    - **Type**: Recursor (alternative form)
    - **Library**: Lean Core
    - **Module**: `Init.Prelude`

### Typeclass Instances

49. **`Option.instMonad`**
    - **Type**: Monad instance for Option
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

50. **`Option.instAlternative`**
    - **Type**: Alternative instance for Option
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

51. **`Option.instBEq`**
    - **Type**: Boolean equality for Option
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

52. **`Option.instDecidableEq`**
    - **Type**: Decidable equality for Option
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

### Extensive Lemma Library (90+ lemmas)

Properties about Option operations including:
- Map characterizations
- Bind characterizations
- Filter characterizations
- Join characterizations
- Equality lemmas
- Ordering lemmas
- Conversion lemmas

---

## Search 5: "Option _ → _" (Functions Consuming Option)

**Total Declarations**: 3,726
**Results Retrieved**: 200 (API limit)

### Core Extractors

1. **`Option.getD`**
   - **Type**: `{α : Type u} (o : Option α) (default : α) : α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`
   - **Description**: Get with default value

2. **`Option.get`**
   - **Type**: `{α : Type u} (o : Option α) (h : isSome o = true) : α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`
   - **Description**: Get with proof of isSome

3. **`Option.get!`**
   - **Type**: `{α : Type u} [Inhabited α] (o : Option α) : α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`
   - **Description**: Get with Inhabited default (unsafe)

4. **`Option.getM`**
   - **Type**: `{α : Type u} {m : Type u → Type v} [Alternative m] (o : Option α) : m α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`
   - **Description**: Get in Alternative monad

### Transformers

5. **`Option.map`**
   - **Type**: `{α β : Type u} (f : α → β) (o : Option α) : Option β`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`

6. **`Option.bind`**
   - **Type**: `{α β : Type u} (o : Option α) (f : α → Option β) : Option β`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`

7. **`Option.filter`**
   - **Type**: `{α : Type u} (p : α → Bool) (o : Option α) : Option α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`

8. **`Option.join`**
   - **Type**: `{α : Type u} (o : Option (Option α)) : Option α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`

### Combinators

9. **`Option.or`**
   - **Type**: `{α : Type u} (o₁ o₂ : Option α) : Option α`
   - **Library**: Lean Core
   - **Module**: `Init.Data.Option.Basic`

10. **`Option.orElse`**
    - **Type**: `{α : Type u} (o₁ : Option α) (o₂ : Unit → Option α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

11. **`Option.merge`**
    - **Type**: `{α : Type u} (f : α → α → α) (o₁ o₂ : Option α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

12. **`Option.max`**
    - **Type**: `{α : Type u} [Max α] (o₁ o₂ : Option α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

13. **`Option.min`**
    - **Type**: `{α : Type u} [Min α] (o₁ o₂ : Option α) : Option α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

### Predicates

14. **`Option.isNone`**
    - **Type**: `{α : Type u} (o : Option α) : Bool`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

15. **`Option.isSome`**
    - **Type**: `{α : Type u} (o : Option α) : Bool`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

16. **`Option.all`**
    - **Type**: `{α : Type u} (o : Option α) (p : α → Bool) : Bool`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

17. **`Option.any`**
    - **Type**: `{α : Type u} (o : Option α) (p : α → Bool) : Bool`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

18. **`Option.isEqSome`**
    - **Type**: `{α : Type u} [BEq α] (o : Option α) (a : α) : Bool`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

### Converters

19. **`Option.toList`**
    - **Type**: `{α : Type u} (o : Option α) : List α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

20. **`Option.toArray`**
    - **Type**: `{α : Type u} (o : Option α) : Array α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

21. **`Option.toBool`**
    - **Type**: `{α : Type u} (o : Option α) : Bool`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

22. **`liftOption`**
    - **Type**: `{α : Type u} {m : Type u → Type v} [Alternative m] (o : Option α) : m α`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`
    - **Description**: Lift Option into Alternative monad

### Monadic Operations

23. **`Option.sequence`**
    - **Type**: `{α : Type u} {m : Type u → Type v} [Monad m] (o : Option (m α)) : m (Option α)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

24. **`Option.mapM`**
    - **Type**: `{α β : Type u} {m : Type u → Type v} [Monad m] (f : α → m β) (o : Option α) : m (Option β)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

25. **`Option.filterM`**
    - **Type**: `{α : Type u} {m : Type u → Type v} [Monad m] (p : α → m Bool) (o : Option α) : m (Option α)`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

26. **`Option.forM`**
    - **Type**: `{α : Type u} {m : Type u → Type v} [Monad m] (o : Option α) (f : α → m PUnit) : m PUnit`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

### Dependent Versions

27. **`Option.pfilter`**
    - **Type**: Dependent filter
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

28. **`Option.pelim`**
    - **Type**: Dependent elimination
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

29. **`Option.pbind`**
    - **Type**: Dependent bind
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

30. **`Option.pmap`**
    - **Type**: Dependent map
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

### Elimination

31. **`Option.elim`**
    - **Type**: `{α β : Type u} (o : Option α) (b : β) (f : α → β) : β`
    - **Library**: Lean Core
    - **Module**: `Init.Data.Option.Basic`

32. **`Option.rec`**
    - **Type**: Recursor for Option
    - **Library**: Lean Core
    - **Module**: `Init.Prelude`

33. **`Option.casesOn`**
    - **Type**: Case analysis for Option
    - **Library**: Lean Core
    - **Module**: `Init.Prelude`

34. **`Option.recOn`**
    - **Type**: Recursor (alternative form)
    - **Library**: Lean Core
    - **Module**: `Init.Prelude`

### Theorems (150+ lemmas)

Properties about Option operations including:
- `Option.getD_none`, `Option.getD_some`
- `Option.get_some`, `Option.get!_some`
- `Option.map_none`, `Option.map_some`
- `Option.bind_none`, `Option.bind_some`
- `Option.filter_none`, `Option.filter_some`
- `Option.join_none`, `Option.join_some`
- `Option.or_none_left`, `Option.or_none_right`, `Option.or_some_left`, `Option.or_some_right`
- `Option.merge_none_left`, `Option.merge_none_right`, `Option.merge_some_some`
- `Option.all_none`, `Option.all_some`
- `Option.any_none`, `Option.any_some`
- `Option.toList_none`, `Option.toList_some`
- And many more...

---

## Categorization Summary

### 1. Exact Matches (Functions/Theorems with "Option.some" in name)

**Total**: 55+ direct matches

**Categories**:
- **Constructor**: `Option.some`
- **Properties**: `Option.some.sizeOf_spec`, `Option.some.injEq`, `Option.some_inj`, `Option.some_ne_none`, `Option.some_get`
- **Boolean Tests**: `Option.isSome_some`, `Option.isNone_some`, `Option.isEqSome_some`
- **Monadic**: `Option.bind_some`, `Option.map_some`, `Option.join_some`, `Option.filter_some`, `Option.pure_def`
- **Extraction**: `Option.get_some`, `Option.getD_some`, `Option.get!_some`, `Option.getM_some`
- **Comparison**: `Option.some_lt_some`, `Option.some_le_some`, `Option.some_beq_some`, `Option.max_some_some`, `Option.min_some_some`
- **Combinators**: `Option.or_some_left`, `Option.or_some_right`, `Option.merge_some_some`
- **Predicates**: `Option.all_some`, `Option.any_some`
- **List Operations**: `List.head?_cons`, `List.tail?_cons`, `List.get?_cons_zero`, etc.
- **GetElem**: `of_getElem?_eq_some`, `getElem?_eq_some_iff`, etc.
- **OptionT**: `OptionT.mk_some`, `OptionT.run_some`, `OptionT.bind_some`

### 2. Partial Matches (Related Option Functions)

**Total**: 100+ functions

**Categories**:
- **Core Operations**: `Option.map`, `Option.bind`, `Option.filter`, `Option.join`, `Option.or`, `Option.orElse`
- **Extractors**: `Option.get`, `Option.getD`, `Option.get!`, `Option.getM`
- **Predicates**: `Option.isSome`, `Option.isNone`, `Option.isEqSome`, `Option.all`, `Option.any`
- **Converters**: `Option.toList`, `Option.toArray`, `Option.toBool`
- **Combinators**: `Option.merge`, `Option.max`, `Option.min`, `Option.guard`
- **Monadic**: `Option.mapM`, `Option.filterM`, `Option.sequence`, `Option.forM`
- **Dependent**: `Option.pfilter`, `Option.pelim`, `Option.pbind`, `Option.pmap`
- **Elimination**: `Option.elim`, `Option.rec`, `Option.casesOn`, `Option.recOn`

### 3. Related Functions (Functions that work with Option)

**Total**: 150+ functions

**Categories**:

**List Operations**:
- `List.find?`, `List.head?`, `List.tail?`, `List.getLast?`, `List.get?`
- `List.findIdx?`, `List.lookup`, `List.findSome?`, `List.findSomeM?`, `List.findSomeRev?`
- `List.filterMap`, `List.findM?`, `List.findIdxM?`

**Array Operations**:
- `Array.find?`, `Array.findIdx?`, `Array.findSome?`, `Array.get?`, `Array.back?`
- `Array.findSomeRev?`, `Array.findSomeM?`, `Array.findSomeRevM?`
- `Array.findM?`, `Array.findIdxM?`

**Type Conversions**:
- `Except.toOption`, `Int.toNat?`, `String.toNat?`, `String.toInt?`
- `GetElem?.getElem?`, `liftOption`

**Type Class Instances**:
- `instInhabitedOption`, `instFunctorOption`, `instMonadOption`, `instAlternativeOption`
- `instBEqOption`, `instDecidableEqOption`, `instLEOption`, `instLTOption`
- `instMaxOption`, `instMinOption`

**Metaprogramming**:
- `Lean.Syntax.getPos?`, `Lean.Syntax.getTailPos?`
- `Lean.Macro.expandMacro?`, `Lean.SourceInfo.getPos?`

---

## Module Distribution

### Primary Modules

1. **`Init.Prelude`**
   - Core Option type definition
   - Constructors: `Option`, `Option.none`, `Option.some`
   - Basic recursors

2. **`Init.Data.Option.Basic`**
   - All core Option operations
   - Monadic operations
   - Combinators
   - Predicates
   - Converters
   - 150+ theorems and lemmas

3. **`Init.Data.List.Basic`**
   - List operations returning Option
   - Safe element access
   - Search functions

4. **`Init.Data.Array.Basic`**
   - Array operations returning Option
   - Safe indexing
   - Search functions

5. **`Init.GetElem`**
   - Generic element access with Option
   - `[i]?` syntax support

6. **`Init.Control.OptionT`**
   - OptionT monad transformer

7. **`Init.Data.Except`**
   - Except to Option conversion

8. **`Init.Data.Int.Basic`**, **`Init.Data.String.Basic`**
   - Type conversions to Option

9. **`Lean.*` modules**
   - Metaprogramming utilities

---

## Key Insights

### 1. Option.some Usage Patterns

**As Constructor**:
- Primary way to create non-empty Option values
- Used throughout the standard library
- Type inference makes it convenient: `some 5 : Option Nat`

**In Pattern Matching**:
```lean
match opt with
| some x => x + 1
| none => 0
```

**In Theorems**:
- Extensive lemma library for reasoning about `some`
- Injectivity: `some a = some b ↔ a = b`
- Distinctness: `some a ≠ none`
- Preservation under operations: `map f (some a) = some (f a)`

### 2. Monadic Structure

Option forms a monad with:
- **Pure**: `pure a = some a`
- **Bind**: `bind (some a) f = f a`, `bind none f = none`
- **Map**: `map f (some a) = some (f a)`, `map f none = none`

### 3. Alternative Structure

Option forms an Alternative with:
- **Empty**: `failure = none`
- **Or**: `or (some a) _ = some a`, `or none o = o`

### 4. Safe Operations

The Option type enables safe operations throughout the standard library:
- Safe indexing: `List.get?`, `Array.get?`
- Safe head/tail: `List.head?`, `List.tail?`
- Safe conversions: `Int.toNat?`, `String.toNat?`
- Safe search: `List.find?`, `Array.find?`

### 5. Extensive Theorem Library

Over 150 theorems prove properties about Option operations:
- Functor laws
- Monad laws
- Alternative laws
- Specific operation properties
- Interaction between operations

---

## Recommendations

### For Using Option.some

1. **Prefer Pattern Matching**: Use pattern matching over `isSome` checks when possible
2. **Use Monadic Operations**: Leverage `map`, `bind`, `filter` instead of manual case analysis
3. **Safe Extraction**: Use `getD` with a default rather than `get!` when possible
4. **Leverage Theorems**: The extensive lemma library makes reasoning about Option straightforward

### For Finding Related Functions

1. **Type-based Search**: Use `_ → Option _` to find all functions returning Option
2. **Name-based Search**: Search for "some" to find all related lemmas
3. **Module Exploration**: Check `Init.Data.Option.Basic` for comprehensive Option API

### For Integration

1. **Monad Transformers**: Use `OptionT` for stacking Option with other monads
2. **Alternative**: Use Alternative instance for combining multiple Option computations
3. **Conversions**: Use `Except.toOption`, `liftOption` for interop with other types

---

## Statistics

- **Total Unique Declarations**: 14,236+ (across all searches)
- **Exact "Option.some" Matches**: 3,953
- **Functions Returning Option**: 3,976
- **Functions Consuming Option**: 3,726
- **Primary Library**: Lean Core (Init namespace)
- **Primary Modules**: 9 main modules
- **Theorem Count**: 150+ lemmas about Option operations
- **Type Class Instances**: 10+ instances

---

## Conclusion

The `Option.some` constructor is a fundamental building block in Lean 4, with extensive support throughout the standard library. The comprehensive search reveals:

1. **Rich API**: Over 100 functions directly related to Option
2. **Extensive Theorems**: 150+ lemmas for reasoning
3. **Pervasive Usage**: Used in List, Array, String, Int, and metaprogramming
4. **Strong Abstractions**: Monad, Alternative, Functor instances
5. **Safe Operations**: Enables safe indexing, conversion, and search throughout the ecosystem

The Option type and its `some` constructor exemplify functional programming best practices in Lean 4, providing a type-safe way to handle potentially absent values with a rich set of combinators and a comprehensive theorem library for verification.
