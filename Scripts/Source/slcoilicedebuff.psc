scriptname SLCoiLiceDebuff extends ActiveMagicEffect hidden

SLCoiInfectionLice property Infection auto

Actor targetRef = None
float severity = 0.0
float lastUpdate = 0.0
float rateDebuff = 0.0

event OnEffectStart(Actor target, Actor caster)
  targetRef = target
  lastUpdate = Utility.GetCurrentGameTime() * 24.0

  RegisterForModEvent(Infection.System.ModEventStartup, "OnSLCoiStartup")
  RegisterForModEvent(Infection.System.ModEventShutdown, "OnSLCoiShutdown")

  RegisterForSingleUpdateGameTime(1)
endEvent

event OnEffectFinish(Actor target, Actor caster)
  UnregisterForUpdateGameTime()
  UnregisterForAllModEvents()

  rateDebuff += Infection.ResetRegenRates(targetRef, rateDebuff)

  targetRef = None
endEvent

event OnUpdateGameTime()
  while(targetRef.IsInCombat())
    Utility.Wait(10)
  endWhile

  if(targetRef.IsDead())
    Infection.Cure(targetRef)
    return
  endIf

  Infection.System.DebugMessage("Current severity: " + severity)

  rateDebuff += Infection.ResetRegenRates(targetRef, rateDebuff)

  severity = Infection.UpdateSeverity(severity, lastUpdate)
  lastUpdate = Utility.GetCurrentGameTime() * 24.0

  Infection.System.DebugMessage("Updated severity: " + severity)

  if(targetRef == Infection.System.PlayerRef)
    Game.DisablePlayerControls()
  endIf

  targetRef.EnableAI(false)

  Infection.StartAnimation(severity, targetRef)

  rateDebuff += Infection.DecreaseRegenRates(severity, targetRef)

  if(targetRef == Infection.System.PlayerRef)
    Game.EnablePlayerControls()
  endIf

  targetRef.EnableAI()

  RegisterForSingleUpdateGameTime(1)
endEvent

event OnSLCoiStartup()
  rateDebuff += Infection.DecreaseRegenRates(severity, targetRef)

  RegisterForSingleUpdateGameTime(1)
endEvent

event OnSLCoiShutdown()
  rateDebuff += Infection.ResetRegenRates(targetRef, rateDebuff)

  UnregisterForUpdateGameTime()
EndEvent
