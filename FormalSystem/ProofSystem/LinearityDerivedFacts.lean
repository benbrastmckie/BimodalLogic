/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation
import FormalSystem.ProofSystem.Axioms

/-!
# Linearity Derived Facts: the record of the TL decision

This prose-only module records why the temporal-linearity schema TL,
  `F(φ) ∧ F(ψ) → F(Fφ ∧ ψ) ∨ (F(φ ∧ ψ) ∨ F(φ ∧ Fψ))`,
is a derived theorem of TM rather than an `Axiom` constructor, and retracts the earlier claim
that it could not be derived.

## TL is derived from CN

`Theorems.LinearityDerived.tempLinearity` derives TL from CN (`Axiom.linear_until`, Burgess
1982 A7a / Xu 1988 (10)) with UF (`self_accum_until`) and UE (`DerivedAxioms.untilF`): UF turns
`Fφ` and `Fψ` into `U(⊤ ∧ Fφ, φ)` and `U(⊤ ∧ Fψ, ψ)`, CN orders the two witnesses, and UE collapses
each of the three CN disjuncts onto the matching TL disjunct. The past form
`Theorems.LinearityDerived.tempLinearityPast` is its time reflection.

The literature anchors are Xu 1988: §3 proves Σ₄ — CN among its axioms, Burgess's A4a deleted —
complete for the class 𝒞₄ of linear frames, which is the system this tree's chronicle
construction already follows (it uses Xu's Lemma 3.2.1/3.2.2 in place of A4a); and §4 Theorem
4.3 shows that the G/H-level linearity formula (13), the TL shape, is strictly weaker than the
Until-level (10). That is the precise sense in which TL is subsumed by CN.

## The retracted claim

An earlier version of this record asserted that TL is not derivable from the base axioms and
offered a branching frame as the witness: three points `{0, 1a, 1b}` with `0 < 1a`, `0 < 1b`,
`1a` and `1b` incomparable, and universal modal accessibility. At `0`, with `φ` true only at `1a`
and `ψ` only at `1b`, every TL disjunct fails.

That frame refutes TL, but it is not a model of the current base: the CN instance
`linear_until (Fp) p (Fq) q` already fails there at `0`, since `U(Fp, p)` and `U(Fq, q)` both hold
(with witnesses `1a` and `1b`) while no point satisfies any of CN's three disjuncts. A frame that
falsifies an axiom cannot witness the independence of a theorem, so the claim is withdrawn. The
branching frame does show something true, and weaker: TL is not derivable from the base *without*
CN, which is why TL had to be primitive before CN was added.

## Historical note

TL was a constructor while CN was absent from the system. Once CN was adopted — stated as the
paper's CN verbatim, with the 3-way disjunction right-associated — TL became redundant, and the
constructor was removed in favour of the derivation above. The paper's `def:BX` still lists TL;
`docs/reference/paper-definitions-of-record.md` records the tree's primitive set as a proper
subset of that list with the same theorems.

## References

* [R. Goldblatt, *Logics of Time and Computation*][goldblatt1992]
* [P. Blackburn, M. de Rijke and Y. Venema, *Modal Logic*][blackburn2002]
* [M. Xu, *On Some U, S-Tense Logics*][xu1988] — §3 (Σ₄ complete for 𝒞₄) and §4 Theorem 4.3
-/

namespace FormalSystem.ProofSystem

open FormalSystem.Syntax

end FormalSystem.ProofSystem
