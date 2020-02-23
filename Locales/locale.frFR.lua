
-- French localisation by thelys
local L = LibStub("AceLocale-3.0"):NewLocale("NauticusClassic", "frFR")
if not L then return; end

-- addon description
L["Tracks the precise arrival & departure schedules of boats and Zeppelins around Azeroth and displays them on the Mini-Map and World Map in real-time."] = "Permet de suivre les arrivées et départs des bateaux et zeppelins sur Azeroth et de les afficher en temps réel sur la carte du monde et la minicarte."

-- slash commands (no spaces!)
L["icons"] = "icons"
L["minishow"] = "minishow"
L["worldshow"] = "worldshow"
L["minisize"] = "minisize"
L["worldsize"] = "worldsize"
L["faction"] = "faction"
L["minibutton"] = "minibutton"
L["autoselect"] = "autoselect"
L["alarm"] = "alarm"

-- options
L["Options"] = "Options"
L["General Settings"] = "Paramètres généraux"
L["Map Icons"] = "Icônes de la carte"
L["Options for displaying transports as icons on the Mini-Map and World Map."] = "Afficher les transports en tant qu'icones sur la carte et la minicarte"
L["Show on Mini-Map"] = "Afficher sur la minicarte"
L["Toggle display of icons on the Mini-Map."] = "Afficher les icones sur la minicarte"
L["Show on World Map"] = "Afficher sur la carte du monde"
L["Toggle display of icons on the World Map."] = "Afficher les icones sur la carte du monde"
L["Mini-Map icon size"] = "Taille des icones de minicarte"
L["Change the size of the Mini-Map icons."] = "Changer la taille des icones de la minicarte."
L["World Map icon size"] = "Taille des icones de carte du monde"
L["Change the size of the World Map icons."] = "Changer la taille des icones de la carte du monde."
L["Faction only"] = "Seulement votre faction"
L["Hide transports of opposite faction from the map, showing only neutral and those of your faction."] = "Ne montrer que les transports neutres et ceux de votre faction"
L["Auto select transport"] = "Sélection auto du transport"
L["Automatically select nearest transport when standing at platform."] = "Sélection auto du transport le plus proche quand on est sur un quai."
L["Alarm delay"] = "Délai d'alarme"
L["Change the alarm delay (in seconds)."] = "Changer le délai d'alarme (en secondes)."
L["Mini-Map button"] = "Bouton de la minicarte"
L["Toggle the Mini-Map button."] = "Afficher le bouton de la minicarte"

-- miscellaneous
L["Arrival"] = "Arrivée"
L["Departure"] = "Départ"
L["Select Transport"] = "Transport"
L["Select None"] = "Aucun"
L["No Transport Selected"] = "Aucun Transport"
L["Not Available"] = "Non Disponible"
L["N/A"] = "ND" -- abbreviation for Not Available
L["NauticusClassic Options"] = "Options de NauticusClassic"
L["Alarm is now: "] = "L'alarme est maintenant"
L["ON"] = "ACTIVÉE"
L["OFF"] = "DÉSACTIVÉE"

L["List friendly faction only"] = "Ne montrer que les transports de votre faction" -- re do?
L["Shows only neutral transports and those of your faction."] = "Ne montrer que les transports neutres et ceux de votre faction." -- re do?
L["List relevant to current zone only"] = "Ne montrer que les transports de la zone courante" -- re do?
L["Shows only transports relevant to your current zone."] = "Ne montrer que les transports de la zone courante." -- re do?
L["Hint: Click to cycle transport. Alt-Click to set up alarm"] = "Astuce: Cliquez pour changer de transport. Alt-Clic pour créer une alarme"
L["New version available! Visit github.com/DungFu/NauticusClassic"] = "Nouvelle version disponible ! Visitez github.com/DungFu/NauticusClassic"

-- ship names
L["The Thundercaller"] = "Le Mande-tonnerre"
L["The Iron Eagle"] = "L'Aigle de fer"
L["The Purple Princess"] = "La Princesse violette"
L["The Maiden's Fancy"] = "Le Caprice de la vierge"
L["The Bravery"] = "La Bravoure"
L["The Lady Mehley"] = "La Dame Mehley"
L["The Moonspray"] = "L'Écume de lune"
L["Feathermoon Ferry"] = "Bac de Pennelune"

-- zones (*must* strictly match the in-game name)
L["Orgrimmar"] = "Orgrimmar"
L["Undercity"] = "Fossoyeuse"
L["Durotar"] = "Durotar"
L["Tirisfal Glades"] = "Clairières de Tirisfal"
L["Stranglethorn Vale"] = "Vall\195\169e de Strangleronce"
L["The Barrens"] = "Les Tarides"
L["Wetlands"] = "Les Paluns"
L["Darkshore"] = "Sombrivage"
L["Dustwallow Marsh"] = "Marécage d'Âprefange"
L["Teldrassil"] = "Teldrassil"
L["Feralas"] = "F\195\169ralas"

-- subzones
L["Grom'gol"] = "Grom'gol"
L["Booty Bay"] = "Baie-du-Butin"
L["Ratchet"] = "Cabestan"
L["Menethil Harbor"] = "Port de Menethil"
L["Auberdine"] = "Auberdine"
L["Theramore"] = "Theramore"
L["Rut'Theran Village"] = "Rut'Theran"
L["Sardor Isle"] = "Ile de Sardor"
L["Feathermoon"] = "Pennelune"
L["Forgotten Coast"] = "Cote oubli\195\169e"

-- abbreviations
L["Org"] = "Org" -- Orgrimmar
L["UC"]  = "Fos" -- Undercity
L["GG"]  = "GrG" -- Grom'gol
L["BB"]  = "BdB" -- Booty Bay
L["Rat"] = "Cab" -- Ratchet
L["MH"]  = "PdM" -- Menethil Harbor
L["Aub"] = "Aub" -- Auberdine
L["Th"]  = "The" -- Theramore
L["RTV"] = "Rut" -- Rut'Theran Village
L["FMS"] = "Pen" -- Feathermoon
L["Fer"] = "Fer" -- Feralas
