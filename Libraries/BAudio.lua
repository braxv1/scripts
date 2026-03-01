-- brax's simple audio library
-- basically just pulls sounds from the web and plays them in roblox
-- usage example: audiolib.play("url", true, "savename.mp3", 1, 1, false)

local library = {}

-- args: url, keepold, filename, volume, speed, deleteonfinish
function library.play(url, keepold, filename, volume, speed, deleteonfinish)
    
    -- check if we already have the file
    local fileexists = isfile(filename)
    
    -- if we dont want to keep the old one or we dont have it yet we download
    if not keepold or not fileexists then
        -- wipe the old one if it exists so we can get a new version
        if fileexists then delfile(filename) end
        
        local success, data = pcall(function() 
            return game:HttpGet(url) 
        end)
        
        if success and data then
            writefile(filename, data)
        else
            warn("brax lib: failed to download the audio check the link")
            return nil
        end
    end
    
    -- standard shit
    local sound = Instance.new("Sound")
    sound.Name = "BraxSound"
    sound.SoundId = getcustomasset(filename)
    sound.Volume = volume or 1
    sound.PlaybackSpeed = speed or 1
    sound.Parent = game:GetService("SoundService")
    
    sound:Play()
    
    -- removes the sound on finish
    sound.Ended:Connect(function()
        sound:Destroy()
        
        -- only deletes the file from the folder if deleteonfinish is true
        if deleteonfinish and isfile(filename) then
            delfile(filename)
        end
    end)
    
    return sound
end

return library
