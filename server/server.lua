ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local data = ""
dataTable = {}
local nombre = 0

function extractdata()
    data = LoadResourceFile(GetCurrentResourceName(), "data.json")
    dataTable = json.decode(data)
end

ESX.RegisterServerCallback('aElection:loaddata', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local group = xPlayer.getGroup()
    extractdata()
    cb(dataTable, xPlayer.identifier, group)
end)

RegisterNetEvent('aElection:avoter')
AddEventHandler('aElection:avoter', function(candidat)
    local src = source
    local xPlayer =  ESX.GetPlayerFromId(src)
    if dataTable[xPlayer.identifier] == nil then
        dataTable[xPlayer.identifier] = {
            select = candidat
        }
        if dataTable[candidat] == nil then
            dataTable[candidat] = {
                votant = nombre + 1
            }
        else
            nombre = dataTable[candidat].votant
            dataTable[candidat] = {
                votant = nombre + 1
            }
        end
        TriggerClientEvent('esx:showNotification', src, "Vous venez de voter pour ~g~"..candidat.."~s~ !")
    else
        TriggerClientEvent('esx:showNotification', src, "~r~Problème~s~ : Vous avez déjà voté !")
    end
    SaveResourceFile(GetCurrentResourceName(), "data.json", json.encode(dataTable), -1)
end)