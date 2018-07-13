scriptname SLCoiInfectionLice extends SLCoiInfection hidden

; TODO:
;   Implement: Cure (Ingame)
;   Fix: Magic Effect does not change dynamically, only on load
;   Bathing/Showering: Add Cooldown

Spell property RegenDebuffSpellRef auto
MagicEffect property SeverityManagerRef auto

; Severity: Increment
int property SeverityIncreasePerHour auto
int property DefaultSeverityIncreasePerHour auto

; Severity: Thresholds
GlobalVariable property UnnervingThreshold auto
int property DefaultUnnervingThreshold auto

GlobalVariable property SevereThreshold auto
int property DefaultSevereThreshold auto

; Severity: Reduction
int property SeverityReductionBathing auto
int property DefaultSeverityReductionBathing auto

int property SeverityReductionShowering auto
int property DefaultSeverityReductionShowering auto

int property SeverityReductionSoapBonus auto
int property DefaultSeverityReductionSoapBonus auto

Message property SeverityReductionMessage auto

; Severity: Faction
Faction property SeverityFaction auto

; Severity: Related Animations
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
function LessenSeverityOnBathing(Actor target, bool withSoap = false)
  int severityCurrent = target.GetFactionRank(SeverityFaction)
  int severityReduction = SeverityReductionBathing

  if(withSoap)
    severityReduction += SeverityReductionSoapBonus
  endIf

  System.DebugMessage("Lice (" +target.GetActorBase().GetName()+"): "         \
    + "Severity will be reduced through bathing by " + severityReduction)

  target.SetFactionRank(SeverityFaction, severityCurrent - severityReduction)

  SeverityReductionMessage.Show()
endFunction

function LessenSeverityOnShowering(Actor target, bool withSoap = false)
  int severityCurrent = target.GetFactionRank(SeverityFaction)
  int severityReduction = SeverityReductionShowering

  if(withSoap)
    severityReduction += SeverityReductionSoapBonus
  endIf

  System.DebugMessage("Lice (" +target.GetActorBase().GetName()+"): "         \
    + "Severity will be reduced through showering by " + severityReduction)

  target.SetFactionRank(SeverityFaction, severityCurrent - severityReduction)

  SeverityReductionMessage.Show()
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

  ; wait for other scenes to end
  System.WaitForSceneEnd(target)

  ; well, go ahead
  Debug.SendAnimationEvent(target, animation)
endFunction
