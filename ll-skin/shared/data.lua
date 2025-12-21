-- Shared adatok (kliens és szerver)

SkinData = {}

-- Alapértelmezett skin (férfi)
SkinData.DefaultMale = {
    model = 'mp_m_freemode_01',
    heritage = {
        mom = 0,
        dad = 0,
        similarity = 0.5,
        skin_similarity = 0.5
    },
    face = {
        nose_width = 0.0,
        nose_peak_height = 0.0,
        nose_peak_length = 0.0,
        nose_bone_height = 0.0,
        nose_peak_lowering = 0.0,
        nose_bone_twist = 0.0,
        eyebrows_height = 0.0,
        eyebrows_width = 0.0,
        cheekbone_height = 0.0,
        cheekbone_width = 0.0,
        cheeks_width = 0.0,
        eyes_opening = 0.0,
        lips_thickness = 0.0,
        jaw_bone_width = 0.0,
        jaw_bone_back_length = 0.0,
        chin_bone_lowering = 0.0,
        chin_bone_length = 0.0,
        chin_bone_width = 0.0,
        chin_hole = 0.0,
        neck_thickness = 0.0
    },
    headBlend = {
        shapeFirst = 0,
        shapeSecond = 0,
        shapeThird = 0,
        skinFirst = 0,
        skinSecond = 0,
        skinThird = 0,
        shapeMix = 0.0,
        skinMix = 0.0,
        thirdMix = 0.0
    },
    hair = {
        style = 0,
        color = 0,
        highlight = 0
    },
    eyebrows = {
        style = 0,
        color = 0,
        opacity = 1.0
    },
    beard = {
        style = -1,
        color = 0,
        opacity = 1.0
    },
    chest = {
        style = -1,
        color = 0,
        opacity = 1.0
    },
    makeup = {
        style = -1,
        color = 0,
        opacity = 0.0
    },
    lipstick = {
        style = -1,
        color = 0,
        opacity = 0.0
    },
    eyeColor = 0,
    ageing = {
        style = -1,
        opacity = 0.0
    },
    blemishes = {
        style = -1,
        opacity = 0.0
    },
    sun_damage = {
        style = -1,
        opacity = 0.0
    },
    complexion = {
        style = -1,
        opacity = 0.0
    },
    moles = {
        style = -1,
        opacity = 0.0
    },
    components = {
        [0] = {drawable = 0, texture = 0, palette = 0},  -- Head
        [1] = {drawable = 0, texture = 0, palette = 0},  -- Mask
        [2] = {drawable = 0, texture = 0, palette = 0},  -- Hair
        [3] = {drawable = 15, texture = 0, palette = 0}, -- Torso
        [4] = {drawable = 21, texture = 0, palette = 0}, -- Legs
        [5] = {drawable = 0, texture = 0, palette = 0},  -- Bag
        [6] = {drawable = 34, texture = 0, palette = 0}, -- Shoes
        [7] = {drawable = 0, texture = 0, palette = 0},  -- Accessories
        [8] = {drawable = 15, texture = 0, palette = 0}, -- Undershirt
        [9] = {drawable = 0, texture = 0, palette = 0},  -- Armor
        [10] = {drawable = 0, texture = 0, palette = 0}, -- Decals
        [11] = {drawable = 15, texture = 0, palette = 0} -- Jacket
    },
    props = {
        [0] = {drawable = -1, texture = 0},  -- Hat
        [1] = {drawable = -1, texture = 0},  -- Glasses
        [2] = {drawable = -1, texture = 0},  -- Ears
        [6] = {drawable = -1, texture = 0},  -- Watch
        [7] = {drawable = -1, texture = 0}   -- Bracelet
    },
    tattoos = {}
}

-- Alapértelmezett skin (nő)
SkinData.DefaultFemale = {
    model = 'mp_f_freemode_01',
    heritage = {
        mom = 0,
        dad = 0,
        similarity = 0.5,
        skin_similarity = 0.5
    },
    face = {
        nose_width = 0.0,
        nose_peak_height = 0.0,
        nose_peak_length = 0.0,
        nose_bone_height = 0.0,
        nose_peak_lowering = 0.0,
        nose_bone_twist = 0.0,
        eyebrows_height = 0.0,
        eyebrows_width = 0.0,
        cheekbone_height = 0.0,
        cheekbone_width = 0.0,
        cheeks_width = 0.0,
        eyes_opening = 0.0,
        lips_thickness = 0.0,
        jaw_bone_width = 0.0,
        jaw_bone_back_length = 0.0,
        chin_bone_lowering = 0.0,
        chin_bone_length = 0.0,
        chin_bone_width = 0.0,
        chin_hole = 0.0,
        neck_thickness = 0.0
    },
    headBlend = {
        shapeFirst = 0,
        shapeSecond = 0,
        shapeThird = 0,
        skinFirst = 0,
        skinSecond = 0,
        skinThird = 0,
        shapeMix = 0.0,
        skinMix = 0.0,
        thirdMix = 0.0
    },
    hair = {
        style = 0,
        color = 0,
        highlight = 0
    },
    eyebrows = {
        style = 0,
        color = 0,
        opacity = 1.0
    },
    beard = {
        style = -1,
        color = 0,
        opacity = 0.0
    },
    chest = {
        style = -1,
        color = 0,
        opacity = 0.0
    },
    makeup = {
        style = -1,
        color = 0,
        opacity = 0.0
    },
    lipstick = {
        style = -1,
        color = 0,
        opacity = 0.0
    },
    eyeColor = 0,
    ageing = {
        style = -1,
        opacity = 0.0
    },
    blemishes = {
        style = -1,
        opacity = 0.0
    },
    sun_damage = {
        style = -1,
        opacity = 0.0
    },
    complexion = {
        style = -1,
        opacity = 0.0
    },
    moles = {
        style = -1,
        opacity = 0.0
    },
    components = {
        [0] = {drawable = 0, texture = 0, palette = 0},  -- Head
        [1] = {drawable = 0, texture = 0, palette = 0},  -- Mask
        [2] = {drawable = 0, texture = 0, palette = 0},  -- Hair
        [3] = {drawable = 15, texture = 0, palette = 0}, -- Torso
        [4] = {drawable = 21, texture = 0, palette = 0}, -- Legs
        [5] = {drawable = 0, texture = 0, palette = 0},  -- Bag
        [6] = {drawable = 35, texture = 0, palette = 0}, -- Shoes
        [7] = {drawable = 0, texture = 0, palette = 0},  -- Accessories
        [8] = {drawable = 15, texture = 0, palette = 0}, -- Undershirt
        [9] = {drawable = 0, texture = 0, palette = 0},  -- Armor
        [10] = {drawable = 0, texture = 0, palette = 0}, -- Decals
        [11] = {drawable = 15, texture = 0, palette = 0} -- Jacket
    },
    props = {
        [0] = {drawable = -1, texture = 0},  -- Hat
        [1] = {drawable = -1, texture = 0},  -- Glasses
        [2] = {drawable = -1, texture = 0},  -- Ears
        [6] = {drawable = -1, texture = 0},  -- Watch
        [7] = {drawable = -1, texture = 0}   -- Bracelet
    },
    tattoos = {}
}

-- Face feature indexek (SetPedFaceFeature)
SkinData.FaceFeatures = {
    nose_width = 0,
    nose_peak_height = 1,
    nose_peak_length = 2,
    nose_bone_height = 3,
    nose_peak_lowering = 4,
    nose_bone_twist = 5,
    eyebrows_height = 6,
    eyebrows_width = 7,
    cheekbone_height = 8,
    cheekbone_width = 9,
    cheeks_width = 10,
    eyes_opening = 11,
    lips_thickness = 12,
    jaw_bone_width = 13,
    jaw_bone_back_length = 14,
    chin_bone_lowering = 15,
    chin_bone_length = 16,
    chin_bone_width = 17,
    chin_hole = 18,
    neck_thickness = 19
}

-- Overlay indexek
SkinData.Overlays = {
    blemishes = 0,
    beard = 1,
    eyebrows = 2,
    ageing = 3,
    makeup = 4,
    blush = 5,
    complexion = 6,
    sun_damage = 7,
    lipstick = 8,
    moles = 9,
    chest = 10
}

-- Hajszínek (színpaletta)
SkinData.HairColors = {
    {name = 'Fekete', id = 0},
    {name = 'Sötétbarna', id = 1},
    {name = 'Barna', id = 2},
    {name = 'Világosbarna', id = 3},
    {name = 'Szőke', id = 4},
    {name = 'Világosszőke', id = 5},
    {name = 'Vörös', id = 6},
    {name = 'Eper szőke', id = 7},
    -- ... további színek 0-63
}

-- Szem színek
SkinData.EyeColors = {
    {name = 'Zöld', id = 0},
    {name = 'Smaragdzöld', id = 1},
    {name = 'Világoskék', id = 2},
    {name = 'Kék', id = 3},
    {name = 'Sötétkék', id = 4},
    {name = 'Barna', id = 5},
    {name = 'Sötétbarna', id = 6},
    {name = 'Mogyoróbarna', id = 7},
    -- ... további színek 0-31
}