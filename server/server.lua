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
    exports.vorp_inventory.addItem(_source, Config.mudBucket, Config.mudBucketAmount,)
    TriggerClientEvent("vorp:TipRight", _source, "You have received a mud bucket", 3000)
    if Config.debug then
        print("player " .. _source .. " has received a mud bucket")
    end
end)


RegisterServerEvent('fists-GoldPanning:hasMudBucket')
AddEventHandler('fists-GoldPanning:hasMudBucket', function()
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local hasItem = exports.vorp_inventory:getItem(_source, Config.mudBucket, function(item)
        if item.amount >= 1 then
          TriggerClientEvent('fists-GoldPanning:hasMudBucket', _source, true)
        else
          TriggerClientEvent("vorp:TipRight", _source, "You don't have a mud bucket", 3000)
        end
      end)
end)

RegisterServerEvent('fists-GoldPanning:hasWaterBucket')
AddEventHandler('fists-GoldPanning:hasWaterBucket', function()
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local hasItem = exports.vorp_inventory:getItem(_source, Config.waterBucket, function(item)
        if item.amount >= 1 then
          TriggerClientEvent('fists-GoldPanning:hasWaterBucket', _source, true)
        else
          TriggerClientEvent("vorp:TipRight", _source, "You don't have a water bucket", 3000)
        end
      end)
end)

RegisterServerEvent('fists-GoldPanning:hasGoldPan')
AddEventHandler('fists-GoldPanning:hasGoldPan', function()
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    local hasItem = exports.vorp_inventory:getItem(_source, Config.goldSiftingProp, function(item)
        if item.amount >= 1 then
          TriggerClientEvent('fists-GoldPanning:hasGoldPan', _source, true)
        else
          TriggerClientEvent("vorp:TipRight", _source, "You don't have a Gold Pan bucket", 3000)
        end
      end)
end)

RegisterServerEvent('fists-GoldPanning:useMudBucket')
AddEventHandler('fists-GoldPanning:useMudBucket', function()
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    exports.vorp_inventory:subItem(_source, Config.mudBucket, 1)
    TriggerClientEvent("vorp:TipRight", _source, "You have used a mud bucket", 3000)
    exports.vorp_inventory.addItem(_source, Config.emptyMudBucket, 1)
    TriggerClientEvent("vorp:TipRight", _source, "You have received a empty mud bucket", 3000)
end)

RegisterServerEvent('fists-GoldPanning:useWaterBucket')
AddEventHandler('fists-GoldPanning:useWaterBucket', function()
    local _source = source
    local character = VORPcore.getUser(_source).getUsedCharacter
    exports.vorp_inventory:subItem(_source, Config.waterBucket, 1)
    TriggerClientEvent("vorp:TipRight", _source, "You have used a water bucket", 3000)
    exports.vorp_inventory.addItem(_source, Config.emptyWaterBucket, 1)
    TriggerClientEvent("vorp:TipRight", _source, "You have received a empty water bucket", 3000)
end)
