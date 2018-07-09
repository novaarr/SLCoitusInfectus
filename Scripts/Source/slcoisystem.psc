scriptname SLCoiSystem extends Quest hidden

; Public Consts
string property ModEventTry = "SLCoi_TryInfectActor" autoReadOnly
string property ModEventStartup = "SLCoi_Setup" autoReadOnly
string property ModEventShutdown = "SLCoi_Shutdown" autoReadOnly

int property SceneWaitTime = 2 autoReadOnly
int property MaxSceneWaitTime = 20 autoReadOnly

int property InfectionCauseVaginal = 1 autoReadOnly
int property InfectionCauseAnal = 2 autoReadOnly
int property InfectionCauseOral = 4 autoReadOnly
int property InfectionCauseAll = 7 autoReadOnly

; Options
bool property OptDebug auto

bool isActive = false
bool property OptActive
  bool function Get()
    return isActive
  endFunction

  function Set(bool set_active)
    if(set_active == isActive)
      return
    else
      isActive = set_active
    endIf

    if(isActive)
      Setup()
    else
      Shutdown()
    endIf
  endFunction
endProperty

bool property OptNPCInfections auto
int property OptInfectionCause auto

; Internal
Actor property PlayerRef auto
SexLabFramework property SexLab auto
SLCoiInfectionRegistry property Infections auto

string settingsPath = "./data/slcoitusinfectus/config.json"

; Support for mods starting scenes
DefeatConfig SLDefeatConfig = None
zadLibs SLDeviousDevicesLib = None

; System
function LoadSupportedMods()
  Quest Defeat = Quest.GetQuest("DefeatRessourcesQst")
  Quest DDi = Quest.GetQuest("zadQuest")

  if(Defeat)
    DebugMessage("Detected: Defeat")
    SLDefeatConfig = Defeat as DefeatConfig
  endIf

  if(DDi)
    DebugMessage("Detected: Devious Devices Integration (DDi)")
    SLDeviousDevicesLib = DDi as zadLibs
  endIf
endFunction

function UnloadSupportedMods()
  SLDefeatConfig = None
  SLDeviousDevicesLib = None
endFunction

function Setup(bool isCellLoad = false)
  if(!isActive)
    DebugMessage("Mod not active")
    return
  endif

  ; Re-/Loading the registry if the game is loaded to make sure
  ; that the previously supported mods are still running.
  if(!isCellLoad)
    Infections.Load()

    LoadSupportedMods()
  endIf

  RegisterForModEvent("PlayerTrack_End", "OnSexLabAnimationEnd")
  RegisterForModEvent(ModEventTry, "OnTryInfectActor")

  SendModEventStartup()

  DebugMessage("Running")
endFunction

function Shutdown()
  DebugMessage("Shutdown (Stopping receival of external events)")

  SendModEventShutdown()

  UnregisterForModEvent("OnSexLabAnimationEnd")
  UnregisterforModEvent("OnTryInfectActor")

  UnloadSupportedMods()

  Infections.Unload()
endFunction

function Restart()
  if(!isActive)
    return
  endIf

  Shutdown()
  Setup()
endFunction

; Debug stuff
function DebugMessage(string msg)
  if(OptDebug)
    Debug.Trace("[SLCoitusInfectus] " + msg)
  endIf
endFunction

; Import / Export of settings
function SettingsImport()
  int settings = JValue.readFromFile(settingsPath)

  OptInfectionCause = JMap.getInt(settings, "General.InfectionCause")
  OptNPCInfections = JMap.getInt(settings, "General.NPCInfections") as bool
  OptDebug = JMap.getInt(settings, "General.Debug") as bool

  Infections.Vampirism.Enabled = JMap.getInt(settings, "Infection.Vampirism.Enabled") as bool
  Infections.Vampirism.NonPlayerProbability = JMap.getFlt(settings, "Infection.Vampirism.NonPlayerProbability")
  Infections.Vampirism.PlayerProbability = JMap.getFlt(settings, "Infection.Vampirism.PlayerProbability")

  Infections.Lycanthropy.Enabled = JMap.getInt(settings, "Infection.Lycanthropy.Enabled") as bool
  Infections.Lycanthropy.NonPlayerProbability = JMap.getFlt(settings, "Infection.Lycanthropy.NonPlayerProbability")
  Infections.Lycanthropy.PlayerProbability = JMap.getFlt(settings, "Infection.Lycanthropy.PlayerProbability")

  Infections.SuccubusCurse.Enabled = JMap.getInt(settings, "Infection.SuccubusCurse.Enabled") as bool
  Infections.SuccubusCurse.NonPlayerProbability = JMap.getFlt(settings, "Infection.SuccubusCurse.NonPlayerProbability")
  Infections.SuccubusCurse.PlayerProbability = JMap.getFlt(settings, "Infection.SuccubusCurse.PlayerProbability")
  Infections.SuccubusCurse.NonPlayerFakeInfectionProbability = JMap.getFlt(settings, "Infection.SuccubusCurse.NonPlayerFakeInfectionProbability")

  Infections.Lice.Enabled = JMap.getInt(settings, "Infection.Lice.Enabled") as bool
  Infections.Lice.NonPlayerProbability = JMap.getFlt(settings, "Infection.Lice.NonPlayerProbability")
  Infections.Lice.PlayerProbability = JMap.getFlt(settings, "Infection.Lice.PlayerProbability")
  Infections.Lice.NonPlayerFakeInfectionProbability = JMap.getFlt(settings, "Infection.Lice.NonPlayerFakeInfectionProbability")
  Infections.Lice.SeverityIncreasePerHour = JMap.getFlt(settings, "Infection.Lice.SeverityIncreasePerHour")
  Infections.Lice.UnnervingThreshold = JMap.getFlt(settings, "Infection.Lice.UnnervingThreshold")
  Infections.Lice.SevereThreshold = JMap.getFlt(settings, "Infection.Lice.SevereThreshold")
  Infections.Lice.MildRegenDebuff = JMap.getFlt(settings, "Infection.Lice.MildRegenDebuff")
  Infections.Lice.UnnervingRegenDebuff = JMap.getFlt(settings, "Infection.Lice.UnnervingRegenDebuff")
  Infections.Lice.SevereRegenDebuff = JMap.getFlt(settings, "Infection.Lice.SevereRegenDebuff")

  DebugMessage("Settings imported")
endFunction

function SettingsExport()
  int settings = JMap.object()

  JMap.setInt(settings, "General.InfectionCause", OptInfectionCause)
  JMap.setInt(settings, "General.NPCInfections", OptNPCInfections as int)
  JMap.setInt(settings, "General.Debug", OptDebug as int)

  JMap.setInt(settings, "Infection.Vampirism.Enabled", Infections.Vampirism.Enabled as int)
  JMap.setFlt(settings, "Infection.Vampirism.NonPlayerProbability", Infections.Vampirism.NonPlayerProbability)
  JMap.setFlt(settings, "Infection.Vampirism.PlayerProbability", Infections.Vampirism.PlayerProbability)

  JMap.setInt(settings, "Infection.Lycanthropy.Enabled", Infections.Lycanthropy.Enabled as int)
  JMap.setFlt(settings, "Infection.Lycanthropy.NonPlayerProbability", Infections.Lycanthropy.NonPlayerProbability)
  JMap.setFlt(settings, "Infection.Lycanthropy.PlayerProbability", Infections.Lycanthropy.PlayerProbability)

  JMap.setInt(settings, "Infection.SuccubusCurse.Enabled", Infections.SuccubusCurse.Enabled as int)
  JMap.setFlt(settings, "Infection.SuccubusCurse.NonPlayerProbability", Infections.SuccubusCurse.NonPlayerProbability)
  JMap.setFlt(settings, "Infection.SuccubusCurse.PlayerProbability", Infections.SuccubusCurse.PlayerProbability)
  JMap.setFlt(settings, "Infection.SuccubusCurse.NonPlayerFakeInfectionProbability", Infections.SuccubusCurse.NonPlayerFakeInfectionProbability)

  JMap.setInt(settings, "Infection.Lice.Enabled", Infections.Lice.Enabled as int)
  JMap.setFlt(settings, "Infection.Lice.NonPlayerProbability", Infections.Lice.NonPlayerProbability)
  JMap.setFlt(settings, "Infection.Lice.PlayerProbability", Infections.Lice.PlayerProbability)
  JMap.setFlt(settings, "Infection.Lice.NonPlayerFakeInfectionProbability", Infections.Lice.NonPlayerFakeInfectionProbability)
  JMap.setFlt(settings, "Infection.Lice.SeverityIncreasePerHour", Infections.Lice.SeverityIncreasePerHour)
  JMap.setFlt(settings, "Infection.Lice.UnnervingThreshold", Infections.Lice.UnnervingThreshold)
  JMap.setFlt(settings, "Infection.Lice.SevereThreshold", Infections.Lice.SevereThreshold)
  JMap.setFlt(settings, "Infection.Lice.MildRegenDebuff", Infections.Lice.MildRegenDebuff)
  JMap.setFlt(settings, "Infection.Lice.UnnervingRegenDebuff", Infections.Lice.UnnervingRegenDebuff)
  JMap.setFlt(settings, "Infection.Lice.SevereRegenDebuff", Infections.Lice.SevereRegenDebuff)

  JValue.writeToFile(settings, settingsPath)

  DebugMessage("Settings exported")
endFunction

; Infection Application / Curing
bool function TryInfect(SLCoiInfection infection, Actor infectingActor, Actor target)
  if(Infections.Player && target == PlayerRef)
    return false
  endIf

  if(!infection.isApplicable(infectingActor, target))
    return false
  endIf

  if(!ProbabilityOccured(infection, target))
    return false
  endIf

  if(!infection.Apply(infectingActor, target))
    return false
  endIf

  if(target == PlayerRef)
    Infections.Player = infection
  endIf

  return true
endFunction

function CureInfection(Actor anActor)
  if(anActor == PlayerRef && Infections.Player && Infections.Player.Supported)
    DebugMessage("Curing Player")
    Infections.Player.Cure(PlayerRef)
    Infections.Player = None

    return
  endIf
  DebugMessage("Curing Actor")

  if(Infections.Vampirism.IsInfected(anActor))
    DebugMessage("Trying to cure actor of Vampirism")
    Infections.Vampirism.Cure(anActor)

  elseIf(Infections.Lycanthropy.IsInfected(anActor))
    DebugMessage("Trying to cure actor of Lycanthropy")
    Infections.Lycanthropy.Cure(anActor)

  elseIf(Infections.SuccubusCurse.IsInfected(anActor))
    DebugMessage("Trying to cure actor of his/her Succubus curse")
    Infections.SuccubusCurse.Cure(anActor)

  elseIf(Infections.Lice.IsInfected(anActor))
    DebugMessage("Trying to cure actor of lice")
    Infections.Lice.Cure(anActor)

  endIf
endFunction

; Validations
bool function IsValidInfectionCause(sslThreadController thread)
  if(!thread.HasPlayer)
    return false
  endIf

  bool VaginalSexCause =                                                      \
    Math.LogicalAnd(OptInfectionCause, InfectionCauseVaginal)                 \
    && thread.IsVaginal

  bool AnalSexCause =                                                         \
    Math.LogicalAnd(OptInfectionCause, InfectionCauseAnal)                    \
    && thread.IsAnal

  bool OralSexCause =                                                         \
    Math.LogicalAnd(OptInfectionCause, InfectionCauseOral)                    \
    && thread.IsOral

  if(VaginalSexCause || AnalSexCause || OralSexCause)
    return true
  endIf

  return false
endFunction

bool function ProbabilityOccured(SLCoiInfection infection, Actor target)
  float random = Utility.RandomFloat()
  float probability = 0

  if(target != PlayerRef)
    probability = infection.NonPlayerProbability
  else
    probability = infection.PlayerProbability
  endIf

  DebugMessage("Probability occured for actor '" + target.GetActorBase().GetName() + "' ("+random+" <= "+probability + ")")

  if(random <= probability && probability > 0)
    return true
  endIf

  return false
endFunction

; Misc - Scene Check
bool function DeviousCursedLootRunning()
  int isRunning = StorageUtil.GetIntValue(Game.GetPlayer(), "DCUR_SceneRunning", -1)

  if(isRunning < 1)
    return false
  endIf

  return true
endFunction

; Main
event OnSexLabAnimationEnd(Form an_actor, int tid)
  sslThreadController thread = SexLab.GetController(tid)

  DebugMessage("SexLab animation has ended. Trying to infect..")

  ; Mod not running anymore
  if(!isActive)
    DebugMessage("Mod has been deactivated. Aborting.")
    return
  endIf

  ; If player is already infected and NPC infections are turned off, abort
  if(!OptNPCInfections && Infections.Player)
    DebugMessage("Player is already infected and NPC infections are turned off. Aborting.")
    return
  endIf

  ; Current animation matching the cause of an infectino?
  if(!IsValidInfectionCause(thread))
    DebugMessage("Animation not matching causes. Aborting.")
    return
  endIf

  ; Infect participating actors
  int pos = 0
  while(pos < thread.Positions.Length)
    Actor currentActor = thread.Positions[pos]

    if(currentActor != PlayerRef)
      SendModEventTry(tid, currentActor, PlayerRef)

      if(OptNPCInfections)
        SendModEventTry(tid, PlayerRef, currentActor)
      endIf
    endIf

    pos += 1
  endWhile
endEvent

event OnTryInfectActor(int threadId, Form infectingActorForm, Form targetForm)
  Actor infectingActor = infectingActorForm as Actor
  Actor target = targetForm as Actor

  sslThreadController thread = SexLab.GetController(threadId)

  bool wasInCombatWithTarget = false
  int totalSceneWaitTime = 0

  ; Scenes / Animations running?
  totalSceneWaitTime = 0
  while(thread.IsLocked && totalSceneWaitTime < MaxSceneWaitTime)

    DebugMessage("Waiting, Animations still active (SexLab)")

    Utility.Wait(SceneWaitTime)
    totalSceneWaitTime += SceneWaitTime

  endWhile

  totalSceneWaitTime = 0
  while(SLDeviousDevicesLib.isAnimating(target)                               \
  && totalSceneWaitTime < MaxSceneWaitTime)

    DebugMessage("Waiting, Animations still active (DDi)")

    Utility.Wait(SceneWaitTime)
    totalSceneWaitTime += SceneWaitTime

  endWhile

  while(SLDefeatConfig                                                        \
  && SLDefeatConfig.IsDefeatActive(target)                                    \
  && target == PlayerRef                                                      \
  && totalSceneWaitTime < MaxSceneWaitTime)

    DebugMessage("Waiting, Animations still active (Defeat)")

    Utility.Wait(SceneWaitTime)
    totalSceneWaitTime += SceneWaitTime

  endWhile

  while(DeviousCursedLootRunning() && target == PlayerRef)

    DebugMessage("Waiting, Animations still active (Devious Cursed Loot)")

    Utility.Wait(SceneWaitTime)
    totalSceneWaitTime += SceneWaitTime

  endWhile

  ; In combat?
  if(infectingActor.IsInCombat()                                              \
  && infectingActor.GetCombatTarget() == target                               \
  && infectingActor != PlayerRef)
    wasInCombatWithTarget = true

    infectingActor.StopCombat()
    target.StopCombatAlarm()
  endIf

  ; Try!
  if(!TryInfect(Infections.Vampirism, infectingActor, target))
    if(!TryInfect(Infections.Lycanthropy, infectingActor, target))
      TryInfect(Infections.SuccubusCurse, infectingActor, target)
    endIf
  endIf

  ; Restart combat
  if(wasInCombatWithTarget)
    Utility.Wait(SceneWaitTime * 5) ; wait a little
    infectingActor.StartCombat(target)
  endIf
endEvent

; Utility
function SendModEventStartup()
  int handle = ModEvent.Create(ModEventStartup)

  if(!handle)
    DebugMessage("Unable to create mod event (Startup)")
    return
  endIf

  if(!ModEvent.Send(handle))
    DebugMessage("Something went wrong with the setup of this mod.")
  endIf
endFunction

function SendModEventShutdown()
  int handle = ModEvent.Create(ModEventShutdown)

  if(!handle)
    DebugMessage("Unable to create mod event (Shutdown)")
    return
  endIf

  if(!ModEvent.Send(handle))
    DebugMessage("Something went wrong with the setup of this mod.")
  endIf
endFunction

function SendModEventTry(int threadId, Actor infectingActor, Actor target)
  int handle = ModEvent.Create(ModEventTry)

  if(!handle)
    DebugMessage("Unable to create mod event (Try)")
    return
  endIf

  ModEvent.PushInt(handle, threadId)
  ModEvent.PushForm(handle, infectingActor)
  ModEvent.PushForm(handle, target)

  if(!ModEvent.Send(handle))
    DebugMessage("Something went wrong with the setup of this mod.")
  endIf
endFunction
