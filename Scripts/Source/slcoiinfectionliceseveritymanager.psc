scriptname SLCoiInfectionLiceSeverityManager extends ActiveMagicEffect hidden

SLCoiSystem property System auto

float lastUpdate = 0.0

event OnEffectStart(Actor target, Actor caster)
  RegisterForSingleUpdateGameTime(1.0)

  lastUpdate = Utility.GetCurrentGameTime() * 24.0
endEvent

event OnUpdateGameTime()
  UpdateSeverity()

  RegisterForSingleUpdateGameTime(1.0)
endEvent

function UpdateSeverity()
  Faction severityFaction = System.Infections.Lice.SeverityFaction
  Actor target = GetTargetActor()

  float currentTime = Utility.GetCurrentGameTime() * 24.0
  float deltaTime = currentTime - lastUpdate
  int severityCurrent = target.GetFactionRank(severityFaction)

  if(severityCurrent == 100)
    System.DebugMessage("Lice: Severity limit has been reached by "           \
      + target.GetActorBase().GetName())
    return
  endIf

  System.DebugMessage("Last Update: " + lastUpdate)
  System.DebugMessage("Current Time: " + currentTime)
  System.DebugMessage("Delta: " + deltaTime)
  System.DebugMessage("Hourly Increase: " + System.Infections.Lice.SeverityIncreasePerHour)

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

  System.DebugMessage("Increasing severity to " + severityTotal               \
    + " for actor " + target.GetActorBase().GetName())

  lastUpdate = currentTime
endFunction
