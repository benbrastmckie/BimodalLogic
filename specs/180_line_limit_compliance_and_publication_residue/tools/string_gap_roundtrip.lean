/-! Round-trip value check for the string-gap breaker.
    Each `#guard` asserts the ORIGINAL literal equals the GAP-BROKEN literal verbatim.
    A failure here is a build error, so a green build IS the proof. -/

structure Args where
  maxFormulas : Nat
structure Cfg where
  depth : Nat
  visitLimit : Nat

-- 1. embedded JSON literal with escaped quotes  (DatasetExport.lean:451 shape)
#guard
  ("    {\"field\": \"formula_str\", \"format\": \"human-readable\", \"description\": \"Pretty-printed unicode notation\"},\n")
  =
  ("    {\"field\": \"formula_str\", \"format\": \"human-readable\", \"description\": \
      \"Pretty-printed unicode notation\"},\n")

-- 2. s! interpolation, gap placed OUTSIDE the antiquotation  (DatasetExport.lean:943 shape)
#guard
  (fun cliArgs : Args => s!"Max formulas: {if cliArgs.maxFormulas == 0 then "unlimited" else toString cliArgs.maxFormulas}") ⟨7⟩
  =
  (fun cliArgs : Args => s!"Max formulas: \
      {if cliArgs.maxFormulas == 0 then "unlimited" else toString cliArgs.maxFormulas}") ⟨7⟩

-- 3. plain interpolated message literal  (Tactics/Commands.lean:155 shape)
#guard
  (fun (cfg : Cfg) (goalType : String) => s!"modal_search: no proof found within depth {cfg.depth} (visitLimit {cfg.visitLimit}) for goal {goalType}") ⟨3, 40⟩ "G"
  =
  (fun (cfg : Cfg) (goalType : String) => s!"modal_search: no proof found within depth {cfg.depth} (visitLimit {cfg.visitLimit}) for \
      goal {goalType}") ⟨3, 40⟩ "G"
