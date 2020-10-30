/*
    Copyright (C) 2020 HirboSH.
    Permission is granted to copy, distribute and/or modify this document
    under the terms of the GNU Free Documentation License, Version 1.3
    or any later version published by the Free Software Foundation;
    with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
    A copy of the license is included in the section entitled "GNU
    Free Documentation License".
*/

#include <sourcemod>
#include <sdktools>

#define PLUGIN_NAME  "[CS:GO] Welcome System;"
#define PLUGIN_AUTHOR "HirboSH / KilleR_gamea ($uicidE)"
#define PLUGIN_DESCRIPTION "[CS:GO] Welcome System, Text + Sound;"
#define PLUGIN_VERSION "1.0.1"
#define PLUGIN_URL "https://hirbosh.cc/"
#define DEBUG

#pragma newdecls required
#pragma semicolon 1

Handle g_hWelcomeSystem[MAXPLAYERS + 1];

ConVar g_cTimeToPost;
ConVar g_cSoundEnabled;
ConVar g_cSoundPath;

char g_szPath[PLATFORM_MAX_PATH];

int g_iHostPort;

public Plugin myinfo = {
    name = PLUGIN_NAME,
    author = PLUGIN_AUTHOR,
    description = PLUGIN_DESCRIPTION,
    version = PLUGIN_VERSION,
    url = PLUGIN_URL
};

public void OnPluginStart(){
    g_cTimeToPost = CreateConVar("sm_welcomesystem_ttp", "5.0", "The Time It Takes Until The Timer Enters The Player's Login Message.");
    g_cSoundEnabled = CreateConVar("sm_welcomesystem_enable_sound", "1", "Enable Or Disable Welcome Sound", 1, true, 0.0, true, 1.0);
    g_cSoundPath = CreateConVar("sm_welcomesystem_soundpath", "", "The Location Of The Sound.");
    
    AutoExecConfig(true, "sm_welcomesystem");
    
    g_iHostPort = FindConVar("hostport").IntValue;
    
    g_cSoundPath.AddChangeHook(OnConVarChanged);
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue){
    g_cSoundPath.GetString(g_szPath, sizeof(g_szPath));
}

public void OnMapStart(){
	if (!g_cSoundEnabled.BoolValue){
		return;
	}
	
    char szBuffer[512];
    
    Format(szBuffer, sizeof(szBuffer), "%s", g_szPath);
    PrecacheSound(szBuffer);
    
    Format(szBuffer, sizeof(szBuffer), "sound/%s", g_szPath);
    AddFileToDownloadsTable(szBuffer);
}

public void OnClientPutInServer(int client){
    if (IsFakeClient(client)){
        return;
    }
    
    g_hWelcomeSystem[client] = CreateTimer(g_cTimeToPost.FloatValue, Timer_WelcomeSystem, client);
}

public Action Timer_WelcomeSystem(Handle timer, any client){
    PrintToChat(client, " \x07▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\x01");
    PrintToChat(client, " \x05Cheers Loudly! \x07%s\x05 Enters The Server\x01!", client);
    PrintToChat(client, " \x01Be Sure To \x07Observe\x01 The Server Rules.");
    PrintToChat(client, " \x01Please \x07Respect\x01 The Server Ttaff Members!");
    PrintToChat(client, " \x01Server IP: \x07%s:%d", GetServerIP(), g_iHostPort);
    PrintToChat(client, " \x07▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\x01");
    
    if (g_cSoundEnabled.BoolValue){
   	}
    EmitSoundToClient(client, g_szPath);
    
    g_hWelcomeSystem[client] = null;
}

public void OnClientDisconnect(int client){
    if (IsFakeClient(client)){
        return;
        
    } if (g_hWelcomeSystem[client] != null){
        KillTimer(g_hWelcomeSystem[client]);
        g_hWelcomeSystem[client] = null;
    }
}

stock char GetServerIP(){ //https://forums.alliedmods.net/showpost.php?p=1422849&postcount=6?p=1422849&postcount=6
	char szIP[512];
	
	int iPieces[4];
	int iIP = GetConVarInt(FindConVar("hostip"));
	
	iPieces[0] = (iIP >> 24) & 0x000000FF;
	iPieces[1] = (iIP >> 16) & 0x000000FF;
	iPieces[2] = (iIP >> 8) & 0x000000FF;
	iPieces[3] = iIP & 0x000000FF;
	
	Format(szIP, sizeof(szIP), "%d.%d.%d.%d", iPieces[0], iPieces[1], iPieces[2], iPieces[3]);
	return szIP;
}
