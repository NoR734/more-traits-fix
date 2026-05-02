local function getPlayers()
    local online = getOnlinePlayers and getOnlinePlayers() or nil
    if not online then return {} end
    local players = {}
    for i = 0, online:size() - 1 do
        players[#players + 1] = online:get(i)
    end
    return players
end

local function evaluateLevelTraits(player)
    if not player or player:isDead() then return end
    local vars = SandboxVars and SandboxVars.MoreTraitsDynamic or nil
    if not vars then return end

    if vars.PackMouseDynamic == true
        and player:HasTrait("packmouse")
        and player:getPerkLevel(Perks.Strength) >= vars.PackMouseDynamicSkill then
        player:getTraits():remove("packmouse")
    end

    if vars.PackMuleDynamic == true
        and not player:HasTrait("packmule")
        and player:getPerkLevel(Perks.Strength) >= vars.PackMuleDynamicSkill then
        player:getTraits():add("packmule")
    end

    if vars.HardyDynamic == true
        and not player:HasTrait("hardy")
        and player:getPerkLevel(Perks.Fitness) >= vars.HardyDynamicSkill then
        player:getTraits():add("hardy")
    end
end

local function ProcessTraitChange(player, trait, isAddition)
    if not trait then return end
    local traits = player:getCharacterTraits()
    local exactTrait = ToadTraitsRegistries[trait]

    if isAddition then
        traits:add(exactTrait)
    else
        traits:remove(exactTrait)
    end
end

local function ProcessXPBoosts(player, perk, boostAmount)
    if not perk and not boostAmount then return end
    player:getXp():setPerkBoost(perk, boostAmount)
end

local function onClientCommands(module, command, player, args)
    if module ~= 'MoreTraitsDynamic' then return end
    if command == 'addTrait' then
        ProcessTraitChange(player, args.trait, true)
    elseif command == 'removeTrait' then
        ProcessTraitChange(player, args.trait, false)
    end

    if command == 'setXpBoosts' then
        ProcessXPBoosts(player, args.perk, args.boostAmount)
    end
end

local function onMinute()
    for _, player in ipairs(getPlayers()) do
        evaluateLevelTraits(player)
    end
end

local function onLevelPerk(player, perk)
    if perk == Perks.Strength or perk == Perks.Fitness then
        evaluateLevelTraits(player)
    end
end

Events.OnClientCommand.Add(onClientCommands)
Events.EveryOneMinute.Add(onMinute)
Events.LevelPerk.Add(onLevelPerk)
