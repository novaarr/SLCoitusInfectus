scriptname SLCoiInfection extends Quest hidden

SLCoiSystem property System auto

bool property Enabled = false auto
bool property Supported = false auto
;bool property Interrupting = false auto ; Does interrupt on infection

float property NonPlayerProbability auto
float property PlayerProbability auto

float property NonPlayerProbabilityDefault auto
float property PlayerProbabilityDefault auto

float property NonPlayerFakeInfectionProbability auto
float property DefaultNonPlayerFakeInfectionProbability auto

Message property InfectionMessageRef auto

string function GetName()
  return "" ; Infection Name (Unique!)
endFunction

function Load()
  ; Load everything you need here and set `Supported` if the mod required
  ; for this infection to work was detected (you have to do it yourself!)
endFunction

function Unload()
endFunction

bool function Apply(Actor infectingActor, Actor target)
  bool wasInfected = false

  if(target == System.PlayerRef)
    wasInfected = InfectPlayer(infectingActor)
  else
    wasInfected = InfectNonPlayer(infectingActor, target)
  endIf

  if(wasInfected && InfectionMessageRef && target == System.PlayerRef)
    InfectionMessageRef.Show()
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

  if(System.Actors.wasFakeInfectedSet(target, self))
    System.Actors.Clear(target, self)
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

bool function IsInfected(Actor target, bool fakeInfection = true)
  if(hasFakeProbabilityOccurred(target) && fakeInfection)
    return true
  endIf

  return false
endFunction

bool function canInfect(Actor target)
  return false
endFunction

bool function hasProbabilityOccurred(bool forNPC = false)
  float random = Utility.RandomFloat()
  float probability = PlayerProbability

  if(forNPC)
    probability = NonPlayerProbability
  endIf

  if(random <= probability && probability > 0)
    return true
  endIf

  return false
endFunction

function determineFakeProbability(Actor infectingActor)
  if(infectingActor == System.PlayerRef)
    return
  endIf

  if(System.Infections.isMajorInfection(self)                                 \
  && System.Infections.hasMajorInfection(infectingActor))
    return
  endIf

  System.Actors.Register(infectingActor)

  if(System.Actors.wasFakeInfectedSet(infectingActor, self))
    return
  endIf

  float random = Utility.RandomFloat()

  if(random <= NonPlayerFakeInfectionProbability                              \
  && NonPlayerFakeInfectionProbability > 0)
    System.Actors.SetFakeInfected(infectingActor, self)

    System.DebugMessage("NPC is infected with " + GetName() + " (Fake infection)")

  else
    System.Actors.SetFakeInfected(infectingActor, self, false)
  endIf
endFunction

bool function hasFakeProbabilityOccurred(Actor infectingActor)
  if(infectingActor == System.PlayerRef)
    return false
  endIf

  if(System.Actors.wasFakeInfectedSet(infectingActor, self))
    System.DebugMessage("NPC already checked for fake infection (" +GetName()+ ")")
    return System.Actors.IsFakeInfected(infectingActor, self)
  endIf

  return false
endFunction
