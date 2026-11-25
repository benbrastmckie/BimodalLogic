# Contextual temporal rules

`luntil intro` and `lsince intro` prove strict Until or Since from a persistent
guard and an eventual event. The operand order is guard, then event.

`ltime_reflect` reflects the whole context and conclusion. Use
`ltime_reflect using d as h` to name the reflection of a derivation.

Use `lunfold inclusiveUntil` or `lfold inclusiveUntil` for the named inclusive view
`inclusiveUntil g e = e ∨ (g ∧ U g e)`. Both tactics also accept `at h`. The
table includes `inclusiveSince`, `release`, `trigger`, `weakUntil`, `weakSince`,
`strongRelease`, `strongTrigger`, `before`, and `after` in both languages.
Inclusive views take the guard first. Release, Trigger and weak or strong
interval views take the event first.

`keeping [...]` on temporal introduction, cases, advance and step retains G/H guarantees
through temporal 4. The rule is chosen by the fact's operator and the scope entered: G into G or
X, and H into H or Y. Entering X or Y requires `ZTime ≤ fc`. Names list the event (if any), ordinary `using` bodies, then kept facts.
Bare current facts need a separate preservation rule. For example, two advances compose opaque
providers without losing the second guarantee at the first witness:

```lean
example (A B C : Formula)
    (ab : [A.someFuture] ⊢ (A.imp B.someFuture).allFuture)
    (bc : [A.someFuture] ⊢ (B.imp C.someFuture).allFuture) :
    [A.someFuture] ⊢ C.someFuture := by
  lstart hA
  ladvance hA using [ab] keeping [bc] as hA hAB hBC
  lhave hB : B.someFuture
  · lapply hAB; lexact hA
  ladvance hB using [hBC] as hB hBC
  lapply hBC
  lexact hB
```

[Derivation proof mode](derivation-proof-mode.md)
