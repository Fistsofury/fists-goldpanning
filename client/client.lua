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

--create a prompt--
CreateThread(function()
    local  PromptGroup = BccUtils.Prompt:SetupPromptGroup()
    local firstPrompt = BccUtils.Prompt:RegisterPrompt("mudBucket", "Press R to use mud bucket", PromptGroup, Config.Keys.R, 1, 1,true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})
    local secondPrompt = BccUtils.Prompt:RegisterPrompt("waterBucket", "Press G to use water bucket", PromptGroup, Config.Keys.G, 1, 1,true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})
    local thirdPrompt = BccUtils.Prompt:RegisterPrompt("goldPan", "Press E to use gold pan", PromptGroup, Config.Keys.E, 1, 1,true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})
    while  true  do
        Citizen.Wait(0)
        
        
        PromptGroup:ShowGroup("My first prompt group")
          
        Wait(1000)
        firstprompt:TogglePrompt(false)
        secondPrompt:TogglePrompt(false)
        thirdPrompt:TogglePrompt(false)
    end
end)


RegisterNetEvent('fists-GoldPanning:useEmptyMudBucket')
AddEventHandler('fists-GoldPanning:useEmptyMudBucket', function()
    if isNearWater() then
        PlayAnim("amb_work@world_human_pickaxe_new@working@male_a@trans", "pre_swing_trans_after_swing", Config.bucketingTime, true, true)
        progressbar.start("Filling bucket with mud", Config.bucketingTime, function () -----------------Replace with locale
        end, 'linear')
        TriggerServerEvent('fists-GoldPanning:mudBuckets')
    else
        TiggerClientEvent("vorp:TipRight", _U('noWater'), 3000)
    end
end)

RegisterNetEvent('fists-GoldPanning:hasMudBucket')
AddEventHandler('fists-GoldPanning:hasMudBucket', function(hasMudBucket)
    if hasMudBucket then
        --Trigger Event
    end
end)







-----------------------------------PROP STUFF-----------------------------------
function SetupBuildPrompt()
    local str = _U('BuildPrompt')
    BuildPrompt = Citizen.InvokeNative(0x04F97DE45A519419)
    PromptSetControlAction(BuildPrompt, Config.Keys.R)
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
    PromptSetControlAction(DelPrompt, Config.Keys.E)
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
      local rakeObj = CreateObject("p_rake02x", playerCoords.x, playerCoords.y, playerCoords.z, true, true, false)
      AttachEntityToEntity(rakeObj, PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "PH_R_Hand"), 0.0, 0.0, 0.19, 0.0, 0.0, 0.0, false, false, true, false, 0, true, false, false)
      Wait(time)
      DeleteObject(rakeObj)
      ClearPedTasksImmediately(PlayerPedId())
    else
      Wait(time)
      ClearPedTasksImmediately(PlayerPedId())
    end
  end

  --example animation PlayAnim("amb_work@world_human_pickaxe_new@working@male_a@trans", "pre_swing_trans_after_swing", Config.MiningTime, true, true)






































--[[

  Walk into a river 
  Check if you are in river")

    If you are in river
    Use empty mud bucket
    Plays animation
    Gives mud bucket
    Walk to prop
    empty mud bucket
    Plays animation
    Walk back to river
    use empty water bucket
    Plays animation
    Walk back to Prop
    empty water bucket
    Have prompt to start sifting and this requires a goldpan
    Spanw a goldpan in the hand
    Start goldpanning animation at prop
    Give gold flakes

  ]]