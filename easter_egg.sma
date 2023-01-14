#pragma semicolon 1

#include <amxmodx>
#include <reapi>
#include <engine>
#include <fvault>

new const NAME[] = "Easter Egg";
new const VERSION[] = "1.0";
new const AUTHOR[] = "KoRrNiK";
new const URL_AUTHOR[] = "https://github.com/KoRrNiK/";
new const F_VAULTFILE[] = "f_easter_egg";

//#define LOAD_METOD

enum _:MODEL_ENUM { 
	EGG_MODEL, 
	EGG_CLASS
};
new const model_info[MODEL_ENUM][] = {
	"models/egg.mdl",
	"egg"
};

enum _:TOP_ENUM { 
	TOP_DATA[750], 
	TOP_NAME[450], 
};
new data[TOP_ENUM];
#if defined LOAD_METOD
	new motd_data[MAX_MOTD_LENGTH];
#endif 

enum _:CVAR_ENUM {
	cvar_percent_drop,
	cvar_speed_drop,
	Float:cvar_distance_pickup,

};
new egg_cvar[CVAR_ENUM];

enum _:DATA_ENUM {
	PLAYER_NAME[33],
	bool:PLAYER_LOADED,
	PLAYER_EGGS,
};
new player_info[33][DATA_ENUM];

public plugin_precache()
	precache_model(model_info[EGG_MODEL]);

public plugin_init() {
	
	register_plugin(NAME, VERSION, AUTHOR, URL_AUTHOR);
	
	#if defined LOAD_METOD
		register_clcmd("say /top10jajek", "show_top");
		create_top_eggs();
		log_amx("LOAD TOP EGGS [SERVER]");
	#else 
		register_clcmd("say /top10jajek", "create_top_eggs");
		log_amx("LOAD TOP EGGS [CLIENT]");
	#endif
	
	RegisterHookChain(RG_CBasePlayer_Killed, "CBasePlayer_Killed", 0);
	register_logevent("round_start", 2, "1=Round_Start");
	
	bind_pcvar_num(create_cvar("amxx4u_egg_drop_percent", "100"), egg_cvar[cvar_percent_drop]);
	bind_pcvar_num(create_cvar("amxx4u_egg_speed_remove", "3"), egg_cvar[cvar_speed_drop]);
	bind_pcvar_float(create_cvar("amxx4u_egg_distance_pickup", "40.0"), egg_cvar[cvar_distance_pickup]);
	

	
}

public client_disconnected(id)
	save_data(id);

public client_connect(id){
	get_user_name(id, player_info[id][PLAYER_NAME], charsmax(player_info[][PLAYER_NAME]));
	
	player_info[id][PLAYER_EGGS] = 0;
	player_info[id][PLAYER_LOADED] = false;
	
	load_data(id);
}

public round_start()
	remove_all_entity(model_info[EGG_CLASS]);

public CBasePlayer_Killed(victim, attacker){
	
	if( victim == attacker || attacker == 0 || victim == 0 ) return;
	
	if( attacker != victim ){
		if(random(100) < egg_cvar[cvar_percent_drop]) 
			create_egg(victim);
	}
}

public create_egg(id){
	
	new Float:fOrigin[3];
	get_entvar(id, var_origin, fOrigin);
	
	new ent = rg_create_entity("info_target");
	
	set_entvar(ent, var_classname, model_info[EGG_CLASS]);
	set_entvar(ent, var_movetype, MOVETYPE_TOSS);
	set_entvar(ent, var_solid, SOLID_SLIDEBOX);
	entity_set_model(ent, model_info[EGG_MODEL]);
	set_entvar(ent, var_iuser1, 255);
	set_rendering(ent, kRenderFxGlowShell, 0,0,0, kRenderTransAlpha, get_entvar(ent, var_iuser1));
	set_entvar(ent, var_origin, fOrigin);
	drop_to_floor(ent);
	
	set_task(0.1, "think_egg", ent);	
}

public think_egg(ent){
	
	if( !is_entity(ent) || ent == 0 ) return PLUGIN_CONTINUE;

	new Float:fOrigin[3], Float:fOriginTarget[3];	
	get_entvar(ent, var_origin, fOrigin);

	for( new i = 1; i <= MAX_PLAYERS; i ++ ){
		
		if(!is_user_connected(i) || !is_user_alive(i)) continue;
				
		get_entvar(i, var_origin, fOriginTarget);
			
		if(get_distance_f(fOriginTarget, fOrigin) >= egg_cvar[cvar_distance_pickup]) continue;
		
		player_info[i][PLAYER_EGGS] ++;
		
		client_print_color(i, i, "^4[JAJKA]^1 Brawo podniosles jajko!^4 |^1 Sprawdz teraz ktory jestes^3 /top10jajek");
		remove_entity(ent);
		
		return PLUGIN_HANDLED_MAIN;	
	}
	
	new alpha = get_entvar(ent, var_iuser1);
	set_entvar(ent, var_iuser1, alpha - egg_cvar[cvar_speed_drop]);
	set_rendering(ent, kRenderFxGlowShell, 0,0,0, kRenderTransAlpha, alpha);
	
	if(!alpha) remove_entity(ent);
	else set_task(0.1, "think_egg", ent);
	
	return PLUGIN_CONTINUE;
}

public save_data(id){
		
	if(!player_info[id][PLAYER_LOADED]) return;
	
	new data_vault[64];
	format(data_vault, charsmax(data_vault), "%d", player_info[id][PLAYER_EGGS]);
	fvault_set_data(F_VAULTFILE, player_info[id][PLAYER_NAME], data_vault);
	
}

public load_data(id){
	
	new data_vault[64];
	
	if( fvault_get_data(F_VAULTFILE, player_info[id][PLAYER_NAME], data_vault, charsmax(data_vault)) ){
		new eggs_parse[7];
		parse(data_vault, eggs_parse, sizeof(eggs_parse));
		player_info[id][PLAYER_EGGS] = str_to_num(eggs_parse);
	}else{
		player_info[id][PLAYER_EGGS] = 0;
	}
	
	player_info[id][PLAYER_LOADED] = true;
	
}

#if defined LOAD_METOD

public show_top(id)
	show_motd(id, motd_data, "Top 10 Zebranych Jajek!");

public create_top_eggs(){
#else 
public create_top_eggs(id){
#endif
	static motd_len;
	
	#if !defined LOAD_METOD
		static motd_data[MAX_MOTD_LENGTH];
	#endif
    
	new Array:keys = ArrayCreate(450);
	new Array:datas = ArrayCreate(750);
	new Array:all = ArrayCreate(TOP_ENUM);
	
	fvault_load(F_VAULTFILE, keys, datas);
	
	new array_size = ArraySize(keys);
			
	for( new i = 0; i < array_size; i++ ){
		ArrayGetString(keys, i, data[TOP_NAME], charsmax(data[TOP_NAME]));
		ArrayGetString(datas, i, data[TOP_DATA], charsmax(data[TOP_DATA]));
		ArrayPushArray(all, data); 	
	}
	
	ArraySort(all, "sort_data");
	
	new size = clamp(array_size, 0, 10);
	
	static player_name[MAX_NAME_LENGTH]; 
	
	motd_len = 0;
	motd_len = format(motd_data[motd_len], charsmax(motd_data) - motd_len, "<body><meta charset='UTF-8'><link rel='stylesheet' href='https://amxx4u.pl/server/top-eggs.css'>");
	
	motd_len += format(motd_data[motd_len], charsmax(motd_data) - motd_len, "<div><p>Top 10 Jajek!</p><table>");
	motd_len += format(motd_data[motd_len], charsmax(motd_data) - motd_len, "<tr><td><b>#</b></td><td><b>Nazwa</b></td><td><b>Jajka</b></td></tr>");
	
	for(new j = 0; j < size; j++ ) { 
	
		ArrayGetArray(all, j, data);	 
		fvault_get_data(F_VAULTFILE, data[TOP_NAME], player_name, charsmax(player_name)); 
		
		if(j+1 == 1) motd_len += format(motd_data[motd_len], charsmax(motd_data) - motd_len, "<tr><td id='f'>%d</td><td id='f'>%s</td><td id='f'>%s</td></tr>", j + 1, data[TOP_NAME], data[TOP_DATA]);
		else if(j+1 == 2) motd_len += format(motd_data[motd_len], charsmax(motd_data) - motd_len, "<tr><td id='s'>%d</td><td id='s'>%s</td><td id='s'>%s</td></tr>", j + 1, data[TOP_NAME], data[TOP_DATA]);
		else if(j+1 == 3) motd_len += format(motd_data[motd_len], charsmax(motd_data) - motd_len, "<tr><td id='t'>%d</td><td id='t'>%s</td><td id='t'>%s</td></tr>", j + 1, data[TOP_NAME], data[TOP_DATA]);
		else motd_len += format(motd_data[motd_len], charsmax(motd_data) - motd_len, "<tr><td>%d</td><td>%s</td><td>%s</td></tr>", j + 1, data[TOP_NAME], data[TOP_DATA]);
		
	} 
	
	motd_len += format(motd_data[motd_len], charsmax(motd_data) - motd_len, "</table></div></body>");
	
	#if !defined LOAD_METOD
		show_motd(id, motd_data, "Top 10 Zebranych Jajek!");
	#endif	
} 

public sort_data( Array:array, item_1, item_2, data[], data_size ) {
	 
    new data_1[TOP_ENUM], data_2[TOP_ENUM];
    ArrayGetArray(array, item_1, data_1);
    ArrayGetArray(array, item_2, data_2);
     
    new points_1[7], points_2[7];
    parse(data_1[TOP_DATA], points_1, charsmax(points_1));
    parse(data_2[TOP_DATA], points_2, charsmax(points_2));
     
    new count_1 = str_to_num(points_1);
    new count_2 = str_to_num(points_2);
     
    return (count_1 > count_2) ? -1 : ((count_1 < count_2) ? 1 : 0); 
}

public remove_all_entity(const class_name[]){
	new ent = -1;
	while ((ent = find_ent_by_class(ent, class_name))){
		if (is_entity(ent)) remove_entity(ent);
	}
}