scriptname SLCoiInfectionVampirismBase extends SLCoiInfection hidden

; Utility
Race function GetVampireRaceComplement(Race originRace)
  Race ArgonianRace = Race.GetRace("ArgonianRace")
  Race BretonRace = Race.GetRace("BretonRace")
  Race DarkElfRace = Race.GetRace("DarkElfRace")
  Race HighELfRace = Race.GetRace("HighELfRace")
  Race ImperialRace = Race.GetRace("ImperialRace")
  Race KhajiitRace = Race.GetRace("KhajiitRace")
  Race NordRace = Race.GetRace("NordRace")
  Race OrcRace = Race.GetRace("OrcRace")
  Race RedguardRace = Race.GetRace("RedguardRace")
  Race WoodElfRace = Race.GetRace("WoodElfRace")

  Race ArgonianRaceVampire = Race.GetRace("ArgonianRaceVampire")
  Race BretonRaceVampire = Race.GetRace("BretonRaceVampire")
  Race DarkElfRaceVampire = Race.GetRace("DarkElfRaceVampire")
  Race HighELfRaceVampire = Race.GetRace("HighELfRaceVampire")
  Race ImperialRaceVampire = Race.GetRace("ImperialRaceVampire")
  Race KhajiitRaceVampire = Race.GetRace("KhajiitRaceVampire")
  Race NordRaceVampire = Race.GetRace("NordRaceVampire")
  Race OrcRaceVampire = Race.GetRace("OrcRaceVampire")
  Race RedguardRaceVampire = Race.GetRace("RedguardRaceVampire")
  Race WoodElfRaceVampire = Race.GetRace("WoodElfRaceVampire")

  if (originRace == ArgonianRace)
		return ArgonianRaceVampire
  elseIf(originRace == ArgonianRaceVampire)
    return ArgonianRace
  endIf

  if (originRace == BretonRace)
		return BretonRaceVampire
  elseIf(originRace == BretonRaceVampire)
    return BretonRace
  endIf

  if (originRace == DarkElfRace)
		return DarkElfRaceVampire
  elseIf(originRace == DarkElfRaceVampire)
    return DarkElfRace
  endIf

  if (originRace == HighELfRace)
		return HighELfRaceVampire
  elseIf(originRace == HighELfRaceVampire)
    return HighELfRace
  endIf

  if (originRace == ImperialRace)
		return ImperialRaceVampire
  elseIf(originRace == ImperialRaceVampire)
    return ImperialRace
  endIf

  if (originRace == KhajiitRace)
		return KhajiitRaceVampire
  elseIf(originRace == KhajiitRaceVampire)
    return KhajiitRace
  endIf

  if (originRace == NordRace)
		return NordRaceVampire
  elseIf(originRace == NordRaceVampire)
    return NordRace
  endIf

  if (originRace == OrcRace)
		return OrcRaceVampire
  elseIf(originRace == OrcRaceVampire)
    return OrcRace
  endIf

  if (originRace == RedguardRace)
		return RedguardRaceVampire
  elseIf(originRace == RedguardRaceVampire)
    return RedguardRace
  endIf

  if (originRace == WoodElfRace)
		return WoodElfRaceVampire
  elseIf(originRace == WoodElfRaceVampire)
    return WoodElfRace
  endIf

  return None
endFunction
