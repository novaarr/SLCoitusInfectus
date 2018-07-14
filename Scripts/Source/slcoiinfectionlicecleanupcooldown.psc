scriptname SLCoiInfectionLiceCleanupCooldown extends ActiveMagicEffect hidden

Spell property SeverityReductionCooldownSpellRef auto
Actor infectedActor = None

event OnEffectStart(Actor target, Actor caster)
  infectedActor = target
  RegisterForSingleUpdateGameTime(1)
endEvent

event OnUpdateGameTime()
  infectedActor.RemoveSpell(SeverityReductionCooldownSpellRef)
endEvent
