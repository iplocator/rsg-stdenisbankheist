Config = {}

-- settings
Config.MinimumLawmen = 4 -- amount of lawman needed for heist
Config.BankLockdown = 170 -- amount of seconds until bank lockdown (300 = 5 mins)
Config.BankCooldown = 14400 -- amount of time in seconds until bank can be robbed again (3600 = 1hr)

-- lock bank doors
Config.VaultDoors = {
	1634115439, -- management door1 (lockpick)
	965922748, -- management door2 (lockpick)
	1751238140, -- vault door (use dynamite)
}

-- set the item rewards
Config.RewardItems = {
    'goldbar', -- example
	'goldwatch', -- example
}

-- set item rewards amount
Config.SmallRewardAmount = 2
Config.MediumRewardAmount = 4
Config.LargeRewardAmount = 6

-- set the money award gveing for large reward amount
Config.MoneyRewardType = 'bloodmoney' -- cash or bloodmoney
Config.MoneyRewardAmount = math.random(400,600) -- amount of money to give player

Config.HeistNpcs = {
	[1] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(2650.98, -1312.82, 50.36 -0.8), ["Heading"] = 323.39672 },
	[2] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(2647.22, -1310.19, 50.38 -0.8), ["Heading"] = 306.5007 },
	[3] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(2565.71, -1283.96, 49.7 -0.8), ["Heading"] = 141.41909 },
	[4] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(2565.83, -1277.5, 50.61 -0.8), ["Heading"] = 140.40957 },
	[5] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(2653.1, -1244.66, 52.45 -0.8), ["Heading"] = 65.686851 },
	[6] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(2653.1, -1244.66, 52.45 -0.8), ["Heading"] = 65.686851 },
	[7] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(2653.1, -1244.66, 52.45 -0.8), ["Heading"] = 65.686851 },
	[8] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(2653.1, -1244.66, 52.45 -0.8), ["Heading"] = 65.686851 },
	[9] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(2653.1, -1244.66, 52.45 -0.8), ["Heading"] = 65.686851 },
	[10] = { ["Model"] = "RE_POLICECHASE_MALES_01", ["Pos"] = vector3(2653.1, -1244.66, 52.45 -0.8), ["Heading"] = 65.686851 },
}

-- -1 DOORSTATE_INVALID,
-- 0 DOORSTATE_UNLOCKED,
-- 1 DOORSTATE_LOCKED_UNBREAKABLE,
-- 2 DOORSTATE_LOCKED_BREAKABLE,
-- 3 DOORSTATE_HOLD_OPEN_POSITIVE,
-- 4 DOORSTATE_HOLD_OPEN_NEGATIVE