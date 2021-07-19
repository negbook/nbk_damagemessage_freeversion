
RegisterServerEvent("nbk_damagemessage:SyncEntityDamage")
AddEventHandler('nbk_damagemessage:SyncEntityDamage',function(nowhp,oldhp,bonehash) --victim,attacker,victimDied,weaponHash,isMeleeDamage,vehicleDamageTypeFlag

        TriggerClientEvent('nbk_damagemessage:OnEntityHealthChange',-1,source,nowhp,oldhp,bonehash)

   
end )