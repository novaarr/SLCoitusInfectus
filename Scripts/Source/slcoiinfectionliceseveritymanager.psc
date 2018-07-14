scriptname SLCoiInfectionLiceSeverityManager extends ActiveMagicEffect hidden

SLCoiSystem property System auto

Actor infectedActor = None
float lastUpdate = 0.0

event OnEffectStart(Actor target, Actor caster)
  RegisterForSingleUpdateGameTime(1.0)

  infectedActor = target
  lastUpdate = Utility.GetCurrentGameTime() * 24.0
endEvent

event OnUpdateGameTime()
  int severity = UpdateSeverity()

  System.Infections.Lice.ResetRegenDebuffSpell(infectedActor, severity)

  System.Infections.Lice.StartAnimation(infectedActor, severity)

  RegisterForSingleUpdateGameTime(1.0)
endEvent

int function UpdateSeverity()
  Faction severityFaction = System.Infections.Lice.SeverityFaction
  string infectedActorName = infectedActor.GetActorBase().GetName()

  ; determine time difference in hours
  float currentTime = Utility.GetCurrentGameTime() * 24.0
  float deltaTime = currentTime - lastUpdate
  int severityCurrent = infectedActor.GetFactionRank(severityFaction)

  if(severityCurrent == 100)
    System.DebugMessage("Lice ("+infectedActorName+"): Severity limit has been reached")
    return severityCurrent
  endIf

  System.DebugMessage("Lice ("+infectedActorName+"): Last Update: " + lastUpdate)
  System.DebugMessage("Lice ("+infectedActorName+"): Current Time: " + currentTime)
  System.DebugMessage("Lice ("+infectedActorName+"): Delta: " + deltaTime)
  System.DebugMessage("Lice ("+infectedActorName+"): Hourly Increase: " + System.Infections.Lice.SeverityIncreasePerHour)

  ; calculate hourly incrementation
  float severityIncrease = System.Infections.Lice.SeverityIncreasePerHour * deltaTime
  float severityRest = severityIncrease - Math.abs(severityIncrease)

  ; round up/down
  if(severityRest >= 0.5)
    severityIncrease = Math.Ceiling(severityIncrease)
  else
    severityIncrease = Math.Floor(severityIncrease)
  endIf

  int severityTotal = severityCurrent + (severityIncrease as int)

  if(severityTotal > 100)
    severityTotal = 100
  endIf

  infectedActor.SetFactionRank(severityFaction, severityTotal)

  System.DebugMessage("Lice ("+infectedActorName+"): Increasing severity to " + severityTotal)

  ; set last update time
  lastUpdate = currentTime

  return severityTotal
endFunction
