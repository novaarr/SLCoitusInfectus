scriptname SLCoiInfectionCommon extends SLCoiInfection hidden

Spell property SpellApplicationRef auto
MagicEffect property MEDebuffRef auto

float property NonPlayerFakeInfectionProbability auto
float property DefaultNonPlayerFakeInfectionProbability auto

bool function InfectPlayer(Actor infectingActor)
  return InfectNonPlayer(infectingActor, System.PlayerRef)
endFunction

bool function InfectNonPlayer(Actor infectingActor, Actor target)
  target.AddSpell(SpellApplicationRef)

  return true
endFunction

bool function CurePlayer()
  return CureNonPlayer(System.PlayerRef)
endFunction

bool function CureNonPlayer(Actor target)
  target.DispelSpell(SpellApplicationRef)
  target.RemoveSpell(SpellApplicationRef)

  return true
endFunction

bool function IsInfected(Actor target)
  return System.PlayerRef.HasMagicEffect(MEDebuffRef)
endFunction
