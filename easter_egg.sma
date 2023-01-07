#include <amxmodx>
#include <reapi>
#include <engine>
#include <fvault>

enum _:eInfoPlugin { PLUGIN, VERSION, AUTHOR, URL, DESCRIPTION };
new const PLUGIN_INFO[eInfoPlugin][] = {
	"Easter Egg",
	"1.0",
	"KoRrNiK",
	"https://github.com/KoRrNiK/",
	"Easter eggs drop for kills"
};

enum _:eModelInfo { EGG_MODEL, EGG_CLASS }
new const modelInfo[eModelInfo][] = {
	"models/egg.mdl",
	"egg"
}

new const fVAULTFILE[] = "f_easter_egg";

enum _:FvaultData { 
	top_DATA[750], 
	top_NAME[450], 
} 

new userEggs[33];
new userName[33][33];
new bool:userLoaded[33];

enum _:allCvars {
	cvarPercentDrop,
	cvarSpeedDrop,
	Float:cvarDistancePickup

}
new eggCvar[allCvars]

public plugin_precache(){
	
	precache_model(modelInfo[EGG_MODEL]);
	
}

public plugin_init() {
	
	register_plugin(
		.plugin_name = PLUGIN_INFO[PLUGIN],
		.version = PLUGIN_INFO[VERSION],
		.author = PLUGIN_INFO[AUTHOR],
		.url = PLUGIN_INFO[URL],
		.description = PLUGIN_INFO[DESCRIPTION]
		
	);
	
	register_clcmd( "say /top10jajek", "cmdTop10" );

	RegisterHookChain(RG_CBasePlayer_Killed, "CBasePlayer_Killed", false);
	
	register_logevent("round_start", 2, "1=Round_Start");
	
	bind_pcvar_num(create_cvar("amxx4u_egg_drop_percent", "100"), eggCvar[cvarPercentDrop]);
	bind_pcvar_num(create_cvar("amxx4u_egg_speed_remove", "3"), eggCvar[cvarSpeedDrop]);
	bind_pcvar_float(create_cvar("amxx4u_egg_distance_pickup", "40.0"), eggCvar[cvarDistancePickup]);
	
}

public client_disconnected(id){
	saveData(id);
}

public client_connect(id){
	get_user_name(id, userName[id], sizeof(userName[]) - 1);
	
	userEggs[id] = 0;
	userLoaded[id] = false;
	
	loadData(id);
}

public round_start(){
	removeAllEntity(modelInfo[EGG_CLASS]);
}


public CBasePlayer_Killed(victim, attacker){
	
	
	if( victim == attacker || attacker == 0 || victim == 0 ) return
	
	if( attacker != victim ) if(random(100) > eggCvar[cvarPercentDrop]) createEgg(victim);
	
}

public createEgg(id){
	
	new Float:fOrigin[3];
	
	get_entvar(id, var_origin, fOrigin);
	
	new ent = rg_create_entity("info_target");
	
	set_entvar(ent, var_classname, modelInfo[EGG_CLASS]);
	
	set_entvar(ent, var_movetype, MOVETYPE_TOSS);
	set_entvar(ent, var_solid, SOLID_SLIDEBOX);
	
	entity_set_model(ent, modelInfo[EGG_MODEL]);
	
	set_entvar(ent, var_iuser1, 255);

	set_rendering(ent, kRenderFxGlowShell, 0,0,0, kRenderTransAlpha, get_entvar(ent, var_iuser1));
	
	set_entvar(ent, var_origin, fOrigin);
	
	drop_to_floor(ent);
	
	set_task(0.1, "eggThink", ent);	
	
}

public eggThink(ent){
	
	if( !is_valid_ent(ent) || ent == 0 ) return PLUGIN_CONTINUE;

	new Float:fOrigin[3], Float:fOriginTarget[3];	
	
	get_entvar(ent, var_origin, fOrigin);

	for( new i = 1; i <= MAX_PLAYERS; i ++ ){
		
		if( !is_user_connected(i)) continue;
		if( !is_user_alive(i)) continue;
				
		get_entvar(i, var_origin, fOriginTarget);
			
		if( get_distance_f(fOriginTarget, fOrigin) >= eggCvar[cvarDistancePickup]) continue;
		
		client_print_color(i, i, "^4[JAJKA]^1 Brawo podniosles jajko!^4 |^1 Sprawdz teraz ktory jestes^3 /top15jajka");
		userEggs[i] ++;
		remove_entity(ent);
		
		return PLUGIN_HANDLED_MAIN;	
	}
	
	new alpha = get_entvar(ent, var_iuser1);
	
	set_entvar(ent, var_iuser1, alpha - eggCvar[cvarSpeedDrop]);
	
	set_rendering(ent, kRenderFxGlowShell, 0,0,0, kRenderTransAlpha, alpha);
	
	if(!alpha) remove_entity(ent);
	else set_task(0.1, "eggThink", ent);
	
	return PLUGIN_CONTINUE;
}

public saveData(id){
		
	if(!userLoaded[id]) return;
	
	new szData[512];
	format(szData, sizeof(szData)-1,"%d", 
		userEggs[id]
	);
	fvault_set_data(fVAULTFILE, userName[id], szData);
	
}

public loadData(id){
	
	new szData[512];
	
	if( fvault_get_data(fVAULTFILE, userName[id], szData, sizeof(szData) - 1) ){
		new szEggs[7];
		parse(szData,
			szEggs,	sizeof(szEggs)
		);
		userEggs[id]	=	str_to_num(szEggs);
	}else{
		userEggs[id]	=	0;
	}
	
	userLoaded[id] = true;
	
}

public cmdTop10(id){
	
	static iLen, gText[MAX_MOTD_LENGTH];
    
	new Array:keys = ArrayCreate(450);
	new Array:datas = ArrayCreate(750);
	new Array:all = ArrayCreate(FvaultData) 
	
	fvault_load(fVAULTFILE, keys, datas);
	
	new arraySize = ArraySize( keys ) 
	
	new data[FvaultData];
			
	for( new i = 0; i < arraySize; i++ ){

		ArrayGetString(keys, i, data[top_NAME], sizeof(data[top_NAME]) - 1);
		ArrayGetString(datas, i, data[top_DATA], sizeof(data[top_DATA]) - 1);
		ArrayPushArray(all, data ) 	
		
	}
	ArraySort(all, "SortData" ) 
	
	new size = clamp(arraySize, 0, 10 ) 
	
	new szName[MAX_NAME_LENGTH] 
	
	iLen = 0;
	iLen = format(gText[iLen], sizeof(gText)-iLen-1, "<body><meta charset='UTF-8'><link rel='stylesheet' href='https://amxx4u.pl/server/top-eggs.css'>");
	
	iLen += format(gText[iLen], sizeof(gText)-iLen-1, "<div>");
	iLen += format(gText[iLen], sizeof(gText)-iLen-1, "<p>Top 10 Jajek!</p>");
	iLen += format(gText[iLen], sizeof(gText)-iLen-1, "<table>");	
	iLen += format(gText[iLen], sizeof(gText)-iLen-1, "<tr><td><b>#</b></td><td><b>Nazwa</b></td><td><b>Jajka</b></td></tr>");
	
	for(new j = 0; j < size; j++ ) { 
	
		ArrayGetArray(all, j, data ) 	 
		fvault_get_data(fVAULTFILE, data[top_NAME], szName, sizeof(szName) - 1 ) 
		
		if(j+1 == 1) iLen += format(gText[iLen], sizeof(gText) - 1 - iLen, "<tr><td id='f'>%d</td><td id='f'>%s</td><td id='f'>%s</td></tr>", j + 1, data[top_NAME], data[top_DATA]);
		else if(j+1 == 2) iLen += format(gText[iLen], sizeof(gText) - 1 - iLen, "<tr><td id='s'>%d</td><td id='s'>%s</td><td id='s'>%s</td></tr>", j + 1, data[top_NAME], data[top_DATA]);
		else if(j+1 == 3) iLen += format(gText[iLen], sizeof(gText) - 1 - iLen, "<tr><td id='t'>%d</td><td id='t'>%s</td><td id='t'>%s</td></tr>", j + 1, data[top_NAME], data[top_DATA]);
		else iLen += format(gText[iLen], sizeof(gText) - 1 - iLen, "<tr><td>%d</td><td>%s</td><td>%s</td></tr>", j + 1, data[top_NAME], data[top_DATA]);
		
	} 
	
	iLen += format(gText[iLen], sizeof(gText)-iLen-1, "</table>");
	iLen += format(gText[iLen], sizeof(gText)-iLen-1, "</div>");
	iLen += format(gText[iLen], sizeof(gText)-iLen-1, "</body>");
	
	show_motd(id, gText, "Top 10 Zebranych Jajek!");

} 

public SortData( Array:aArray, iItem1, iItem2, iData[ ], iDataSize ) {
	 
    new Data1[FvaultData];
    new Data2[FvaultData];
     
    ArrayGetArray(aArray, iItem1, Data1) 
    ArrayGetArray(aArray, iItem2, Data2) 
     
    new szPoints_1[ 7 ] 
    parse(Data1[top_DATA], szPoints_1, sizeof(szPoints_1) - 1) 
     
    new szPoints_2[ 7 ] 
    parse(Data2[top_DATA], szPoints_2, sizeof(szPoints_2) - 1) 
     
    new iCount1 = str_to_num( szPoints_1 ) 
    new iCount2 = str_to_num( szPoints_2 ) 
     
    return ( iCount1 > iCount2 ) ? -1 : ( ( iCount1 < iCount2 ) ? 1 : 0 ) 
} 

public removeAllEntity(const nameClass[]){
	new ent = -1;
	while ((ent = find_ent_by_class(ent, nameClass))){
		if (is_valid_ent(ent)) remove_entity(ent);
	}
}