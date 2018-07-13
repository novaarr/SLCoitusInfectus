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
