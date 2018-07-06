scriptname SLCoiInfectionLice extends SLCoiInfectionCommon hidden

float property SeverityIncreatePerHour auto

float property UnnervingThreshold auto
float property SevereThreshold auto

; TODO: Whenever the debuff rates are about to get changed:
;       Reset EVERY actor value modified who's infected
float property MildRegenDebuff auto
float property UnnervingRegenDebuff auto
float property SevereRegenDebuff auto

string[] property AnimationsMild auto
string[] property AnimationsUnnerving auto
string[] property AnimationsSevere auto

string function GetName()
  return "Lice"
endFunction

float function UpdateSeverity(float severity, float lastUpdate)
  float currentTime = Utility.GetCurrentGameTime() * 24.0
  float deltaTime = currentTime - lastUpdate

  System.DebugMessage("Last Update: " + lastUpdate)
  System.DebugMessage("Current Time: " + currentTime)
  System.DebugMessage("Delta: " + deltaTime)
  System.DebugMessage("Hourly Increase: " + SeverityIncreatePerHour)

  if(deltaTime >= 0.0 && deltaTime < 1.0)
    return severity
  endIf

  if(severity == 1.0)
    return 1.0
  endIf

  severity += SeverityIncreatePerHour * (deltaTime as int)

  if(severity > 1.0)
    severity = 1.0
  endIf

  return severity
endFunction

function StartAnimation(float severity, Actor target)
  string animation = ""

  return ; not yet implemented

  if(severity < UnnervingThreshold)
    int random = Utility.RandomInt(0, AnimationsMild.Length - 1)
    animation = AnimationsMild[random]

  elseIf(severity >= UnnervingThreshold && severity < SevereThreshold)
    int random = Utility.RandomInt(0, AnimationsUnnerving.Length - 1)
    animation = AnimationsUnnerving[random]

  else
    int random = Utility.RandomInt(0, AnimationsSevere.Length - 1)
    animation = AnimationsSevere[random]

  endIf

  Debug.SendAnimationEvent(target, animation)
endFunction

float function DecreaseRegenRates(float severity, Actor target)
  float rateChange = 0

  if(severity < UnnervingThreshold)
    rateChange = -MildRegenDebuff

  elseIf(severity >= UnnervingThreshold && severity < SevereThreshold)
    rateChange = -UnnervingRegenDebuff

  else
    rateChange = -SevereRegenDebuff

  endIf

  System.DebugMessage("Modifying regen rates for actor '"+ target.GetActorBase().GetName()  +"': "+ rateChange)

  target.ModAV("MagickaRate", rateChange)
  target.ModAV("StaminaRate", rateChange)

  return rateChange
endFunction

float function ResetRegenRates(Actor target, float rate)
  target.ModAV("MagickaRate", -rate)
  target.ModAV("StaminaRate", -rate)

  return -rate
endFunction
