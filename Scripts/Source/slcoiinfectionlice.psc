scriptname SLCoiInfectionLice extends SLCoiInfection hidden

; TODO:
;   Notification that severity has been increased

; ypsShavingKnife

Spell property SeverityManagerSpellRef auto

Spell property MildRegenDebuffSpellRef auto
Spell property UnnervingRegenDebuffSpellRef auto
Spell property SevereRegenDebuffSpellRef auto

; Severity: Increment
int property SeverityIncreasePerHour auto
int property DefaultSeverityIncreasePerHour auto

; Severity: Thresholds
GlobalVariable property UnnervingThreshold auto
int property DefaultUnnervingThreshold auto

GlobalVariable property SevereThreshold auto
int property DefaultSevereThreshold auto

; Severity: Reduction
float property SeverityReductionBathingMultiplier auto
float property DefaultSeverityReductionBathingMultiplier auto

float property SeverityReductionShoweringMultiplier auto
float property DefaultSeverityReductionShoweringMultiplier auto

float property SeverityReductionSoapBonusMultiplier auto
float property DefaultSeverityReductionSoapBonusMultiplier auto

Message property SeverityReductionMessage auto

; Severity: Faction
Faction property SeverityFaction auto

; Severity: Cooldown
Spell property SeverityReductionCooldownSpellRef auto
MagicEffect property SeverityReductionCooldownRef auto

; Container
float property ContainerContainsCureProbability auto
float property DefaultContainerContainsCureProbability auto

; Items
Potion property CurePotionRef auto

; Severity: Related Animations
string[] property AnimationsMild auto
string[] property AnimationsUnnerving auto
string[] property AnimationsSevere auto

; Support
bool property BiSSupport auto
string BiSShowerSoapEffectName = "Shower with Soap"
string BiSShowerNoSoapEffectName = "Shower without Soap"
string BiSBathSoapEffectName = "Bathe with Soap"
string BiSBathNoSoapEffectName = "Bathe without Soap"

bool property ESDSupport auto
string ESDWashBodyEffectName = "Play Wash Body"

bool property YPSSupport auto
string YPSShavingKnife = "Shaving Knife"
string YPSShavingCream = "Shaving Cream"

; SLCoiInfection
string function GetName()
  return "Lice"
endFunction

function Load()
  if(Quest.GetQuest("YPS01"))
    YPSSupport = true

    System.DebugMessage("Detected: YPS")
  else
    YPSSupport = false
  endIf

  if(Quest.GetQuest("aaaKNNMCMQuest"))
    ESDSupport = true

    System.DebugMessage("Detected: Eating Sleeping Drinking")
  else
    ESDSupport = false
  endIf

  if(Quest.GetQuest("mzinBatheQuest"))
    BiSSupport = true

    System.DebugMessage("Detected: Bathing in Skyrim")
  else
    BiSSupport = false
  endIf
endFunction

function Unload()
  YPSSupport = false
  ESDSupport = false
  BiSSupport = false
endFunction

bool function InfectPlayer(Actor infectingActor)
  return InfectNonPlayer(infectingActor, System.PlayerRef)
endFunction

bool function InfectNonPlayer(Actor infectingActor, Actor target)
  target.AddToFaction(SeverityFaction)
  target.SetFactionRank(SeverityFaction, 0)
  target.AddSpell(SeverityManagerSpellRef, false)
  target.AddSpell(MildRegenDebuffSpellRef, false)

  return IsInfected(target)
endFunction

bool function CurePlayer()
  return CureNonPlayer(System.PlayerRef)
endFunction

bool function CureNonPlayer(Actor target)
  target.RemoveSpell(SeverityManagerSpellRef)
  target.RemoveSpell(MildRegenDebuffSpellRef)
  target.RemoveSpell(UnnervingRegenDebuffSpellRef)
  target.RemoveSpell(SevereRegenDebuffSpellRef)
  target.RemoveSpell(SeverityReductionCooldownSpellRef)

  target.RemoveFromFaction(SeverityFaction)

  return true
endFunction

bool function IsInfected(Actor target, bool includeFakeInfection = true)
  if(parent.IsInfected(target, includeFakeInfection))
    return true
  endIf

  return target.IsInFaction(SeverityFaction)
endFunction

; Infection
function ResetRegenDebuffSpell(Actor target, int severity)
  int thresholdUnnerving = UnnervingThreshold.GetValue() as int
  int thresholdSevere = SevereThreshold.GetValue() as int

  ; remove active debuffs
  target.RemoveSpell(MildRegenDebuffSpellRef)
  target.RemoveSpell(UnnervingRegenDebuffSpellRef)
  target.RemoveSpell(SevereRegenDebuffSpellRef)

  ; apply debuff related to severity
  if(severity < thresholdUnnerving)
    target.AddSpell(MildRegenDebuffSpellRef, false)

  elseIf(severity >= thresholdUnnerving && severity < thresholdSevere)
    target.AddSpell(UnnervingRegenDebuffSpellRef, false)

  else
    target.AddSpell(SevereRegenDebuffSpellRef, false)
  endIf
endFunction

int function CalcReduction(bool isBathing = false, bool isShowering = false, bool withSoap = false)
  if(isBathing && isShowering)
    return 0
  endIf

  float soapBonusMult = 1.0
  float reductionMult = 1.0

  if(isBathing)
    reductionMult = SeverityReductionBathingMultiplier
  elseIf(isShowering)
    reductionMult = SeverityReductionShoweringMultiplier
  endIf

  if(withSoap)
    soapBonusMult = SeverityReductionSoapBonusMultiplier
  endIf

  return Math.abs(SeverityIncreasePerHour * (soapBonusMult * reductionMult)) as int
endFunction

function LessenSeverityOnCleaning(Actor target, int reduction)
  if(target.HasMagicEffect(SeverityReductionCooldownRef))
    System.DebugMessage("Lice (" +target.GetDisplayName()+"): "       \
      + "Unable to lessen severity: Cooldown active")
    return
  endIf

  int reducedSeverity = target.GetFactionRank(SeverityFaction) - reduction

  if(reducedSeverity < 0)
    reducedSeverity = 0
  endIf

  System.DebugMessage("Lice (" +target.GetDisplayName()+"): "         \
    + "Severity will be reduced through cleaning to " + reducedSeverity)

  target.SetFactionRank(SeverityFaction, reducedSeverity)

  ResetRegenDebuffSpell(target, reducedSeverity)

  SeverityReductionMessage.Show()

  target.AddSpell(SeverityReductionCooldownSpellRef, false)
endFunction

function StartAnimation(Actor target, float severity)
  string animation = ""

  if(!target)
    return
  endIf

  ; get a random scene
  if(AnimationsMild.Length > 0                                                \
  && severity < UnnervingThreshold.GetValue())

    int random = Utility.RandomInt(0, AnimationsMild.Length - 1)
    animation = AnimationsMild[random]

  elseIf(AnimationsUnnerving.Length > 0                                       \
  && severity >= UnnervingThreshold.GetValue()                                \
  && severity < SevereThreshold.GetValue())

    int random = Utility.RandomInt(0, AnimationsUnnerving.Length - 1)
    animation = AnimationsUnnerving[random]

  elseIf(AnimationsSevere.Length > 0                                          \
  && severity >= SevereThreshold.GetValue())
    int random = Utility.RandomInt(0, AnimationsSevere.Length - 1)
    animation = AnimationsSevere[random]

  endIf

  if(animation == "")
    return
  endIf

  ; wait for other scenes to end
  System.WaitForSceneEnd(target)

  ; well, go ahead
  Debug.SendAnimationEvent(target, animation)
endFunction

function HandleContainerActivation(ObjectReference activationContainer)
  if(ContainerContainsCureProbability <= 0)
    return
  endIf

  float random = Utility.RandomFloat()

  if(random > ContainerContainsCureProbability)
    return
  endIf

  activationContainer.AddItem(CurePotionRef, 1, true)

  System.DebugMessage("Lice: Added cure to container")
endFunction

function HandleShaving(Actor target) ; TODO: recognize shaved parts
  int totalSceneWaitTime = System.MaxSceneWaitTime
  Form ShavingCreamForm = ActorGetItemWithFormName(target, YPSShavingCream)

  if(!ShavingCreamForm)
    System.DebugMessage("Lice("+target.GetDisplayName()+"): "                 \
      + "No Shaving Cream was found (YPS). Aborting.")

    return
  endIf

  int ShavingCreamAmount = target.GetItemCount(ShavingCreamForm)

  while(ShavingCreamAmount == target.GetItemCount(ShavingCreamForm)           \
  && totalSceneWaitTime)
    Utility.Wait(System.SceneWaitTime)
    totalSceneWaitTime -= System.SceneWaitTime
  endWhile

  if(ShavingCreamAmount != target.GetItemCount(ShavingCreamForm))
    System.DebugMessage("Lice("+target.GetDisplayName()+"): "                 \
      + "Shaving Cream was used, actor is/was shaving")

    Cure(target)
  else
    System.DebugMessage("Lice("+target.GetDisplayName()+"): "                 \
      + "Shaving Cream wasn't reduced, shaving has probably been aborted")
  endIf
endFunction

; Diverted Actor Events
function OnPlayerObjectEquipped(Form baseObject, ObjectReference objRef)
  if(!System.Infections.Lice.YPSSupport)
    return
  endIf

  if(baseObject.GetName() == YPSShavingKnife)
    System.DebugMessage("Lice("+System.PlayerRef.GetDisplayName()+"): "       \
      + "Equipped Shaving Knife (YPS)")

    System.Infections.Lice.HandleShaving(System.PlayerRef)
  endIf
endFunction

function OnPlayerMagicEffectApply(ObjectReference caster, MagicEffect meRef)
  if(System.Infections.Lice.ESDSupport)
    OnPlayerMagicEffectApplyESD(caster, meRef)
  endIf

  if(System.Infections.Lice.BiSSupport)
    OnPlayerMagicEffectApplyBiS(caster, meRef)
  endIf
endFunction

; Support: BiS
function OnPlayerMagicEffectApplyBiS(ObjectReference caster, MagicEffect meRef)
  int liceSeverityReduction = 0
  string meName = meRef.GetName()

  if(meName == BiSBathSoapEffectName)
    liceSeverityReduction = CalcReduction(isBathing = true, withSoap = true)

  elseIf(meName == BiSBathNoSoapEffectName)
    liceSeverityReduction = CalcReduction(isBathing = true)

  elseif(meName == BiSShowerSoapEffectName)
      liceSeverityReduction = CalcReduction(isShowering = true, withSoap = true)

  elseIf(meName == BiSShowerNoSoapEffectName)
    liceSeverityReduction = CalcReduction(isShowering = true)

  endIf

  if(liceSeverityReduction > 0)
    LessenSeverityOnCleaning(System.PlayerRef, liceSeverityReduction)
  endIf
endFunction

; Support: ESD
function OnPlayerMagicEffectApplyESD(ObjectReference caster, MagicEffect meRef)
  if(meRef.GetName() != ESDWashBodyEffectName)
    return
  endIf

  System.DebugMessage("Lice("+System.PlayerRef.GetDisplayName()+"): "         \
    + "Washing through Eating Sleeping Drinking detected")

  ; randomizing: bath/shower/soap
  bool isBathing = Utility.RandomInt(0, 1) as bool
  bool isShowering = !isBathing
  bool withSoap = Utility.RandomInt(0, 1) as bool

  ; calc reduction
  int reduction = CalcReduction(isBathing, isShowering, withSoap)

  ; update severity
  LessenSeverityOnCleaning(System.PlayerRef, reduction)
endFunction

; Utility
Form function ActorGetItemWithFormName(Actor target, string id)
  int pos = target.GetNumItems()

  while(pos)
    pos -= 1

    Form itemForm = target.GetNthForm(pos)

    if(itemForm.GetName() == id)
      return itemForm
    endIf
  endWhile

  return None
endFunction
