scriptname SLCoiInfectionLiceNPCBehavior extends ActiveMagicEffect

SLCoiSystem property System auto
FormList property CleaningSpaces auto

Actor NPC

event OnEffectStart(Actor target, Actor caster)
  RegisterForSingleUpdateGameTime(1.0)
  NPC = target

  System.DebugMessage("Lice (" + NPC.GetDisplayName() + "): "                 \
    + "Started NPC Behavior Script")
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

  bool wantsToClean = Utility.RandomInt(0, 1) as bool
  bool wantsToCure = !wantsToClean

  if(wantsToClean && CleaningSpaces)
    System.DebugMessage("Lice (" + NPC.GetDisplayName() + "): "               \
      + "NPC is trying to clean herself/himself")

    bool isBathing = Utility.RandomInt(0, 1) as bool
    bool isShowering = !isBathing
    bool withSoap = Utility.RandomInt(0, 1) as bool

    int reduction = System.Infections.Lice.CalcReduction(isBathing, isShowering, withSoap)

    if(inLOSOfPlayer)
      ObjectReference nearestRef =                                            \
        Game.FindClosestReferenceOfAnyTypeInListFromRef(                      \
          CleaningSpaces,                                                     \
          NPC,                                                                \
          500.0                                                               \
        )

      if(!nearestRef)
        return
      endIf

      float severityAsUrgency =                                               \
        NPC.GetFactionRank(System.Infections.Lice.SeverityFaction) / 100.0

      NPC.EnableAI(false)
      NPC.PathToReference(nearestRef, severityAsUrgency)

      inLOSOfPlayer = System.PlayerRef.HasLOS(NPC)

      if(inLOSOfPlayer)
        ; TODO: Animations?
      endIf

      NPC.EnableAI(true)
    endIf

    System.Infections.Lice.LessenSeverityOnCleaning(NPC, reduction)

  elseIf(wantsToCure)
    bool hasCure = Utility.RandomInt(0, 1) as bool
    System.DebugMessage("Lice (" + NPC.GetDisplayName() + "): "               \
      + "NPC wants to be cured")

    if(hasCure)
      System.DebugMessage("Lice (" + NPC.GetDisplayName() + "): "             \
        + "NPC has the cure")

      if(inLOSOfPlayer)
        NPC.AddItem(System.Infections.Lice.CurePotionRef, 1, true)
        NPC.EquipItem(System.Infections.Lice.CurePotionRef, true, true)
      else
        System.Infections.Lice.Cure(NPC)
      endIf
    else
      System.DebugMessage("Lice (" + NPC.GetDisplayName() + "): "             \
        + "NPC has no cure")
    endIf
  endIf
endFunction
