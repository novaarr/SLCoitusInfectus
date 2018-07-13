scriptname SLCoiInfectionLiceSeverityManager extends ActiveMagicEffect hidden

SLCoiSystem property System auto

float lastUpdate = 0.0

event OnEffectStart(Actor target, Actor caster)
  RegisterForSingleUpdateGameTime(1.0)

  lastUpdate = Utility.GetCurrentGameTime() * 24.0
endEvent

event OnUpdateGameTime()
  int severity = UpdateSeverity()

  System.Infections.Lice.StartAnimation(severity, GetTargetActor())

  RegisterForSingleUpdateGameTime(1.0)
endEvent

int function UpdateSeverity()
  Faction severityFaction = System.Infections.Lice.SeverityFaction
  Actor target = GetTargetActor()
  string targetName = target.GetActorBase().GetName()

  float currentTime = Utility.GetCurrentGameTime() * 24.0
  float deltaTime = currentTime - lastUpdate
  int severityCurrent = target.GetFactionRank(severityFaction)

  if(severityCurrent == 100)
    System.DebugMessage("Lice ("+targetName+"): Severity limit has been reached")
    return
  endIf

  System.DebugMessage("Lice ("+targetName+"): Last Update: " + lastUpdate)
  System.DebugMessage("Lice ("+targetName+"):Current Time: " + currentTime)
  System.DebugMessage("Lice ("+targetName+"):Delta: " + deltaTime)
  System.DebugMessage("Lice ("+targetName+"):Hourly Increase: " + System.Infections.Lice.SeverityIncreasePerHour)

  float severityIncrease = System.Infections.Lice.SeverityIncreasePerHour * deltaTime
  float severityRest = severityIncrease - Math.abs(severityIncrease)

  if(severityRest >= 0.5)
    severityIncrease = Math.Ceiling(severityIncrease)
  else
    severityIncrease = Math.Floor(severityIncrease)
  endIf

  int severityTotal = severityCurrent + (severityIncrease as int)

  if(severityTotal > 100)
    severityTotal = 100
  endIf

  target.SetFactionRank(severityFaction, severityTotal)

  System.DebugMessage("Lice ("+targetName+"): Increasing severity to " + severityTotal)

  lastUpdate = currentTime

  return severityTotal
endFunction
