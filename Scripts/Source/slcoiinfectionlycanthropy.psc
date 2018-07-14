scriptname SLCoiInfectionLycanthropy extends SLCoiInfection hidden

Faction property FactionWerewolfRef auto
Race property RaceWerewolfRef auto

Spell property SpellBeastFormRef auto
Spell property SpellWerewolfImmunityRef auto

CompanionsHousekeepingScript property QuestCompanions auto

MT_Quest_PlayerFrameworkScript MTPlayerFramework

bool property MTSupport auto

string function GetName()
  return "Lycanthropy"
endFunction

function Load()
  Quest MTP = Quest.GetQuest("MT_Quest_PlayerFramework")

  if(MTP)
    MTPlayerFramework = MTP as MT_Quest_PlayerFrameworkScript
    MTSupport = true

    System.DebugMessage("Detected: Moonlight Tales")

  else
    MTSupport = false
  endIf

  Supported = true
endFunction

function Unload()
  MTPlayerFramework = None
  MTSupport = false

  Supported = false
endFunction

bool function InfectPlayer(Actor infectingActor)
  if(MTSupport)
    return InfectPlayerMT(infectingActor)
  endIf

  return InfectPlayerVanilla(infectingActor)
endFunction

bool function CurePlayer()
  if(MTSupport)
    return CurePlayerMT()
  endIf

  return CurePlayerVanilla()
endFunction

bool function IsInfected(Actor anActor, bool includeFakeInfection = true)
  if(parent.IsInfected(anActor, includeFakeInfection))
    return true
  endIf

  if(MTSupport)
    return IsInfectedMT(anActor)
  endIf

  return IsInfectedVanilla(anActor)
endFunction

; Vanilla
bool function InfectPlayerVanilla(Actor infectingActor)
  QuestCompanions.PlayerIsWerewolfVirgin = false
  QuestCompanions.PlayerOriginalRace = System.PlayerRef.GetRace()
  QuestCompanions.PlayerIsWerewolf.SetValue(1)
  QuestCompanions.PlayerHasBeastBlood = true

  System.PlayerRef.AddSpell(SpellBeastFormRef, false)
  System.PlayerRef.AddSpell(SpellWerewolfImmunityRef, false)

  System.PlayerRef.DoCombatSpellApply(SpellBeastFormRef, System.PlayerRef)
endFunction

bool function CurePlayerVanilla()
  if(QuestCompanions.PlayerIsWerewolf.GetValue() == 1)
    QuestCompanions.CurePlayer()

    QuestCompanions.PlayerIsWerewolfVirgin = true
    QuestCompanions.PlayerIsWerewolf.SetValue(0)

    return true
  endIf

  return false
endFunction

bool function IsInfectedVanilla(Actor anActor)
  if(anActor == System.PlayerRef                                              \
  && QuestCompanions.PlayerIsWerewolf.GetValue() == 1)
    return true
  endIf

  if(anActor != System.PlayerRef                                              \
  && anActor.GetDisplayName() == "Werewolf")
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

; MT
bool function InfectPlayerMT(Actor infectingActor)
  string BeastName = ""

  if(IsWereBear(infectingActor))
    BeastName = "Werebear"
    MTPlayerFramework.InfectWereBear()

  else
    BeastName = "Werewolf"
    MTPlayerFramework.InfectWerewolf()

  endIf

  System.DebugMessage("Player is becoming a " + BeastName)

  System.PlayerRef.DoCombatSpellApply(MTPlayerFramework.WerewolfChange,     \
                                      System.PlayerRef)

  return true
endFunction

bool function CurePlayerMT()
  MTPlayerFramework.Cure()
  CurePlayerVanilla()
endFunction

bool function IsInfectedMT(Actor anActor)
  if(IsInfectedVanilla(anActor))
    return true
  endIf

  return IsWereBear(anActor)
endFunction

bool function IsWereBear(Actor anActor)
  if(anActor != System.PlayerRef                                              \
  && anActor.GetBaseObject().GetName() == "Werebear")

    return true
  endIf

  if(anActor.IsInFaction(MTPlayerFramework.MT_WerebearFaction))
    return True
  endIf

  return false
endFunction
