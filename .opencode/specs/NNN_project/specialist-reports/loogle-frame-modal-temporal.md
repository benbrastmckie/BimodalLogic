# Loogle Search Results: Frame (Modal/Temporal Logic Context)

**Type Pattern**: "Frame"
**Date**: 2025-12-21
**Total Matches Found**: 131 declarations
**Relevant Matches**: 0 (modal/temporal logic specific)

## Executive Summary

The Loogle search for "Frame" returned 131 results from Mathlib, but **none are directly related to modal logic, temporal logic, or Kripke semantics**. All results pertain to **Order.Frame**, which is a concept from lattice theory (complete Heyting algebras), not modal logic frames.

### Key Finding

**Order.Frame** in Mathlib refers to:
- A complete lattice with distributive meet over arbitrary joins
- Also known as a complete Heyting algebra
- Used in locale theory and pointless topology
- **NOT** related to Kripke frames for modal/temporal logic

## Analysis: Order.Frame vs Modal Logic Frames

### Order.Frame (What Was Found)
- **Domain**: Lattice theory, locale theory
- **Definition**: Complete lattice where `a ⊓ sSup s = ⨆ b ∈ s, a ⊓ b`
- **Purpose**: Algebraic structure for pointless topology
- **Key Operations**: Meet (`⊓`), join (`⊔`), Heyting implication (`⇨`)

### Modal Logic Frames (What Was Expected)
- **Domain**: Modal logic, Kripke semantics
- **Definition**: Structure `⟨W, R⟩` with worlds W and accessibility relation R
- **Purpose**: Semantic interpretation of modal formulas
- **Key Operations**: Accessibility relation, frame conditions (reflexivity, transitivity, etc.)

## Complete Results from Loogle

### Primary Structure

**`Order.Frame`**
- **Type**: `(α : Type u_1) : Type u_1`
- **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
- **Category**: Type class
- **Description**: A frame, aka complete Heyting algebra, is a complete lattice whose `⊓` distributes over `⨆`.

---

### Core Constructors

1. **`Order.Frame.ofMinimalAxioms`**
   - **Type**: `{α : Type u} (minAx : Order.Frame.MinimalAxioms α) : Order.Frame α`
   - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
   - **Category**: Constructor
   - **Description**: Construct a frame instance using minimal axioms

2. **`Order.Frame.MinimalAxioms.of`**
   - **Type**: `{α : Type u} [Order.Frame α] : Order.Frame.MinimalAxioms α`
   - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
   - **Category**: Constructor

3. **`Order.Frame.mk`**
   - **Type**: `{α : Type u_1} [toCompleteLattice : CompleteLattice α] [toHImp : HImp α] (le_himp_iff : ∀ (a b c : α), a ≤ b ⇨ c ↔ a ⊓ b ≤ c) [toHasCompl : HasCompl α] (himp_bot : ∀ (a : α), a ⇨ ⊥ = aᶜ) : Order.Frame α`
   - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
   - **Category**: Constructor

---

### Type Class Conversions

4. **`CompleteDistribLattice.toFrame`**
   - **Type**: `{α : Type u_1} [self : CompleteDistribLattice α] : Order.Frame α`
   - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
   - **Category**: Instance

5. **`Frame.toDistribLattice`**
   - **Type**: `{α : Type u} [Order.Frame α] : DistribLattice α`
   - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
   - **Category**: Instance

6. **`Order.Frame.toCompleteLattice`**
   - **Type**: `{α : Type u_1} [self : Order.Frame α] : CompleteLattice α`
   - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
   - **Category**: Instance

7. **`Order.Frame.toHImp`**
   - **Type**: `{α : Type u_1} [self : Order.Frame α] : HImp α`
   - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
   - **Category**: Instance

8. **`Order.Frame.toHasCompl`**
   - **Type**: `{α : Type u_1} [self : Order.Frame α] : HasCompl α`
   - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
   - **Category**: Instance

9. **`Order.Frame.toHeytingAlgebra`**
   - **Type**: `{α : Type u_1} [self : Order.Frame α] : HeytingAlgebra α`
   - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
   - **Category**: Instance

---

### Instances for Specific Types

10. **`OrderDual.instFrame`**
    - **Type**: `{α : Type u} [Order.Coframe α] : Order.Frame αᵒᵈ`
    - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
    - **Category**: Instance

11. **`OrderDual.instCoframe`**
    - **Type**: `{α : Type u} [Order.Frame α] : Order.Coframe αᵒᵈ`
    - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
    - **Category**: Instance

12. **`Prod.instFrame`**
    - **Type**: `{α : Type u} {β : Type v} [Order.Frame α] [Order.Frame β] : Order.Frame (α × β)`
    - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
    - **Category**: Instance

13. **`Pi.instFrame`**
    - **Type**: `{ι : Type u_1} {π : ι → Type u_2} [(i : ι) → Order.Frame (π i)] : Order.Frame ((i : ι) → π i)`
    - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
    - **Category**: Instance

14. **`TopologicalSpace.Opens.instFrame`**
    - **Type**: `{α : Type u_2} [TopologicalSpace α] : Order.Frame (TopologicalSpace.Opens α)`
    - **Module**: `Mathlib.Topology.Sets.Opens`
    - **Category**: Instance
    - **Note**: Open sets form a frame (locale theory connection to topology)

15. **`Nucleus.instFrame`**
    - **Type**: `{X : Type u_1} [Order.Frame X] : Order.Frame (Nucleus X)`
    - **Module**: `Mathlib.Order.Nucleus`
    - **Category**: Instance

---

### Key Frame Laws

16. **`Order.Frame.le_himp_iff`**
    - **Type**: `{α : Type u_1} [self : Order.Frame α] (a b c : α) : a ≤ b ⇨ c ↔ a ⊓ b ≤ c`
    - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
    - **Category**: Theorem
    - **Description**: `(a ⇨ ·)` is right adjoint to `(a ⊓ ·)`

17. **`Order.Frame.himp_bot`**
    - **Type**: `{α : Type u_1} [self : Order.Frame α] (a : α) : a ⇨ ⊥ = aᶜ`
    - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
    - **Category**: Theorem
    - **Description**: `aᶜ` is defined as `a ⇨ ⊥`

18. **`inf_sSup_eq`**
    - **Type**: `{α : Type u_1} [Order.Frame α] {s : Set α} {a : α} : a ⊓ sSup s = ⨆ b ∈ s, a ⊓ b`
    - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
    - **Category**: Theorem
    - **Description**: `⊓` distributes over `⨆` (defining property of frames)

19. **`sSup_inf_eq`**
    - **Type**: `{α : Type u} [Order.Frame α] {s : Set α} {b : α} : sSup s ⊓ b = ⨆ a ∈ s, a ⊓ b`
    - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
    - **Category**: Theorem

20. **`inf_iSup_eq`**
    - **Type**: `{α : Type u} {ι : Sort w} [Order.Frame α] (a : α) (f : ι → α) : a ⊓ ⨆ i, f i = ⨆ i, a ⊓ f i`
    - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
    - **Category**: Theorem

21. **`iSup_inf_eq`**
    - **Type**: `{α : Type u} {ι : Sort w} [Order.Frame α] (f : ι → α) (a : α) : (⨆ i, f i) ⊓ a = ⨆ i, f i ⊓ a`
    - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
    - **Category**: Theorem

---

### Utility Functions

22. **`Function.Injective.frame`**
    - **Type**: `{α : Type u} {β : Type v} [Max α] [Min α] [SupSet α] [InfSet α] [Top α] [Bot α] [HasCompl α] [HImp α] [Order.Frame β] (f : α → β) (hf : Function.Injective f) (map_sup : ∀ (a b : α), f (a ⊔ b) = f a ⊔ f b) (map_inf : ∀ (a b : α), f (a ⊓ b) = f a ⊓ f b) (map_sSup : ∀ (s : Set α), f (sSup s) = ⨆ a ∈ s, f a) (map_sInf : ∀ (s : Set α), f (sInf s) = ⨅ a ∈ s, f a) (map_top : f ⊤ = ⊤) (map_bot : f ⊥ = ⊥) (map_compl : ∀ (a : α), f aᶜ = (f a)ᶜ) (map_himp : ∀ (a b : α), f (a ⇨ b) = f a ⇨ f b) : Order.Frame α`
    - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
    - **Category**: Function
    - **Description**: Pullback an `Order.Frame` along an injection

23. **`Frame.copy`**
    - **Type**: `{α : Type u} (c : Order.Frame α) (le : α → α → Prop) (eq_le : le = LE.le) (top : α) (eq_top : top = ⊤) (bot : α) (eq_bot : bot = ⊥) (sup : α → α → α) (eq_sup : sup = max) (inf : α → α → α) (eq_inf : inf = min) (himp : α → α → α) (eq_himp : himp = HImp.himp) (compl : α → α) (eq_compl : compl = HasCompl.compl) (sSup : Set α → α) (eq_sSup : sSup = SupSet.sSup) (sInf : Set α → α) (eq_sInf : sInf = InfSet.sInf) : Order.Frame α`
    - **Module**: `Mathlib.Order.Copy`
    - **Category**: Function
    - **Description**: Create a provable equal copy of a frame with different definitional equalities

---

### Category Theory (Frm Category)

24. **`Frm.of`**
    - **Type**: `(carrier : Type u_1) [str : Order.Frame carrier] : Frm`
    - **Module**: `Mathlib.Order.Category.Frm`
    - **Category**: Constructor
    - **Description**: Construct a bundled `Frm` from the underlying type and typeclass

25. **`Frm.str`**
    - **Type**: `(self : Frm) : Order.Frame ↑self`
    - **Module**: `Mathlib.Order.Category.Frm`
    - **Category**: Function

26. **`Frm.ofHom`**
    - **Type**: `{X Y : Type u} [Order.Frame X] [Order.Frame Y] (f : FrameHom X Y) : { carrier := X, str := inst✝ } ⟶ { carrier := Y, str := inst✝¹ }`
    - **Module**: `Mathlib.Order.Category.Frm`
    - **Category**: Function
    - **Description**: Typecheck a `FrameHom` as a morphism in `Frm`

---

### Disjointness Results

27. **`disjoint_iSup_iff`**
    - **Type**: `{α : Type u} {ι : Sort w} [Order.Frame α] {a : α} {f : ι → α} : Disjoint a (⨆ i, f i) ↔ ∀ (i : ι), Disjoint a (f i)`
    - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
    - **Category**: Theorem

28. **`iSup_disjoint_iff`**
    - **Type**: `{α : Type u} {ι : Sort w} [Order.Frame α] {a : α} {f : ι → α} : Disjoint (⨆ i, f i) a ↔ ∀ (i : ι), Disjoint (f i) a`
    - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
    - **Category**: Theorem

29. **`disjoint_sSup_iff`**
    - **Type**: `{α : Type u} [Order.Frame α] {a : α} {s : Set α} : Disjoint a (sSup s) ↔ ∀ b ∈ s, Disjoint a b`
    - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
    - **Category**: Theorem

30. **`sSup_disjoint_iff`**
    - **Type**: `{α : Type u} [Order.Frame α] {a : α} {s : Set α} : Disjoint (sSup s) a ↔ ∀ b ∈ s, Disjoint b a`
    - **Module**: `Mathlib.Order.CompleteBooleanAlgebra`
    - **Category**: Theorem

---

### Nucleus and Sublocale Theory

31. **`Nucleus.restrict`**
    - **Type**: `{X : Type u_1} [Order.Frame X] (n : Nucleus X) : FrameHom X ↑(Set.range ⇑n)`
    - **Module**: `Mathlib.Order.Nucleus`
    - **Category**: Function
    - **Description**: Restrict a nucleus to its range

32. **`Nucleus.giRestrict`**
    - **Type**: `{X : Type u_1} [Order.Frame X] (n : Nucleus X) : GaloisInsertion (⇑n.restrict) Subtype.val`
    - **Module**: `Mathlib.Order.Nucleus`
    - **Category**: Theorem
    - **Description**: The restriction of a nucleus to its range forms a Galois insertion

33. **`Sublocale`**
    - **Type**: `(X : Type u_2) [Order.Frame X] : Type u_2`
    - **Module**: `Mathlib.Order.Sublocale`
    - **Category**: Definition
    - **Description**: A sublocale of a locale `X` is a set closed under meets and Heyting implication

34. **`Sublocale.restrict`**
    - **Type**: `{X : Type u_1} [Order.Frame X] (S : Sublocale X) : FrameHom X ↥S`
    - **Module**: `Mathlib.Order.Sublocale`
    - **Category**: Function
    - **Description**: The restriction from a locale X into the sublocale S

35. **`nucleusIsoSublocale`**
    - **Type**: `{X : Type u_1} [Order.Frame X] : (Nucleus X)ᵒᵈ ≃o Sublocale X`
    - **Module**: `Mathlib.Order.Sublocale`
    - **Category**: Theorem
    - **Description**: Nuclei correspond exactly to sublocales (dual order)

---

## Additional Categories of Results

The remaining 96 results include:

### Distribution Laws (20+ theorems)
- Various forms of `inf` distributing over `iSup`/`sSup`
- Indexed and set-based versions
- Dual forms with `sup` and `iInf`/`sInf`

### Heyting Implication (15+ theorems)
- Properties of `⇨` operator
- Adjunction properties
- Complement definitions

### Independence Results (10+ theorems)
- `iSupIndep` and `sSupIndep` for frames
- Pairwise independence
- Independence preservation

### Atom Theory (8+ theorems)
- Atomic and atomistic frames
- Atom-related properties

### Finite Lattice Results (5+ theorems)
- Finite frame properties
- Finite distributivity

### Monotone/Antitone Functions (10+ theorems)
- Frame homomorphisms
- Order-preserving maps

### Set Operations (15+ theorems)
- Frame operations on `Set α`
- Closure properties

## Recommendations for Modal Logic Frame Search

Since Loogle found no modal logic frames, here are alternative search strategies:

### 1. Search for Kripke-Related Terms
```
Loogle queries to try:
- "Kripke"
- "accessibility"
- "modal"
- "possible world"
- "□" (box operator)
- "◇" (diamond operator)
```

### 2. Search by Type Signature
```
Loogle queries to try:
- "Type → (Type → Type → Prop) → Type"  (Frame structure)
- "_ → (_ → _ → Prop) → _"  (Generic frame pattern)
```

### 3. Check Project-Specific Code
The ProofChecker project defines its own modal logic frames:
- `Logos/Core/Semantics/TaskFrame.lean` - Custom frame definition
- `Logos/Core/Semantics/TaskModel.lean` - Model based on frames
- `Logos/Core/Semantics/WorldHistory.lean` - Temporal structures

### 4. Use LeanSearch Instead
LeanSearch provides semantic search and might better understand "modal logic frame" as a concept rather than exact name matching.

## Conclusion

**No modal logic or Kripke frame results found in Mathlib.** The term "Frame" in Mathlib exclusively refers to the lattice-theoretic concept (complete Heyting algebras) used in locale theory and pointless topology.

For modal logic frames, the ProofChecker project must rely on its own custom definitions in `Logos/Core/Semantics/`.

---

**Search Metadata**
- **Tool**: Loogle API
- **Query**: "Frame"
- **Total Results**: 131
- **Relevant Results**: 0
- **Primary Library**: Mathlib
- **Primary Modules**: 
  - `Mathlib.Order.CompleteBooleanAlgebra`
  - `Mathlib.Order.Nucleus`
  - `Mathlib.Order.Sublocale`
  - `Mathlib.Topology.Sets.Opens`
  - `Mathlib.Order.Category.Frm`
