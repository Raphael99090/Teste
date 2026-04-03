-- HitboxExpander.lua

-- Hitbox Expander feature implementation

local HitboxExpander = {}

-- Function to expand hitbox size
function HitboxExpander.expandHitbox(originalSize, expansionAmount)
    local newSize = originalSize + expansionAmount
    return newSize
end

-- Function to set hitbox size with adjustable settings
function HitboxExpander.setHitboxSize(originalSize, expansionAmount)
    local expandedSize = HitboxExpander.expandHitbox(originalSize, expansionAmount)
    print(string.format('Hitbox size adjusted from %d to %d', originalSize, expandedSize))
    return expandedSize
end

return HitboxExpander
