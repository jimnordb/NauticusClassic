
-- Spanish localisation by StiviS
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("NauticusClassic", "esES") or AceLocale:NewLocale("NauticusClassic", "esMX")
if not L then return; end

-- addon description
L["Tracks the precise arrival & departure schedules of boats and Zeppelins around Azeroth and displays them on the Mini-Map and World Map in real-time."] = "Sigue con precisión los horarios de llegada y salida de barcos y zepelines en todo Azeroth y los muestra en el Minimapa y Mapa del Mundo en tiempo real."

-- slash commands (no spaces!)
L["icons"] = true
L["minishow"] = true
L["worldshow"] = true
L["minisize"] = true
L["worldsize"] = true
L["framerate"] = true
L["faction"] = true
L["minibutton"] = true
L["autoselect"] = true
L["alarm"] = true

-- options
L["Options"] = "Opciones"
L["General Settings"] = "Opciones Generales"
L["Map Icons"] = "Iconos del mapa"
L["Options for displaying transports as icons on the Mini-Map and World Map."] = "Opciones de visualización de iconos de transporte en el Minimapa y el Mapa del Mundo."
L["Show on Mini-Map"] = "Mostrar en minimapa"
L["Toggle display of icons on the Mini-Map."] = "Activar/Desactivar los iconos en el minimapa."
L["Show on World Map"] = "Mostrar en Mapa del Mundo"
L["Toggle display of icons on the World Map."] = "Activar/Desactivar los iconos en el Mapa del Mundo"
L["Mini-Map icon size"] = "Tamaño del icono del minimapa"
L["Change the size of the Mini-Map icons."] = "Cambia el tamaño de los iconos del minimapa."
L["World Map icon size"] = "Tamaño de icono del Mapa del Mundo"
L["Change the size of the World Map icons."] = "Cambia el tamaño de los iconos del mapa del mundo."
L["Icon framerate"] = "FPS del icono"
L["Change the framerate of the World Map/Mini-Map icons (lower this value if you are seeing performance issues with the map open)."] = "Cambie la velocidad de fotogramas de los iconos del Mapa del Mundo/Minimapa (reduzca este valor si observa problemas de rendimiento con el mapa abierto)."
L["Faction only"] = "Solo facción"
L["Hide transports of opposite faction from the map, showing only neutral and those of your faction."] = "Ocultar transportes de la facción contraria en el mapa, mostrar solo neutrales y los de tu facción."
L["Auto select transport"] = "Auto seleccionar transporte"
L["Automatically select nearest transport when standing at platform."] = "Seleccionar automáticamente el transporte más cercano cuando estés en una plataforma de embarque."
L["Alarm delay"] = "Retardo de alarma"
L["Change the alarm delay (in seconds)."] = "Cambia el retardo de la alarma (en segundos)."
L["Mini-Map button"] = "Botón del minimapa"
L["Toggle the Mini-Map button."] = "Activar/Desactivar el botón del minimapa."

-- miscellaneous
L["Arrival"] = "Llegada"
L["Departure"] = "Salida"
L["Select Transport"] = "Seleccionar Transporte"
L["Select None"] = "Seleccionar Ninguno"
L["No Transport Selected"] = "Ningun Transporte Seleccionado"
L["Not Available"] = "No Disponible"
L["N/A"] = "N/D" -- abbreviation for Not Available
L["NauticusClassic Options"] = "Opciones de NauticusClassic"
L["Alarm is now: "] = "Alarma es ahora:" -- check?
L["ON"] = "Encendido"
L["OFF"] = "Apagado"

L["List friendly faction only"] = "Mostrar sólo transportes para tu facción" -- re do?
L["Shows only neutral transports and those of your faction."] = "Muestra sólo neutrales y transportes específicos para tu facción." -- re do?
L["List relevant to current zone only"] = "Mostrar sólo transportes en tu zona actual " -- re do?
L["Shows only transports relevant to your current zone."] = "Muestra sólo transportes en tu zona actual." -- re do?
L["Hint: Click to cycle transport. Alt-Click to set up alarm"] = "Consejo: Click para rotar transporte. Alt-Click para crear alarma"
L["New version available! Visit github.com/DungFu/NauticusClassic"] = true

-- ship names
L["The Thundercaller"] = "El Invocador del Trueno"
L["The Iron Eagle"] = "El Águila de Hierro"
L["The Purple Princess"] = "La Princesa Púrpura"
L["The Maiden's Fancy"] = "La fantasía de la doncella"
L["The Bravery"] = "El Valentía"
L["The Lady Mehley"] = "El Lady Mehley"
L["The Moonspray"] = "Espuma de la Luna"
L["Feathermoon Ferry"] = "Ferry Plumaluna"

-- zones (*must* strictly match the in-game name)
L["Orgrimmar"] = "Orgrimmar"
L["Undercity"] = "Entrañas"
L["Durotar"] = "Durotar"
L["Tirisfal Glades"] = "Claros de Tirisfal"
L["Stranglethorn Vale"] = "Vega de Tuercespina"
L["The Barrens"] = "Los Baldíos"
L["Wetlands"] = "Los Humedales"
L["Darkshore"] = "Costa Oscura"
L["Dustwallow Marsh"] = "Marjal Revolcafango"
L["Teldrassil"] = "Teldrassil"
L["Feralas"] = "Feralas"

-- subzones
L["Grom'gol"] = "Grom'Gol"
L["Booty Bay"] = "Bahía del Botín"
L["Ratchet"] = "Trinquete"
L["Menethil Harbor"] = "Refugio de Marshal"
L["Auberdine"] = "Auberdine"
L["Theramore"] = "Theramore"
L["Rut'Theran Village"] = "Aldea Rut'Theran"
L["Sardor Isle"] = "Isla de Sardor"
L["Feathermoon"] = "Plumaluna"
L["Forgotten Coast"] = "La Costa Olvidada"

-- abbreviations
L["Org"] = true -- Orgrimmar
L["UC"]  = true -- Undercity
L["GG"]  = true -- Grom'gol
L["BB"]  = true -- Booty Bay
L["Rat"] = true -- Ratchet
L["MH"]  = true -- Menethil Harbor
L["Aub"] = true -- Auberdine
L["Th"]  = true -- Theramore
L["RTV"] = true -- Rut'Theran Village
L["FMS"] = true -- Feathermoon
L["Fer"] = true -- Feralas
