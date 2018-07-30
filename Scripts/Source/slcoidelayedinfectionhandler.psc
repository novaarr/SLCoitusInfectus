scriptname SLCoiDelayedInfectionHandler extends ActiveMagicEffect hidden

Message[] property ProgressMessages auto
Message property AboutToApplyMessage auto

float lastUpdate
float timeLeftInHours
bool firstUpdate

event OnEffectStart(Actor target, Actor infectingActor)
  timeLeftInHours = GetInfection().System.OptDelayedInfectionTime
  lastUpdate = Utility.GetCurrentGameTime() * 24.0
  firstUpdate = true

  RegisterForSingleUpdateGameTime(0.1)
endEvent

event OnEffectFinish(Actor target, Actor infectingActor)
  AboutToApplyMessage.Show()

  GetInfection().ApplyImmediately(infectingActor, target)
endEvent

event OnUpdateGameTime()
  float currentTime = Utility.GetCurrentGameTime() * 24.0
  float delta = currentTime - lastUpdate

  timeLeftinHours -= delta

  ; Apply
  if(timeLeftInHours <= 0.0)
    Dispel()
    return
  endIf

  if(!firstUpdate && ProgressMessages.Length > 0)
    int randomIndex = Utility.RandomInt(0, ProgressMessages.Length - 1)
    Message randomMessage = ProgressMessages[randomIndex]

    randomMessage.Show()
  endIf

  float updateTimeInHours = GetUpdateTime()
  RegisterForSingleUpdateGameTime(updateTimeInHours)

  lastUpdate = currentTime
  firstUpdate = false
endEvent

float function GetUpdateTime()
  if(timeLeftInHours <= 1.0)
    return timeLeftInHours
  endif

  return Utility.RandomFloat(0.5, timeLeftInHours - 0.5)
endFunction

SLCoiInfection function GetInfection()
  return None
endFunction
