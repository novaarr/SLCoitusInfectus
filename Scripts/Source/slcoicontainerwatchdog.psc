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

function OnContainerActivation(ObjectReference activationContainer, Actor perkOwner)
  if(System.Infections.Lice.Enabled)
    System.Infections.Lice.HandleContainerActivation(activationContainer)
  endIf
endFunction
