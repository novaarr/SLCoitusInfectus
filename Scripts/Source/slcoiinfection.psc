scriptname SLCoiInfection extends Quest hidden

SLCoiSystem property System auto

bool property Enabled = false auto
bool property Supported = false auto
;bool property Interrupting = false auto ; Does interrupt on infection

float property NonPlayerProbability auto
float property PlayerProbability auto

float property NonPlayerProbabilityDefault auto
float property PlayerProbabilityDefault auto

string function GetName()
  return "" ; Infection Name (Unique!)
endFunction

function Load()
  ; Load everything you need here and set `Supported` if the mod required
  ; for this infection to work was detected (you have to do it yourself!)
endFunction

function Unload()
endFunction

bool function isApplicable(Actor infectingActor, Actor target)
  if(!Supported || !Enabled)
    return false
  endIf

  if(!IsInfected(infectingActor) || !canInfect(target))
    return false
  endIf

  return true
endFunction

bool function Apply(Actor infectingActor, Actor target)
  return Infect(infectingActor, target)
endFunction

bool function Infect(Actor infectingActor, Actor target)
  ;if(!Supported)
  ;  System.DebugMessage("Unable to infect actor (" + GetName() + " is not loaded)")
  ;  return false
  ;endIf

  bool wasInfected = false

  if(target == System.PlayerRef)
    wasInfected = InfectPlayer(infectingActor)
  else
    wasInfected = InfectNonPlayer(infectingActor, target)
  endIf

  if(wasInfected)
    System.DebugMessage(target.GetActorBase().GetName() + " has been infected with " + GetName() + " by " + infectingActor.GetActorBase().GetName())
  endIf

  return wasInfected
endFunction

bool function InfectPlayer(Actor infectingActor)
  return false
endFunction

bool function InfectNonPlayer(Actor infectingActor, Actor target)
  return false
endFunction

bool function Cure(Actor target)
  if(!Supported)
    System.DebugMessage("Unable to cure actor (" + GetName() + " is not loaded)")
    return false
  endIf

  bool wasCured = false

  if(target == System.PlayerRef)
    wasCured = CurePlayer()
  else
    wasCured = CureNonPlayer(target)
  endIf

  if(wasCured)
    System.DebugMessage(target.GetActorBase().GetName() + " has been cured of " + GetName())
  endIf

  return wasCured
endFunction

bool function CurePlayer()
  return false
endFunction

bool function CureNonPlayer(Actor target)
  return false
endFunction

bool function IsInfected(Actor target)
  return false
endFunction

bool function canInfect(Actor target)
  return !IsInfected(target)
endFunction
