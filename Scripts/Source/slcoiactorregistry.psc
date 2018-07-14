scriptname SLCoiActorRegistry extends Quest hidden

float _CleanupInterval = 3600.0 ; 1h interval
float property CleanupInterval
  float function Get()
    return _CleanupInterval
  endFunction

  function Set(float interval)
    _CleanupInterval = interval
    RegisterForSingleUpdate(_CleanupInterval)
  endFunction
endProperty
float property DefaultCleanupInterval auto

; Keys
string property StorageActorListKey = "SLCoi.RegisteredActors" autoReadOnly
string property StorageActorFakeInfectKey = "SLCoi.FakeInfect" autoReadOnly
string property StorageActorInfectionsKey = "SLCoi.RegisteredInfectionsForActor" autoReadOnly

; Registry
function Load()
  RegisterForSingleUpdate(_CleanupInterval)
endFunction

function Unload()
  UnregisterForUpdate()
endFunction

function Register(Actor target)
  if(!IsRegistered(target))
    StorageUtil.FormListAdd(self as Form, StorageActorListKey, target as Form, false)
  endif
endFunction

function Unregister(Actor target)
  if(IsRegistered(target))
    StorageUtil.FormListRemove(self as Form, StorageActorListKey, target as Form, true)
  endIf
endFunction

function Remove(int pos)
  StorageUtil.FormListRemoveAt(self as Form, StorageActorListKey, pos)
endFunction

bool function IsRegistered(Actor target)
  return StorageUtil.FormListHas(self as Form, StorageActorListKey, target as Form)
endFunction

function RegisterInfection(Actor target, SLCoiInfection infection)
  Register(target)

  if(!IsRegisteredInfection(target, infection))
    StorageUtil.FormListAdd(target as Form, StorageActorInfectionsKey, infection as Form, false)
  endif
endFunction

function UnregisterInfection(Actor target, SLCoiInfection infection)
  if(IsRegisteredInfection(target, infection))
    StorageUtil.FormListRemove(target as Form, StorageActorInfectionsKey, infection as Form, true)
  endIf
endFunction

bool function IsRegisteredInfection(Actor target, SLCoiInfection infection)
  return StorageUtil.FormListHas(target as Form, StorageActorInfectionsKey, infection as Form)
endFunction

int function Count()
  return StorageUtil.FormListCount(self as Form, StorageActorListKey)
endFunction

Actor function Get(int at)
  return (StorageUtil.FormListGet(self as Form, StorageActorListKey, at) as Actor)
endFunction

function Clear(Actor target)
  ; Infections
  StorageUtil.FormListClear(target as Form, StorageActorInfectionsKey)

  ; Fake Infections
  StorageUtil.UnsetIntValue(target as Form, StorageActorFakeInfectKey + "." + "Lice")
  StorageUtil.UnsetIntValue(target as Form, StorageActorFakeInfectKey + "." + "SuccubusCurse")
endFunction

function SetFakeInfected(Actor target, SLCoiInfection infection, bool isInfected = true)
  string fullKey = StorageActorFakeInfectKey + "." + infection.GetName()
  StorageUtil.SetIntValue(target as Form, fullKey, isInfected as int)
endFunction

bool function wasFakeInfectedSet(Actor target, SLCoiInfection infection)
  string fullKey = StorageActorFakeInfectKey + "." + infection.GetName()

  if(StorageUtil.GetIntValue(target as Form, fullKey, -1) == -1)
   return false
  endIf

  return true
endFunction

bool function IsFakeInfected(Actor target, SLCoiInfection infection)
  string fullKey = StorageActorFakeInfectKey + "." + infection.GetName()
  return StorageUtil.GetIntValue(target as Form, fullKey) as bool
endFunction

function UnsetFakeInfection(Actor target, SLCoiInfection infection)
  string fullKey = StorageActorFakeInfectKey + "." + infection.GetName()
  StorageUtil.UnsetIntValue(target as Form, fullKey)
endFunction

; Cleanup
function Cleanup()
  int pos = Count()

  if(pos == 0)
    return
  endIf

  while(pos)
    pos -= 1

    Actor registeredActor = Get(pos)

    if(!registeredActor)
      Remove(pos)

    elseIf(registeredActor && registeredActor.IsDead())
      Clear(registeredActor)
      Unregister(registeredActor)
    endIf
  endwhile
endFunction

event OnUpdate()
  Cleanup()

  RegisterForSingleUpdate(_CleanupInterval)
endEvent
