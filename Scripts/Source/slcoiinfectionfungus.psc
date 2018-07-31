scriptname SLCoiInfectionFungus extends SLCoiInfection

; SLCoiInfection
string function GetName()
  return "Fungus"
endFunction

bool function InfectPlayer(Actor infectingActor)
  return InfectNonPlayer(infectingActor, System.PlayerRef)
endFunction

bool function InfectNonPlayer(Actor infectingActor, Actor target)

  return IsInfected(target)
endFunction

bool function CurePlayer()
  return CureNonPlayer(System.PlayerRef)
endFunction

bool function CureNonPlayer(Actor target)

  return true
endFunction

bool function IsInfected(Actor target, bool includeFakeInfection = true)
  if(parent.IsInfected(target, includeFakeInfection))
    return true
  endIf

  return false
endFunction
