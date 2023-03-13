local RSGCore = exports['rsg-core']:GetCoreObject()
local lockdownSecondsRemaining = 0 -- done to zero lockdown on restart
local cooldownSecondsRemaining = 0 -- done to zero cooldown on restart
local CurrentLawmen = 0
local lockpicked = false
local dynamiteused = false
local stdvault1 = false
local stdvault2 = false
local robberystarted = false
local lockdownactive = false

------------------------------------------------------------------------------------------------------------------------

-- lock vault doors
Citizen.CreateThread(function()
    for k,v in pairs(Config.VaultDoors) do
        Citizen.InvokeNative(0xD99229FE93B46286,v,1,1,0,0,0,0)
        Citizen.InvokeNative(0x6BAB9442830C7F53,v,1)
    end
end)

------------------------------------------------------------------------------------------------------------------------

-- lockpick door
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local pos, awayFromObject = GetEntityCoords(PlayerPedId()), true
		local object = Citizen.InvokeNative(0xF7424890E4A094C0, 1634115439, 0)
		local object2 = Citizen.InvokeNative(0xF7424890E4A094C0, 965922748, 0)
		if object ~= 0 and lockdownSecondsRemaining == 0 and lockpicked == false then
			local objectPos = GetEntityCoords(object)
			if #(pos - objectPos) < 3.0 then
				awayFromObject = false
				DrawText3Ds(2647.82, -1300.55, 52.25, "Lockpick [J]") --vector3(2647.82, -1300.55, 52.25)
				if IsControlJustReleased(0, RSGCore.Shared.Keybinds['J']) then
					RSGCore.Functions.TriggerCallback('police:GetCops', function(result)
						CurrentLawmen = result
						if CurrentLawmen >= Config.MinimumLawmen then
							local hasItem = RSGCore.Functions.HasItem('lockpick', 1)
							if hasItem then
								TriggerServerEvent('rsg-stdenisbankheist:server:removeItem', 'lockpick', 1)
								TriggerEvent('rsg-lockpick:client:openLockpick', lockpickFinish)
							else
								RSGCore.Functions.Notify('you need a lockpick', 'error')
							end
						else
							RSGCore.Functions.Notify('not enough lawmen on duty!', 'error')
						end
					end)
				end
			end
		end
		if awayFromObject then
			Wait(1000)
		end
	end
end)

function lockpickFinish(success)
    if success then
		RSGCore.Functions.Notify('lockpick successful', 'success')
		Citizen.InvokeNative(0x6BAB9442830C7F53, 1634115439, 0)
		lockpicked = true
		robberystarted = true
		handleLockdown()
		lockdownactive = true
    else
        RSGCore.Functions.Notify('lockpick unsuccessful', 'error')
    end
end

------------------------------------------------------------------------------------------------------------------------

-- blow vault prompt
Citizen.CreateThread(function()
	while true do
		Wait(0)
		local pos, awayFromObject = GetEntityCoords(PlayerPedId()), true
		local object = Citizen.InvokeNative(0xF7424890E4A094C0, 1751238140, 0)
		if object ~= 0 and robberystarted == true and dynamiteused == false then
			local objectPos = GetEntityCoords(object)
			if #(pos - objectPos) < 3.0 then
				awayFromObject = false
				DrawText3Ds(2643.88, -1300.54, 52.25, "Place Dynamite [J]") --vector3(2643.88, -1300.54, 52.25)
				if IsControlJustReleased(0, RSGCore.Shared.Keybinds['J']) then
					TriggerEvent('rsg-stdenisbankheist:client:boom')
				end
			end
		end
		if awayFromObject then
			Wait(1000)
		end
	end
end)

-- blow vault doors
RegisterNetEvent('rsg-stdenisbankheist:client:boom')
AddEventHandler('rsg-stdenisbankheist:client:boom', function()
	if robberystarted == true then
		local hasItem = RSGCore.Functions.HasItem('dynamite', 1)
		if hasItem then
			dynamiteused = true
			TriggerServerEvent('rsg-stdenisbankheist:server:removeItem', 'dynamite', 1)
			local playerPed = PlayerPedId()
			TaskStartScenarioInPlace(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 5000, true, false, false, false)
			Wait(5000)
			ClearPedTasksImmediately(PlayerPedId())
			local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.5, 0.0))
			local prop = CreateObject(GetHashKey("p_dynamite01x"), x, y, z, true, false, true)
			SetEntityHeading(prop, GetEntityHeading(PlayerPedId()))
			PlaceObjectOnGroundProperly(prop)
			FreezeEntityPosition(prop,true)
			RSGCore.Functions.Notify('explosives set, stand well back', 'primary')
			Wait(10000)
			AddExplosion(2643.88, -1300.54, 52.25, 25 , 5000.0 ,true , false , 27)
			DeleteObject(prop)
			Citizen.InvokeNative(0x6BAB9442830C7F53, 1751238140, 0)
			TriggerEvent('rsg-stdenisbankheist:client:policenpc')
			local alertcoords = GetEntityCoords(PlayerPedId())
			TriggerServerEvent('police:server:policeAlert', 'St Denis Bank is being robbed')
		else
			RSGCore.Functions.Notify('you need dynamite to do that', 'error')
		end
	else
		RSGCore.Functions.Notify('you can\'t do that right now', 'error')
	end
end)

------------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
	exports['rsg-core']:createPrompt('stdvault1', vector3(2644.46, -1306.59, 52.25), 0xF3830D8E, 'Loot Vault', {
		type = 'client',
		event = 'rsg-stdenisbankheist:client:checkstdvault1',
		args = {},
	})
end)

local isLootingstdVault1 = false
local stdvault1Cooldown = 0

RegisterNetEvent('rsg-stdenisbankheist:client:checkstdvault1')
AddEventHandler('rsg-stdenisbankheist:client:checkstdvault1', function()
    local player = PlayerPedId()
    SetCurrentPedWeapon(player, `WEAPON_UNARMED`, true)
    if robberystarted == true and stdvault1 == false then
        if not isLootingstdVault1 and stdvault1Cooldown == 0 then
            isLootingstdVault1 = true
            local animDict = "script_ca@cachr@ig@ig4_vaultloot"
            local anim = "ig13_14_grab_money_front01_player_zero"
            RequestAnimDict(animDict)
            while (not HasAnimDictLoaded(animDict)) do
                Wait(100)
            end
			RSGCore.Functions.Notify('Started Looting', 'primary')
            TaskPlayAnim(player, animDict, anim, 8.0, -8.0, 25000, 1, 0, true, 0, false, 0, false)
            Wait(25000)
            ClearPedTasks(player)
            SetCurrentPedWeapon(player, `WEAPON_UNARMED`, true)
            TriggerServerEvent('rsg-stdenisbankheist:server:reward')
            stdvault1 = true
            isLootingstdVault1 = false
            stdvault1Cooldown = 240 -- Set a 4 hour cooldown (240 minutes)
        else
            RSGCore.Functions.Notify('You must wait before looting this vault again', 'error')
        end
    else
        RSGCore.Functions.Notify('Vault not lootable', 'error')
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Check every minute
        if stdvault1Cooldown > 0 then
            stdvault1Cooldown = stdvault1Cooldown - 1
        end
    end
end)

------------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
	exports['rsg-core']:createPrompt('stdvault2', vector3(2640.99, -1302.19, 52.25), 0xF3830D8E, 'Loot Vault', {
		type = 'client',
		event = 'rsg-stdenisbankheist:client:checkstdvault2',
		args = {},
	})
end)

local isLootingstdVault2 = false
local stdvault2Cooldown = 0

RegisterNetEvent('rsg-stdenisbankheist:client:checkstdvault2')
AddEventHandler('rsg-stdenisbankheist:client:checkstdvault2', function()
    local player = PlayerPedId()
    SetCurrentPedWeapon(player, `WEAPON_UNARMED`, true)
    if robberystarted == true and stdvault2 == false then
        if not isLootingstdVault2 and stdvault2Cooldown == 0 then
            isLootingstdVault2 = true
            local animDict = "script_ca@cachr@ig@ig4_vaultloot"
            local anim = "ig13_14_grab_money_front01_player_zero"
            RequestAnimDict(animDict)
            while (not HasAnimDictLoaded(animDict)) do
                Wait(100)
            end
			RSGCore.Functions.Notify('Started Looting', 'primary')
            TaskPlayAnim(player, animDict, anim, 8.0, -8.0, 25000, 1, 0, true, 0, false, 0, false)
            Wait(25000)
            ClearPedTasks(player)
            SetCurrentPedWeapon(player, `WEAPON_UNARMED`, true)
            TriggerServerEvent('rsg-stdenisbankheist:server:reward')
            stdvault2 = true
            isLootingstdVault2 = false
            stdvault2Cooldown = 240 -- Set a 4 hour cooldown (240 minutes)
        else
            RSGCore.Functions.Notify('You must wait before looting this vault again', 'error')
        end
    else
        RSGCore.Functions.Notify('Vault not lootable', 'error')
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Check every minute
        if stdvault2Cooldown > 0 then
            stdvault2Cooldown = stdvault2Cooldown - 1
        end
    end
end)

------------------------------------------------------------------------------------------------------------------------

function modelrequest( model )
    Citizen.CreateThread(function()
        RequestModel( model )
    end)
end

-- start mission npcs
RegisterNetEvent('rsg-stdenisbankheist:client:policenpc')
AddEventHandler('rsg-stdenisbankheist:client:policenpc', function()
	for z, x in pairs(Config.HeistNpcs) do
	while not HasModelLoaded( GetHashKey(Config.HeistNpcs[z]["Model"]) ) do
		Wait(500)
		modelrequest( GetHashKey(Config.HeistNpcs[z]["Model"]) )
	end
	local npc = CreatePed(GetHashKey(Config.HeistNpcs[z]["Model"]), Config.HeistNpcs[z]["Pos"].x, Config.HeistNpcs[z]["Pos"].y, Config.HeistNpcs[z]["Pos"].z, Config.HeistNpcs[z]["Heading"], true, false, 0, 0)
	while not DoesEntityExist(npc) do
		Wait(300)
	end
	if not NetworkGetEntityIsNetworked(npc) then
		NetworkRegisterEntityAsNetworked(npc)
	end
	Citizen.InvokeNative(0x283978A15512B2FE, npc, true) -- SetRandomOutfitVariation
	GiveWeaponToPed_2(npc, 0x64356159, 500, true, 1, false, 0.0)
	TaskCombatPed(npc, PlayerPedId())
	end
end)

------------------------------------------------------------------------------------------------------------------------

-- bank lockdown timer
function handleLockdown()
    lockdownSecondsRemaining = Config.BankLockdown
    Citizen.CreateThread(function()
        while lockdownSecondsRemaining > 0 do
            Wait(1000)
            lockdownSecondsRemaining = lockdownSecondsRemaining - 1
        end
    end)
end

-- bank lockdown and reset after cooldown
Citizen.CreateThread(function()
	while true do
		Wait(1000)
		if robberystarted == true and lockdownactive == true then
			exports['rsg-core']:DrawText('Bank Lockdown in '..lockdownSecondsRemaining..' seconds!', 'left')
		end
		if lockdownSecondsRemaining == 0 and robberystarted == true and lockdownactive == true then
			-- lock doors
			for k,v in pairs(Config.VaultDoors) do
				Citizen.InvokeNative(0xD99229FE93B46286,v,1,1,0,0,0,0)
				Citizen.InvokeNative(0x6BAB9442830C7F53,v,1)
			end
			-- disable vault looting / trigger cooldown
			stdvault1 = true
			stdvault2 = true
			exports['rsg-core']:HideText()
			lockdownactive = false
			handleCooldown()
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------

-- cooldown timer
function handleCooldown()
    cooldownSecondsRemaining = Config.BankCooldown
    Citizen.CreateThread(function()
        while cooldownSecondsRemaining > 0 do
            Wait(1000)
            cooldownSecondsRemaining = cooldownSecondsRemaining - 1
        end
    end)
end

-- reset bank so it can be robbed again
Citizen.CreateThread(function()
	while true do
		Wait(1000)
		if lockdownactive == false and cooldownSecondsRemaining == 0 and robberystarted == true then
			-- confirm doors are locked
			for k,v in pairs(Config.VaultDoors) do
				Citizen.InvokeNative(0xD99229FE93B46286,v,1,1,0,0,0,0)
				Citizen.InvokeNative(0x6BAB9442830C7F53,v,1)
			end
			-- reset bank robbery
			robberystarted = false
			lockpicked = false
			dynamiteused = false
			stdvault1 = false
			stdvault2 = false
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------

function DrawText3Ds(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(9)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
end

------------------------------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
	exports['rsg-core']:createPrompt('stdenislock', vector3(2644.9, -1293.98, 52.25 -0.8), RSGCore.Shared.Keybinds['J'], 'Emergency Menu', {
		type = 'client',
		event = 'rsg-stdenisbankheist:client:bankmenu',
		args = {},
	})
end)

-- emergency menu
RegisterNetEvent('rsg-stdenisbankheist:client:bankmenu', function()
    exports['rsg-menu']:openMenu({
        {
            header = 'Emergency Menu',
            isMenuHeader = true,
        },
        {
            header = "Lock Bank",
            txt = "used by law enforcement to lock bank in an emergency",
			icon = "fas fa-lock",
            params = {
                event = 'rsg-stdenisbankheist:client:policelock',
				isServer = false,
            }
        },
        {
            header = "Unlock Bank",
            txt = "used by law enforcement to unlock bank in an emergency",
			icon = "fas fa-lock-open",
            params = {
                event = 'rsg-stdenisbankheist:client:policeunlock',
				isServer = false,
            }
        },
        {
            header = "Close Menu",
            txt = '',
            params = {
                event = 'rsg-menu:closeMenu',
            }
        },
    })
end)

RegisterNetEvent('rsg-stdenisbankheist:client:policelock', function()
    RSGCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.job.name == "police" then
			-- lock doors
			for k,v in pairs(Config.VaultDoors) do
				Citizen.InvokeNative(0x6BAB9442830C7F53,v,1)
			end
			RSGCore.Functions.Notify('emergency doors locked', 'success')
        else
			RSGCore.Functions.Notify('law enforcement only', 'error')
		end
    end)
end)

RegisterNetEvent('rsg-stdenisbankheist:client:policeunlock', function()
    RSGCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.job.name == "police" then
			-- lock doors
			for k,v in pairs(Config.VaultDoors) do
				Citizen.InvokeNative(0x6BAB9442830C7F53,v,0)
			end
			RSGCore.Functions.Notify('emergency doors unlocked', 'success')
        else
			RSGCore.Functions.Notify('law enforcement only', 'error')
		end
    end)
end)

------------------------------------------------------------------------------------------------------------------------
