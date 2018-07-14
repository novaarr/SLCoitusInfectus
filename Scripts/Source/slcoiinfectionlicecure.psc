scriptname SLCoiInfectionLiceCure extends ActiveMagicEffect hidden

SLCoiInfectionLice property Infection auto

event OnEffectStart(Actor target, Actor caster)
  Infection.Cure(target)
endEvent
