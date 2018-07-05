scriptname SLCoiInfectionPSQ extends SLCoiInfectionSuccubusCurseBase hidden

float property NonPlayerFakeInfectionProbability auto
float property DefaultNonPlayerFakeInfectionProbability auto

PlayerSuccubusQuestScript PSQScript

string function GetName()
  return "(Succubus Curse) PSQ"
endFunction

function Load()
  Quest PSQ = Quest.GetQuest("PlayerSuccubusQuest")

  if(!PSQ)
    Supported = false

  else
    Supported = true
    PSQScript = PSQ as PlayerSuccubusQuestScript

  endIf
endFunction

function Unload()
  PSQScript = None
  Supported = false
endFunction

bool function InfectPlayer(Actor infectingActor)
  PSQScript.BecomeSuccubus()

  return true
endFunction

bool function CurePlayer()
  PSQScript.QuitSuccubus()

  return true
endFunction

bool function IsInfected(Actor anActor)
  if(!Supported)
    System.DebugMessage("PSQ: Unable to determine if Actor is Succubus, PSQ is not loaded.")
    return false
  endIf

  if(anActor == System.PlayerRef                                              \
  && PSQScript.PlayerIsSuccubus.GetValue() == 1)
    return true

  elseIf(anActor != System.PlayerRef)
    float random = Utility.RandomFloat()

    if(random <= NonPlayerFakeInfectionProbability                          \
    && NonPlayerFakeInfectionProbability > 0)
      System.DebugMessage("NPC is treated as Succubus")

      return true
    endIf
  endIf

  System.DebugMessage("Player has been cured of his/her Succubus curse")

  return false
endFunction

bool function CanInfect(Actor target)
  if(System.Infections.Lycanthropy.IsInfected(target))
    return false
  endIf

  if(System.Infections.Vampirism.IsInfected(target))
    return false
  endIf

  return parent.CanInfect(target)
endFunction
