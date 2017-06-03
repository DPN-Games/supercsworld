local __title = "Message Box Logger";
local __version = "1.0";
local __description = "Records the messagebox text, which can be openened again.";
local __author = "Kevsoft";
local __url = "https://github.com/Wohlhabend-Networks/LunaDLL/tree/master/LuaScriptsLibExt";


local function limitText(text, charsLen)
    if(text:len() > charsLen)then
        return text:sub(1, charsLen - 4) .. "..."
    end
    return text
end


-- Trigger system
local msgBoxSelectionActive = false
local doToggleMsgBoxSelection = false

-- Message box
local doToggleMsgBox = false
local coolDownEnterKey = 0

-- Key scanner
local timeSinceLastKeySwitch = 0
local lastPressedUpState = false
local lastPressedDownState = false
local pressedTimes = 0

-- Log system
local MessageBoxLog = {}
local currentSelection = 1


local MessageBoxLoggerAPI = {}


function MessageBoxLoggerAPI.onInitAPI()
    registerEvent(MessageBoxLoggerAPI, "onInputUpdate")
    registerEvent(MessageBoxLoggerAPI, "onLoop")
    registerEvent(MessageBoxLoggerAPI, "onMessageBox")
end

function MessageBoxLoggerAPI.onMessageBox(eventObj, text)
    if(msgBoxSelectionActive)then return end
    
    table.insert(MessageBoxLog, 1, text)
    if(#MessageBoxLog >= 8)then
        table.remove(MessageBoxLog)
    end
end

function MessageBoxLoggerAPI.onInputUpdate()
    if(msgBoxSelectionActive)then
        if(player.altRunKeyPressing)then
            msgBoxSelectionActive = false
            playSFX(20)
            pressedTimes = 0
            timeSinceLastKeySwitch = 0
            currentSelection = 1
            lastPressedUpState = false
            lastPressedDownState = false
            return
        end
        
        if(not lastPressedUpState and player.upKeyPressing)then
            if(currentSelection > 1)then
                currentSelection = currentSelection - 1
            end
            lastPressedUpState = true
        end
        if(lastPressedUpState and not player.upKeyPressing)then
            lastPressedUpState = false
        end
        
        if(not lastPressedDownState and player.downKeyPressing)then
            if(currentSelection < #MessageBoxLog)then
                currentSelection = currentSelection + 1
            end
            lastPressedDownState = true
        end
        if(lastPressedDownState and not player.downKeyPressing)then
            lastPressedDownState = false
        end
        
        if(coolDownEnterKey <= 0 and player.jumpKeyPressing and #MessageBoxLog >= 1)then
            doToggleMsgBox = true
        end
        
        if(not doToggleMsgBox)then
            player.upKeyPressing = false
            player.downKeyPressing = false
            player.leftKeyPressing = false
            player.rightKeyPressing = false
            player.jumpKeyPressing = false
            player.altJumpKeyPressing = false
            player.runKeyPressing = false
            player.altRunKeyPressing = false
            player.dropItemKeyPressing = false       
        end
    end
    
end

function MessageBoxLoggerAPI.onLoop()
    if(doToggleMsgBox)then
        Text.showMessageBox(MessageBoxLog[currentSelection])
        coolDownEnterKey = 10
        doToggleMsgBox = false
    end
    
    if(not doToggleMsgBoxSelection)then
        if(Misc.cheatBuffer():find("boxmebro"))then
            doToggleMsgBoxSelection = true
            Misc.cheatBuffer("")
        end
    end
    
    if(doToggleMsgBoxSelection)then
        msgBoxSelectionActive = true
        playSFX(20)
        currentSelection = 1
        doToggleMsgBoxSelection = false
        lastPressedUpState = false
        lastPressedDownState = false
    end
        
    if(msgBoxSelectionActive)then
        -- Drawing code
        Text.print("Last Messages: ", 20, 370)
        for tIndex, v in pairs(MessageBoxLog) do
            Text.print(limitText(v, 35), 40, 380 + tIndex * 20)
        end
        Text.print(">", 20, 380 + currentSelection * 20)
    end
    
    if(coolDownEnterKey > 0)then
        coolDownEnterKey = coolDownEnterKey - 1
    end
end

return MessageBoxLoggerAPI