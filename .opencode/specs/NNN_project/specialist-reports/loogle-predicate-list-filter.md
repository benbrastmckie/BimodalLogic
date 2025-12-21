# Loogle Search Report: Predicate List Filter Functions

**Search Date:** Sun Dec 21 2025  
**Type Pattern:** `(_ → Bool) → List _ → List _`  
**Search Query:** Functions that take a predicate (something → Bool), a List, and return a List  
**Total Matches:** 25 functions  
**Total Declarations Searched:** 3,793 (mentioning List and Bool)  
**Heartbeats Used:** 5,126

---

## Executive Summary

The search successfully identified 25 functions matching the pattern of taking a predicate function and a list to return a list. These functions are distributed across:

- **Init.Data.List.Basic** (7 functions) - Core Lean standard library
- **Init.Data.List.Impl** (4 functions) - Tail-recursive implementations
- **Batteries.Data.List.Basic** (12 functions) - Extended Batteries library
- **Mathlib.Data.List.DropRight** (2 functions) - Mathlib extensions

The functions primarily perform filtering, selection, dropping, taking, erasing, and splitting operations on lists based on predicates.

---

## 1. EXACT MATCHES (Primary Functions)

These functions match the pattern `(_ → Bool) → List _ → List _` exactly or very closely.

### 1.1 Core Filter Functions

#### `List.filter`
- **Full Type:** `{α : Type u} (p : α → Bool) (l : List α) : List α`
- **Library:** Init (Lean Standard Library)
- **Module:** `Init.Data.List.Basic`
- **Complexity:** O(|l|)
- **Documentation:**
  > Returns the list of elements in `l` for which `p` returns `true`.
  >
  > Examples:
  > * `[1, 2, 5, 2, 7, 7].filter (· > 2) = [5, 7, 7]`
  > * `[1, 2, 5, 2, 7, 7].filter (fun _ => false) = []`
  > * `[1, 2, 5, 2, 7, 7].filter (fun _ => true) = [1, 2, 5, 2, 7, 7]`

#### `List.filterTR`
- **Full Type:** `{α : Type u} (p : α → Bool) (as : List α) : List α`
- **Library:** Init (Lean Standard Library)
- **Module:** `Init.Data.List.Basic`
- **Complexity:** O(|l|)
- **Documentation:**
  > Returns the list of elements in `l` for which `p` returns `true`.
  >
  > O(|l|). This is a tail-recursive version of `List.filter`, used at runtime.
  >
  > Examples:
  > * `[1, 2, 5, 2, 7, 7].filterTR (· > 2) = [5, 7, 7]`
  > * `[1, 2, 5, 2, 7, 7].filterTR (fun _ => false) = []`
  > * `[1, 2, 5, 2, 7, 7].filterTR (fun _ => true) = [1, 2, 5, 2, 7, 7]`

### 1.2 Prefix/Suffix Selection

#### `List.takeWhile`
- **Full Type:** `{α : Type u} (p : α → Bool) (xs : List α) : List α`
- **Library:** Init (Lean Standard Library)
- **Module:** `Init.Data.List.Basic`
- **Complexity:** O(|xs|)
- **Documentation:**
  > Returns the longest initial segment of `xs` for which `p` returns true.
  >
  > Examples:
  > * `[7, 6, 4, 8].takeWhile (· > 5) = [7, 6]`
  > * `[7, 6, 6, 5].takeWhile (· > 5) = [7, 6, 6]`
  > * `[7, 6, 6, 8].takeWhile (· > 5) = [7, 6, 6, 8]`

#### `List.takeWhileTR`
- **Full Type:** `{α : Type u_1} (p : α → Bool) (l : List α) : List α`
- **Library:** Init (Lean Standard Library)
- **Module:** `Init.Data.List.Impl`
- **Complexity:** O(|xs|)
- **Documentation:**
  > Returns the longest initial segment of `xs` for which `p` returns true.
  >
  > O(|xs|). This is a tail-recursive version of `List.take`, used at runtime.
  >
  > Examples:
  > * `[7, 6, 4, 8].takeWhileTR (· > 5) = [7, 6]`
  > * `[7, 6, 6, 5].takeWhileTR (· > 5) = [7, 6, 6]`
  > * `[7, 6, 6, 8].takeWhileTR (· > 5) = [7, 6, 6, 8]`

#### `List.dropWhile`
- **Full Type:** `{α : Type u} (p : α → Bool) : List α → List α`
- **Library:** Init (Lean Standard Library)
- **Module:** `Init.Data.List.Basic`
- **Complexity:** O(|l|)
- **Documentation:**
  > Removes the longest prefix of a list for which `p` returns `true`.
  >
  > Elements are removed from the list until one is encountered for which `p` returns `false`. This
  > element and the remainder of the list are returned.
  >
  > Examples:
  > * `[1, 3, 2, 4, 2, 7, 4].dropWhile (· < 4) = [4, 2, 7, 4]`
  > * `[8, 3, 2, 4, 2, 7, 4].dropWhile (· < 4) = [8, 3, 2, 4, 2, 7, 4]`
  > * `[8, 3, 2, 4, 2, 7, 4].dropWhile (· < 100) = []`

#### `List.after`
- **Full Type:** `{α : Type u_1} (p : α → Bool) : List α → List α`
- **Library:** Batteries
- **Module:** `Batteries.Data.List.Basic`
- **Documentation:**
  > `after p xs` is the suffix of `xs` after the first element that satisfies
  > `p`, not including that element.
  > ```lean
  > after      (· == 1) [0, 1, 2, 3] = [2, 3]
  > drop_while (· != 1) [0, 1, 2, 3] = [1, 2, 3]
  > ```

### 1.3 Element Removal

#### `List.eraseP`
- **Full Type:** `{α : Type u} (p : α → Bool) : List α → List α`
- **Library:** Init (Lean Standard Library)
- **Module:** `Init.Data.List.Basic`
- **Documentation:**
  > Removes the first element of a list for which `p` returns `true`. If no element satisfies `p`, then
  > the list is returned unchanged.
  >
  > Examples:
  > * `[2, 1, 2, 1, 3, 4].eraseP (· < 2) = [2, 2, 1, 3, 4]`
  > * `[2, 1, 2, 1, 3, 4].eraseP (· > 2) = [2, 1, 2, 1, 4]`
  > * `[2, 1, 2, 1, 3, 4].eraseP (· > 8) = [2, 1, 2, 1, 3, 4]`

#### `List.erasePTR`
- **Full Type:** `{α : Type u_1} (p : α → Bool) (l : List α) : List α`
- **Library:** Init (Lean Standard Library)
- **Module:** `Init.Data.List.Impl`
- **Documentation:**
  > Removes the first element of a list for which `p` returns `true`. If no element satisfies `p`, then
  > the list is returned unchanged.
  >
  > This is a tail-recursive version of `eraseP`, used at runtime.
  >
  > Examples:
  > * `[2, 1, 2, 1, 3, 4].erasePTR (· < 2) = [2, 2, 1, 3, 4]`
  > * `[2, 1, 2, 1, 3, 4].erasePTR (· > 2) = [2, 1, 2, 1, 4]`
  > * `[2, 1, 2, 1, 3, 4].erasePTR (· > 8) = [2, 1, 2, 1, 3, 4]`

### 1.4 Reverse Operations (Mathlib)

#### `List.rdropWhile`
- **Full Type:** `{α : Type u_1} (p : α → Bool) (l : List α) : List α`
- **Library:** Mathlib
- **Module:** `Mathlib.Data.List.DropRight`
- **Documentation:**
  > Drop elements from the tail end of a list that satisfy `p : α → Bool`.
  > Implemented naively via `List.reverse`

#### `List.rtakeWhile`
- **Full Type:** `{α : Type u_1} (p : α → Bool) (l : List α) : List α`
- **Library:** Mathlib
- **Module:** `Mathlib.Data.List.DropRight`
- **Documentation:**
  > Take elements from the tail end of a list that satisfy `p : α → Bool`.
  > Implemented naively via `List.reverse`

---

## 2. PARTIAL MATCHES (Related Signatures)

These functions have signatures that include the pattern but with additional parameters or modified return types.

### 2.1 Functions with Additional Parameters

#### `List.insertP`
- **Full Type:** `{α : Type u_1} (p : α → Bool) (a : α) (l : List α) : List α`
- **Library:** Batteries
- **Module:** `Batteries.Data.List.Basic`
- **Pattern:** Takes predicate AND an element to insert
- **Documentation:**
  > O(|l|). Inserts `a` in `l` right before the first element such that `p` is true, or at the end of
  > the list if `p` always false on `l`.

#### `List.findIdxs`
- **Full Type:** `{α : Type u_1} (p : α → Bool) (l : List α) (start : ℕ := 0) : List ℕ`
- **Library:** Batteries
- **Module:** `Batteries.Data.List.Basic`
- **Pattern:** Returns List of indices instead of List of elements
- **Documentation:**
  > `findIdxs p l` is the list of indexes of elements of `l` that satisfy `p`, added to an
  > optional parameter `start` (so that the members of `findIdxs p l` will be greater than or
  > equal to `start` and less than `l.length + start`).

#### `List.findIdxsValues`
- **Full Type:** `{α : Type u_1} (p : α → Bool) (l : List α) (start : ℕ := 0) : List (ℕ × α)`
- **Library:** Batteries
- **Module:** `Batteries.Data.List.Basic`
- **Pattern:** Returns List of pairs (index, value) instead of List of elements
- **Documentation:**
  > Returns the elements of `l` that satisfy `p` together with their indexes in
  > `l` added to an optional parameter `start`. The returned list is ordered by index.
  > We have `l.findIdxsValues p s = (l.findIdxs p s).zip (l.filter p)`.

#### `List.indexsValues`
- **Full Type:** `{α : Type u_1} (p : α → Bool) (l : List α) (start : ℕ := 0) : List (ℕ × α)`
- **Library:** Batteries
- **Module:** `Batteries.Data.List.Basic`
- **Pattern:** Alias of `List.findIdxsValues`
- **Documentation:**
  > **Alias** of `List.findIdxsValues`.

### 2.2 Functions with Different Return Types

#### `List.splitOnP`
- **Full Type:** `{α : Type u_1} (P : α → Bool) (l : List α) : List (List α)`
- **Library:** Batteries
- **Module:** `Batteries.Data.List.Basic`
- **Pattern:** Returns List of Lists (splits the input)
- **Documentation:**
  > Split a list at every element satisfying a predicate. The separators are not in the result.
  > ```
  > [1, 1, 2, 3, 2, 4, 4].splitOnP (· == 2) = [[1, 1], [3], [4, 4]]
  > ```

#### `List.splitOnPTR`
- **Full Type:** `{α : Type u_1} (P : α → Bool) (l : List α) : List (List α)`
- **Library:** Batteries
- **Module:** `Batteries.Data.List.Basic`
- **Pattern:** Tail recursive version of splitOnP
- **Documentation:**
  > Tail recursive version of `splitOnP`.

---

## 3. HELPER/INTERNAL FUNCTIONS

These are implementation details and auxiliary functions.

### 3.1 Loop Functions

#### `List.filterTR.loop`
- **Full Type:** `{α : Type u} (p : α → Bool) : List α → List α → List α`
- **Library:** Init
- **Module:** `Init.Data.List.Basic`
- **Purpose:** Internal loop for tail-recursive filter

#### `List.insertP.loop`
- **Full Type:** `{α : Type u_1} (p : α → Bool) (a : α) : List α → List α → List α`
- **Library:** Batteries
- **Module:** `Batteries.Data.List.Basic`
- **Documentation:** Inner loop for `insertP`. Tail recursive.

#### `List.splitOnP.go`
- **Full Type:** `{α : Type u_1} (P : α → Bool) : List α → List α → List (List α)`
- **Library:** Batteries
- **Module:** `Batteries.Data.List.Basic`
- **Documentation:**
  > Auxiliary for `splitOnP`: `splitOnP.go xs acc = res'`
  > where `res'` is obtained from `splitOnP P xs` by prepending `acc.reverse` to the first element.

#### `List.splitOnPTR.go`
- **Full Type:** `{α : Type u_1} (P : α → Bool) : List α → Array α → Array (List α) → List (List α)`
- **Library:** Batteries
- **Module:** `Batteries.Data.List.Basic`
- **Documentation:**
  > Auxiliary for `splitOnP`: `splitOnP.go xs acc r = r.toList ++ res'`
  > where `res'` is obtained from `splitOnP P xs` by prepending `acc.toList` to the first element.

### 3.2 String-Related Internal Functions

#### `String.splitAux`
- **Full Type:** `(s : String) (p : Char → Bool) (b i : String.Pos.Raw) (r : List String) : List String`
- **Library:** Init
- **Module:** `Init.Data.String.Legacy`
- **Note:** Internal auxiliary function for string splitting, different domain (Char vs generic α)

---

## 4. EQUALITY THEOREMS

These establish equivalences between the main implementations and their tail-recursive variants.

### 4.1 Filter Equivalences

#### `List.filter_eq_filterTR`
- **Full Type:** `@List.filter = @List.filterTR`
- **Library:** Init
- **Module:** `Init.Data.List.Basic`
- **Purpose:** Proves filter and filterTR are extensionally equal

### 4.2 EraseP Equivalences

#### `List.eraseP_eq_erasePTR`
- **Full Type:** `@List.eraseP = @List.erasePTR`
- **Library:** Init
- **Module:** `Init.Data.List.Impl`
- **Purpose:** Proves eraseP and erasePTR are extensionally equal

### 4.3 TakeWhile Equivalences

#### `List.takeWhile_eq_takeWhileTR`
- **Full Type:** `@List.takeWhile = @List.takeWhileTR`
- **Library:** Init
- **Module:** `Init.Data.List.Impl`
- **Purpose:** Proves takeWhile and takeWhileTR are extensionally equal

### 4.4 SplitOnP Equivalences

#### `List.splitOnP_eq_splitOnPTR`
- **Full Type:** `@List.splitOnP = @List.splitOnPTR`
- **Library:** Batteries
- **Module:** `Batteries.Data.List.Basic`
- **Purpose:** Proves splitOnP and splitOnPTR are extensionally equal

---

## 5. CATEGORIZATION BY SEMANTIC PURPOSE

### 5.1 Selection (Keep elements matching predicate)
- `List.filter` / `List.filterTR` - Keep all matching elements
- `List.takeWhile` / `List.takeWhileTR` - Keep prefix while predicate holds
- `List.rtakeWhile` - Keep suffix while predicate holds (from tail)

### 5.2 Removal (Remove elements matching predicate)
- `List.dropWhile` - Remove prefix while predicate holds
- `List.rdropWhile` - Remove suffix while predicate holds (from tail)
- `List.eraseP` / `List.erasePTR` - Remove first element matching predicate

### 5.3 Advanced Operations
- `List.after` - Get suffix after first match (excluding the match)
- `List.insertP` - Insert element before first match
- `List.splitOnP` / `List.splitOnPTR` - Split list at all matches

### 5.4 Index/Value Extraction
- `List.findIdxs` - Get indices of matching elements
- `List.findIdxsValues` / `List.indexsValues` - Get (index, value) pairs

---

## 6. LIBRARY DISTRIBUTION ANALYSIS

### Init (Lean Standard Library)
**11 total functions** (7 primary + 4 implementation)
- Core filtering: `filter`, `filterTR`, `filterTR.loop`
- Prefix operations: `takeWhile`, `dropWhile`
- Erasure: `eraseP`
- Tail-recursive: `erasePTR`, `takeWhileTR`
- Equivalence proofs: 3 theorems

### Batteries
**12 total functions**
- Advanced operations: `after`, `insertP`, `splitOnP`, `splitOnPTR`
- Index operations: `findIdxs`, `findIdxsValues`, `indexsValues`
- Helper functions: 4 auxiliary/loop functions
- Equivalence proofs: 1 theorem

### Mathlib
**2 total functions**
- Reverse operations: `rdropWhile`, `rtakeWhile`

---

## 7. RECOMMENDATIONS

### For Basic Filtering
**Use:** `List.filter`
- Most common use case
- Well-documented with examples
- Has tail-recursive variant for runtime performance

### For Prefix/Suffix Operations
**Use:**
- `List.takeWhile` - Take elements while predicate is true
- `List.dropWhile` - Drop elements while predicate is true
- `List.rtakeWhile` / `List.rdropWhile` - Same from tail end (Mathlib required)

### For Single Element Removal
**Use:** `List.eraseP`
- Removes only the first matching element
- Returns unchanged list if no match

### For Splitting
**Use:** `List.splitOnP`
- Splits list at all matching elements
- Does not include separators in result

### For Index Tracking
**Use:**
- `List.findIdxs` - When you only need indices
- `List.findIdxsValues` - When you need both indices and values

---

## 8. PERFORMANCE NOTES

### Tail Recursion
Most functions have tail-recursive variants (suffix `TR`):
- `filterTR`, `erasePTR`, `takeWhileTR`, `splitOnPTR`
- Used automatically at runtime via equality theorems
- Better stack behavior for large lists

### Complexity
- All basic operations are O(n) where n = list length
- `rdropWhile` and `rtakeWhile` use `List.reverse` internally (O(n) but with overhead)

---

## 9. IMPLEMENTATION PATTERNS

### Common Pattern: Predicate-First Design
Most functions take the predicate as the first parameter, enabling partial application:
```lean
let isEven := (· % 2 == 0)
let evenFilter := List.filter isEven
-- Can now apply evenFilter to multiple lists
```

### Tail Recursion Pattern
The standard library provides both simple recursive and tail-recursive versions, with theorems proving their equivalence. This allows:
- Simple proofs using the direct recursive version
- Efficient execution using the tail-recursive version
- Automatic selection at runtime

---

## 10. SEARCH METADATA

- **Total Declarations Scanned:** 3,793 (containing List and Bool)
- **Matching Functions:** 25
- **Match Rate:** 0.66%
- **Computational Cost:** 5,126 heartbeats
- **Libraries Covered:** Init (Lean Std), Batteries, Mathlib
- **Function Categories:** 9 exact matches (primary), 7 partial matches, 5 helpers, 4 equivalence theorems

---

## Conclusion

The Loogle search successfully identified a comprehensive collection of 25 functions matching or related to the pattern `(_ → Bool) → List _ → List _`. The ecosystem provides:

1. **Core filtering capabilities** through `List.filter` and variants
2. **Prefix/suffix operations** through `takeWhile`, `dropWhile`, and reverse variants
3. **Element removal** through `eraseP`
4. **Advanced operations** like splitting, insertion, and index tracking
5. **Performance optimization** through tail-recursive variants
6. **Formal verification** through equivalence proofs

The distribution across Init (standard), Batteries (extended), and Mathlib (mathematical) libraries provides users with options from basic to advanced use cases, all with strong performance characteristics and formal guarantees.
