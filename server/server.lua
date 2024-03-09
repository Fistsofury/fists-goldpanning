local VORPcore = exports.vorp_core:GetCore()


-------------------------------------Register Usable Items-------------------------------------
  
exports.vorp_inventory:registerUsableItem(Config.emptyMudBucket, function(data) --Use the empty mud bucket
    TriggerClientEvent('fists-GoldPanning:useEmptyMudBucket', data.source, data.item.amount)
    exports.vorp_inventory:closeInventory(data.source)
  end)

  exports.vorp_inventory:registerUsableItem(Config.goldwashProp, function(data) --The Gold Wash Table
    TriggerClientEvent('fists-GoldPanning:placeProp', data.source, data.item.item)
    exports.vorp_inventory:subItem(data.source, Config.goldwashProp, 1)
    exports.vorp_inventory:closeInventory(data.source)
  end)



  -------------------------------------Logic for Mud Buckets-------------------------------------

  RegisterServerEvent('fists-GoldPanning:mudBuckets')  -- Use the empty mud bucket and gain a mud bucket
AddEventHandler('fists-GoldPanning:mudBuckets', function()
    local _source = source
    if exports.vorp_inventory:canCarryItem(_source, Config.mudBucket, 1, nil) then --Check if player can carry the mud bucket
        exports.vorp_inventory:subItem(_source, Config.emptyMudBucket, 1)
            if Config.debug then
                print("player " .. _source .. " has used a empty mud bucket")
            end
        TriggerClientEvent("vorp:TipRight", _source, _U('usedEmptyMudBucket'), 3000) 

        exports.vorp_inventory:addItem(_source, Config.mudBucket, 1)
        if Config.debug then
            print("player " .. _source .. " has received a mud bucket") 
        end
        TriggerClientEvent("vorp:TipRight", _source, _U('receivedEmptyMudBucket'), 3000) 
    else
        TriggerClientEvent("vorp:TipRight", _source, _U('cannotCarryMoreMudBuckets'), 3000) 
    end

end)



-------------------------------------Handle Prompt responses-------------------------------------
RegisterServerEvent('fists-GoldPanning:useMudBucket') -- Use the mud bucket
AddEventHandler('fists-GoldPanning:useMudBucket', function()
    local _source = source
    local itemCount = exports.vorp_inventory:getItemCount(_source, nil, Config.mudBucket) --Check if player has a mud bucket

    if exports.vorp_inventory:canCarryItem(_source, Config.emptyMudBucket, 1, nil) then --Check if player can carry the empty mud bucket rest of the code is self explanatory
        if itemCount > 0 then
            exports.vorp_inventory:subItem(_source, Config.mudBucket, 1)
            TriggerClientEvent("vorp:TipRight", _source, _U('usedMudBucket'), 3000)
            exports.vorp_inventory:addItem(_source, Config.emptyMudBucket, 1)
            TriggerClientEvent("vorp:TipRight", _source, _U('receivedEmptyMudBucket'), 3000)
            TriggerClientEvent('fists-GoldPanning:mudBucketUsedSuccess', _source)
        else
            TriggerClientEvent("vorp:TipRight", _source, _U('dontHaveMudBucket'), 3000)
            TriggerClientEvent("fists-GoldPanning:mudBucketUsedfailure", _source)
        end
    else
        TriggerClientEvent("vorp:TipRight", _source, _U('cannotCarryMoreMudBuckets'), 3000)
    end
end)

RegisterServerEvent('fists-GoldPanning:useWaterBucket')
AddEventHandler('fists-GoldPanning:useWaterBucket', function()
    local _source = source
    local itemCount = exports.vorp_inventory:getItemCount(_source, nil, Config.waterBucket)
    if exports.vorp_inventory:canCarryItem(_source, Config.emptyWaterBucket, 1, nil) then
        if itemCount > 0 then
            exports.vorp_inventory:subItem(_source, Config.waterBucket, 1)
            TriggerClientEvent("vorp:TipRight", _source, _U('usedWaterBucket'), 3000)
            exports.vorp_inventory:addItem(_source, Config.emptyWaterBucket, 1)
            TriggerClientEvent("vorp:TipRight", _source, _U('receivedEmptyWaterBucket'), 3000)
            TriggerClientEvent('fists-GoldPanning:waterUsedSuccess', _source)
        else
            TriggerClientEvent("vorp:TipRight", _source, _U('dontHaveWaterBucket'), 3000)
            TriggerClientEvent("fists-GoldPanning:waterUsedfailure", _source)
        end
    else
        TriggerClientEvent("vorp:TipRight", _source, _U('cantCarryMoreEmptyWaterCans'), 3000)
    end
end)

RegisterServerEvent('fists-GoldPanning:usegoldPan')
AddEventHandler('fists-GoldPanning:usegoldPan', function()
    local _source = source
    local itemCount = exports.vorp_inventory:getItemCount(_source, nil, Config.goldPan)
    if exports.vorp_inventory:canCarryItem(_source, Config.emptyWaterBucket, 1, nil) then
        if itemCount > 0 then
            TriggerClientEvent('fists-GoldPanning:goldPanUsedSuccess', _source)
        else
            TriggerClientEvent("vorp:TipRight", _source, _U('noPan'), 3000)
            TriggerClientEvent("fists-GoldPanning:goldPanfailure", _source)
        end
    else
        TriggerClientEvent("vorp:TipRight", _source, _U('cantCarryMoreEmptyWaterCans'), 3000)
    end
end)

RegisterServerEvent('fists-GoldPanning:placePropGlobal')
AddEventHandler('fists-GoldPanning:placePropGlobal', function(propName, x, y, z, heading)
    TriggerClientEvent('fists-GoldPanning:spawnPropForAll', -1, propName, x, y, z, heading)
end)

-------------------------------------Handle Gold Rewards-------------------------------------
RegisterServerEvent('fists-GoldPanning:panSuccess')
AddEventHandler('fists-GoldPanning:panSuccess', function()
    local _source = source
    local itemCount = exports.vorp_inventory:getItemCount(_source, Config.goldPan)
    if itemCount > 0 then
        if exports.vorp_inventory:canCarryItem(_source, Config.goldWashReward, Config.goldWashRewardAmount) then
            exports.vorp_inventory:addItem(_source, Config.goldWashReward, Config.goldWashRewardAmount)
            TriggerClientEvent("vorp:TipRight", _source, _U('receivedGoldFlakes'), 3000)
            if Config.debug then
                print("player " .. _source .. " has received " .. Config.goldWashRewardAmount .. " gold flakes")
            end
        else
            TriggerClientEvent("vorp:TipRight", _source, _U('cantCarryMoreGoldFlakes'), 3000)
        end
        
        if math.random(100) <= Config.extraRewardChance then
            exports.vorp_inventory:addItem(_source, Config.extraReward, Config.extraRewardAmount)
            TriggerClientEvent("vorp:TipRight", _source, _U('receivedExtraReward'), 3000)
            if Config.debug then
                print("player " .. _source .. " has received " .. Config.extraRewardAmount .. " extra reward")
            end
        end
    else
        TriggerClientEvent("vorp:TipRight", _source, _U('noPan'), 3000)
        if Config.debug then
            print("player " .. _source .. " attempted to pan for gold without a gold pan")
        end
    end
end)
-------------------------------------Handle Prop Returns-------------------------------------
RegisterServerEvent('fists-GoldPanning:givePropBack')
AddEventHandler('fists-GoldPanning:givePropBack', function()
    local _source = source
    if exports.vorp_inventory:canCarryItem(_source, Config.goldwashProp, 1, nil) then
        exports.vorp_inventory:addItem(_source, Config.goldwashProp, 1)
        TriggerClientEvent("vorp:TipRight", _source, _U('propPickup'), 3000)
    else
        TriggerClientEvent("vorp:TipRight", _source, _U('propFull'), 3000)
    end

end)



