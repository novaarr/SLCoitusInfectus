scriptname SLCoiPlayerAlias extends ReferenceAlias hidden

SLCoiSystem property System auto

event OnPlayerLoadGame()
  System.DebugMessage("OnPlayerLoadGame")

  System.Restart(soft = true)
endEvent

event OnCellLoad()
  System.DebugMessage("OnCellLoad")

  System.Setup(isCellLoad = true)
EndEvent

event OnObjectEquipped(Form baseObject, ObjectReference objRef)
  if(!System.Enabled)
    return
  endIf

  ; Lice: yps Support
  if(System.Infections.Lice.Enabled)
    System.Infections.Lice.OnPlayerObjectEquipped(baseObject, objRef)
  endIf
endEvent

event OnMagicEffectApply(ObjectReference caster, MagicEffect meRef)
  if(!System.Enabled)
    return
  endIf

  ; Lice: Better Eating Sleeping Support
  if(System.Infections.Lice.Enabled)
    System.Infections.Lice.OnPlayerMagicEffectApply(caster, meRef)
  endIf
endEvent
