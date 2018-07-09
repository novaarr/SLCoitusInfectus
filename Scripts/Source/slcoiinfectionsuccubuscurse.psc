scriptname SLCoiInfectionSuccubusCurse extends SLCoiInfection hidden

float property NonPlayerFakeInfectionProbability auto
float property DefaultNonPlayerFakeInfectionProbability auto

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

  if(anActor != System.PlayerRef)
    return hasFakeProbabilityOccurred(anActor)
  endIf

  return (PSQScript.PlayerIsSuccubus.GetValue() == 1)
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

bool function hasFakeProbabilityOccurred(Actor infectingActor)
  System.Actors.Register(infectingActor)

  if(System.Actors.wasFakeInfectedSet(infectingActor, self))
    System.DebugMessage("NPC already checked for fake infection")
    return System.Actors.IsFakeInfected(infectingActor, self)
  endIf

  float random = Utility.RandomFloat()

  if(random <= NonPlayerFakeInfectionProbability                              \
  && NonPlayerFakeInfectionProbability > 0)
    System.Actors.SetFakeInfected(infectingActor, self)

    System.DebugMessage("NPC is treated as Succubus")

    return true
  endIf

  System.Actors.SetFakeInfected(infectingActor, self, false)
  return false
endFunction
