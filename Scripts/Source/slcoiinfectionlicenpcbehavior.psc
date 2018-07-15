scriptname SLCoiInfectionLiceNPCBehavior extends ActiveMagicEffect

SLCoiSystem property System auto

Actor NPC

event OnEffectStart(Actor target, Actor caster)
  RegisterForSingleUpdateGameTime(1.0)
  NPC = target
endEvent

event OnEffectFinish(Actor target, Actor caster)
endEvent

event OnUpdateGameTime()
  if(!NPC || NPC.isDead())
    Dispel()
    return
  endIf

  if(NPC.IsInCombat()                                                         \
  || NPC.IsInDialogueWithPlayer())
    return
  endIf

  bool decideToDoSomething = Utility.RandomInt(0, 1) as bool

  if(decideToDoSomething)
    TryToLessenSeverity()
  endIf

  RegisterForSingleUpdateGameTime(1.0)
endEvent

function TryToLessenSeverity()
  bool inLOSOfPlayer = System.PlayerRef.HasLOS(NPC)
  bool isBathing = Utility.RandomInt(0, 1) as int
  bool isShowering = !isBathing
  bool withSoap = Utility.RandomInt(0, 1) as int

  if(inLOSOfPlayer)
    ; TODO
  endIf

  int reduction = System.Infections.Lice.CalcReduction(isBathing, isShowering, withSoap)

  System.Infections.Lice.LessenSeverityOnCleaning(NPC, reduction)
endFunction
