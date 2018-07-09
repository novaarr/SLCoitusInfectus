scriptname SLCoiInfectionSuccubusCurse extends SLCoiInfection hidden

float property NonPlayerFakeInfectionProbability auto
float property DefaultNonPlayerFakeInfectionProbability auto

bool property PSQSupport auto

PlayerSuccubusQuestScript PSQScript

string function GetName()
  return "Succubus Curse"
endFunction

function Load()
  Quest PSQ = Quest.GetQuest("PlayerSuccubusQuest")

  if(PSQ)
    PSQScript = PSQ as PlayerSuccubusQuestScript
    PSQSupport = true
  endIf

  if(PSQ) ; add: SuccubusHearts, ..
    Supported = true

  else
    Supported = false
    Enabled = false

  endIf
endFunction

function Unload()
  PSQScript = None
  PSQSupport = false

  Supported = false
endFunction

bool function InfectPlayer(Actor infectingActor)
  if(!PSQSupport)
    return false
  endIf

  PSQScript.BecomeSuccubus()

  return true
endFunction

bool function CurePlayer()
  if(!PSQSupport)
    return false
  endIf

  PSQScript.QuitSuccubus()

  return true
endFunction

bool function IsInfected(Actor anActor)
  if(!PSQSupport)
    System.DebugMessage("PSQ: Unable to determine if Actor is Succubus, PSQ is not loaded.")
    return false
  endIf

  if(anActor == System.PlayerRef                                              \
  && PSQScript.PlayerIsSuccubus.GetValue() == 1)
    return true

  elseIf(anActor != System.PlayerRef)
    float random = Utility.RandomFloat()

    if(random <= NonPlayerFakeInfectionProbability                            \
    && NonPlayerFakeInfectionProbability > 0)
      System.DebugMessage("NPC is treated as Succubus")

      return true
    endIf
  endIf

  System.DebugMessage("Player has been cured of his/her Succubus curse")

  return false
endFunction

bool function CanInfect(Actor target)
  if(!PSQSupport)
    return false
  endIf

  if(System.Infections.Lycanthropy.IsInfected(target))
    return false
  endIf

  if(System.Infections.Vampirism.IsInfected(target))
    return false
  endIf

  return parent.CanInfect(target)
endFunction
