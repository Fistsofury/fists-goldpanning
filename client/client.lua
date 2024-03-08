BccUtils = exports['bcc-utils'].initiate()
progressbar = exports["feather-progressbar"]:initiate()

local placing = false
local prompt = false
local BuildPrompt, DelPrompt, PlacingObj


-----------------------------------Mud Bucket-----------------------------------

function isNearWater()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local water = Citizen.InvokeNative(0x5BA7A68A346A5A91, coords.x, coords.y, coords.z, 1.0)
    return water
end

local promptGroup = BccUtils.Prompt:SetupPromptGroup()
local useMudBucketPrompt = promptGroup:RegisterPrompt("Use Mud Bucket", Config.keys.R, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
local useWaterBucketPrompt = promptGroup:RegisterPrompt("Use Water Bucket", Config.keys.R, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
local useGoldPanPrompt = promptGroup:RegisterPrompt("Use Gold Pan", Config.keys.R, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
local deletePrompt = promptGroup:RegisterPrompt("Use Gold Pan", Config.keys.G, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })

-- Initial state
local stage = "mudBucket" 


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
                deletePrompt:TogglePrompt(true)
                useMudBucketPrompt:TogglePrompt(stage == "mudBucket")
                useWaterBucketPrompt:TogglePrompt(stage == "waterBucket")
                useGoldPanPrompt:TogglePrompt(stage == "goldPan")

                if stage == "mudBucket" and useMudBucketPrompt:HasCompleted() then
                    TriggerServerEvent('fists-GoldPanning:useMudBucket')
                    stage = "waterBucket"
                elseif stage == "waterBucket" and useWaterBucketPrompt:HasCompleted() then
                    TriggerServerEvent('fists-GoldPanning:useWaterBucket')
                    stage = "goldPan"
                elseif stage == "goldPan" and useGoldPanPrompt:HasCompleted() then
                    exports['mor_minigames']:skill_circle({
                        style = 'default', -- Style template
                        icon = 'fa-solid fa-sun', -- Any font-awesome icon; will use template icon if none is provided
                        area_size = 4, -- Size of the target area in Math.PI / "value"
                        speed = 0.02, -- Speed the target area moves
                    }, function(success) -- Game callback
                        if success then
                            PlayAnim("script_re@gold_panner@gold_success", "panning_idle", 8000, true, true)
                            stage = "mudBucket"
                        else
                            stage = "mudBucket"
                        end
                    end)
                end
            else

            end
        else
        end
    end
end)



RegisterNetEvent('fists-GoldPanning:mudBucketUsedSuccess', function()
    local playerPed = PlayerPedId()
    Citizen.InvokeNative(0x524B54361229154F, playerPed, GetHashKey('WORLD_HUMAN_BUCKET_POUR_LOW'), -1, true, 0, -1, false)
    progressbar.start("Pouring mud", 8000, function ()
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
    progressbar.start("Pouring Water", 8000, function ()
        ClearPedTasks(playerPed, true, true)
        Citizen.InvokeNative(0xFCCC886EDE3C63EC, playerPed, 2, true) 
        Wait(100)
    end, 'linear', 'rgba(255, 255, 255, 0.8)', '20vw', 'rgba(255, 255, 255, 0.1)', 'rgba(211, 211, 211, 0.5)')
    Wait(8000)
    stage = "goldPan"
end)

RegisterNetEvent('fists-GoldPanning:mudBucketUsedfailure', function()
    stage = "mudBucket"
end)
RegisterNetEvent('fists-GoldPanning:waterUsedfailure', function()
    stage = "mudBucket"
end)


RegisterNetEvent('fists-GoldPanning:useEmptyMudBucket')
AddEventHandler('fists-GoldPanning:useEmptyMudBucket', function()
    if isNearWater() then
        local playerPed = PlayerPedId()
        Citizen.InvokeNative(0x524B54361229154F, playerPed, GetHashKey('WORLD_HUMAN_BUCKET_FILL'), -1, true, 0, -1, false)
        progressbar.start("Collecting Mud", 8000, function ()
            ClearPedTasks(playerPed, true, true)
            Citizen.InvokeNative(0xFCCC886EDE3C63EC, playerPed, 2, true) 
            Wait(100)
        end, 'linear', 'rgba(255, 255, 255, 0.8)', '20vw', 'rgba(255, 255, 255, 0.1)', 'rgba(211, 211, 211, 0.5)')
        TriggerServerEvent('fists-GoldPanning:mudBuckets')
    else
        TiggerClientEvent("vorp:TipRight", _U('noWater'), 3000)
    end
end)



-----------------------------------PROP STUFF-----------------------------------
function SetupBuildPrompt()
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

function SetupDelPrompt()
    local str = _U('DestroyPrompt')
    DelPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
    PromptSetControlAction(DelPrompt, Config.keys.E)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(DelPrompt, str)
    PromptSetEnabled(DelPrompt, false)
    PromptSetVisible(DelPrompt, false)
    PromptSetHoldMode(DelPrompt, true)
    PromptRegisterEnd(DelPrompt)
end

RegisterNetEvent('fists-GoldPanning:placeProp')
AddEventHandler('fists-GoldPanning:placeProp', function(propName)
    SetupBuildPrompt()
    SetupDelPrompt()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local pHead = GetEntityHeading(PlayerPedId())
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
            --TriggerEvent("vorp:TipBottom", _U('PlacingProp'), 4000)
            TaskStartScenarioInPlace(PlayerPedId(), GetHashKey('WORLD_HUMAN_SLEDGEHAMMER'), -1, true, false, false, false)
            Citizen.Wait(Config.washBuildTime * 1000)
            ClearPedTasksImmediately(PlayerPedId())
            if propName == Config.goldwashProp then
                --TriggerServerEvent('bcc-brewing:SaveToDB', Config.Props.still, PropPos.x, PropPos.y, PropPos.z, PropHeading)
                --TriggerEvent("vorp:TipBottom", _U('StillPlaced'), 4000)
                TempObj = CreateObject(object, PropPos.x, PropPos.y, PropPos.z, false, true, false)
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
      local rakeObj = CreateObject("p_copperpan02x", playerCoords.x, playerCoords.y, playerCoords.z, true, true, false)
      AttachEntityToEntity(rakeObj, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "PH_R_Hand"), 0.0, 0.0, 0.19, 0.0, 0.0, 0.0, false, false, true, false, 0, true, false, false)
      progressbar.start("Sifting Gold", time, function () -----------------Replace with locale
      Wait(time)
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








--[[

 Add Progress Bar to build
 Add Prompt to destory and add item back
 Fix prop position on gold panning


  ]]