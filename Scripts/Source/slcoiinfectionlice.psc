scriptname SLCoiInfectionLice extends SLCoiInfection hidden

; TODO:
;   Implement: Cure (Ingame), Lessen Severity (Ingame)
;   Fix: Magic Effect does not change dynamically, only on load

Spell property RegenDebuffSpellRef auto
MagicEffect property SeverityManagerRef auto

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
  target.SetFactionRank(SeverityFaction, 0)

  return IsInfected(target)
endFunction

bool function CurePlayer()
  return CureNonPlayer(System.PlayerRef)
endFunction

bool function CureNonPlayer(Actor target)
  target.DispelSpell(RegenDebuffSpellRef)
  target.RemoveSpell(RegenDebuffSpellRef)

  target.RemoveFromFaction(SeverityFaction)

  return true
endFunction

bool function IsInfected(Actor target, bool includeFakeInfection = true)
  if(parent.IsInfected(target, includeFakeInfection))
    return true
  endIf

  return  target.HasMagicEffect(SeverityManagerRef)
endFunction

; Infection


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
