# Handoff: Phase 5b Inconsistent Case -- DCS Definition Gap

**Task**: 107
**Session**: sess_1777486014_fa6129
**Date**: 2026-04-29

## Summary

Phase 5b consistent case is fully proved. The inconsistent case has a genuine blocker: the codebase's `SetDeductivelyClosed` includes a consistency requirement that Burgess 1982 and Xu 1988 do NOT have. This breaks Report 47's Set.univ argument.

## What was accomplished

### Helpers (all compile sorry-free):
- `conj_intro_curried`: |- phi -> (beta -> (beta /\ phi))
- `G_conj_strengthen`: G(phi) in A => G(beta -> beta /\ phi) in A
- `H_conj_strengthen`: H(psi) in C => H(beta -> beta /\ psi) in C
- `g_content_consistent_case`: when {phi} union B consistent and G(phi) in A, burgessR3(A, DC({phi} union B), C) via dc_delta_B_burgessR3 + left_mono_until_G

### Consistent case (proved):
- `g_content_sub_B_of_BurgessR3Maximal`: consistent case closed via g_content_consistent_case + BurgessR3Maximal_extension_fails
- `h_content_sub_B_of_BurgessR3Maximal`: consistent case closed via H_conj_strengthen + snce_left_mono_H + burgessRSince_implies_burgessR

### Splitting lemma (depends on inconsistent case):
- `splitting_seed_consistent` and `lemma_2_6_splitting` moved after g_content/h_content theorems (dependency ordering)
- `splitting_seed_consistent` proof complete BUT depends on the sorry'd theorems

### File structure:
- PointInsertion.lean compiles with 2 sorries (inconsistent cases of g_content_sub_B and h_content_sub_B)

## The blocker

### Report 47's argument is wrong

Report 47 claims Set.univ is SetDeductivelyClosed. This is FALSE in our codebase:

```lean
def SetDeductivelyClosed (S : Set Formula) : Prop :=
  SetConsistent S /\    -- <-- THIS PART
  forall (L : List Formula) (phi : Formula),
    (forall psi in L, psi in S) -> (DerivationTree L phi) -> phi in S
```

Set.univ is NOT SetConsistent because `[bot]` derives bot and bot in Set.univ.

### Burgess/Xu do NOT require consistency in their DCS definition

Burgess 1982, line 65: "A is deductively closed if it contains all its consequences."
Xu 1988, line 75: "A deductively closed set (DCS) is any A containing all its syntactic consequences."

No consistency requirement! Set.univ IS a DCS in Burgess's and Xu's framework.

### Why this matters

BurgessR3Maximal maximality clause: `forall D, SetDeductivelyClosed D -> B subset D -> not burgessR3 A D C`

In Burgess's framework, D = Set.univ is covered (since Set.univ is derivatively closed). In our framework, D = Set.univ is NOT covered (since Set.univ is not consistent).

When {phi} union B is inconsistent:
- We can show burgessR3(A, Set.univ, C) via the ex-falso + left_mono_until_G argument
- But we CANNOT apply BurgessR3Maximal's maximality because Set.univ is not SetDeductivelyClosed

## Proposed fix

### Option A: Split SetDeductivelyClosed (RECOMMENDED)

Define a new predicate without the consistency requirement:

```lean
def ClosedUnderDerivation (S : Set Formula) : Prop :=
  forall (L : List Formula) (phi : Formula),
    (forall psi in L, psi in S) -> (DerivationTree L phi) -> phi in S

-- Then: SetDeductivelyClosed S = SetConsistent S /\ ClosedUnderDerivation S
```

Change BurgessR3Maximal to:
```lean
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B /\
  burgessR3 A B C /\
  forall D, ClosedUnderDerivation D -> B subset D -> not burgessR3 A D C
```

Impact:
1. B itself is still required to be consistent + closed (SetDeductivelyClosed)
2. Maximality quantifies over ALL derivatively-closed sets (matching Burgess/Xu)
3. The Zorn construction (`burgessR3Maximal_extension_exists`) needs to be verified:
   - It constructs B as maximal among CONSISTENT DCS extensions
   - Need to verify B is also maximal among ALL derivatively-closed extensions
   - This requires showing: if burgessR3(A, Set.univ, C) holds, then B is an MCS (every {delta} union B is inconsistent), which means burgessR3(A, DC({delta} union B), C) can never add new elements to B. The argument appears circular but may work because if B is MCS, any proper derivatively-closed extension is inconsistent, so the only candidate is Set.univ.
   - CRITICAL CHECK: Can burgessR3(A, Set.univ, C) actually hold? If yes, the Zorn-maximal B might not satisfy the stronger maximality. If no, the change is safe.

### Option B: Prove inconsistent case cannot occur

Show that {phi} union B must be consistent when G(phi) in A, BurgessR3Maximal(A, B, C), and g_content(A) subset C.

This would require showing: the Zorn construction never produces a B where phi.neg in B for some phi with G(phi) in A. This seems difficult without changing the definition.

### Option C: Accept sorry and proceed

The splitting_seed_consistent proof currently uses g_content_sub_B and h_content_sub_B. If these remain sorry'd, splitting is blocked.

However: the splitting lemma is used in Phase 6+ (Lemma 2.7, counterexample elimination). If the inconsistent case never arises in practice (i.e., the B constructed by burgessR3Maximal_from_g_content_sub always has {phi} union B consistent for phi in g_content(A)), then the sorry is never reached.

## Current sorry count in PointInsertion.lean

2 sorries:
- g_content_sub_B_of_BurgessR3Maximal (inconsistent case, line ~681)
- h_content_sub_B_of_BurgessR3Maximal (inconsistent case, line ~699)

## Files modified

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`

## Build status

`lake build` succeeds (with sorry warnings).
