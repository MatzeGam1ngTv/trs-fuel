ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('ug-fuel:checkMoney', function(source, cb, data)

    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayerMoney = xPlayer.getMoney()

    if xPlayerMoney >= data.price then
        xPlayer.removeMoney(data.price)
        cb(true)
    else
        cb(false)
    end
end)
