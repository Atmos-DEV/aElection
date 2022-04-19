ESX = nil

local isMenuOpened = false
listvote = {}
local peuxvot = true

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(500)
	end
end)

RMenu.Add("election", "princ", RageUI.CreateMenu("Elections", "~b~Actions :", nil, nil, "aLib", "black"))
RMenu:Get("election", "princ").Closed = function()
	FreezeEntityPosition(PlayerPedId(), false)
	isMenuOpened = false
end

RMenu.Add('election', 'confirm', RageUI.CreateSubMenu(RMenu:Get("election", "princ"), 'Elections', "~b~Etes vous sur :"))
RMenu:Get('election', 'confirm').Closed = function()end

RMenu.Add('election', 'resultats', RageUI.CreateSubMenu(RMenu:Get("election", "princ"), 'Elections', "~b~Résultats :"))
RMenu:Get('election', 'resultats').Closed = function()end

function openMenuElection()
	
	FreezeEntityPosition(PlayerPedId(), true)

    if isMenuOpened then return end
    isMenuOpened = true

	RageUI.Visible(RMenu:Get("election", "princ"), true)

	Citizen.CreateThread(function()
        while isMenuOpened do
            RageUI.IsVisible(RMenu:Get("election", "princ"),true,true,true,function()
                RageUI.Separator('↓ Candidats ↓')
                for k, v in pairs(Configelection.candidat) do
                    RageUI.ButtonWithStyle(v.name, nil, {RightLabel = "Voter pour →→→"}, peuxvot,function(a,h,s)
                        if s then
                            elect = v.name
                        end
                    end, RMenu:Get('election', 'confirm'))
                end
                RageUI.ButtonWithStyle("Résultats", nil, {RightLabel = "→→→"}, admin,function(a,h,s) end, RMenu:Get('election', 'resultats'))
            end, function()end, 1)
            RageUI.IsVisible(RMenu:Get('election', 'confirm'),true,true,true,function()
                RageUI.Separator('↓ Décision : '..elect..' ↓')
                RageUI.ButtonWithStyle("~g~Confirmer", nil, {}, true,function(a,h,s)
                    if s then
                        TriggerServerEvent('aElection:avoter', elect)
                        RageUI.CloseAll()
                        FreezeEntityPosition(PlayerPedId(), false)
                        isMenuOpened = false
                    end
                end)
                RageUI.ButtonWithStyle("~r~Annuler", nil, {}, true,function(a,h,s)
                    if s then
                        RageUI.GoBack()
                    end
                end)
            end, function()end, 1)
            RageUI.IsVisible(RMenu:Get('election', 'resultats'),true,true,true,function()
                RageUI.Separator('↓ Candidats ↓')
                for k, v in pairs(Configelection.candidat) do
                    if listvote[v.name] ~= nil then
                        RageUI.ButtonWithStyle(v.name, nil, {RightLabel = "Votants : "..listvote[v.name].votant}, true,function(a,h,s) end)
                    else
                        RageUI.ButtonWithStyle(v.name, nil, {RightLabel = "~r~Aucun votants"}, true,function(a,h,s) end)
                    end
                end
            end, function()end, 1)
            Wait(0)
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        interval = 750
        local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
        local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, Configelection.menu)
        if dist <= 15 then
            interval = 1
            DrawMarker(1, Configelection.menu, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.0, 120, 120, 240, 100, false, true, 2, false, false, false, false)
            if dist <= 1.2 and not isMenuOpened then
                ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour voter")
                if IsControlJustPressed(1,51) then
                    ESX.TriggerServerCallback('aElection:loaddata', function(data, identifier, group)
                        listvote = data
                        if listvote[identifier] ~= nil then
                            peuxvot = false
                        end
                        if group == "admin" then
                            admin = true
                        end
                    end)
                    openMenuElection()
                end
            end
        end
    Citizen.Wait(interval)
    end
end)

Citizen.CreateThread(function()
    local pedName = Configelection.pedmodel
    local pedHash = GetHashKey(pedName)
    RequestModel(pedHash)
    while not HasModelLoaded(pedHash) do
        Citizen.Wait(10)
    end
    local ped = CreatePed(9, pedHash, Configelection.pedcoords, Configelection.pedheading, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
end)
