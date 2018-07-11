scriptname SLCoiSystem extends Quest hidden

; Public Consts
string property ModEventTry = "SLCoi_TryInfectActor" autoReadOnly
string property ModEventStartup = "SLCoi_Setup" autoReadOnly
string property ModEventShutdown = "SLCoi_Shutdown" autoReadOnly
;string property ModEventUninstall = "SLCoi_Uninstall" autoReadOnly

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

; Dependencies
bool property DepPapyrusUtil auto

; Internal
Actor property PlayerRef auto
SexLabFramework property SexLab auto

SLCoiInfectionRegistry property Infections auto
SLCoiActorRegistry property Actors auto

string SettingsFile = "slcoitusinfectus-config.json"

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

bool function DependencyCheck()
  if(SKSE.GetPluginVersion("papyrusutil plugin") == -1)
    DepPapyrusUtil = false
  else
    DepPapyrusUtil = true
  endIf

  return (DepPapyrusUtil)
endFunction

function Setup(bool isCellLoad = false)
  if(!isActive)
    return
  endif

  if(!DependencyCheck())
    DebugMessage("ERROR: Dependencies not found. Make sure to meet the requirements!")
    return
  endIf

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

function Uninstall()
  int i = 0
  int actor_count = Actors.Count()

  while(actor_count > i)
    Actor target = Actors.Get(i)

    CureInfections(target)
    Actors.Clear(target)

    i += 1
  endWhile

  Actors.UnregisterAll()

  CureInfections(PlayerRef)

  Shutdown()
  OptActive = false
endFunction

; Debug stuff
function DebugMessage(string msg)
  if(OptDebug)
    Debug.Trace("[SLCoitusInfectus] " + msg)
  endIf
endFunction

; Import / Export of settings
function SettingsImport()
  if(!JsonUtil.Load(SettingsFile))
    return
  endIf

  OptInfectionCause = JsonUtil.GetIntValue(SettingsFile, "General.InfectionCause")
  OptNPCInfections = JsonUtil.GetIntValue(SettingsFile, "General.NPCInfections") as bool
  OptDebug = JsonUtil.GetIntValue(SettingsFile, "General.Debug") as bool

  Infections.Vampirism.Enabled = JsonUtil.GetIntValue(SettingsFile, "Infection.Vampirism.Enabled") as bool
  Infections.Vampirism.NonPlayerProbability = JsonUtil.GetFloatValue(SettingsFile, "Infection.Vampirism.NonPlayerProbability")
  Infections.Vampirism.PlayerProbability = JsonUtil.GetFloatValue(SettingsFile, "Infection.Vampirism.PlayerProbability")

  Infections.Lycanthropy.Enabled = JsonUtil.GetIntValue(SettingsFile, "Infection.Lycanthropy.Enabled") as bool
  Infections.Lycanthropy.NonPlayerProbability = JsonUtil.GetFloatValue(SettingsFile, "Infection.Lycanthropy.NonPlayerProbability")
  Infections.Lycanthropy.PlayerProbability = JsonUtil.GetFloatValue(SettingsFile, "Infection.Lycanthropy.PlayerProbability")

  Infections.SuccubusCurse.Enabled = JsonUtil.GetIntValue(SettingsFile, "Infection.SuccubusCurse.Enabled") as bool
  Infections.SuccubusCurse.NonPlayerProbability = JsonUtil.GetFloatValue(SettingsFile, "Infection.SuccubusCurse.NonPlayerProbability")
  Infections.SuccubusCurse.PlayerProbability = JsonUtil.GetFloatValue(SettingsFile, "Infection.SuccubusCurse.PlayerProbability")
  Infections.SuccubusCurse.NonPlayerFakeInfectionProbability = JsonUtil.GetFloatValue(SettingsFile, "Infection.SuccubusCurse.NonPlayerFakeInfectionProbability")

  Infections.Lice.Enabled = JsonUtil.GetIntValue(SettingsFile, "Infection.Lice.Enabled") as bool
  Infections.Lice.NonPlayerProbability = JsonUtil.GetFloatValue(SettingsFile, "Infection.Lice.NonPlayerProbability")
  Infections.Lice.PlayerProbability = JsonUtil.GetFloatValue(SettingsFile, "Infection.Lice.PlayerProbability")
  Infections.Lice.NonPlayerFakeInfectionProbability = JsonUtil.GetFloatValue(SettingsFile, "Infection.Lice.NonPlayerFakeInfectionProbability")
  Infections.Lice.SeverityIncreasePerHour = JsonUtil.GetFloatValue(SettingsFile, "Infection.Lice.SeverityIncreasePerHour")
  Infections.Lice.UnnervingThreshold = JsonUtil.GetFloatValue(SettingsFile, "Infection.Lice.UnnervingThreshold")
  Infections.Lice.SevereThreshold = JsonUtil.GetFloatValue(SettingsFile, "Infection.Lice.SevereThreshold")
  Infections.Lice.MildRegenDebuff = JsonUtil.GetFloatValue(SettingsFile, "Infection.Lice.MildRegenDebuff")
  Infections.Lice.UnnervingRegenDebuff = JsonUtil.GetFloatValue(SettingsFile, "Infection.Lice.UnnervingRegenDebuff")
  Infections.Lice.SevereRegenDebuff = JsonUtil.GetFloatValue(SettingsFile, "Infection.Lice.SevereRegenDebuff")

  DebugMessage("Settings imported")
endFunction

function SettingsExport()
  int settings = JMap.object()

  JsonUtil.SetIntValue(SettingsFile, "General.InfectionCause", OptInfectionCause)
  JsonUtil.SetIntValue(SettingsFile, "General.NPCInfections", OptNPCInfections as int)
  JsonUtil.SetIntValue(SettingsFile, "General.Debug", OptDebug as int)

  JsonUtil.SetIntValue(SettingsFile, "Infection.Vampirism.Enabled", Infections.Vampirism.Enabled as int)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.Vampirism.NonPlayerProbability", Infections.Vampirism.NonPlayerProbability)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.Vampirism.PlayerProbability", Infections.Vampirism.PlayerProbability)

  JsonUtil.SetIntValue(SettingsFile, "Infection.Lycanthropy.Enabled", Infections.Lycanthropy.Enabled as int)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.Lycanthropy.NonPlayerProbability", Infections.Lycanthropy.NonPlayerProbability)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.Lycanthropy.PlayerProbability", Infections.Lycanthropy.PlayerProbability)

  JsonUtil.SetIntValue(SettingsFile, "Infection.SuccubusCurse.Enabled", Infections.SuccubusCurse.Enabled as int)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.SuccubusCurse.NonPlayerProbability", Infections.SuccubusCurse.NonPlayerProbability)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.SuccubusCurse.PlayerProbability", Infections.SuccubusCurse.PlayerProbability)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.SuccubusCurse.NonPlayerFakeInfectionProbability", Infections.SuccubusCurse.NonPlayerFakeInfectionProbability)

  JsonUtil.SetIntValue(SettingsFile, "Infection.Lice.Enabled", Infections.Lice.Enabled as int)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.Lice.NonPlayerProbability", Infections.Lice.NonPlayerProbability)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.Lice.PlayerProbability", Infections.Lice.PlayerProbability)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.Lice.NonPlayerFakeInfectionProbability", Infections.Lice.NonPlayerFakeInfectionProbability)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.Lice.SeverityIncreasePerHour", Infections.Lice.SeverityIncreasePerHour)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.Lice.UnnervingThreshold", Infections.Lice.UnnervingThreshold)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.Lice.SevereThreshold", Infections.Lice.SevereThreshold)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.Lice.MildRegenDebuff", Infections.Lice.MildRegenDebuff)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.Lice.UnnervingRegenDebuff", Infections.Lice.UnnervingRegenDebuff)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.Lice.SevereRegenDebuff", Infections.Lice.SevereRegenDebuff)

  if(JsonUtil.Save(SettingsFile))
    DebugMessage("Settings exported")
  endIf
endFunction

; Infection Application / Curing
bool function TryInfect(SLCoiInfection infection, Actor infectingActor, Actor target)
  if(Infections.isMajorInfection(infection) && Infections.hasMajorInfection(target))
    return false
  endIf

  if(!infection.isApplicable(infectingActor, target))
    return false
  endIf

  if(!infection.hasProbabilityOccurred(target != PlayerRef))
    return false
  else
    DebugMessage("Probability occurred for " + target.GetActorBase().GetName())
  endIf

  if(!infection.Apply(infectingActor, target))
    return false
  endIf

  DebugMessage(target.GetActorBase().GetName() + " has been infected with "   \
    + infection.GetName() + " by " + infectingActor.GetActorBase().GetName())

  return true
endFunction

function CureInfections(Actor anActor)
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
  while(thread.IsLocked && totalSceneWaitTime < MaxSceneWaitTime)

    DebugMessage("Waiting, Animations still active (SexLab)")

    Utility.Wait(SceneWaitTime)
    totalSceneWaitTime += SceneWaitTime
  endWhile

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

  while(DeviousCursedLootRunning() && target == PlayerRef                     \
  &&  totalSceneWaitTime < MaxSceneWaitTime)

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
  TryInfect(Infections.Vampirism, infectingActor, target)
  TryInfect(Infections.Lycanthropy, infectingActor, target)
  TryInfect(Infections.SuccubusCurse, infectingActor, target)

  TryInfect(Infections.Lice, infectingActor, target)

  ; Restart combat
  if(wasInCombatWithTarget && !infectingActor.IsDead() && !target.IsDead())
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
