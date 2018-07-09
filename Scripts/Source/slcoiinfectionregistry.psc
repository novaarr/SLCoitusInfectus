scriptname SLCoiInfectionRegistry extends Quest hidden

SLCoiSystem property System auto

SLCoiInfection property Player auto

; Race changing
SLCoiInfectionVampirism property Vampirism auto
SLCoiInfectionLycanthropy property Lycanthropy auto
SLCoiInfectionSuccubusCurse property SuccubusCurse auto

; Common STDs
SLCoiInfectionLice property Lice auto

; Maintenance
function Load()
  System.DebugMessage("Loading up infections")

  Vampirism.Load()
  Lycanthropy.Load()
  SuccubusCurse.Load()
endFunction

function Unload()
  System.DebugMessage("Unloading infections")

  Vampirism.Unload()
  Lycanthropy.Unload()
  SuccubusCurse.Unload()
endFunction
