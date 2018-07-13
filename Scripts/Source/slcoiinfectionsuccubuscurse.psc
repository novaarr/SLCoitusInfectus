scriptname SLCoiInfectionSuccubusCurse extends SLCoiInfection hidden

bool property PSQSupport auto

PlayerSuccubusQuestScript PSQScript

string function GetName()
  return "SuccubusCurse"
endFunction

function Load()
  Quest PSQ = Quest.GetQuest("PlayerSuccubusQuest")

  if(PSQ)
    PSQScript = PSQ as PlayerSuccubusQuestScript
    PSQSupport = true
  endIf

  if(PSQ) ; add: SuccubusHearts, ..
    Supported = true

    System.DebugMessage("Detected: PlayerSuccubusQuest")

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

bool function IsInfected(Actor anActor, bool includeFakeInfection = true)
  if(!PSQSupport)
    System.DebugMessage("PSQ: Unable to determine if Actor is Succubus, PSQ is not loaded.")
    return false
  endIf

  if(parent.IsInfected(anActor, includeFakeInfection))
    return true
  endIf

  return (PSQScript.PlayerIsSuccubus.GetValue() == 1)
endFunction
