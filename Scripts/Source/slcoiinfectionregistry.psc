scriptname SLCoiInfectionRegistry extends Quest hidden

; Race changing - Major
SLCoiInfectionVampirism property Vampirism auto
SLCoiInfectionLycanthropy property Lycanthropy auto
SLCoiInfectionSuccubusCurse property SuccubusCurse auto

; Common STDs
SLCoiInfectionLice property Lice auto

; Registry
function Load()
  Vampirism.Load()
  Lycanthropy.Load()
  SuccubusCurse.Load()

  Lice.Load()
endFunction

function Unload()
  Vampirism.Unload()
  Lycanthropy.Unload()
  SuccubusCurse.Unload()

  Lice.Unload()
endFunction

function DisableAll()
  Vampirism.Enabled = false
  Lycanthropy.Enabled = false
  SuccubusCurse.Enabled = false

  Lice.Enabled = false
endFunction

bool function IsMajorInfection(SLCoiInfection infection)
  if(infection.GetName() == Vampirism.GetName())
    return true
  endIf

  if(infection.GetName() == Lycanthropy.GetName())
    return true
  endIf

  if(infection.GetName() == SuccubusCurse.GetName())
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
