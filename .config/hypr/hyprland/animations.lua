-------------------------------------------------------------------------------
-- ANIMATION OVERRIDES  (was: hyprland/animations.conf)
--
-- This file is require()d after general.lua, so the values here win over the
-- base animations defined there — same behavior as the old sourcing order.
-------------------------------------------------------------------------------

hl.animation({ leaf = "windows",    enabled = true, speed = 3, bezier = "default", style = "popin 20%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "default", style = "fade" })

-- was "animation = specialWorkspace, 0" → disabled entirely
-- (when enabled = false, no other fields are needed)
hl.animation({ leaf = "specialWorkspace", enabled = false })
