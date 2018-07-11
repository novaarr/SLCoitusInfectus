scriptname SLCoiInfectionLice extends SLCoiInfection hidden

; TODO: Implement: Cure (Ingame), Lessen Severity (Ingame)
Spell property RegenDebuffSpellRef auto

MagicEffect property MagickaRegenDebuffRef auto
MagicEffect property StaminaRegenDebuffRef auto

int property SeverityIncreasePerHour auto
int property DefaultSeverityIncreasePerHour auto

GlobalVariable property UnnervingThreshold auto
int property DefaultUnnervingThreshold auto

GlobalVariable property SevereThreshold auto
int property DefaultSevereThreshold auto

Faction property SeverityFaction auto

string[] property AnimationsMild auto
string[] property AnimationsUnnerving auto
string[] property AnimationsSevere auto

; SLCoiInfection
string function GetName()
  return "Lice"
endFunction

bool function InfectPlayer(Actor infectingActor)
  return InfectNonPlayer(infectingActor, System.PlayerRef)
endFunction

bool function InfectNonPlayer(Actor infectingActor, Actor target)
  target.AddSpell(RegenDebuffSpellRef, false)
  target.AddToFaction(SeverityFaction)

  return IsInfected(target)
endFunction

bool function CurePlayer()
  return CureNonPlayer(System.PlayerRef)
endFunction

bool function CureNonPlayer(Actor target)
  target.DispelSpell(RegenDebuffSpellRef)
  target.RemoveSpell(RegenDebuffSpellRef)

  return true
endFunction

bool function IsInfected(Actor target, bool fakeInfection = true)
  if(parent.IsInfected(target, fakeInfection))
    return true
  endIf

  return  target.HasMagicEffect(MagickaRegenDebuffRef)                        \
  &&      target.HasMagicEffect(StaminaRegenDebuffRef)
endFunction

; Infection
float function UpdateSeverity(Actor target, float lastUpdate)
  float currentTime = Utility.GetCurrentGameTime() * 24.0
  float deltaTime = currentTime - lastUpdate

  System.DebugMessage("Last Update: " + lastUpdate)
  System.DebugMessage("Current Time: " + currentTime)
  System.DebugMessage("Delta: " + deltaTime)
  System.DebugMessage("Hourly Increase: " + SeverityIncreasePerHour)

  if(deltaTime >= 0.0 && deltaTime < 1.0)
    return severity
  endIf

  if(severity == 1.0)
    return 1.0
  endIf

  severity += SeverityIncreasePerHour * (deltaTime as int)

  if(severity > 1.0)
    severity = 1.0
  endIf

  return severity
endFunction

function StartAnimation(float severity, Actor target)
  string animation = ""

  return ; not yet implemented

  if(severity < UnnervingThreshold.GetValue())
    int random = Utility.RandomInt(0, AnimationsMild.Length - 1)
    animation = AnimationsMild[random]

  elseIf(severity >= UnnervingThreshold.GetValue() && severity < SevereThreshold.GetValue())
    int random = Utility.RandomInt(0, AnimationsUnnerving.Length - 1)
    animation = AnimationsUnnerving[random]

  else
    int random = Utility.RandomInt(0, AnimationsSevere.Length - 1)
    animation = AnimationsSevere[random]

  endIf

  Debug.SendAnimationEvent(target, animation)
endFunction
