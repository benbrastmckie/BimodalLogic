# Modal congruence and simplification

A boxed guarantee rewrites a proposition under `□`. A stability guarantee works under `⊡`
in TM⁺. An equivalence in the current context requires separately justified scope evidence
before it can rewrite within either operator.

Use closed rules such as `ModalS5.boxConjIff` and `ModalS5.s5DiamondBox` with `lsimp only`.
The registry orients Boolean seeds `doubleNegationIff` and `conjunctionSelfIff`, plus
distribution and collapse rules for TM and TM⁺.

`lunfold diamond` changes the formula representation; `lfold diamond` restores the named
form. Other registered views include TM⁺ `dstab`.

[Checked examples](../../Tests/BimodalTest/Automation/ProofModeModalBooleanTest.lean)
cover the goal-side `boxDne` proof and simplification under native stability.

[Derivation proof mode](derivation-proof-mode.md)
