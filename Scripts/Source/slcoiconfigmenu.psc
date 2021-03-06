scriptname SLCoiConfigMenu extends SKI_ConfigBase hidden

SLCoiSystem property System auto

; CONSTS
int TOP_LEFT = 0
int TOP_RIGHT = 1
int BOTTOM_LEFT = 63

string COLOR_RED = "#AA5555"
string COLOR_GREEN = "#55AA55"

; OIDs
int oidStatusActive = -1

int oidSettingsNPCInfections = -1
int oidSettingsMajorImmunities = -1
int oidSettingsDelayedInfection = -1

int oidSettingsInfectionTypeLycanthropyEnabled = -1
int oidSettingsInfectionTypeVampirismEnabled = -1
int oidSettingsInfectionTypeSuccubusCurseEnabled = -1

int oidSettingsInfectionCauseVaginal = -1
int oidSettingsInfectionCauseAnal = -1
int oidSettingsInfectionCauseOral = -1

int oidSettingsInfectionLycanthropyProbabilityPC = -1
int oidSettingsInfectionLycanthropyProbabilityNPC = -1
int oidSettingsInfectionVampirismProbabilityPC = -1
int oidSettingsInfectionVampirismProbabilityNPC = -1
int oidSettingsInfectionSuccubusCurseProbabilityPC = -1
int oidSettingsInfectionSuccubusCurseProbabilityNPC = -1

int oidSettingsPSQNPCInfectionProbability = -1

int oidSettingsInfectionTypeLiceEnabled = -1
int oidSettingsInfectionLiceProbabilityPC = -1
int oidSettingsInfectionLiceProbabilityNPC = -1
int oidSettingsInfectionLiceSeverityIncrease = -1
int oidSettingsInfectionLiceUnnervingThreshold = -1
int oidSettingsInfectionLiceSevereThreshold = -1
int oidSettingsInfectionLiceFakeNPCProbability = -1
int oidSettingsInfectionLiceBathing = -1
int oidSettingsInfectionLiceShowering = -1
int oidSettingsInfectionLiceSoap = -1
int oidSettingsInfectionLiceContainerProbability = -1

int oidMiscDebug = -1

int oidMiscCure = -1
int oidMiscCureNearby = -1
Actor[] tempNearbyActors

int oidMiscImport = -1
int oidMiscExport = -1

int oidMiscCleanupInterval = -1

int oidMiscUninstall = -1

; Version
int function GetVersion()
  return 3
endFunction

; SkyUI MCM Events
event OnConfigInit()
endEvent

event OnConfigRegister()
endEvent

event OnVersionUpdate(int version)
  if(version > CurrentVersion)
    System.Update(version, CurrentVersion)
  endIf

  if CurrentVersion < 3
    System.DebugMessage("MCM: Updating to version 3")
    Pages = new string[5]

    Pages[0] = "$PageStatus"
    Pages[1] = "$PageGeneral"
    Pages[2] = "$PageMajor"
    Pages[3] = "$PageMinor"
    Pages[4] = "$PageMisc"
  endIf
endEvent

event OnPageReset(string a_page)
  ; if mod not active, show message instead of page
  if((a_page != "$PageStatus" && a_page != "") && !System.Enabled)
    ShowMessage("$ModIsNotActivated")

    SetupPageStatus()
    return
  endIf

  if(a_page == "$PageStatus" || a_page == "")
    SetupPageStatus()
  endIf

  If(a_page == "$PageGeneral")
    SetupPageGeneral()

  elseIf(a_page == "$PageMajor")
    SetupPageMajor()

  elseIf(a_page == "$PageMinor")
    SetupPageMinor()

  elseIf(a_page == "$PageMisc")
    SetupPageMisc()

  endIf
endEvent

event OnOptionHighlight(int option)
  if(option == oidSettingsMajorImmunities)
    SetInfoText("$SettingsMajorImmunitiesHint")

  elseIf(option == oidSettingsInfectionTypeSuccubusCurseEnabled)
    SetInfoText("$SettingsInfectionTypeSuccubusCurseHint")

  elseIf(option == oidSettingsPSQNPCInfectionProbability                      \
  ||    option == oidSettingsInfectionLiceFakeNPCProbability)
    SetInfoText("$SettingsFakeNPCInfectionProbabilityHint")

  elseIf(option == oidSettingsNPCInfections)
    SetInfoText("$SettingsNPCInfectionsHint")

  elseIf(option == oidSettingsInfectionLiceSeverityIncrease)
    SetInfoText("$SettingsSTDLiceSeverityIncreasePerHourHint")

  elseIf(option == oidMiscCleanupInterval)
    SetInfoText("$MiscCleanupIntervalHint")

  elseIf(option == oidSettingsInfectionLiceBathing                            \
  ||    option == oidSettingsInfectionLiceShowering                           \
  ||    option == oidSettingsInfectionLiceSoap)
    SetInfoText("$SettingsSTDLiceSeverityReductionHint")

  elseIf(option == oidSettingsInfectionLiceContainerProbability)
    SetInfoText("$SettingsSTDLiceContainerContainsCureHint")

  elseIf(option == oidSettingsDelayedInfection)
    SetInfoText("$SettingsDelayedInfectionHint")

  endIf
endEvent

event OnOptionSelect(int option)
  ; warnings
  if( (option == oidSettingsInfectionTypeVampirismEnabled                     \
  &&  System.Infections.Vampirism.Enabled)                                    \
                                                                              \
  ||  (option == oidSettingsInfectionTypeLycanthropyEnabled                   \
  &&  System.Infections.Lycanthropy.Enabled)                                  \
                                                                              \
  ||  (option == oidSettingsInfectionTypeSuccubusCurseEnabled                 \
  &&  System.Infections.SuccubusCurse.Enabled)                                \
                                                                              \
  ||  (option == oidSettingsInfectionTypeLiceEnabled                          \
  &&  System.Infections.Lice.Enabled))

    if(false == ShowMessage("$SettingsInfectionDisableWarning"))
      return
    endIf

  elseIf(option == oidStatusActive && System.Enabled)
    if(false == ShowMessage("$StatusModDisableWarning"))
      return
    endIf

  elseIf(option == oidMiscUninstall)
    if(false == ShowMessage("$MiscUninstallWarning"))
      return
    endIf
  endIf

  if(option == oidStatusActive)
    System.Enabled = !System.Enabled

  elseIf(option == oidSettingsNPCInfections)
    System.OptNPCInfections = !System.OptNPCInfections

  elseIf(option == oidSettingsMajorImmunities)
    System.OptMajorImmunities = !System.OptMajorImmunities

  ; Infection Activation
  elseIf(option == oidSettingsInfectionTypeLycanthropyEnabled)
    System.Infections.Lycanthropy.Enabled = !System.Infections.Lycanthropy.Enabled

  elseIf(option == oidSettingsInfectionTypeVampirismEnabled)
    System.Infections.Vampirism.Enabled = !System.Infections.Vampirism.Enabled

  elseIf(option == oidSettingsInfectionTypeSuccubusCurseEnabled)
    System.Infections.SuccubusCurse.Enabled = !System.Infections.SuccubusCurse.Enabled

  elseIf(option == oidSettingsInfectionTypeLiceEnabled)
    System.Infections.Lice.Enabled = !System.Infections.Lice.Enabled

  ; Infeciton Causes
  elseIf(option == oidSettingsInfectionCauseVaginal)
    System.OptInfectionCause =                                                \
      Math.LogicalOr(System.OptInfectionCause, System.InfectionCauseVaginal)

  elseIf(option == oidSettingsInfectionCauseAnal)
    System.OptInfectionCause =                                                \
      Math.LogicalOr(System.OptInfectionCause, System.InfectionCauseAnal)

  elseIf(option == oidSettingsInfectionCauseOral)
    System.OptInfectionCause =                                                \
      Math.LogicalOr(System.OptInfectionCause, System.InfectionCauseOral)

  ; DebugMessage
  elseIf(option == oidMiscDebug)
    System.OptDebug = !System.OptDebug

  ; Cure
  elseIf(option == oidMiscCure)
      ShowMessage("$MiscCureMessage")
      System.CureInfections(System.PlayerRef)

  ; Import / Export
  elseIf(option == oidMiscImport)
    System.SettingsImport()
    ShowMessage("$MessageDone")

  elseIf(option == oidMiscExport)
    System.SettingsExport()
    ShowMessage("$MessageDone")

  elseIf(option == oidMiscUninstall)
    System.Uninstall()
    ShowMessage("$MessageDone")

  else
    return

  endIf

  ForcePageReset()
endEvent

event OnOptionSliderOpen(int option)
  ; Delayed Infection
  if(option == oidSettingsDelayedInfection)
    SetSliderDialogStartValue(System.OptDelayedInfectionTime)
    SetSliderDialogDefaultValue(0.0)
    SetSliderDialogInterval(1.0)
    SetSliderDialogRange(0.0, 72.0)

  ; PSQ
  elseif(option == oidSettingsPSQNPCInfectionProbability)
    ; simply use the same values as above, no need for further consts
    SetSliderDialogStartValue(System.Infections.SuccubusCurse.NonPlayerFakeInfectionProbability)
    SetSliderDialogDefaultValue(System.Infections.SuccubusCurse.DefaultNonPlayerFakeInfectionProbability)
    SetSliderDialogInterval(0.001)
    SetSliderDialogRange(0.0, 1.0)

  ; Lycanthropy
  elseIf(option == oidSettingsInfectionLycanthropyProbabilityPC)
    SetSliderDialogStartValue(System.Infections.Lycanthropy.PlayerProbability)
    SetSliderDialogDefaultValue(System.Infections.Lycanthropy.PlayerProbabilityDefault)
    SetSliderDialogInterval(0.001)
    SetSliderDialogRange(0.0, 1.0)

  elseIf(option == oidSettingsInfectionLycanthropyProbabilityNPC)
    SetSliderDialogStartValue(System.Infections.Lycanthropy.NonPlayerProbability)
    SetSliderDialogDefaultValue(System.Infections.Lycanthropy.NonPlayerProbabilityDefault)
    SetSliderDialogInterval(0.001)
    SetSliderDialogRange(0.0, 1.0)

  ; Vampirism
  elseIf(option == oidSettingsInfectionVampirismProbabilityPC)
    SetSliderDialogStartValue(System.Infections.Vampirism.PlayerProbability)
    SetSliderDialogDefaultValue(System.Infections.Vampirism.PlayerProbabilityDefault)
    SetSliderDialogInterval(0.001)
    SetSliderDialogRange(0.0, 1.0)

  elseIf(option == oidSettingsInfectionVampirismProbabilityNPC)
    SetSliderDialogStartValue(System.Infections.Vampirism.NonPlayerProbability)
    SetSliderDialogDefaultValue(System.Infections.Vampirism.NonPlayerProbabilityDefault)
    SetSliderDialogInterval(0.001)
    SetSliderDialogRange(0.0, 1.0)

  ; Succubus Curse
  elseIf(option == oidSettingsInfectionSuccubusCurseProbabilityPC)
    SetSliderDialogStartValue(System.Infections.SuccubusCurse.PlayerProbability)
    SetSliderDialogDefaultValue(System.Infections.SuccubusCurse.PlayerProbabilityDefault)
    SetSliderDialogInterval(0.001)
    SetSliderDialogRange(0.0, 1.0)

  elseIf(option == oidSettingsInfectionSuccubusCurseProbabilityNPC)
    SetSliderDialogStartValue(System.Infections.SuccubusCurse.NonPlayerProbability)
    SetSliderDialogDefaultValue(System.Infections.SuccubusCurse.NonPlayerProbabilityDefault)
    SetSliderDialogInterval(0.001)
    SetSliderDialogRange(0.0, 1.0)

  ; Lice
  elseIf(option == oidSettingsInfectionLiceProbabilityPC)
    SetSliderDialogStartValue(System.Infections.Lice.PlayerProbability)
    SetSliderDialogDefaultValue(System.Infections.Lice.PlayerProbabilityDefault)
    SetSliderDialogInterval(0.001)
    SetSliderDialogRange(0.0, 1.0)

  elseIf(option == oidSettingsInfectionLiceProbabilityNPC)
    SetSliderDialogStartValue(System.Infections.Lice.NonPlayerProbability)
    SetSliderDialogDefaultValue(System.Infections.Lice.NonPlayerProbabilityDefault)
    SetSliderDialogInterval(0.001)
    SetSliderDialogRange(0.0, 1.0)

  elseIf(option == oidSettingsInfectionLiceSeverityIncrease)
    SetSliderDialogStartValue(System.Infections.Lice.SeverityIncreasePerHour)
    SetSliderDialogDefaultValue(System.Infections.Lice.DefaultSeverityIncreasePerHour)
    SetSliderDialogInterval(1)
    SetSliderDialogRange(0, 20)

  elseIf(option == oidSettingsInfectionLiceUnnervingThreshold)
    SetSliderDialogStartValue(System.Infections.Lice.UnnervingThreshold.GetValue() as int)
    SetSliderDialogDefaultValue(System.Infections.Lice.DefaultUnnervingThreshold)
    SetSliderDialogInterval(1)
    SetSliderDialogRange(1.0, 99.0)

  elseIf(option == oidSettingsInfectionLiceSevereThreshold)
    SetSliderDialogStartValue(System.Infections.Lice.SevereThreshold.GetValue() as int)
    SetSliderDialogDefaultValue(System.Infections.Lice.DefaultSevereThreshold)
    SetSliderDialogInterval(1)
    SetSliderDialogRange(2.0, 100.0)

  elseIf(option == oidSettingsInfectionLiceFakeNPCProbability)
    SetSliderDialogStartValue(System.Infections.Lice.NonPlayerFakeInfectionProbability)
    SetSliderDialogDefaultValue(System.Infections.Lice.DefaultNonPlayerFakeInfectionProbability)
    SetSliderDialogInterval(0.001)
    SetSliderDialogRange(0.0, 1.0)

  elseIf(option == oidMiscCleanupInterval)
    SetSliderDialogStartValue(System.Actors.CleanupInterval)
    SetSliderDialogDefaultValue(System.Actors.DefaultCleanupInterval)
    SetSliderDialogInterval(0.01)
    SetSliderDialogRange(1.0, 18000.0) ; 1s to 5d

  elseIf(option == oidSettingsInfectionLiceBathing)
    SetSliderDialogStartValue(System.Infections.Lice.SeverityReductionBathingMultiplier)
    SetSliderDialogDefaultValue(System.Infections.Lice.DefaultSeverityReductionBathingMultiplier)
    SetSliderDialogInterval(0.01)
    SetSliderDialogRange(1.0, 3.0)

  elseIf(option == oidSettingsInfectionLiceShowering)
    SetSliderDialogStartValue(System.Infections.Lice.SeverityReductionShoweringMultiplier)
    SetSliderDialogDefaultValue(System.Infections.Lice.DefaultSeverityReductionShoweringMultiplier)
    SetSliderDialogInterval(0.01)
    SetSliderDialogRange(1.0, 2.0)

  elseIf(option == oidSettingsInfectionLiceSoap)
    SetSliderDialogStartValue(System.Infections.Lice.SeverityReductionSoapBonusMultiplier)
    SetSliderDialogDefaultValue(System.Infections.Lice.DefaultSeverityReductionSoapBonusMultiplier)
    SetSliderDialogInterval(0.01)
    SetSliderDialogRange(1.0, 3.0)

  elseIf(option == oidSettingsInfectionLiceContainerProbability)
    SetSliderDialogStartValue(System.Infections.Lice.ContainerContainsCureProbability)
    SetSliderDialogDefaultValue(System.Infections.Lice.DefaultContainerContainsCureProbability)
    SetSliderDialogInterval(0.01)
    SetSliderDialogRange(0.0, 1.0)

  endIf
endEvent

event OnOptionSliderAccept(int option, float value)
  ; Delayed Infection
  if(option == oidSettingsDelayedInfection)
    System.OptDelayedInfectionTime = value

  ; Lycanthropy
  elseif(option == oidSettingsInfectionLycanthropyProbabilityPC)
    System.Infections.Lycanthropy.PlayerProbability = value

  elseIf(option == oidSettingsInfectionLycanthropyProbabilityNPC)
    System.Infections.Lycanthropy.NonPlayerProbability = value

  ; Vampirism
  elseIf(option == oidSettingsInfectionVampirismProbabilityPC)
    System.Infections.Vampirism.PlayerProbability = value

  elseIf(option == oidSettingsInfectionVampirismProbabilityNPC)
    System.Infections.Vampirism.NonPlayerProbability = value

  ; SuccubusCurse
  elseIf(option == oidSettingsInfectionSuccubusCurseProbabilityPC)
    System.Infections.SuccubusCurse.PlayerProbability = value

  elseIf(option == oidSettingsInfectionSuccubusCurseProbabilityNPC)
    System.Infections.SuccubusCurse.NonPlayerProbability = value

  elseIf(option == oidSettingsPSQNPCInfectionProbability)
    System.Infections.SuccubusCurse.NonPlayerFakeInfectionProbability = value

  ; Lice
  elseIf(option == oidSettingsInfectionLiceProbabilityPC)
    System.Infections.Lice.PlayerProbability = value

  elseIf(option == oidSettingsInfectionLiceProbabilityNPC)
    System.Infections.Lice.NonPlayerProbability = value

  elseIf(option == oidSettingsInfectionLiceSeverityIncrease)
    System.Infections.Lice.SeverityIncreasePerHour = value as int

  elseIf(option == oidSettingsInfectionLiceUnnervingThreshold)
    System.Infections.Lice.UnnervingThreshold.SetValue(value)

  elseIf(option == oidSettingsInfectionLiceSevereThreshold)
    System.Infections.Lice.SevereThreshold.SetValue(value)

  elseIf(option == oidSettingsInfectionLiceFakeNPCProbability)
    System.Infections.Lice.NonPlayerFakeInfectionProbability = value

  elseIf(option == oidSettingsInfectionLiceBathing)
    System.Infections.Lice.SeverityReductionBathingMultiplier = value

  elseIf(option == oidSettingsInfectionLiceShowering)
    System.Infections.Lice.SeverityReductionShoweringMultiplier = value

  elseIf(option == oidSettingsInfectionLiceSoap)
    System.Infections.Lice.SeverityReductionSoapBonusMultiplier = value

  elseIf(option == oidSettingsInfectionLiceContainerProbability)
    System.Infections.Lice.ContainerContainsCureProbability = value

  ; Misc
  elseIf(option == oidMiscCleanupInterval)
    System.Actors.CleanupInterval = value

  endIf

  ForcePageReset()
endEvent

event OnOptionMenuOpen(int option)
  if(option == oidMiscCureNearby)
    tempNearbyActors = MiscUtil.ScanCellNPCs(                                 \
      System.PlayerRef as ObjectReference,                                    \
      radius = 1000                                                           \
    )

    string[] actorNames = Utility.CreateStringArray(tempNearbyActors.Length)

    int i = 0
    while(i < tempNearbyActors.Length)
      actorNames[i] = tempNearbyActors[i].GetDisplayName()
      i += 1
    endWhile

    SetMenuDialogOptions(actorNames)
    SetMenuDialogStartIndex(0)
  endIf
endEvent

event OnOptionMenuAccept(int option, int index)
  if(option == oidMiscCureNearby)
    System.CureInfections(tempNearbyActors[index])
    ShowMessage("$MessageDone")

    tempNearbyActors = new Actor[1] ; thanks bethesda for not implementing deletion
    ;tempNearbyActors[0] = None
  endIf
endEvent

; Pages
function SetupPageStatus()
  SetCursorFillMode(TOP_TO_BOTTOM)
  SetCursorPosition(TOP_LEFT)

  oidStatusActive =                                                           \
    AddTextOption(                                                            \
      "$StatusMod",                                                           \
      SexLabUtil.StringIfElse(System.Enabled,                               \
          ColoredText("$StatusActive", COLOR_GREEN),                          \
          ColoredText("$StatusInactive", COLOR_RED)                           \
      )                                                                       \
    )

  SetCursorPosition(TOP_RIGHT)

  AddHeaderOption("$StatusDependencies")

  AddTextOption(                                                              \
    SexLabUtil.StringIfElse(System.DepPapyrusUtil,                            \
          ColoredText("$STATUSDEPENDENCYPAPYRUSUTIL", COLOR_GREEN),           \
          ColoredText("$STATUSDEPENDENCYPAPYRUSUTIL", COLOR_RED)              \
      ),                                                                      \
      ""                                                                      \
    )

  AddEmptyOption()

  AddHeaderOption("$StatusSupportedMods")

  AddTextOption(                                                              \
    SexLabUtil.StringIfElse(System.Infections.Lycanthropy.MTSupport,          \
      ColoredText("$STATUSSUPPORTMT", COLOR_GREEN),                           \
      "$STATUSSUPPORTMT"                                                      \
    ),                                                                        \
    "")

  AddTextOption(                                                              \
    SexLabUtil.StringIfElse(System.Infections.SuccubusCurse.PSQSupport,       \
      ColoredText("$STATUSSUPPORTPSQ", COLOR_GREEN),                          \
      "$STATUSSUPPORTPSQ"                                                     \
    ),                                                                        \
    "")

  AddTextOption(                                                              \
    SexLabUtil.StringIfElse(System.Infections.Lice.YPSSupport,                \
      ColoredText("$STATUSSUPPORTYPS", COLOR_GREEN),                          \
      "$STATUSSUPPORTYPS"                                                     \
    ),                                                                        \
    "")

  AddTextOption(                                                              \
    SexLabUtil.StringIfElse(System.Infections.Lice.ESDSupport,                \
      ColoredText("$STATUSSUPPORTESD", COLOR_GREEN),                          \
      "$STATUSSUPPORTESD"                                                     \
    ),                                                                        \
    "")

  AddTextOption(                                                              \
    SexLabUtil.StringIfElse(System.Infections.Lice.BiSSupport,                \
      ColoredText("$STATUSSUPPORTBIS", COLOR_GREEN),                          \
      "$STATUSSUPPORTBIS"                                                     \
    ),                                                                        \
    "")

endFunction

function SetupPageGeneral()
  SetCursorFillMode(TOP_TO_BOTTOM)
  SetCursorPosition(TOP_LEFT)

  ; General
  AddHeaderOption("$SettingsInfectionCauses")

  oidSettingsInfectionCauseVaginal =                                          \
    AddToggleOption(                                                          \
      "$SettingsInfectionCauseVaginal",                                       \
      Math.LogicalAnd(System.OptInfectionCause, System.InfectionCauseVaginal))

  oidSettingsInfectionCauseAnal =                                             \
    AddToggleOption(                                                          \
      "$SettingsInfectionCauseAnal",                                          \
      Math.LogicalAnd(System.OptInfectionCause, System.InfectionCauseAnal))

  oidSettingsInfectionCauseOral =                                             \
    AddToggleOption(                                                          \
      "$SettingsInfectionCauseOral",                                          \
      Math.LogicalAnd(System.OptInfectionCause, System.InfectionCauseOral))

  SetCursorPosition(TOP_RIGHT)

  oidSettingsNPCInfections =                                                  \
    AddToggleOption(                                                          \
      "$SettingsNPCInfections",                                               \
      System.OptNPCInfections                                                 \
    )

  AddEmptyOption()

  oidSettingsDelayedInfection =                                               \
    AddSliderOption(                                                          \
      "$SettingsDelayedInfection",                                            \
      System.OptDelayedInfectionTime,                                         \
      "$SettingsDelayedInfectionFormat"                                       \
    )

  AddEmptyOption()

  oidSettingsMajorImmunities =                                                \
    AddToggleOption(                                                          \
      "$SettingsMajorImmunities",                                             \
      System.OptMajorImmunities                                               \
    )
endFunction

function SetupPageMajor()
  SetCursorPosition(TOP_LEFT)
  SetCursorFillMode(TOP_TO_BOTTOM)

  ; Infection: Lycanthropy
  AddHeaderOption("$SettingsInfectionTypeLycanthropy")

  oidSettingsInfectionTypeLycanthropyEnabled =                                \
    AddTextOption(                                                            \
      "$SettingsInfectionEnabled",                                            \
      System.Infections.Lycanthropy.Enabled)

  oidSettingsInfectionLycanthropyProbabilityPC =                              \
    AddSliderOption(                                                          \
      "$SettingsInfectionProbabilityPC",                                      \
      System.Infections.Lycanthropy.PlayerProbability,                        \
      "$SettingsInfectionProbabilityFormat")

  oidSettingsInfectionLycanthropyProbabilityNPC =                             \
    AddSliderOption(                                                          \
      "$SettingsInfectionProbabilityNPC",                                     \
      System.Infections.Lycanthropy.NonPlayerProbability,                     \
      "$SettingsInfectionProbabilityFormat")

  ; Infection: Vampirism
  AddEmptyOption()
  AddHeaderOption("$SettingsInfectionTypeVampirism")

  oidSettingsInfectionTypeVampirismEnabled =                                  \
    AddTextOption(                                                            \
      "$SettingsInfectionEnabled",                                            \
      System.Infections.Vampirism.Enabled)

  oidSettingsInfectionVampirismProbabilityPC =                                \
    AddSliderOption(                                                          \
      "$SettingsInfectionProbabilityPC",                                      \
      System.Infections.Vampirism.PlayerProbability,                          \
      "$SettingsInfectionProbabilityFormat")

  oidSettingsInfectionVampirismProbabilityNPC =                               \
    AddSliderOption(                                                          \
      "$SettingsInfectionProbabilityNPC",                                     \
      System.Infections.Vampirism.NonPlayerProbability,                       \
      "$SettingsInfectionProbabilityFormat")

  ; Infection: Succubus Curse
  SetCursorPosition(TOP_RIGHT)

  AddHeaderOption("$SettingsInfectionTypeSuccubusCurse")

  int SuccubusCurseEnableSwitchFlags = OPTION_FLAG_NONE

  if(!System.Infections.SuccubusCurse.Supported)
    SuccubusCurseEnableSwitchFlags = OPTION_FLAG_DISABLED
  endIf

  oidSettingsInfectionTypeSuccubusCurseEnabled =                              \
    AddTextOption(                                                            \
      "$SettingsInfectionEnabled",                                            \
      System.Infections.SuccubusCurse.Enabled,                                \
      SuccubusCurseEnableSwitchFlags)

  oidSettingsInfectionSuccubusCurseProbabilityPC =                            \
    AddSliderOption(                                                          \
      "$SettingsInfectionProbabilityPC",                                      \
      System.Infections.SuccubusCurse.PlayerProbability,                      \
      "$SettingsInfectionProbabilityFormat")

  oidSettingsInfectionSuccubusCurseProbabilityNPC =                           \
    AddSliderOption(                                                          \
      "$SettingsInfectionProbabilityNPC",                                     \
      System.Infections.SuccubusCurse.NonPlayerProbability,                   \
      "$SettingsInfectionProbabilityFormat")

  oidSettingsPSQNPCInfectionProbability = AddSliderOption(                  \
    "$SettingsFakeNPCInfectionProbability",                                 \
    System.Infections.SuccubusCurse.NonPlayerFakeInfectionProbability,      \
    "$SettingsFakeNPCInfectionProbabilityFormat")
endFunction

function SetupPageMinor()
  SetCursorPosition(TOP_LEFT)
  SetCursorFillMode(TOP_TO_BOTTOM)

  ; Infection: Lice (STD)
  AddHeaderOption("$SLCoiSTDLice")

  oidSettingsInfectionTypeLiceEnabled =                                       \
    AddTextOption(                                                            \
      "$SettingsInfectionEnabled",                                            \
      System.Infections.Lice.Enabled)

  oidSettingsInfectionLiceProbabilityPC =                                     \
    AddSliderOption(                                                          \
      "$SettingsInfectionProbabilityPC",                                      \
      System.Infections.Lice.PlayerProbability,                               \
      "$SettingsInfectionProbabilityFormat")

  oidSettingsInfectionLiceProbabilityNPC =                                    \
    AddSliderOption(                                                          \
      "$SettingsInfectionProbabilityNPC",                                     \
      System.Infections.Lice.NonPlayerProbability,                            \
      "$SettingsInfectionProbabilityFormat")

  oidSettingsInfectionLiceFakeNPCProbability =                                \
    AddSliderOption(                                                          \
      "$SettingsFakeNPCInfectionProbability",                                 \
      System.Infections.Lice.NonPlayerFakeInfectionProbability,               \
      "$SettingsFakeNPCInfectionProbabilityFormat"                            \
    )

  oidSettingsInfectionLiceSeverityIncrease =                                  \
    AddSliderOption(                                                          \
      "$SettingsSTDLiceSeverityIncreasePerHour",                              \
      System.Infections.Lice.SeverityIncreasePerHour,                         \
      "$SettingsSTDLiceSeverityIncreasePerHourFormat"                         \
    )

  oidSettingsInfectionLiceUnnervingThreshold =                                \
    AddSliderOption(                                                          \
      "$SettingsSTDLiceUnnervingThreshold",                                   \
      System.Infections.Lice.UnnervingThreshold.GetValue(),                   \
      "$SettingsSTDLiceThresholdFormat"                                       \
    )

  oidSettingsInfectionLiceSevereThreshold =                                   \
    AddSliderOption(                                                          \
      "$SettingsSTDLiceSevereThreshold",                                      \
      System.Infections.Lice.SevereThreshold.GetValue(),                      \
      "$SettingsSTDLiceThresholdFormat"                                       \
    )

  oidSettingsInfectionLiceBathing =                                           \
    AddSliderOption(                                                          \
      "$SettingsSTDLiceSeverityReductionBathing",                             \
      System.Infections.Lice.SeverityReductionBathingMultiplier,              \
      "$SettingsSTDLiceSeverityReductionFormat"                               \
    )

  oidSettingsInfectionLiceShowering =                                         \
    AddSliderOption(                                                          \
      "$SettingsSTDLiceSeverityReductionShowering",                           \
      System.Infections.Lice.SeverityReductionShoweringMultiplier,            \
      "$SettingsSTDLiceSeverityReductionFormat"                               \
    )

  oidSettingsInfectionLiceSoap =                                              \
    AddSliderOption(                                                          \
      "$SettingsSTDLiceSeverityReductionSoapBonus",                           \
      System.Infections.Lice.SeverityReductionSoapBonusMultiplier,            \
      "$SettingsSTDLiceSeverityReductionFormat"                               \
    )

  oidSettingsInfectionLiceContainerProbability =                              \
    AddSliderOption(                                                          \
      "$SettingsSTDLiceContainerContainsCureProbability",                     \
      System.Infections.Lice.ContainerContainsCureProbability,                \
      "$SettingsSTDLiceContainerContainsCureFormat"                           \
    )
endFunction

function SetupPageMisc()
  SetCursorFillMode(TOP_TO_BOTTOM)
  SetCursorPosition(TOP_LEFT)

  oidMiscCure = AddTextOption("$MiscCureMe", "")
  oidMiscCureNearby = AddMenuOption("$MiscCureNearby", "")

  AddEmptyOption()
  AddHeaderOption("$MiscSettings")
  oidMiscImport = AddTextOption("$MiscSettingsImport", "")
  oidMiscExport = AddTextOption("$MiscSettingsExport", "")

  AddEmptyOption()
  oidMiscCleanupInterval =                                                    \
    AddSliderOption(                                                          \
      "$MiscCleanupInterval",                                                 \
      System.Actors.CleanupInterval,                                          \
      "$MiscCleanupIntervalFormat"                                            \
    )


  AddEmptyOption()
  oidMiscUninstall = AddTextOption("$MiscUninstall", "")

  SetCursorPosition(TOP_RIGHT)

  oidMiscDebug = AddToggleOption("$MiscDebug", System.OptDebug)
endFunction

; Utility
string function ColoredText(string text, string color)
  return "<font color='" + color + "'>" + text + "</font>"
endFunction
