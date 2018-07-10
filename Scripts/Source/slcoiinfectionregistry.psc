scriptname SLCoiInfectionRegistry extends Quest hidden

SLCoiSystem property System auto

; Race changing - Major
SLCoiInfectionVampirism property Vampirism auto
SLCoiInfectionLycanthropy property Lycanthropy auto
SLCoiInfectionSuccubusCurse property SuccubusCurse auto

; Common STDs
SLCoiInfectionLice property Lice auto

; Utility
bool function IsMajorInfection(SLCoiInfection infection)
  if(infection == Vampirism)
    return true
  endIf

  if(infection == Lycanthropy)
    return true
  endIf

  if(infection == SuccubusCurse)
    return true
  endif

  return false
endFunction

bool function hasMajorInfection(Actor target)
  if(Vampirism.IsInfected(target))
    return true
  endIf

  if(Lycanthropy.IsInfected(target))
    return true
  endIf

  if(SuccubusCurse.IsInfected(target))
    return true
  endIf

  return false
endFunction

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
