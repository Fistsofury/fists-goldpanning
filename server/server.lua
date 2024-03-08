local VORPcore = exports.vorp_core:GetCore()

exports.vorp_inventory:registerUsableItem(Config.goldwashProp, function(data)
    TriggerClientEvent('fists-GoldPanning:placeProp', data.source, data.item.item)
    exports.vorp_inventory:closeInventory(data.source)
  end)

exports.vorp_inventory:registerUsableItem(Config.emptyMudBucket, function(data)
    TriggerClientEvent('fists-GoldPanning:useEmptyMudBucket', data.source, data.item.amount) --Create a client event to use the item, play animation and then trigger Server event to give mud bucket
    exports.vorp_inventory:closeInventory(data.source)
  end)

  RegisterServerEvent('fists-GoldPanning:mudBuckets')
AddEventHandler('fists-GoldPanning:mudBuckets', function()
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    exports.vorp_inventory:subItem(_source, Config.emptyMudBucket, 1)
    if Config.debug then
        print("player " .. _source .. " has used a empty mud bucket")
    end
    TriggerClientEvent("vorp:TipRight", _source, "You have used a empty mud bucket", 3000)
    exports.vorp_inventory.addItem(_source, Config.mudBucket, Config.mudBucketAmount)
    TriggerClientEvent("vorp:TipRight", _source, "You have received a mud bucket", 3000)
    if Config.debug then
        print("player " .. _source .. " has received a mud bucket")
    end
end)


RegisterServerEvent('fists-GoldPanning:useMudBucket')
AddEventHandler('fists-GoldPanning:useMudBucket', function()
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local itemCount = exports.vorp_inventory:getItemCount(_source, Config.mudBucket)

    if itemCount > 0 then
        exports.vorp_inventory:subItem(_source, Config.mudBucket, 1)
        TriggerClientEvent("vorp:TipRight", _source, "You have used a mud bucket", 3000)
        exports.vorp_inventory:addItem(_source, Config.emptyMudBucket, 1)
        TriggerClientEvent("vorp:TipRight", _source, "You have received an empty mud bucket", 3000)
        TriggerClientEvent('fists-GoldPanning:mudBucketUsedSuccess', _source)
    else
        TriggerClientEvent("vorp:TipRight", _source, "You don't have a mud bucket", 3000)
        TriggerClientEvent("fists-GoldPanning:mudBucketUsedfailure", _source)
    end
end)

RegisterServerEvent('fists-GoldPanning:useWaterBucket')
AddEventHandler('fists-GoldPanning:useWaterBucket', function()
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local itemCount = exports.vorp_inventory:getItemCount(_source, Config.waterBucket)

    if itemCount > 0 then
        exports.vorp_inventory:subItem(_source, Config.waterBucket, 1)
        TriggerClientEvent("vorp:TipRight", _source, "You have used a mud bucket", 3000)
        exports.vorp_inventory:addItem(_source, Config.emptyWaterBucket, 1)
        TriggerClientEvent("vorp:TipRight", _source, "You have received an empty mud bucket", 3000)
        TriggerClientEvent('fists-GoldPanning:waterUsedSuccess', _source)
    else
        TriggerClientEvent("vorp:TipRight", _source, "You don't have a mud bucket", 3000)
        TriggerClientEvent("fists-GoldPanning:waterUsedfailure", _source)
    end
end)




