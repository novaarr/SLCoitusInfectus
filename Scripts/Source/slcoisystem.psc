scriptname SLCoiSystem extends Quest hidden

; Public Consts
string property ModEventTry = "SLCoi_TryInfectActor" autoReadOnly

int property SceneWaitTime = 2 autoReadOnly
int property MaxSceneWaitTime = 20 autoReadOnly

int property InfectionCauseVaginal = 1 autoReadOnly
int property InfectionCauseAnal = 2 autoReadOnly
int property InfectionCauseOral = 4 autoReadOnly
int property InfectionCauseAll = 7 autoReadOnly

; Options
bool property OptDebug auto

bool isEnabled = false
bool property Enabled
  bool function Get()
    return isEnabled
  endFunction

  function Set(bool set_active)
    if(set_active == isEnabled)
      return
    else
      isEnabled = set_active
    endIf

    if(isEnabled)
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
sslThreadSlots property SexLabThreadSlots auto

SLCoiInfectionRegistry property Infections auto
SLCoiActorRegistry property Actors auto

string SettingsFile = "slcoitusinfectus-config.json"

; Support for mods starting scenes
DefeatConfig SLDefeatConfig = None
zadLibs SLDeviousDevicesLib = None
mzinBatheQuest property BathingInSkyrim = None auto

; BathingInSkyrim Registered keys (in case they get changed)
int BiSBathCode = 0
int BiSShowerCode = 0

; System
function LoadSupportedMods()
  Quest Defeat = Quest.GetQuest("DefeatRessourcesQst")
  Quest DDi = Quest.GetQuest("zadQuest")
  Quest BiS = Quest.GetQuest("mzinBatheQuest")

  if(Defeat)
    DebugMessage("Detected: Defeat")
    SLDefeatConfig = Defeat as DefeatConfig
  endIf

  if(DDi)
    DebugMessage("Detected: Devious Devices Integration (DDi)")
    SLDeviousDevicesLib = DDi as zadLibs
  endIf

  if(BiS)
    DebugMessage("Detected: Bathing in Skyrim")
    BathingInSkyrim = BiS as mzinBatheQuest
    BiSBathCode = BathingInSkyrim.BatheKeyCode.GetValueInt()
    BiSShowerCode = BathingInSkyrim.ShowerKeyCode.GetValueInt()
  endIf
endFunction

function UnloadSupportedMods()
  SLDefeatConfig = None
  SLDeviousDevicesLib = None
  BathingInSkyrim = None
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
  if(!isEnabled)
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
    Actors.Load()

    LoadSupportedMods()
  endIf

  RegisterForModEvent("PlayerTrack_Start", "OnSexLabAnimationStart")
  RegisterForModEvent("PlayerTrack_End", "OnSexLabAnimationEnd")
  RegisterForModEvent(ModEventTry, "OnTryInfectActor")

  RegisterForKey(BiSBathCode)
	RegisterForKey(BiSShowerCode)

  DebugMessage("Running")
endFunction

function Shutdown(bool soft = false)
  DebugMessage("Shutdown")

  UnregisterForKey(BiSBathCode)
	UnregisterForKey(BiSShowerCode)

  UnregisterForModEvent("OnSexLabAnimationStart")
  UnregisterForModEvent("OnSexLabAnimationEnd")
  UnregisterforModEvent("OnTryInfectActor")

  UnloadSupportedMods()

  Infections.Unload()
  Actors.Unload()

  if(!soft)
    Infections.DisableAll()
  endIf
endFunction

function Restart(bool soft = false)
  if(!isEnabled)
    return
  endIf

  Shutdown(soft)
  Setup()
endFunction

function Uninstall()
  int i = Actors.Count()

  while(i > 0)
    Actor target = Actors.Get(i - 1)

    CureInfections(target)

    Actors.Clear(target)
    Actors.Unregister(target)

    i -= 1
  endWhile

  Enabled = false
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
  Infections.Lice.SeverityIncreasePerHour = JsonUtil.GetIntValue(SettingsFile, "Infection.Lice.SeverityIncreasePerHour")
  Infections.Lice.UnnervingThreshold.SetValue(JsonUtil.GetIntValue(SettingsFile, "Infection.Lice.UnnervingThreshold"))
  Infections.Lice.SevereThreshold.SetValue(JsonUtil.GetIntValue(SettingsFile, "Infection.Lice.SevereThreshold"))
  Infections.Lice.SeverityReductionBathingMultiplier = JsonUtil.GetFloatValue(SettingsFile, "Infection.Lice.SeverityReductionBathingMultiplier")
  Infections.Lice.SeverityReductionShoweringMultiplier = JsonUtil.GetFloatValue(SettingsFile, "Infection.Lice.SeverityReductionShoweringMultiplier")
  Infections.Lice.SeverityReductionSoapBonusMultiplier = JsonUtil.GetFloatValue(SettingsFile, "Infection.Lice.SeverityReductionSoapBonusMultiplier")

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
  JsonUtil.SetIntValue(SettingsFile, "Infection.Lice.SeverityIncreasePerHour", Infections.Lice.SeverityIncreasePerHour)
  JsonUtil.SetIntValue(SettingsFile, "Infection.Lice.UnnervingThreshold", Infections.Lice.UnnervingThreshold.GetValue() as int)
  JsonUtil.SetIntValue(SettingsFile, "Infection.Lice.SevereThreshold", Infections.Lice.SevereThreshold.GetValue() as int)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.Lice.SeverityReductionBathingMultiplier", Infections.Lice.SeverityReductionBathingMultiplier)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.Lice.SeverityReductionShoweringMultiplier", Infections.Lice.SeverityReductionShoweringMultiplier)
  JsonUtil.SetFloatValue(SettingsFile, "Infection.Lice.SeverityReductionSoapBonusMultiplier", Infections.Lice.SeverityReductionSoapBonusMultiplier)

  if(JsonUtil.Save(SettingsFile))
    DebugMessage("Settings exported")
  endIf
endFunction

; Infection Application / Curing
function TryInfect(SLCoiInfection infection, Actor infectingActor, Actor targetActor)
  if(!infection.Enabled || !infection.Supported)
    return
  endIf

  if(infection.IsInfected(targetActor))
    return
  endIf

  if(!infection.IsInfected(infectingActor))
    return
  endIf

  if(Infections.isMajorInfection(infection)                                   \
  && Infections.hasMajorInfection(targetActor))
    return
  endIf

  if(infection.hasProbabilityOccurred(targetActor != PlayerRef))
    DebugMessage("Probability occurred for " + targetActor.GetActorBase().GetName())
  endIf

  if(!infection.Apply(infectingActor, targetActor))
    return
  endIf

  DebugMessage(targetActor.GetActorBase().GetName()                           \
    + " has been infected with "                                              \
    + infection.GetName() + " by " + infectingActor.GetActorBase().GetName())

  if(targetActor == PlayerRef && OptNPCInfections)
    TryInfect(infection, targetActor, infectingActor)
  endIf
endFunction

function TryFakeInfect(SLCoiInfection infection, Actor NonPlayer)
  if(!infection.Enabled || !infection.Supported)
    return
  endIf

  infection.determineFakeProbability(NonPlayer)

  if(OptNPCInfections                                                         \
  && infection.hasFakeProbabilityOccurred(NonPlayer)                          \
  && !infection.isInfected(NonPlayer, false))

    infection.Apply(NonPlayer, NonPlayer)
  endIf
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
bool function DeviousCursedLootRunning(Actor target)
  int isRunning = StorageUtil.GetIntValue(target, "DCUR_SceneRunning", -1)

  if(isRunning < 1)
    return false
  endIf

  return true
endFunction

function WaitForSceneEnd(Actor target)
  if(target == None)
    return
  endIf

  sslThreadController thread = SexLabThreadSlots.GetActorController(target)

  int totalSceneWaitTime = 0

  ; SexLAb
  if(thread)
    while(thread.IsLocked && totalSceneWaitTime < MaxSceneWaitTime)

      DebugMessage("Waiting, Animations still active (SexLab)")

      Utility.Wait(SceneWaitTime)
      totalSceneWaitTime += SceneWaitTime
    endWhile
  endIf

  ; Devious Devices
  while(SLDeviousDevicesLib.isAnimating(target)                            \
  && totalSceneWaitTime < MaxSceneWaitTime)

    DebugMessage("Waiting, Animations still active (DDi)")

    Utility.Wait(SceneWaitTime)
    totalSceneWaitTime += SceneWaitTime
  endWhile

  ; Defeat
  while(SLDefeatConfig                                                        \
  && SLDefeatConfig.IsDefeatActive(target)                                 \
  && totalSceneWaitTime < MaxSceneWaitTime)

    DebugMessage("Waiting, Animations still active (Defeat)")

    Utility.Wait(SceneWaitTime)
    totalSceneWaitTime += SceneWaitTime
  endWhile

  ; Devious Cursed Loot
  while(DeviousCursedLootRunning(target) && totalSceneWaitTime < MaxSceneWaitTime)

    DebugMessage("Waiting, Animations still active (Devious Cursed Loot)")

    Utility.Wait(SceneWaitTime)
    totalSceneWaitTime += SceneWaitTime
  endWhile
endFunction

; SexLab Events
event OnSexLabAnimationStart(Form anActor, int threadId)
  sslThreadController thread = SexLab.GetController(threadId)

  DebugMessage("SexLab animation has started. Determining fake infections for actors involved.")

  ; Mod not running anymore
  if(!isEnabled)
    DebugMessage("Mod has been deactivated. Aborting.")
    return
  endIf

  ; Cycle through invovlved actors
  int pos = 0
  while(pos < thread.Positions.Length)
    Actor currentActor = thread.Positions[pos]

    if(currentActor != PlayerRef)

      TryFakeInfect(Infections.Lice, currentActor)
      TryFakeInfect(Infections.SuccubusCurse, currentActor)

    endIf

    pos += 1
  endWhile
endEvent

event OnSexLabAnimationEnd(Form anActor, int threadId)
  sslThreadController thread = SexLab.GetController(threadId)

  DebugMessage("SexLab animation has ended. Trying to infect..")

  ; Mod not running anymore
  if(!isEnabled)
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
      SendModEventTry(threadId, currentActor)
    endIf

    pos += 1
  endWhile
endEvent

; Event to infect the Player and/or NonPLayer
event OnTryInfectActor(int threadId, Form NonPlayerForm)
  Actor NonPlayer = NonPlayerForm as Actor
  bool wasInCombatWithTarget = false

  ; Scenes / Animations running?
  WaitForSceneEnd(PlayerRef)

  ; In combat?
  if(NonPlayer.IsInCombat()                                                      \
  && NonPlayer.GetCombatTarget() == PlayerRef)
    wasInCombatWithTarget = true

    NonPlayer.StopCombat()
    PlayerRef.StopCombatAlarm()
  endIf

  ; Try!
  TryInfect(Infections.Vampirism, NonPlayer, PlayerRef)
  TryInfect(Infections.Lycanthropy, NonPlayer, PlayerRef)
  TryInfect(Infections.SuccubusCurse, NonPlayer, PlayerRef)

  TryInfect(Infections.Lice, NonPlayer, PlayerRef)

  ; Restart combat
  if(wasInCombatWithTarget && !NonPlayer.IsDead() && !PlayerRef.IsDead())
    Utility.Wait(SceneWaitTime * 5) ; wait a little
    NonPlayer.StartCombat(PlayerRef)
  endIf
endEvent

; Registered Keys
event OnKeyDown(int code)
  if(BathingInSkyrim)
    ; Will only work if key stays the same or after cell change / load game
    int liceSeverityReduction = 0

    if(BathingInSkyrim.BatheKeyCode.GetValueInt() == code)
      Utility.Wait(5)

      if(HasAndWaitForSpellRemoval(PlayerRef, BathingInSkyrim.PlayBatheAnimationWithSoap))
        liceSeverityReduction = Infections.Lice.CalcReduction(isBathing = true, withSoap = true)

      elseIf(HasAndWaitForSpellRemoval(PlayerRef, BathingInSkyrim.PlayBatheAnimationWithoutSoap))
        liceSeverityReduction = Infections.Lice.CalcReduction(isBathing = true)

      endIf
    elseif(BathingInSkyrim.ShowerKeyCode.GetValueInt() == code)
      Utility.Wait(5)

      if(HasAndWaitForSpellRemoval(PlayerRef, BathingInSkyrim.PlayShowerAnimationWithSoap))
        liceSeverityReduction = Infections.Lice.CalcReduction(isShowering = true, withSoap = true)

      elseIf(HasAndWaitForSpellRemoval(PlayerRef, BathingInSkyrim.PlayShowerAnimationWithoutSoap))
        liceSeverityReduction = Infections.Lice.CalcReduction(isShowering = true)

      endIf
    endIf

    if(liceSeverityReduction > 0)
      Infections.Lice.LessenSeverityOnCleaning(PlayerRef, liceSeverityReduction)
    endIf
  endIf
endEvent

; Utility
function SendModEventTry(int threadId, Actor NonPlayer)
  int handle = ModEvent.Create(ModEventTry)

  if(!handle)
    DebugMessage("Unable to create mod event (Try)")
    return
  endIf

  ModEvent.PushInt(handle, threadId)
  ModEvent.PushForm(handle, NonPlayer)

  if(!ModEvent.Send(handle))
    DebugMessage("Something went wrong with the setup of this mod.")
  endIf
endFunction

bool function HasAndWaitForSpellRemoval(Actor target, Spell waitForSpell)
  if(!target.hasSpell(waitForSpell))
    return false
  endIf

  while(target.hasSpell(waitForSpell))
    Utility.Wait(1)
  endWhile

  return true
endFunction
