config = {}

config.lang = "en"

config.commands = {
    setWeight = { command = "setweight", permission = "group.admin" }, -- command to set weight
    setHeight = { command = "setheight", permission = "group.admin" }, -- command to set height
}

config.height = {
    active = true,
    min = 0.5,
    max = 1.5,
}

-- changing the weight value will cause more animation distortions
config.weight = {
    active = true,
    min = 0.8,
    max = 1.15,
}

config.stateName = "tgiann:pedScale:weightHeight" -- state name for height and weight (used in state bags)
config.langs = {}
