scriptname SLCoiInfectionLycanthropy extends SLCoiInfectionLycanthropyBase hidden

Faction property FactionWerewolfRef auto
Race property RaceWerewolfRef auto

Spell property SpellBeastFormRef auto
Spell property SpellWerewolfImmunityRef auto

CompanionsHousekeepingScript property QuestCompanions auto

string function GetName()
  return "(Lycanthropy) Vanilla"
endFunction

bool function InfectPlayer(Actor infectingActor)
  QuestCompanions.PlayerIsWerewolfVirgin = false
  QuestCompanions.PlayerOriginalRace = System.PlayerRef.GetRace()
  QuestCompanions.PlayerIsWerewolf.SetValue(1)
  QuestCompanions.PlayerHasBeastBlood = true

  System.PlayerRef.AddSpell(SpellBeastFormRef, false)
  System.PlayerRef.AddSpell(SpellWerewolfImmunityRef, false)

  System.PlayerRef.DoCombatSpellApply(SpellBeastFormRef, System.PlayerRef)

  return true
endFunction

bool function CurePlayer()
  if(QuestCompanions.PlayerIsWerewolf.GetValue() == 1)
    QuestCompanions.CurePlayer()

    QuestCompanions.PlayerIsWerewolfVirgin = true
    QuestCompanions.PlayerIsWerewolf.SetValue(0)

    return true
  endIf

  return false
endFunction

bool function IsInfected(Actor anActor)
  if(anActor == System.PlayerRef                                              \
  && QuestCompanions.PlayerIsWerewolf.GetValue() == 1)
    return true
  endIf

  if(anActor != System.PlayerRef                                              \
  && anActor.GetBaseObject().GetName() == "Werewolf")
    return true
  endIf

  if(anActor.IsInFaction(FactionWerewolfRef)                                  \
  || anActor.GetRace() == RaceWerewolfRef)

    return true
  endIf

  if(anActor.IsInFaction(QuestCompanions.CompanionsFaction))
    return true
  endIf

  return false
endFunction

bool function CanInfect(Actor target)
  if(System.Infections.Vampirism.IsInfected(target))
    return false
  endIf

  if(System.Infections.SuccubusCurse.IsInfected(target))
    return false
  endIf

  return parent.CanInfect(target)
endFunction
