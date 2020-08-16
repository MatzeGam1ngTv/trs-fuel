ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

function ui(data)
    SetNuiFocus(data.focus, data.focus)
    SendNUIMessage({
        action = data.action,
        config = Config,
        vehicleClass = data.vehicleClass
    })
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = GetPlayerPed(-1)
        local playerCoords = GetEntityCoords(playerPed)
        local isInVeh = GetVehiclePedIsIn(playerPed, false)
        local closestVeh = ESX.Game.GetClosestVehicle()

        for k, v in pairs(Config.Coords) do
            local distance = GetDistanceBetweenCoords(playerCoords[1], playerCoords[2], playerCoords[3], v.x, v.y, v.z, false)
            if distance < 3.0 then
                DrawText3Ds(v.x, v.y, v.z, 'Pressione [E] para meter gasolina.')
                if distance < 1.0 and isInVeh == 0 then
                    if IsControlJustReleased(1, 51) then
                        ui({focus = true, action = 'show', vehicleClass = GetVehicleClass(closestVeh)})
                    end
                end
            end
        end
    end
end)

RegisterNUICallback('close', function(data)
    if data.notification then
        ESX.ShowNotification(data.notification)
    end
    ui({focus = false, action = 'hide'})
end)

RegisterNUICallback('pay', function(data)

    if data.liters == 0 then
        ui({focus = false, action = 'hide'})
        ESX.ShowNotification('~y~Nenhum montante selecionado.')
        return
    end

    ESX.TriggerServerCallback('trs-fuel:checkMoney', function(cb)

        if cb then

            local playerPed = GetPlayerPed(-1)
            local playerCoords = GetEntityCoords(playerPed)
            local closestVeh = ESX.Game.GetClosestVehicle()
            local vehCoords = GetEntityCoords(closestVeh)
            local dist = GetDistanceBetweenCoords(playerCoords[1], playerCoords[2], playerCoords[3], vehCoords[1], vehCoords[2], vehCoords[3], false)
            
            local dict = 'timetable@gardener@filling_can'
            local anim = 'gar_ig_5_filling_can'

            local fuel = GetVehicleFuelLevel(closestVeh)
            local newFuel = fuel + data.liters + 0.0

            ui({focus = false, action = 'hide'})

            if (GetVehicleFuelLevel(closestVeh) + data.liters + 0.0) > 60 then
                ESX.ShowNotification('~y~Capacidade do déposito insuficiente.')
                return
            end

            if dist < 3.0 then

                while not HasAnimDictLoaded(dict) do
                    RequestAnimDict(dict)
                    Wait(10)
                end

                ClearPedTasks(GetPlayerPed(-1))
                FreezeEntityPosition(playerPed, true)
                TaskPlayAnim(GetPlayerPed(-1), dict, anim, 8.0, 8.0, -1, 50, 0, false, false, false)
                Citizen.Wait(data.liters * Config.TimeoutPerLiter)
                ClearPedTasks(GetPlayerPed(-1))
            
                SetVehicleFuelLevel(closestVeh, newFuel)
                FreezeEntityPosition(playerPed, false)

                ESX.ShowNotification(string.format('~g~Pago: %s%s por: %sL', data.price, Config.Currency, data.liters))
            else
                ESX.ShowNotification('~r~Nenhum veiculo encontrado.')
            end

        else
            ESX.ShowNotification('~r~Dinheiro insuficiente.')
            ui({focus = false, action = 'hide'})
        end
    end, data)
end)

RegisterCommand('uf', function(...)
    local closestVeh = ESX.Game.GetClosestVehicle()
    SetVehicleFuelLevel(closestVeh, 0.0)
end)
