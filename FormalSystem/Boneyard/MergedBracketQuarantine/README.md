# MergedBracketQuarantine

**Archived**: Task 332

**Original location**: `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/MergedQuarantine.lean`

**Why archived**: Refuted merged-bracket route (bracket-whose-points-are-brackets). Violates
the no-nesting audit rule and the Rabinovich 2014 Lemma 5.1 quantifier-free point-type
requirement. The file (1,026 lines) was extracted byte-identical from
`NfMultiAnchorBridge.lean` by task 331 as an in-tree quarantine, and retired by task 321's
verdict once the faithful route was settled.

**Not on any live call path**: All 20 declarations are dead. Before archival the file had
exactly one inbound import edge (`NfMultiAnchorBridge.lean:34`), which task 332 removed. No
live declaration references any of its symbols (`kvE_gate`, `kvE_body`, `bracketEndChar_kvE`,
`kvE2_body`, etc.).

The file carries a `#exit` above its imports, so it is inert under the never-built
Boneyard policy (Boneyard code is never compiled; liveness = reachability from a
lakefile root). The original namespace (`Bimodal.Metalogic.WeakCanonical.Kamp`) is preserved for the
historical record.
