local isInPanel, noNotify = false, false
local activeTicketMarkers = {}

CreateThread(function()
    while true do
        local hasMarkers = false
        for uniqueId, markerData in pairs(activeTicketMarkers) do
            hasMarkers = true
            local player = GetPlayerFromServerId(markerData.playerId)
            if player ~= -1 then
                local ped = GetPlayerPed(player)
                if ped and ped ~= 0 and DoesEntityExist(ped) then
                    local coords = GetEntityCoords(ped)
                    DrawText3D(coords.x, coords.y, coords.z + 1.2, markerData.playerName)
                end
            end
        end
        Wait(hasMarkers and 0 or 500)
    end
end)

RegisterNUICallback('close', function(data, cb) closeUi() end)
function closeUi()

    print('Trying to sync, TicketContent', ESX.DumpTable(ticketContent))

    activeTicketMarkers[newUniqueId] = { playerId = ticketContent.playerId, playerName = ticketContent.playerName }

    SendNUIMessage({type = 'createTicket', ticketContent = ticketContent})

    if not noNotify then 
end)

RegisterNUICallback('syncDelete', function(uniqueId)  TriggerServerEvent('rlo_ticketpanel:server:syncDelete', uniqueId) end)
RegisterNetEvent('rlo_ticketpanel:client:syncDelete', function(uniqueId)
    activeTicketMarkers[uniqueId] = nil
    SendNUIMessage({type = 'removeTicket', uniqueId = uniqueId})
end)

RegisterNUICallback('syncState', function(ticketContent)  
    print('(Client) syncing this is the ticket content:', ESX.DumpTable(ticketContent))
    print('Active Tickets: '..ESX.DumpTable(activeTickets))
    for uniqueId, ticketContent in pairs(activeTickets) do
        print('uniqueId: '..uniqueId.. ' | ticketContent: '..ESX.DumpTable(ticketContent))
        activeTicketMarkers[uniqueId] = { playerId = ticketContent.playerId, playerName = ticketContent.playerName }
        SendNUIMessage({type = 'createRequest', ticketContent = ticketContent})
    end
end)
