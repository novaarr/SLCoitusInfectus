scriptname SLCoiLiceDebuff extends ActiveMagicEffect hidden

SLCoiInfectionLice property Infection auto

Actor targetRef = None

event OnEffectStart(Actor target, Actor caster)
  targetRef = target

  RegisterForSingleUpdate(1)
endEvent

event OnEffectFinish(Actor target, Actor caster)
  targetRef = None
endEvent

event OnUpdate()
  PlayAnimation()
endEvent

function PlayAnimation()
  Debug.SendAnimationEvent(targetRef, "test_animation")
endFunction
