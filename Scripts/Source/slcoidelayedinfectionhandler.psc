scriptname SLCoiDelayedInfectionHandler extends ActiveMagicEffect hidden

Message[] property ProgressMessages auto
Message property AboutToApplyMessage auto

float timeLeftInHours

event OnEffectStart(Actor target, Actor infectingActor)
  timeLeftInHours = GetInfection().System.OptDelayedInfectionTime

  RegisterForSingleUpdateGameTime(0.5)
endEvent

event OnEffectFinish(Actor target, Actor infectingActor)
  GetInfection().Apply(target, infectingActor)
endEvent

event OnUpdateGameTime()
  ; Apply
  if(timeLeftInHours <= 0)
    Dispel()

  ; Show immediate infection message
  elseIf(timeLeftInHours > 0 && timeleftInHours <= 1.0)
    AboutToApplyMessage.Show()

  ; Show random progression message
  elseIf(timeLeftInHours > 1.0 && ProgressMessages.Length > 0)
    int randomIndex = Utility.RandomInt(0, ProgressMessages.Length - 1)
    Message randomMessage = ProgressMessages[randomIndex]

    randomMessage.Show()
  endIf

  float updateTimeInHours = GetUpdateTime()
  RegisterForSingleUpdateGameTime(updateTimeInHours)

  timeLeftInHours -= updateTimeInHours
endEvent

float function GetUpdateTime()
  if(timeLeftInHours <= 1.0)
    return timeLeftInHours
  endif


  return Utility.RandomFloat(0.5, timeLeftInHours - 0.9)
endFunction

SLCoiInfection function GetInfection()
  return None
endFunction
