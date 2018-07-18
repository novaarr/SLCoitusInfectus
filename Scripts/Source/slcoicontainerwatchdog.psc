;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname slcoicontainerwatchdog Extends Perk Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1(ObjectReference akTargetRef, Actor akActor)
;BEGIN CODE
OnContainerActivation(akTargetRef, akActor)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
SLCoiSystem property System auto

string property StorageContainerListKey = "SLCoi.RegisteredContainers" autoReadOnly

function OnContainerActivation(ObjectReference activationContainer, Actor perkOwner)
  if(System.Infections.Lice.Enabled                                           \
  && !IsContainerRegistered(System.Infections.Lice, activationContainer))

    System.Infections.Lice.HandleContainerActivation(activationContainer)
    RegisterContainer(System.Infections.Lice, activationContainer)

  endIf
endFunction

function RegisterContainer(SLCoiInfection infection, ObjectReference aContainer)
  StorageUtil.FormListAdd(infection as Form, StorageContainerListKey, aContainer as Form, false)
endFunction

bool function IsContainerRegistered(SLCoiInfection infection, ObjectReference aContainer)
  return StorageUtil.FormListHas(infection as Form, StorageContainerListKey, aContainer as Form)
endFunction
