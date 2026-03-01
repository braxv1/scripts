-- brax's chat library
-- handles system messages and normal chat for robllox
-- usage: chatlib.system("hello world", "#ff0000")
-- "hello world" - any message you want
-- "#ff0000" - any hex color you want

local library = {}

-- text: the message, color: hex code like #ffffff
function library.system(text, color)
    local TextChatService = game:GetService("TextChatService")
    
    -- check if the game is using the new textchatservice
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then
            -- uses rich text to apply the color
            channel:DisplaySystemMessage("<font color='" .. (color or "#ffffff") .. "'>" .. text .. "</font>")
        end
    else
        -- falls back to the old legacy chat system
        -- note: this sends as a normal message since legacy system messages are handled differently
        local event = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if event then
            event.SayMessageRequest:FireServer(text, "All")
        end
    end
end


-- usage chatlib.speak('hello world')
-- sends a message from your player or wtv way you explain it
function library.speak(text)
    local TextChatService = game:GetService("TextChatService")
    
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then
            channel:SendAsync(text)
        end
    else
        local event = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if event then
            event.SayMessageRequest:FireServer(text, "All")
        end
    end
end

return library
