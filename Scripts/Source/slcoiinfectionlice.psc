scriptname SLCoiInfectionLice extends SLCoiInfectionCommon hidden

string function GetName()
  return "Lice"
endFunction

float function GetSkillLevel(Actor target, bool forWeapon = true, bool leftHand = false)
  float skill = 1.0

  if(forWeapon)
    Weapon equippedWeapon = target.GetEquippedWeapon(leftHand)

      if(equippedWeapon)
        if(equippedWeapon.isGreatSword() || equippedWeapon.isBattleAxe() || equippedWeapon.isWarhammer())
          skill = target.GetActorValue("TwoHanded")
        elseif(equippedWeapon.isBow())
          skill = target.GetActorValue("Marksman")
        else
          skill = target.GetActorValue("OneHanded")
        endIf
      endIf
  else
    Spell equippedSpell = target.GetEquippedSpell((!leftHand) as int)

  endIf

  return skill
endFunction

function ReduceStamina(Actor target)
  float stamina = target.GetActorValue("Stamina")
  float rate = target.GetActorValue("StaminaRate")
  float skill = GetSkillLevel(target)

  System.DebugMessage("Stamina: " + stamina + ", rate: " + rate + ", skill: " + skill)

  if(stamina == 0)
    return
  endIf

endFunction

function ReduceMagicka(Actor target, bool leftHand = false)
  float magicka = target.GetActorValue("Magicka")
  float rate = target.GetActorValue("MagickaRate")
  float skill = GetSkillLevel(target, forWeapon = false, leftHand = leftHand)

  if(magicka == 0)
    return
  endIf
endFunction
