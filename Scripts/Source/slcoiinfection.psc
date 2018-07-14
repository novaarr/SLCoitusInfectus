scriptname SLCoiInfection extends Quest hidden

SLCoiSystem property System auto

bool _Enabled = false
bool property Enabled
  bool function Get()
    return _Enabled
  endFunction

  function Set(bool enable)
    if(enable)
      Enable()
    else
      Disable()
    endIf

    _Enabled = enable
  endFunction
endProperty

bool property Supported = false auto
;bool property Interrupting = false auto ; Does interrupt on infection

float property NonPlayerProbability auto
float property PlayerProbability auto

float property NonPlayerProbabilityDefault auto
float property PlayerProbabilityDefault auto

float property NonPlayerFakeInfectionProbability auto
float property DefaultNonPlayerFakeInfectionProbability auto

Message property InfectionMessageRef auto
Message property CureMessageRef auto

string function GetName()
  return "" ; Infection Name (Unique!)
endFunction

function Enable()
  int pos = 0
  while(pos < System.Actors.Count())
    Actor registeredActor = System.Actors.Get(pos)

    if(registeredActor != None) ; ??
      if(!IsInfected(registeredActor)                                           \
      && System.Actors.IsRegisteredInfection(registeredActor, self))
        Apply(registeredActor, registeredActor)
      endIf
    endif

    pos += 1
  endwhile
endFunction

function Disable()
  int pos = 0
  while(pos < System.Actors.Count())
    Actor registeredActor = System.Actors.Get(pos)

    if(registeredActor != None) ; ??
      Cure(registeredActor, unregisterActor = false)
    endIf

    pos += 1
  endwhile
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

  if(wasInfected)
    System.Actors.RegisterInfection(target, self)

    if(InfectionMessageRef && target == System.PlayerRef)
      InfectionMessageRef.Show()
    endIf
  endIf

  return wasInfected
endFunction

bool function InfectPlayer(Actor infectingActor)
  return false
endFunction

bool function InfectNonPlayer(Actor infectingActor, Actor target)
  return false
endFunction

bool function Cure(Actor target, bool unregisterActor = true)
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
    if(unregisterActor)
      System.Actors.UnregisterInfection(target, self)

      if(target != System.PlayerRef)
        System.Actors.UnsetFakeInfection(target, self)
      endIf
    endIf

    if(target == System.PlayerRef && CureMessageRef)
      CureMessageRef.Show()
    endIf

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

bool function IsInfected(Actor target, bool includeFakeInfection = true)
  if(hasFakeProbabilityOccurred(target) && includeFakeInfection)
    return true
  endIf

  return false
endFunction

bool function hasProbabilityOccurred(bool probabilityForNPC = false)
  float random = Utility.RandomFloat()
  float probability = PlayerProbability

  if(probabilityForNPC)
    probability = NonPlayerProbability
  endIf

  if(random <= probability && probability > 0)
    return true
  endIf

  return false
endFunction

function determineFakeProbability(Actor target)
  if(target == System.PlayerRef)
    return
  endIf

  if(NonPlayerFakeInfectionProbability <= 0)
    ;System.DebugMessage("Fake infections for this infection disabled")
    return
  endIf

  if(System.Actors.wasFakeInfectedSet(target, self))
    ;System.DebugMessage("Fake infeciton was already set")
    return
  endIf

  if(System.Infections.isMajorInfection(self)                                 \
  && System.Infections.hasMajorInfection(target))
    ;System.DebugMessage("Already has a major infection")
    return
  endIf

  System.Actors.Register(target)

  float random = Utility.RandomFloat()

  if(random <= NonPlayerFakeInfectionProbability)
    System.Actors.SetFakeInfected(target, self)

    System.DebugMessage("NPC (" + target.GetActorBase().GetName() + ")"       \
    + "is infected with " + GetName() + " (fake)")

  else
    ;System.DebugMessage("Fake infection failed")
    System.Actors.SetFakeInfected(target, self, false)
  endIf
endFunction

bool function hasFakeProbabilityOccurred(Actor infectingActor)
  if(infectingActor == System.PlayerRef)
    return false
  endIf

  if(System.Actors.wasFakeInfectedSet(infectingActor, self))
    System.DebugMessage("NPC is set as infected with " +GetName()+ " (fake)")
    return System.Actors.IsFakeInfected(infectingActor, self)
  endIf

  return false
endFunction
