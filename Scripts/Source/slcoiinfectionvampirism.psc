scriptname SLCoiInfectionVampirism extends SLCoiInfection hidden

Faction property FactionVampireRef auto

Spell property SpellVampirisimRef auto
MagicEffect property MEVampireDiseaseRef auto

PlayerVampireQuestScript property QuestVampire auto

string function GetName()
  return "Vampirism"
endFunction

bool function InfectPlayer(Actor infectingActor)
  while(!System.PlayerRef.HasMagicEffect(MEVampireDiseaseRef))
    System.PlayerRef.DoCombatSpellApply(                                    \
      SpellVampirisimRef,                                                   \
      System.PlayerRef                                                      \
    )

  endWhile

  return true
endFunction

bool function InfectNonPlayer(Actor infectingActor, Actor target)
  ;Race targetRace = target.GetActorBase().GetRace()
  ;Race targetVampireRace = GetVampireRaceComplement(targetRace)

  ;if(!targetVampireRace)
  ;  return false
  ;endIf

  ;System.DebugMessage(targetRace + " " + targetVampireRace)
  ;target.SetRace(targetVampireRace)
  ;target.AddToFaction(FactionVampireRef)

  ;return true
  return false
endFunction

bool function CurePlayer()
  if(System.PlayerRef.HasMagicEffect(MEVampireDiseaseRef))
    System.PlayerRef.DispelSpell(SpellVampirisimRef)
  endIf

  If(QuestVampire.PlayerIsVampire.GetValue() == 1)
    QuestVampire.VampireCure(System.PlayerRef)
  endIf

  return true
endFunction

bool function IsInfected(Actor anActor)
  if(anActor.HasMagicEffect(MEVampireDiseaseRef))
    return true
  endIf

  if(anActor.IsInFaction(FactionVampireRef))
    return true
  endIf

  if(anActor == System.PlayerRef                                              \
  && QuestVampire.PlayerIsVampire.GetValue() == 1)
    return true
  endIf

  return false
endFunction

bool function CanInfect(Actor target)
  if(System.Infections.Lycanthropy.IsInfected(target))
    return false
  endIf

  if(System.Infections.SuccubusCurse.IsInfected(target))
    return false
  endIf

  return parent.CanInfect(target)
endFunction
