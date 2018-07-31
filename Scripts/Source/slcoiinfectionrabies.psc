scriptname SLCoiInfectionRabies extends SLCoiInfection

Race[] property AnimalRaces auto

Spell property FirstStageSpell auto

MagicEffect[] property MEStages auto

; SLCoiInfection
string function GetName()
  return "Rabies"
endFunction

bool function InfectPlayer(Actor infectingActor)
  return InfectNonPlayer(infectingActor, System.PlayerRef)
endFunction

bool function InfectNonPlayer(Actor infectingActor, Actor target)
  target.AddSpell(FirstStageSpell, false)
  
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

  int pos = MEStages.Length
  while(pos)
    pos -= 1

    if(target.HasMagicEffect(MEStages[pos]))
      return true
    endIf
  endWhile

  return false
endFunction

function determineFakeProbability(Actor target)
  int raceIndex = AnimalRaces.Length

  while(raceIndex)
    raceIndex -= 1

    if(target.GetRace() == AnimalRaces[raceIndex])
      parent.determineFakeProbability(target)
      return
    endIf
  endWhile
endFunction
