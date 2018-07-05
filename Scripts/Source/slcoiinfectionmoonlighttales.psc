scriptname SLCoiInfectionMoonlightTales extends SLCoiInfectionLycanthropyBase hidden

SLCoiInfectionLycanthropy property InfectionLycanthropy auto

MT_Quest_PlayerFrameworkScript MTPlayerFramework

string BeastName = "Werewolf" ; Default

string function GetName()
  return "(Lycanthropy) MoonlightTales"
endFunction

function Load()
  Quest MTP = Quest.GetQuest("MT_Quest_PlayerFramework")

  if(!MTP)
    Supported = false

  else
    Supported = true
    MTPlayerFramework = MTP as MT_Quest_PlayerFrameworkScript

  endIf
endFunction

function Unload()
  MTPlayerFramework = None
  Supported = false
endFunction

bool function InfectPlayer(Actor infectingActor)
  if(IsWereBear(infectingActor))
    BeastName = "Werebear"
    MTPlayerFramework.InfectWereBear()

  else
    BeastName = "Werewolf"
    MTPlayerFramework.InfectWerewolf()

  endIf

  System.DebugMessage("Player is becoming a " + BeastName)

  System.PlayerRef.DoCombatSpellApply(MTPlayerFramework.WerewolfChange,     \
                                      System.PlayerRef)

  return true
endFunction

bool function CurePlayer()
  MTPlayerFramework.Cure()
  InfectionLycanthropy.Cure(System.PlayerRef)

  return true
endFunction

bool function IsInfected(Actor anActor)
  if(!Supported)
    System.DebugMessage("MT: Unable to determine if actor is infected, MT is not loaded.")
    return false
  endIf

  if(InfectionLycanthropy.IsInfected(anActor))
    return true
  endIf

  return IsWereBear(anActor)
endFunction

; Internal
bool function IsWereBear(Actor anActor)
  if(anActor != System.PlayerRef                                              \
  && anActor.GetBaseObject().GetName() == "Werebear")

    return true
  endIf

  if(anActor.IsInFaction(MTPlayerFramework.MT_WerebearFaction))
    return True
  endIf

  return false
endFunction

bool function CanInfect(Actor target)
  if(InfectionLycanthropy.IsInfected(target))
    return false
  endIf

  return parent.CanInfect(target)
endFunction
