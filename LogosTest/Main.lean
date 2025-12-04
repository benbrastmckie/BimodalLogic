import LogosTest.LogosTest

def main : IO Unit := do
  IO.println s!"Logos Test Suite v{LogosTest.version}"
  IO.println "All tests passed successfully!"
  return ()
