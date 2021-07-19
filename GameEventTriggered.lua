local ThisIsUtilForLocalScript = true
local decor = {} 

function LocalDecorExistOn(ped,proper)
    return decor and decor[ped] and decor[ped][proper] and true or false
end 
function LocalDecorSetInt(ped,proper,value)
    if not decor[ped] then decor[ped] = {} end 
    decor[ped][proper] = value 
end 
function LocalDecorGetInt(ped,proper)
    if not decor[ped] then decor[ped] = {} end 
    return decor[ped] and decor[ped][proper] 
end 
AddEventHandler('gameEventTriggered',function(name,args)
   GameEventTriggered(name,args)
end)



CreateThread(function()
    while true do 
        local PPed = PlayerPedId()
        if not LocalDecorExistOn(PPed,"lasthp") then 
            LocalDecorSetInt(PPed,"lasthp",GetEntityHealth(PPed, false))
        end 
        if not LocalDecorExistOn(PPed,"lastarmour") then 
            LocalDecorSetInt(PPed,"lastarmour",GetPedArmour(PPed, false))
        end 
        Wait(0)
    end 
end )

function GameEventTriggered(eventName, data)
    if eventName == "CEventNetworkEntityDamage" then
        victim = tonumber(data[1])
        attacker = tonumber(data[2])
        victimDied = tonumber(data[4]) == 1 and true or false 
        weaponHash = tonumber(data[5])
        isMeleeDamage = tonumber(data[10]) ~= 0 and true or false 
        vehicleDamageTypeFlag = tonumber(data[11]) 
        local FoundLastDamagedBone, LastDamagedBone = GetPedLastDamageBone(victim)
        local bonehash = nil 
        if FoundLastDamagedBone then
            bonehash = tonumber(LastDamagedBone)
        end
        local PPed = PlayerPedId()
        if victim == PPed then 
            CreateThread(function()

                while not LocalDecorExistOn(victim,"lasthp") do 
                    Wait(0)
                end 
                if LocalDecorExistOn(victim,"lasthp") then 
                    local nowhp = victimDied and 0 or GetEntityHealth(victim)
                    local oldhp = LocalDecorGetInt(victim,"lasthp")
                    if nowhp  < oldhp then
                        TriggerServerEvent("nbk_damagemessage:SyncEntityDamage",nowhp,oldhp,bonehash)
                        
                    end 
                    if victimDied then 
                        DecorRemove(victim,"lasthp")
                    else
                        LocalDecorSetInt(victim,"lasthp",nowhp)
                    end 
                end 
                
                return
            end )
            CreateThread(function()

                while not LocalDecorExistOn(victim,"lastarmour") do 
                    Wait(0)
                end 
                if LocalDecorExistOn(victim,"lastarmour") then 
                    local nowarmour = victimDied and 0 or GetPedArmour(victim)
                    local oldarmour = LocalDecorGetInt(victim,"lastarmour")
                    if nowarmour  < oldarmour then
                        TriggerServerEvent("nbk_damagemessage:SyncEntityDamage",nowarmour,oldarmour,bonehash)
                        
                    end 
                    if victimDied then 
                        DecorRemove(victim,"lastarmour")
                    else
                        LocalDecorSetInt(victim,"lastarmour",nowhp)
                    end 
                end 
                
                return
            end )
            
        elseif  not IsPedAPlayer(victim) then 
            if victim and attacker then
                if IsEntityAPed(victim) then 
                    local nowhp = victimDied and 0 or GetEntityHealth(victim)
                    
                    if not LocalDecorExistOn(victim,"lasthp") then 
                        LocalDecorSetInt(victim,"lasthp",GetEntityMaxHealth(victim))
                    end 
                    local oldhp = LocalDecorGetInt(victim,"lasthp")

                    if oldhp ~= nowhp then 
                        if nowhp and oldhp then 
                            if tonumber(nowhp) - tonumber(oldhp) < 0 then
                                --dmg = - change 
                                if OnEntityHealthChange then  
                                OnEntityHealthChange(victim,nowhp,oldhp,bonehash)
                                
                                end 
                            end
                        end 
                        LocalDecorSetInt(victim,"lasthp",nowhp)
                    end 
                    
                    local nowarmour = victimDied and 0 or GetPedArmour(victim)
                    
                    if not LocalDecorExistOn(victim,"lastarmour") then 
                        LocalDecorSetInt(victim,"lastarmour",GetEntityMaxHealth(victim))
                    end 
                    local oldarmour = LocalDecorGetInt(victim,"lastarmour")

                    if oldarmour ~= nowarmour then 
                        if nowarmour and oldarmour then 
                            if tonumber(nowarmour) - tonumber(oldarmour) < 0 then
                                --dmg = - change 
                                if OnEntityArmourChange then  
                                OnEntityArmourChange(victim,nowarmour,oldarmour,bonehash)
                                
                                end 
                            end
                        end 
                        LocalDecorSetInt(victim,"lastarmour",nowarmour)
                    end 
                end 
                if victimDied then
                    if IsEntityAVehicle(victim) then
                        if not ThisIsUtilForLocalScript then 
                            TriggerEvent("OnVehicleDestroyed", victim, attacker, weaponHash, isMeleeDamage, vehicleDamageTypeFlag)
                        elseif OnVehicleDestroyed then 
                            OnVehicleDestroyed(victim, attacker, weaponHash, isMeleeDamage, vehicleDamageTypeFlag)
                        end 
                    else

                        if IsEntityAPed(victim) then
                            if IsEntityAVehicle(attacker) then
                                if not ThisIsUtilForLocalScript then 
                                    TriggerEvent("OnPedKilledByVehicle", victim, attacker, weaponHash)
                                elseif OnPedKilledByVehicle then  
                                    OnPedKilledByVehicle(victim, attacker, weaponHash)
                                end 
                                
                            elseif IsEntityAPed(attacker)  then
                                if IsPedAPlayer(attacker) then
                                    player = NetworkGetPlayerIndexFromPed(attacker);
                                    if not ThisIsUtilForLocalScript then 
                                        TriggerEvent("OnPedKilledByPlayer", victim, player, weaponHash, isMeleeDamage)
                                    elseif OnPedKilledByPlayer then   
                                        OnPedKilledByPlayer(victim, player, weaponHash, isMeleeDamage)
                                    end 
                                else
                                    if not ThisIsUtilForLocalScript then 
                                        TriggerEvent("OnPedKilledByPed",victim, attacker, weaponHash, isMeleeDamage)
                                    elseif OnPedKilledByPed then   
                                        OnPedKilledByPed(victim, attacker, weaponHash, isMeleeDamage)
                                    end 
                                end
                            end
                            if not ThisIsUtilForLocalScript then 
                                TriggerEvent("OnPedDied", victim, attacker, weaponHash, isMeleeDamage, vehicleDamageTypeFlag)
                            elseif OnPedDied then     
                                OnPedDied(victim, attacker, weaponHash, isMeleeDamage, vehicleDamageTypeFlag)
                            end 
                        else
                            if not ThisIsUtilForLocalScript then 
                                TriggerEvent("OnEntityKilled", victim, attacker, weaponHash, isMeleeDamage, vehicleDamageTypeFlag)
                            elseif OnEntityKilled then     
                                OnEntityKilled(victim, attacker, weaponHash, isMeleeDamage, vehicleDamageTypeFlag)
                            end 
                        end
                    end
                else

                    if not IsEntityAVehicle(victim)  then
                        if not ThisIsUtilForLocalScript then 
                            TriggerEvent("OnEntityDamaged", victim, attacker, weaponHash, isMeleeDamage, vehicleDamageTypeFlag)
                        elseif OnEntityDamaged then  
                            OnEntityDamaged(victim, attacker, weaponHash, isMeleeDamage, vehicleDamageTypeFlag)
                        end 
                    else
                        if not ThisIsUtilForLocalScript then 
                            TriggerEvent("OnVehicleDamaged", victim, attacker, weaponHash, isMeleeDamage, vehicleDamageTypeFlag)
                        elseif OnVehicleDamaged then   
                            OnVehicleDamaged(victim, attacker, weaponHash, isMeleeDamage, vehicleDamageTypeFlag)
                        end 
                    end
                end
            end
        end 

        
    end
end
