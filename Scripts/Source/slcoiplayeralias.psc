scriptname SLCoiPlayerAlias extends ReferenceAlias hidden

SLCoiSystem property System auto

event OnPlayerLoadGame()
  System.DebugMessage("OnPlayerLoadGame")

  System.Restart()
endEvent

event OnCellLoad()
  System.DebugMessage("OnCellLoad")

  System.Setup(isCellLoad = true)
EndEvent


; TODO: Move event stuff for player here
