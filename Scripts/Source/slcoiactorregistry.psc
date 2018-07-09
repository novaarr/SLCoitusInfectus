scriptname SLCoiActorRegistry extends Quest hidden

; TODO: purge list of dead actors (+ interval setting)
; TODO: cleanup / uninstall

string property StorageActorListKey = "SLCoi.RegisteredActors" autoReadOnly
string property StorageActorFakeInfectKey = "SLCoi.FakeInfect" autoReadOnly

function Register(Actor target)
  StorageUtil.FormListAdd(self as Form, StorageActorListKey, target as Form, false)
endFunction

function Unregister(Actor target)
  StorageUtil.FormListRemove(self as Form, StorageActorListKey, target as Form, true)
endFunction

function UnregisterAll()
  StorageUtil.FormListClear(self as Form, StorageActorListKey)
endFunction

int function Count()
  return StorageUtil.FormListCount(self as Form, StorageActorListKey)
endFunction

Actor function Get(int at)
  return (StorageUtil.FormListGet(self as Form, StorageActorListKey, at) as Actor)
endFunction

function Clear(Actor target)
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
