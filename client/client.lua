BccUtils = exports['bcc-utils'].initiate()
progressbar = exports["feather-progressbar"]:initiate()
local MiniGame = exports['bcc-minigames'].initiate()


local placing = false
local prompt = false
local BuildPrompt, DelPrompt, PlacingObj
local stage = "mudBucket"

local promptGroup = BccUtils.Prompt:SetupPromptGroup()
local useMudBucketPrompt = promptGroup:RegisterPrompt(_U('promptMudBucket'), Config.keys.E, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
local useWaterBucketPrompt = promptGroup:RegisterPrompt(_U('promptWaterBucket'), Config.keys.R, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
local useGoldPanPrompt = promptGroup:RegisterPrompt(_U('promptPan'), Config.keys.G, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
local removeTablePrompt = promptGroup:RegisterPrompt(_U('promptPickUp'), Config.keys.F, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })



-----------------------------------Mud Bucket-----------------------------------

function isNearWater()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed, true)
    local waterHash = Citizen.InvokeNative(0x5BA7A68A346A5A91, coords.x, coords.y, coords.z) -- GetWaterMapZoneAtCoords
    local pos = GetEntityCoords(PlayerPedId(), true)


    local isInAllowedZone = false
    for _, waterZone in ipairs(Config.waterTypes) do
        if waterHash == GetHashKey(waterZone.hash) and IsPedOnFoot(playerPed) and IsEntityInWater(playerPed) then
            isInAllowedZone = true
            break
        end
    end

    if not isInAllowedZone then
        TriggerEvent("vorp:TipBottom", _U('noWater'), 4000)
        return
    end
    return isInAllowedZone
end

Citizen.CreateThread(function()
    while true do
        Wait(5)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local prop = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 2.0, GetHashKey(Config.goldwashProp), false, false, false)
        
        if prop ~= 0 and placing == false  then
            local propCoords = GetEntityCoords(prop)
            local distance = GetDistanceBetweenCoords(playerCoords, propCoords, true)
            
            if distance < 2.0 then
                promptGroup:ShowGroup("Gold Panning")
                
                useMudBucketPrompt:TogglePrompt(stage == "mudBucket")
                useWaterBucketPrompt:TogglePrompt(stage == "waterBucket")
                useGoldPanPrompt:TogglePrompt(stage == "goldPan")
                removeTablePrompt:TogglePrompt(true)

                if stage == "mudBucket" and useMudBucketPrompt:HasCompleted() then
                    TriggerServerEvent('fists-GoldPanning:useMudBucket')
                elseif stage == "waterBucket" and useWaterBucketPrompt:HasCompleted() then
                    TriggerServerEvent('fists-GoldPanning:useWaterBucket')
                elseif stage == "goldPan" and useGoldPanPrompt:HasCompleted() then
                    TriggerServerEvent('fists-GoldPanning:usegoldPan')
                end
                if removeTablePrompt:HasCompleted() then
                    print("Delete prompt entered")
                    removeTable()
                    
                end
            end
        end
    end
end)





RegisterNetEvent('fists-GoldPanning:mudBucketUsedSuccess', function()
    local playerPed = PlayerPedId()
    Citizen.InvokeNative(0x524B54361229154F, playerPed, GetHashKey('WORLD_HUMAN_BUCKET_POUR_LOW'), -1, true, 0, -1, false)
    progressbar.start("Pouring mud", Config.bucketingTime, function ()
        ClearPedTasks(playerPed, true, true)
        Citizen.InvokeNative(0xFCCC886EDE3C63EC, playerPed, 2, true) 
        Wait(100)
    end, 'linear', 'rgba(255, 255, 255, 0.8)', '20vw', 'rgba(255, 255, 255, 0.1)', 'rgba(211, 211, 211, 0.5)')
    Wait(8000)
    stage = "waterBucket"
end)



RegisterNetEvent('fists-GoldPanning:waterUsedSuccess', function()
    local playerPed = PlayerPedId()
    Citizen.InvokeNative(0x524B54361229154F, playerPed, GetHashKey('WORLD_HUMAN_BUCKET_POUR_LOW'), -1, true, 0, -1, false)
    progressbar.start(_U('pouringWater'), Config.bucketingTime, function ()
        ClearPedTasks(playerPed, true, true)
        Citizen.InvokeNative(0xFCCC886EDE3C63EC, playerPed, 2, true) 
        Wait(100)
    end, 'linear', 'rgba(255, 255, 255, 0.8)', '20vw', 'rgba(255, 255, 255, 0.1)', 'rgba(211, 211, 211, 0.5)')
    Wait(8000)
    stage = "goldPan"
end)

RegisterNetEvent('fists-GoldPanning:goldPanUsedSuccess', function()
    MiniGame.Start('skillcheck', Config.Minigame, function(result)
        if result.passed then
            PlayAnim("script_re@gold_panner@gold_success", "panning_idle", Config.goldWashTime, true, true)
            Wait(Config.goldWashTime)
            TriggerServerEvent('fists-GoldPanning:panSuccess')
            stage = "mudBucket"
        end
    end)
end)

RegisterNetEvent('fists-GoldPanning:mudBucketUsedfailure', function()
    stage = "mudBucket"
end)
RegisterNetEvent('fists-GoldPanning:waterUsedfailure', function()
    stage = "mudBucket"
end)
RegisterNetEvent('fists-GoldPanning:goldPanfailure', function()
    stage = "mudBucket"
end)


RegisterNetEvent('fists-GoldPanning:useEmptyMudBucket')
AddEventHandler('fists-GoldPanning:useEmptyMudBucket', function()
    if isNearWater() then
        local playerPed = PlayerPedId()
        Citizen.InvokeNative(0x524B54361229154F, playerPed, GetHashKey('WORLD_HUMAN_BUCKET_FILL'), -1, true, 0, -1, false)
        progressbar.start(_U('collectingMud'), Config.bucketingTime, function ()
            ClearPedTasks(playerPed, true, true)
            Citizen.InvokeNative(0xFCCC886EDE3C63EC, playerPed, 2, true) 
            Wait(100)
            TriggerServerEvent('fists-GoldPanning:mudBuckets')
        end, 'linear', 'rgba(255, 255, 255, 0.8)', '20vw', 'rgba(255, 255, 255, 0.1)', 'rgba(211, 211, 211, 0.5)')

    else
        TriggerServerEvent('fists-GoldPanning:addMudBack')
        
    end
end)


RegisterNetEvent('fists-GoldPanning:useWaterBucket')
AddEventHandler('fists-GoldPanning:useWaterBucket', function()
    if isNearWater() then
        local playerPed = PlayerPedId()
        Citizen.InvokeNative(0x524B54361229154F, playerPed, GetHashKey('WORLD_HUMAN_BUCKET_FILL'), -1, true, 0, -1, false)
        progressbar.start(_U('collectingWater'), Config.bucketingTime, function ()
            ClearPedTasks(playerPed, true, true)
            Citizen.InvokeNative(0xFCCC886EDE3C63EC, playerPed, 2, true) 
            Wait(100)
            TriggerServerEvent('fists-GoldPanning:waterBuckets')
        end, 'linear', 'rgba(255, 255, 255, 0.8)', '20vw', 'rgba(255, 255, 255, 0.1)', 'rgba(211, 211, 211, 0.5)')

    else
        TriggerServerEvent('fists-GoldPanning:addWaterBack')
    end
end)



-----------------------------------PROP STUFF-----------------------------------

function removeTable() -- Removes the spawned prop
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local prop = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 2.0, GetHashKey(Config.goldwashProp), false, false, false)
    
    if prop ~= 2 then
        print("Deleting" .. prop)
        DeleteObject(prop)
        TriggerServerEvent('fists-GoldPanning:givePropBack')
    end
end


function SetupBuildPrompt() -- Sets up the prompt for building the prop
    local str = _U('BuildPrompt')
    BuildPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
    PromptSetControlAction(BuildPrompt, Config.keys.R)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(BuildPrompt, str)
    PromptSetEnabled(BuildPrompt, false)
    PromptSetVisible(BuildPrompt, false)
    PromptSetHoldMode(BuildPrompt, true)
    PromptRegisterEnd(BuildPrompt)
end

function SetupDelPrompt() -- Sets up the prompt for deleting the prop when being placed
    local str = _U('DelPrompt')
    DelPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
    PromptSetControlAction(DelPrompt, Config.keys.E)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(DelPrompt, str)
    PromptSetEnabled(DelPrompt, false)
    PromptSetVisible(DelPrompt, false)
    PromptSetHoldMode(DelPrompt, true)
    PromptRegisterEnd(DelPrompt)
end

RegisterNetEvent('fists-GoldPanning:placeProp') --you guessed it, places the prop
AddEventHandler('fists-GoldPanning:placeProp', function(propName)
    SetupBuildPrompt()
    SetupDelPrompt()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed, true)
    local waterHash = Citizen.InvokeNative(0x5BA7A68A346A5A91, coords.x, coords.y, coords.z)
    local pos = GetEntityCoords(PlayerPedId(), true)


    local isInAllowedZone = false
    for _, waterZone in ipairs(Config.waterTypes) do
        if waterHash == GetHashKey(waterZone.hash) and IsPedOnFoot(playerPed) and IsEntityInWater(playerPed) then
            isInAllowedZone = true
            break
        end
    end

    if not isInAllowedZone then
        TriggerEvent("vorp:TipBottom", _U('noWater'), 4000)
        TriggerServerEvent('fists-GoldPanning:givePropBack')
        return
    end

    local pHead = GetEntityHeading(playerPed)
    local object = GetHashKey(propName)
    if not HasModelLoaded(object) then
        RequestModel(object)
    end
    while not HasModelLoaded(object) do
        Wait(5)
    end

    placing = true
    PlacingObj = CreateObject(object, pos.x, pos.y, pos.z, false, true, false)
    SetEntityHeading(PlacingObj, pHead)
    SetEntityAlpha(PlacingObj, 51)
    AttachEntityToEntity(PlacingObj, PlayerPedId(), 0, 0.0, 1.0, -0.7, 0.0, 0.0, 0.0, true, false, false, false, false,
        true)
    while placing do
        Wait(10)
        if prompt == false then
            PromptSetEnabled(BuildPrompt, true)
            PromptSetVisible(BuildPrompt, true)
            PromptSetEnabled(DelPrompt, true)
            PromptSetVisible(DelPrompt, true)
            prompt = true
        end
        if PromptHasHoldModeCompleted(BuildPrompt) then
            PromptSetEnabled(BuildPrompt, false)
            PromptSetVisible(BuildPrompt, false)
            PromptSetEnabled(DelPrompt, false)
           PromptSetVisible(DelPrompt, false)
            prompt = false
            local PropPos = GetEntityCoords(PlacingObj, true)
            local PropHeading = GetEntityHeading(PlacingObj)
            DeleteObject(PlacingObj)
            progressbar.start(_U('buildingTable'), Config.washBuildTime , function ()
            end, 'linear', 'rgba(255, 255, 255, 0.8)', '20vw', 'rgba(255, 255, 255, 0.1)', 'rgba(211, 211, 211, 0.5)')
            TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_SLEDGEHAMMER'), -1, true, false, false, false)
            Citizen.Wait(Config.washBuildTime)
            ClearPedTasksImmediately(PlayerPedId())
            if propName == Config.goldwashProp then
                TempObj = CreateObject(object, PropPos.x, PropPos.y, PropPos.z, true, true, true)
                SetEntityHeading(TempObj, PropHeading)
                PlaceObjectOnGroundProperly(TempObj)
                placing = false
            end
            break
        end
        if PromptHasHoldModeCompleted(DelPrompt) then
            PromptSetEnabled(BuildPrompt, false)
            PromptSetVisible(BuildPrompt, false)
            PromptSetEnabled(DelPrompt, false)
            PromptSetVisible(DelPrompt, false)
            DeleteObject(PlacingObj)
            prompt = false
            TriggerServerEvent('fists-GoldPanning:givePropBack')
            break
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    prompt = false
    PromptSetEnabled(BuildPrompt, false)
    PromptSetVisible(BuildPrompt, false)
    PromptSetEnabled(BrewPrompt, false)
    PromptSetVisible(BrewPrompt, false)
    PromptSetEnabled(DelPrompt, false)
    PromptSetVisible(DelPrompt, false)
    DeleteEntity(PlacingObj)
end)


-----------------------------------Animations-----------------------------------
function PlayAnim(animDict, animName, time, raking, loopUntilTimeOver) --function to play an animation
    local animTime = time
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
      Wait(100)
    end
    local flag = 16
    -- if time is -1 then play the animation in an infinite loop which is not possible with flag 16 but with 1
    -- if time is -1 the caller has to deal with ending the animation by themselve
    if loopUntilTimeOver then
      flag = 1
      animTime = -1
    end
    TaskPlayAnim(PlayerPedId(), animDict, animName, 1.0, 1.0, animTime, flag, 0, true, 0, false, 0, false)
    if raking then
      local playerCoords = GetEntityCoords(PlayerPedId())
      local rakeObj = CreateObject(Config.goldSiftingProp, playerCoords.x, playerCoords.y, playerCoords.z, true, true, false)
      AttachEntityToEntity(rakeObj, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "PH_R_Hand"), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 0, true, false, false)
      progressbar.start(_U('siftingGold'), time, function ()
      Wait(5)
      DeleteObject(rakeObj)
      ClearPedTasksImmediately(PlayerPedId())
    end, 'linear', 'rgba(255, 255, 255, 0.8)', '20vw', 'rgba(255, 255, 255, 0.1)', 'rgba(211, 211, 211, 0.5)')
    else
      Wait(time)
      ClearPedTasksImmediately(PlayerPedId())
    end
  end

  function ScenarioInPlace(hash, time) -- CHANGE ALL SCENARIOS OR REMOVE
    local pl = PlayerPedId()
    FreezeEntityPosition(pl, true)
    TaskStartScenarioInPlace(pl, joaat(hash), time, true, false, false, false)
    Wait(time)
    ClearPedTasksImmediately(pl)
    FreezeEntityPosition(pl, false)
  end
