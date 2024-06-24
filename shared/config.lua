Config = {
    DefaultBlipColor = 0, -- White
    DefaultBlipSprite = GetHashKey("blip_ambient_ped_medium"),
    DefaultBlipScale = 0.2,
    BlipUpdateInterval = 1000, -- Update every second
    WantedBlipColor = 1, -- Red
    WantedBlipSprite = GetHashKey("blip_ambient_bounty_target"),
    Jobs = {
        police = { blipColor = 18, tracked = true },
        -- other jobs...
    }
    
}