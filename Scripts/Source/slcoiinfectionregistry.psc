scriptname SLCoiInfectionRegistry extends Quest hidden

; Race changing - Major
SLCoiInfectionVampirism property Vampirism auto
SLCoiInfectionLycanthropy property Lycanthropy auto
SLCoiInfectionSuccubusCurse property SuccubusCurse auto

; Minor
SLCoiInfectionLice property Lice auto
SLCoiInfectionFungus property Fungus auto
SLCoiInfectionRabies property Rabies auto


; Registry
function Load()
  Vampirism.Load()
  Lycanthropy.Load()
  SuccubusCurse.Load()

  Lice.Load()
  Fungus.Load()
  Rabies.Load()
endFunction

function Unload()
  Vampirism.Unload()
  Lycanthropy.Unload()
  SuccubusCurse.Unload()

  Lice.Unload()
  Fungus.Unload()
  Rabies.Unload()
endFunction

function DisableAll()
  Vampirism.Enabled = false
  Lycanthropy.Enabled = false
  SuccubusCurse.Enabled = false

  Lice.Enabled = false
  Fungus.Enabled = false
  Rabies.Enabled = false
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

SLCoiInfection[] function GetMajorInfections()
  SLCoiInfection[] infections = new SLCoiInfection[3]

  infections[0] = Vampirism
  infections[1] = Lycanthropy
  infections[2] = SuccubusCurse

  return infections
endFunction

SLCoiInfection[] function GetMinorInfections()
  SLCoiInfection[] infections = new SLCoiInfection[3]

  infections[0] = Lice
  infections[1] = Fungus
  infections[2] = Rabies

  return infections
endFunction

SLCoiInfection[] function GetInfections(bool reversed = false)
  SLCoiInfection[] infections = new SLCoiInfection[6]

  infections[0] = Vampirism
  infections[1] = Lycanthropy
  infections[2] = SuccubusCurse
  infections[3] = Lice
  infections[4] = Fungus
  infections[5] = Rabies

  if(reversed)
    int posTop = infections.Length
    int posBottom = 0

    while posTop > posBottom
      SLCoiInfection tmp

      tmp = infections[posTop]
      infections[posTop] = infections[posBottom]
      infections[posBottom] = tmp

      posTop -= 1
      posBottom += 1
    endWhile
  endIf

  return infections
endFunction
