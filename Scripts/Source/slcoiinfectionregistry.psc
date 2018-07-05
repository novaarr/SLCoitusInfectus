scriptname SLCoiInfectionRegistry extends Quest hidden

SLCoiSystem property System auto

SLCoiInfection property Player auto

; Vampirism
SLCoiInfectionVampirismBase property Vampirism auto ; Active

SLCoiInfectionVampirism property DefaultVampirism auto

; Lycanthropy
SLCoiInfectionLycanthropyBase property Lycanthropy auto ; Active

SLCoiInfectionLycanthropy property DefaultLycanthropy auto
SLCoiInfectionMoonlightTales property MT_Lycanthropy auto

; Succubus Curse
SLCoiInfectionSuccubusCurseBase property SuccubusCurse auto ; Active

SLCoiInfectionSuccubusCurse property DefaultSuccubusCurse auto
SLCoiInfectionPSQ property PSQ_SuccubusCurse auto

; Common STDs
SLCoiInfectionLice property Lice auto

; Maintenance
function Load()
  System.DebugMessage("Loading up infections")

  MT_Lycanthropy.Load()
  PSQ_SuccubusCurse.Load()

  if(!Lycanthropy.Supported)
    Lycanthropy = DefaultLycanthropy
  endIf

  if(!SuccubusCurse.Supported)
    SuccubusCurse = DefaultSuccubusCurse
  endIf
endFunction

function Unload()
  System.DebugMessage("Unloading infections")

  MT_Lycanthropy.Unload()
  PSQ_SuccubusCurse.Unload()
endFunction

; Infection Activation
bool function SetVampirism(SLCoiInfectionLycanthropyBase infection)
  return true
endFunction

bool function SetLycanthropy(SLCoiInfectionLycanthropyBase infection)
  bool savedEnabledState = Lycanthropy.Enabled

  if(infection == MT_Lycanthropy && !MT_Lycanthropy.Supported)
    return false
  endIf

  Lycanthropy = infection
  Lycanthropy.Enabled = savedEnabledState

  System.DebugMessage("Lycanthropy set: " + Lycanthropy.GetName())

  return true
endFunction

bool function SetSuccubusCurse(SLCoiInfectionSuccubusCurseBase infection)
  bool savedEnabledState = SuccubusCurse.Enabled

  if(infection == PSQ_SuccubusCurse && !PSQ_SuccubusCurse.Supported)
    return false
  endIf

  SuccubusCurse = infection
  SuccubusCurse.Enabled = savedEnabledState

  System.DebugMessage("SuccubusCurse set: " + SuccubusCurse.GetName())

  return true
endFunction
