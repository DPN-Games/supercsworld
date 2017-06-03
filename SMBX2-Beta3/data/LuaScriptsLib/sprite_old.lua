local __title = "Animated Sprite Utility Class";
local __version = "1.0";
local __description = "Provides functions for placing (animated) sprites with moving abilities.";
local __author = "Kevsoft";
local __url = "https://github.com/Wohlhabend-Networks/LunaDLL/tree/master/LuaScriptsLibExt";

local SpriteFactory = {
    COOR_CAMERA = 0,
    COOR_SCENE = 1
}

local function validateLuaResourceImageArray(vTable)
    for k,v in pairs(vTable) do
        local typeOfKey = type(k)
        local typeOfValue = type(v)
        if(typeOfKey ~= "number")then
            error("One of the elements in the animation array does not contain a number key!\nType of Key: " .. typeOfKey .. "\nType of Value: " .. typeOfValue)
        end
        if(typeOfValue ~= "userdata")then
            error("One of the elements in the animation array does not contain a LuaResourceImage value!\nType of Key: " .. typeOfKey .. "\nType of Value: " .. typeOfValue)
        end
    end
end
local function validateAnimationSetMap(vTable)
    for k,v in pairs(vTable) do
        local typeOfKey = type(k)
        local typeOfValue = type(v)
        if(typeOfKey ~= "string")then
            error("One of the elements in the animation map does not contain a string key!\nType of Key: " .. typeOfKey .. "\nType of Value: " .. typeOfValue)
        end
        if(typeOfValue ~= "table")then
            error("One of the elements in the animation map does not contain a animation array table value!\nType of Key: " .. typeOfKey .. "\nType of Value: " .. typeOfValue)
        end
        
        validateLuaResourceImageArray(v)
    end
end


local SpriteClass_mt = {}
SpriteClass_mt.__index = SpriteClass_mt

function SpriteClass_mt:onLoop()
    self.x = self.x + self.speedX
    self.y = self.y + self.speedY
    
    local currentAnimationSet = self.animationSets[self.currentAnimationSet]
    if(type(currentAnimationSet) ~= "table")then
        error("Internal Error: Current animation set does not exist in the animation sets of the sprite")
    end
    if(#currentAnimationSet == 0)then
        return
    end
    
    if(self.frameTimerCurrent == self.frameTimerSpeed)then
        if(self.currentAnimationSetFrame >= #currentAnimationSet)then
            self.currentAnimationSetFrame = 1
        else
            self.currentAnimationSetFrame = self.currentAnimationSetFrame + 1
        end
    end
    
    if(self.frameTimerCurrent == self.frameTimerSpeed)then
        self.frameTimerCurrent = 1
    else
        self.frameTimerCurrent = self.frameTimerCurrent + 1
    end
end

function SpriteClass_mt:onHUDDraw()
    local currentAnimationSet = self.animationSets[self.currentAnimationSet]
    if(type(currentAnimationSet) ~= "table")then
        error("Internal Error: Current animation set does not exist in the animation sets of the sprite")
    end
    if(#currentAnimationSet == 0)then
        return
    end
    
    if(self.isShown)then
        local nextFrameImage = currentAnimationSet[self.currentAnimationSetFrame]
        if(not nextFrameImage)then error("The current frame in the current animation set is empty!") end
        if(self.mode == SpriteFactory.COOR_CAMERA)then
            Graphics.drawImage(nextFrameImage, self.x, self.y, 0, 0, 0, 0)
        elseif(self.mode == SpriteFactory.COOR_SCENE)then
            Graphics.drawImageToScene(nextFrameImage, self.x, self.y, 0, 0, 0, 0)
        end
    end
    
end



local createdSpriteRegister = {}
--setmetatable(createdSpriteRegister, { __mode = "v" })


    
function SpriteFactory.onInitAPI() 
    registerEvent(SpriteFactory, "onLoop", nil, false)
    registerEvent(SpriteFactory, "onHUDDraw", nil, false)
end

function SpriteFactory.onLoop()
    for _, v in pairs(createdSpriteRegister) do
        v:onLoop()
    end
end

function SpriteFactory.onHUDDraw()
    for _, v in pairs(createdSpriteRegister) do
        v:onHUDDraw()
    end
end

setmetatable(SpriteFactory, {

    --[[    Create new instance
            Sprite([mode, x, y, speedX, speedY])
            Sprite(LuaResourceImage, [mode, x, y, speedX, speedY])
            Sprite({LuaResourceImage...}, [mode, x, y, speedX, speedY])
            Sprite({ someAnim = {LuaResourceImage...}, someAnim2 = {LuaResourceImage...}, [mode, x, y, speedX, speedY]})
    ]]--
    __call = function(_t, ...)
        local newSprite = {}
        setmetatable(newSprite, SpriteClass_mt)
        
        newSprite.animationSets = {}
        newSprite.currentAnimationSet = "default"
        newSprite.currentAnimationSetFrame = 1
        newSprite.isShown = false
        newSprite.frameTimerSpeed = 1
        newSprite.frameTimerCurrent = 1
        
        
        
        local args = {...}
        local firstArg = args[1]
        local firstArgTypeStr = type(firstArg)
        if(#args > 0 and firstArgTypeStr ~= "number")then --If we assum parameters has been passed and the first argument is not a number
            
            
            --[[ Detect argument signature
                0 - is normal LuaResourceImage
                1 - is default image animation
                2 - map of image animations
            ]]
            local firstArgType = 0
            if(firstArgTypeStr ~= "userdata" and firstArgTypeStr ~= "table") then
                error("Arg #1 in Sprite constructor is not LuaResourceImage or a table (got " .. firstArgTypeStr .. ")")
            end
            
            if(type(firstArg) == "userdata")then
                firstArgType = 0
            else
                if(#firstArg <= 0)then
                    error("Arg #1 in Sprite constructor is an empty table (use nil instead)")
                end
                
                if(type(firstArg[1]) == "userdata")then
                    firstArgType = 1
                else
                    firstArgType = 2
                end
            end
            
            if(firstArgType == 0)then
                newSprite.animationSets["default"] = {firstArg}
            elseif(firstArgType == 1)then
                -- Validate
                validateLuaResourceImageArray(firstArg)
                newSprite.animationSets["default"] = firstArg
            elseif(firstArgType == 2)then
                -- Validate
                validateAnimationSetMap(firstArg)
                newSprite.animationSets = firstArg
                for k,v in pairs(newSprite.animationSets) do newSprite.currentAnimationSet = k break end -- Set the first animation set as the current one
            end
            
            table.remove(args, 1)
        else
            newSprite.animationSets["default"] = {}
        end
        
        if(args[1])then if(type(args[1]) ~= "number") then error("Arg #2 \"mode\" expected number, got " .. type(args[1])) end end
        if(args[2])then if(type(args[2]) ~= "number") then error("Arg #3 \"x\" expected number, got " .. type(args[2])) end end
        if(args[3])then if(type(args[3]) ~= "number") then error("Arg #4 \"y\" expected number, got " .. type(args[3])) end end
        if(args[4])then if(type(args[4]) ~= "number") then error("Arg #5 \"speedX\" expected number, got " .. type(args[4])) end end 
        if(args[5])then if(type(args[5]) ~= "number") then error("Arg #6 \"speedY\" expected number, got " .. type(args[5])) end end
        
        if(args[1])then
            if(args[1] ~= SpriteFactory.COOR_CAMERA and args[1] ~= SpriteFactory.COOR_SCENE)then
                error("Arg #2 \"mode\" is not Sprite.COOR_CAMERA or Sprite.COOR_SCENE!")
            end
        end
        
        newSprite.mode = args[1] or SpriteFactory.COOR_CAMERA
        newSprite.x = args[2] or 0
        newSprite.y = args[3] or 0
        newSprite.speedX = args[4] or 0
        newSprite.speedY = args[5] or 0
        
        
        
        table.insert(createdSpriteRegister, newSprite)
        return newSprite
    end

})
return SpriteFactory

