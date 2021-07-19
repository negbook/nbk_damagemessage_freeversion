DrawText2D = function(text,scale,x,y,a)
    
	SetTextScale(scale/24, scale/24)
	SetTextFont(0)
	SetTextColour(255, 0, 0, a)
	--SetTextDropshadow(0, 0, 0, 0, 255)
	--SetTextDropShadow()
	--SetTextOutline()
	SetTextCentre(true)

	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x, y)
	ClearDrawOrigin()
end

DrawText2DTweenUp = function(text,scale,x,y,moveheight,speed)
    CreateThread(function()
        local height = y
        local total_ = height - (y-moveheight) 
        local total = height - (y-moveheight) 
        
        while height > y-moveheight do 
            DrawText2D(text,scale,x,height,math.floor(255* (total/total_)))
            height = height - 0.003*speed
            total = total - 0.003*speed
            Wait(0)
        end 
    end)
end 
OnEntityHealthChange = function(victim,newhp,oldhp,bonehash)
    local datas = {}
    local isDead = (IsEntityDead(victim) or IsPedDeadOrDying(victim) or newhp == 0)
    local value = newhp-oldhp
    local coords =  bonehash and GetPedBoneCoords(
		victim --[[ Ped ]], 
		bonehash --[[ integer ]], 
		0.0 --[[ number ]], 
		0.0 --[[ number ]], 
		0.0 --[[ number ]]
	) or GetEntityCoords(victim)
    local camCoords = GetGameplayCamCoords()
    local distance = #(coords - camCoords)

    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    if scale < 0.2 then scale = 0.2 end 
    if bonehash == 31086 then 
        datas.headshot = true 
        coords = vector3(coords.x,coords.y,coords.z+1.0)
        
        damagemessage(coords,"HEADSHOT!",12*scale+10)

    end 
    local k = 8 + math.floor((-(value))/GetEntityMaxHealth(victim)*200)
    local size = isDead and 120*scale or (k)*scale
    if k > 44 then 
    damagemessage(coords,isDead and "死" or ""..tostring(value).."",size )
    else 
    damagemessage(coords,isDead and "死" or ""..tostring(value).."",size )
    end 

end
RegisterNetEvent('nbk_damagemessage:OnEntityHealthChange')
AddEventHandler('nbk_damagemessage:OnEntityHealthChange',function(victimServerid,newhp,oldhp,bonehash)
    local player = GetPlayerFromServerId(victimServerid)
    if player ~= -1 then 
        local victim = GetPlayerPed(GetPlayerFromServerId(victimServerid))
        OnEntityHealthChange(victim,newhp,oldhp,bonehash)
    end 
end)

damagemessage = function(coords, dmg, size)
    local bool,xper2,yper2 = GetScreenCoordFromWorldCoord(coords.x,coords.y,coords.z)
    if bool then 
        DrawText2DTweenUp(dmg,size,xper2,yper2,0.1,0.5)
    end 
end
