#pragma semicolon 1
#pragma newdecls required

static const char g_DeathSounds[][] = {
	"npc/antlion_guard/antlion_guard_die1.wav",
	"npc/antlion_guard/antlion_guard_die2.wav"
};
static const char g_HurtSounds[][] = {
	"npc/zombie_poison/pz_pain1.wav",
	"npc/zombie_poison/pz_pain2.wav",
	"npc/zombie_poison/pz_pain3.wav"
};
static const char g_MeleeAttackSounds[][] = {
	"npc/antlion/attack_single1.wav",
	"npc/antlion/attack_single2.wav",
	"npc/antlion/attack_single3.wav"
};
static const char g_SummonSounds[][] = {
	"npc/antlion_guard/angry1.wav",
	"npc/antlion_guard/angry2.wav",
	"npc/antlion_guard/angry3.wav"
};
static const char g_RandomGroupScreamSea[][] = {
	"zombiesurvival/medieval_raid/special_mutation/battlecry1.mp3",
	"zombiesurvival/medieval_raid/special_mutation/battlecry2.mp3",
	"zombiesurvival/medieval_raid/special_mutation/battlecry3.mp3",
	"zombiesurvival/medieval_raid/special_mutation/battlecry4.mp3"
};

static const char g_PullSounds[] = "weapons/physcannon/energy_sing_explosion2.wav";
static const char g_SlamSounds[] = "ambient/rottenburg/barrier_smash.wav";
static const char g_MeleeHitSounds[] = "npc/antlion_guard/shove1.wav";
static const char g_LastStand[] = "#zombiesurvival/void_wave/center_of_the_void_1.mp3";

static int i_LaserEntityIndex[MAXENTITIES]={-1, ...};
static float f_ZsSphynxCantDieLimit[MAXENTITIES];
static float f_TalkDelayCheck;
static int i_TalkDelayCheck;

#define ZsSphynx_BUFF_MAXRANGE 500.0

#define ZsSphynx_Xeno_INFECTED 555
static int NPCId;
static int NPCId2;
public void ZsSphynx_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Dummy");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_sphynx");
	strcopy(data.Icon, sizeof(data.Icon), "medic");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPCId = NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheSoundArray(g_DeathSounds);
	PrecacheSoundArray(g_HurtSounds);
	PrecacheSoundArray(g_MeleeAttackSounds);
	PrecacheSoundArray(g_SummonSounds);
	PrecacheSoundArray(g_RandomGroupScreamSea);
	PrecacheSound(g_PullSounds);
	PrecacheSound(g_SlamSounds);
	PrecacheSound(g_MeleeHitSounds);
	PrecacheSound(g_LastStand);
	PrecacheSoundCustom("#zombiesurvival/medieval_raid/kazimierz_boss.mp3");
	PrecacheSoundCustom("zombiesurvival/medieval_raid/arkantos_scream_buff.mp3");
	PrecacheModel("models/antlion_guard.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return ZsSphynx(vecPos, vecAng, team, data);
}

methodmap ZsSphynx < CClotBody
{
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		int sound = GetRandomInt(0, sizeof(g_HurtSounds) - 1);
		EmitCustomToAll(g_HurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_HurtSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(1.6, 2.5);
	}
	public void PlayDeathSound() 
	{
		int sound = GetRandomInt(0, sizeof(g_DeathSounds) - 1);

		EmitCustomToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_DeathSounds[sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeSound() 
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() 
	{
		EmitSoundToAll(g_MeleeHitSounds, this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayMeleeWarCry() 
	{
		EmitCustomToAll("zombiesurvival/medieval_raid/arkantos_scream_buff.mp3", this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitCustomToAll("zombiesurvival/medieval_raid/arkantos_scream_buff.mp3", this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitCustomToAll("zombiesurvival/medieval_raid/arkantos_scream_buff.mp3", this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 100);
		EmitCustomToAll("zombiesurvival/medieval_raid/arkantos_scream_buff.mp3", this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public void PlaySummonSound() 
	{
		EmitSoundToAll(g_SummonSounds[GetRandomInt(0, sizeof(g_SummonSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		int r = 200;
		int g = 200;
		int b = 255;
		int a = 200;
		
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 1.0, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 15.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.9, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.8, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 35.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.7, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 45.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.6, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 55.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.5, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 65.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.4, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 75.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.3, 6.0, 6.1, 1);
		spawnRing(this.index, 75.0 * 2.0, 0.0, 0.0, 85.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.2, 6.0, 6.1, 1);
	}
	public void PlayMeleeMissSound() 
	{
		EmitSoundToAll(g_DefaultMeleeMissSounds[GetRandomInt(0, sizeof(g_DefaultMeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlaySlamSound() 
	{
		EmitSoundToAll(g_SlamSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayPullSound() {
		EmitSoundToAll(g_PullSounds, this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	public void PlayRageSound() 
	{
		EmitCustomToAll(g_LastStand, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_LastStand, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_LastStand, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_LastStand, this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
	}
	
	property float m_flZsSphynxSeaInfectedStance
	{
		public get()							{ return fl_AbilityOrAttack[this.index][0]; }
		public set(float TempValueForProperty) 	{ fl_AbilityOrAttack[this.index][0] = TempValueForProperty; }
	}
	property float m_flZsSphynxBuffEffect
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	property float m_flReviveZsSphynxTime
	{
		public get()							{ return fl_GrappleCooldown[this.index]; }
		public set(float TempValueForProperty) 	{ fl_GrappleCooldown[this.index] = TempValueForProperty; }
	}

	public ZsSphynx(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		ZsSphynx npc = view_as<ZsSphynx>(CClotBody(vecPos, vecAng, "models/antlion_guard.mdl", "1.15", "25000", ally, false, false, true,true)); //giant!
		
		i_NpcWeight[npc.index] = 4;
		npc.SetActivity("ACT_RUN");
		npc.AddGesture("ACT_ANTLIONGUARD_UNBURROW");
		func_NPCFuncWin[npc.index] = view_as<Function>(Raidmode_ZsSphynx_Win);

		SetVariantInt(4);
		AcceptEntityInput(npc.index, "SetBodyGroup");
		npc.m_bDissapearOnDeath = true;

		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		RaidBossActive = EntIndexToEntRef(npc.index);
		RaidAllowsBuildings = false;
		RaidModeTime = GetGameTime(npc.index) + 200.0;
		RemoveAllDamageAddition();

		npc.m_iChanged_WalkCycle = 4;
		npc.m_flSpeed = 325.0;
	
		npc.m_flMeleeArmor = 1.25;
		
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		EmitSoundToAll("npc/zombie_poison/pz_alert1.wav", _, _, _, _, 1.0);	
		b_thisNpcIsARaid[npc.index] = true;
		
		for(int client_check=1; client_check<=MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				/*SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "ZsSphynx Arrived");*/
			}
		}

		i_RaidGrantExtra[npc.index] = 1;
		if(StrContains(data, "wave_10") != -1)
		{
			i_RaidGrantExtra[npc.index] = 2;
		}
		else if(StrContains(data, "wave_20") != -1)
		{
			i_RaidGrantExtra[npc.index] = 3;
		}
		else if(StrContains(data, "wave_30") != -1)
		{
			i_RaidGrantExtra[npc.index] = 4;
		}
		else if(StrContains(data, "wave_40") != -1)
		{
			i_RaidGrantExtra[npc.index] = 5;
		}
		if(StrContains(data, "seainfection") != -1)
		{
			b_NpcUnableToDie[npc.index] = true;
			i_RaidGrantExtra[npc.index] = ZsSphynx_Xeno_INFECTED;
		}

		bool final = StrContains(data, "final_item") != -1;
		
		if(final)
		{
			b_NpcUnableToDie[npc.index] = true;
			i_RaidGrantExtra[npc.index] = 6;
		}

		if(i_RaidGrantExtra[npc.index] >= 5)
		{
			RaidModeTime = GetGameTime(npc.index) + 300.0;
		}
		if(ally == TFTeam_Red)
		{
			RaidModeTime = GetGameTime(npc.index) + 9999.0;
			RaidAllowsBuildings = true;
		}
		if(Waves_InFreeplay())
		{
			RaidModeTime = GetGameTime(npc.index) + 9999999.0;
		}
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		if(StrContains(data, "seainfection") != -1)
			npc.m_iBleedType = BLEEDTYPE_SEABORN;

		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPSOUND_NORMAL;		
		
		npc.m_bThisNpcIsABoss = true;
		f_TalkDelayCheck = 0.0;
		i_TalkDelayCheck = 0;
		
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		b_angered_twice[npc.index] = false;

		SetVariantColor(view_as<int>({255, 255, 255, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		char buffers[3][64];
		ExplodeString(data, ";", buffers, sizeof(buffers), sizeof(buffers[]));
		//the very first and 2nd char are SC for scaling
		if(buffers[0][0] == 's' && buffers[0][1] == 'c')
		{
			//remove SC
			ReplaceString(buffers[0], 64, "sc", "");
			float value = StringToFloat(buffers[0]);
			RaidModeScaling = value;
		}
		else
		{	
			RaidModeScaling = float(Waves_GetRoundScale()+1);
		}
		
		npc.Anger = false;

		npc.m_flZsSphynxBuffEffect = GetGameTime() + 7.0;
		npc.m_flRangedSpecialDelay = GetGameTime() + 5.0;
		npc.m_flNextRangedAttack = GetGameTime() + 8.0;
		npc.m_flNextRangedAttackHappening = 0.0;
		npc.g_TimesSummoned = 0;
		f_ZsSphynxCantDieLimit[npc.index] = 0.0;
		
		if(RaidModeScaling < 35)
		{
			RaidModeScaling *= 0.25; //abit low, inreacing
		}
		else
		{
			RaidModeScaling *= 0.5;
		}
		
		float amount_of_people = ZRStocks_PlayerScalingDynamic();
		
		if(amount_of_people > 12.0)
		{
			amount_of_people = 12.0;
		}
		
		amount_of_people *= 0.12;
		
		if(amount_of_people < 1.0)
			amount_of_people = 1.0;
			
		RaidModeScaling *= amount_of_people; //More then 9 and he raidboss gets some troubles, bufffffffff
		
		func_NPCDeath[npc.index] = ZsSphynx_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = ZsSphynx_OnTakeDamage;
		func_NPCThink[npc.index] = ZsSphynx_ClotThink;
		
		SDKHook(npc.index, SDKHook_OnTakeDamagePost, ZsSphynx_OnTakeDamagePost);

		SetEntityRenderColor(npc.index, 255, 0, 0, 255);
		MusicEnum music;
		strcopy(music.Path, sizeof(music.Path), "#zombiesurvival/medieval_raid/kazimierz_boss.mp3");
		music.Time = 189;
		music.Volume = 2.0;
		music.Custom = true;
		strcopy(music.Name, sizeof(music.Name), "Arknights - Putrid");
		strcopy(music.Artist, sizeof(music.Artist), "Arknights");
		Music_SetRaidMusic(music);
		Citizen_MiniBossSpawn();

		float flPos[3]; // original
		GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
		npc.m_iWearable6 = ParticleEffectAt_Parent(flPos, "utaunt_wispy_parent_g", npc.index, "", {0.0,0.0,0.0});
		npc.StartPathing();

		DoGlobalMultiScaling();
		
		return npc;
	}
}


public void ZsSphynx_ClotThink(int iNPC)
{
	ZsSphynx npc = view_as<ZsSphynx>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	if(GetTeam(npc.index) != TFTeam_Red && LastMann)
	{
		if(!npc.m_fbGunout)
		{
			npc.m_fbGunout = true;
			switch(GetRandomInt(0,2))
			{
				case 0:
				{
					CPrintToChatAll("{green}감염이 당신의 동료를 전부 집어삼키고 말았습니다... 가능하면 도주하세요.");
				}
				case 1:
				{
					CPrintToChatAll("{green}이제 이곳에 감염되지 않은 자는 당신 혼자 입니다...");
				}
				case 3:
				{
					CPrintToChatAll("{green}아무래도 이곳에 희망은 없는 것 같습니다...");
				}
			}
		}
	}
	if(GetTeam(npc.index) != TFTeam_Red && RaidModeTime < GetGameTime())
	{
		DeleteAndRemoveAllNpcs = 8.0;
		mp_bonusroundtime.IntValue = (9 * 2);
		
		if(i_RaidGrantExtra[npc.index] != ZsSphynx_Xeno_INFECTED)
		{
			for(int targ; targ<i_MaxcountNpcTotal; targ++)
			{
				int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
				if (IsValidEntity(baseboss_index) && GetTeam(baseboss_index) != TFTeam_Red)
				{
					SetTeam(baseboss_index, TFTeam_Red);
					SetEntityCollisionGroup(baseboss_index, 24);
				}
			}
			CPrintToChatAll("{green}저 멀리서 어마어마하게 많은 감염체들이 몰려오는 것이 보입니다...");
			RaidBossActive = INVALID_ENT_REFERENCE;
			for(int i; i<32; i++)
			{
				float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
				float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
				int Spawner_entity = GetRandomActiveSpawner();
				if(IsValidEntity(Spawner_entity))
				{
					GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", pos);
					GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", ang);
				}
				int spawn_index = NPC_CreateByName("npc_zs_runner", -1, pos, ang, GetTeam(npc.index));
				if(spawn_index > MaxClients)
				{
					NpcStats_CopyStats(npc.index, spawn_index);
					NpcAddedToZombiesLeftCurrently(spawn_index, true);
					SetEntProp(spawn_index, Prop_Data, "m_iHealth", 10000000);
					SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", 10000000);
					fl_Extra_Damage[spawn_index] = 25.0;
					fl_Extra_Speed[spawn_index] = 1.5;
				}
			}
			float pos[3]; GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(npc.index, Prop_Data, "m_angRotation", ang);
			int Spawner_entity = GetRandomActiveSpawner();
			if(IsValidEntity(Spawner_entity))
			{
				GetEntPropVector(Spawner_entity, Prop_Data, "m_vecOrigin", pos);
				GetEntPropVector(Spawner_entity, Prop_Data, "m_angRotation", ang);
			}
			int spawn_index = NPC_CreateByName("npc_zs_the_shit_slapper", -1, pos, ang, GetTeam(npc.index));
			if(spawn_index > MaxClients)
			{
				NpcStats_CopyStats(npc.index, spawn_index);
				NpcAddedToZombiesLeftCurrently(spawn_index, true);
				SetEntProp(spawn_index, Prop_Data, "m_iHealth", 100000000);
				SetEntProp(spawn_index, Prop_Data, "m_iMaxHealth", 100000000);
				fl_Extra_Damage[spawn_index] = 25.0;
				fl_Extra_Speed[spawn_index] = 1.5;
			}
		}
		npc.m_bDissapearOnDeath = true;
		BlockLoseSay = true;
		return;
	}
	if(i_RaidGrantExtra[npc.index] != ZsSphynx_Xeno_INFECTED && b_angered_twice[npc.index])
	{
		npc.m_bDissapearOnDeath = true;
		BlockLoseSay = true;
		int closestTarget = GetClosestAllyPlayer(npc.index);
		if(IsValidEntity(closestTarget))
		{
			float WorldSpaceVec[3]; WorldSpaceCenter(closestTarget, WorldSpaceVec);
			npc.FaceTowards(WorldSpaceVec, 100.0);
		}
		npc.SetActivity("ACT_IDLE");
		npc.m_bisWalking = false;
		npc.StopPathing();
		for (int client = 1; client <= MaxClients; client++)
		{
			if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING)
			{
				TF2_StunPlayer(client, 0.5, 0.5, TF_STUNFLAGS_LOSERSTATE);
			}
		}
		if(ZsSphynxForceTalk())
		{
			npc.m_bDissapearOnDeath = true;
			RequestFrame(KillNpc, EntIndexToEntRef(npc.index));
		}
		return;
	}
	if(f_ZsSphynxCantDieLimit[npc.index] && f_ZsSphynxCantDieLimit[npc.index] < GetGameTime())
	{
		int RandSound = GetRandomInt(0, sizeof(g_RandomGroupScreamSea) - 1);
		EmitCustomToAll(g_RandomGroupScreamSea[RandSound], npc.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_RandomGroupScreamSea[RandSound], npc.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		EmitCustomToAll(g_RandomGroupScreamSea[RandSound], npc.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME);
		f_ZsSphynxCantDieLimit[npc.index] = 0.0;
	}
	if(npc.m_flSpeed >= 1.0)
	{
		if(HasSpecificBuff(npc.index, "Godly Motivation"))
		{
			npc.m_flSpeed = 220.0;
		}
		else if(!HasSpecificBuff(npc.index, "Godly Motivation"))
		{
			npc.m_flSpeed = 320.0;
		}	
	}

	if(npc.m_flNextDelayTime > gameTime)
	{
		return;
	}
	if(npc.m_flDoingSpecial < gameTime)
	{
		npc.m_flRangedArmor = 1.0;
		npc.m_flMeleeArmor = 1.25;
	}
	else
	{
		npc.m_flRangedArmor = 0.5;
		npc.m_flMeleeArmor = 0.65;
	}		


	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_BIG_FLINCH", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}

	if(npc.g_TimesSummoned == 4)
	{
		bool allyAlive = false;
		for(int targ; targ<i_MaxcountNpcTotal; targ++)
		{
			int baseboss_index = EntRefToEntIndexFast(i_ObjectsNpcsTotal[targ]);
			if (IsValidEntity(baseboss_index) && !b_NpcHasDied[baseboss_index] && i_NpcInternalId[baseboss_index] != NPCId && i_NpcInternalId[baseboss_index] != NPCId2 && GetTeam(npc.index) == GetTeam(baseboss_index))
			{
				allyAlive = true;
			}
		}
		if(!Waves_IsEmpty())
			allyAlive = true;

		if(GetTeam(npc.index) == TFTeam_Red)
			allyAlive = false;

		if(allyAlive)
		{
			b_NpcIsInvulnerable[npc.index] = true;
		}
		else
		{
			if(!npc.Anger)
			{
				npc.PlayRageSound();
				ZsSphynxSayWordsAngry(npc.index);
				npc.Anger = true;
				b_NpcIsInvulnerable[npc.index] = false;
				SetEntProp(npc.index, Prop_Data, "m_iHealth", (ReturnEntityMaxHealth(npc.index) * 6) / 7);
			}
		}
	}

	if(GetTeam(npc.index) == TFTeam_Red)
	{
		if(!IsValidEnemy(npc.index, npc.m_iTarget))
		{
			if(f_TargetToWalkToDelay[npc.index] < gameTime)
			{
				npc.m_iTargetWalkTo = GetClosestAlly(npc.index);	
				if(npc.m_iTargetWalkTo == -1) //there was no alive ally, we will return to finding an enemy and killing them.
				{
					npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
				}
			}
			else 
			{
				npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
			}
			f_TargetToWalkToDelay[npc.index] = gameTime + 0.5;	
		}	
	}
	
	if(f_TargetToWalkToDelay[npc.index] < gameTime)
	{
		if(npc.m_flZsSphynxBuffEffect < GetGameTime(npc.index) && !npc.m_flNextRangedAttackHappening && i_RaidGrantExtra[npc.index] >= 4)
		{
			npc.m_iTargetWalkTo = GetClosestAlly(npc.index);	
			if(npc.m_iTargetWalkTo == -1) //there was no alive ally, we will return to finding an enemy and killing them.
			{
				npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
			}
		}
		else 
		{
			npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
		}
		f_TargetToWalkToDelay[npc.index] = gameTime + 0.5;
	}	
	int ActionToTake = -1;
	bool AllowSelfDefense = true;
	//This means nothing, we do nothing.
	if(IsEntityAlive(npc.m_iTargetWalkTo))
	{
		//Predict their pos.
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTargetWalkTo, vecTarget );
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		float vPredictedPos[3]; PredictSubjectPosition(npc, npc.m_iTargetWalkTo,_,_, vPredictedPos);
		if(flDistanceToTarget < npc.GetLeadRadius()) 
		{
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTargetWalkTo);
		}

		if(npc.m_flNextRangedAttackHappening > GetGameTime(npc.index))
		{
			ActionToTake = -1;
		}	
		else if(npc.m_flDoingAnimation > GetGameTime(npc.index)) //I am doing an animation or doing something else, default to doing nothing!
		{
			ActionToTake = -1;
		}
		else if(IsValidEnemy(npc.index, npc.m_iTargetWalkTo) && !(i_RaidGrantExtra[npc.index] >= 4 && npc.Anger && npc.m_flZsSphynxBuffEffect < GetGameTime(npc.index)))
		{
			if(flDistanceToTarget < (500.0 * 500.0) && flDistanceToTarget > (250.0 * 250.0) && npc.m_flRangedSpecialDelay < GetGameTime(npc.index))
			{
				ActionToTake = 1;
				//first we try to jump to them if close enough.
			}
			else if(flDistanceToTarget < (250.0 * 250.0) && npc.m_flNextRangedAttack < GetGameTime(npc.index) && i_RaidGrantExtra[npc.index] >= 3)
			{
				//We are pretty close, we will do a wirlwind to kick everyone away after a certain amount of delay so they can prepare.
				ActionToTake = 2;
			}
		}
		else if(IsValidAlly(npc.index, npc.m_iTargetWalkTo) || npc.Anger)
		{
			if((npc.Anger || flDistanceToTarget < (125.0* 125.0)) && npc.m_flZsSphynxBuffEffect < GetGameTime(npc.index) && i_RaidGrantExtra[npc.index] >= 4)
			{
				//can only be above wave 15.
				ActionToTake = -1;
				ZsSphynxAOEBuff(npc,GetGameTime(npc.index));
			}
		}
		else
		{
			ActionToTake = -1; //somethings wrong, do nothing.
		}

		switch(ActionToTake)
		{
			case 1:
			{
				static float flPos[3]; 
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
				flPos[2] += 5.0;
				ParticleEffectAt(flPos, "taunt_flip_land_red", 0.25);
				npc.PlayPullSound();
				flPos[2] += 500.0;
				npc.SetVelocity({0.0,0.0,0.0});
				PluginBot_Jump(npc.index, flPos);
				
				npc.m_flSpeed = 0.0;
				if(npc.m_bPathing)
				{
					npc.StopPathing();
					
				}
				if(npc.m_iChanged_WalkCycle != 8) 	
				{
					npc.m_iChanged_WalkCycle = 8;
					npc.SetActivity("ACT_JUMP");
					npc.m_bisWalking = false;
					npc.SetPlaybackRate(1.0);
					npc.m_iTarget = -1;
				}
				
				npc.m_flNextRangedSpecialAttackHappens = GetGameTime(npc.index) + 1.5;
				if(npc.Anger)
					npc.m_flNextRangedSpecialAttackHappens = GetGameTime(npc.index) + 1.0;

				if(npc.g_TimesSummoned == 4)
				{
					npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 10.0;
				}
				else
				{
					npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 20.0;
				}
				if(npc.Anger)
					npc.m_flRangedSpecialDelay = GetGameTime(npc.index) + 7.0;

				npc.m_flDoingAnimation = GetGameTime(npc.index) + 2.0; //lets not intiate any new ability for a second.
				npc.m_fbRangedSpecialOn = true;
				//just jump at them.
			}
			case 2:
			{
				static float flPos[3]; 
				GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", flPos);
				flPos[2] += 5.0;
				int particle = ParticleEffectAt(flPos, "utaunt_headless_glow", 3.0);
				SetParent(npc.index, particle, "effect_hand_r");
				npc.m_flNextRangedAttackHappening = GetGameTime(npc.index) + 3.0; //3 seconds to prepare.
				npc.m_flNextRangedAttack = GetGameTime(npc.index) + 20.0;
				npc.m_flDoingAnimation = GetGameTime(npc.index) + 4.5; //lets not intiate any new ability for a second.
				if(npc.Anger)
				{
					npc.m_flNextRangedAttack = GetGameTime(npc.index) + 10.0;
					npc.m_flNextRangedAttackHappening = GetGameTime(npc.index) + 1.5; //1.5 seconds to prepare.
					npc.m_flDoingAnimation = GetGameTime(npc.index) + 2.5; //lets not intiate any new ability for a second.
				}
			}
		}
	}
	else
	{
		npc.m_iTargetWalkTo = GetClosestTarget(npc.index);
		f_TargetToWalkToDelay[npc.index] = gameTime + 0.5;		
	}
	if(AllowSelfDefense)
	{
		ZsSphynxSelfDefense(npc, gameTime);
	}
	if(npc.m_flNextThinkTime > GetGameTime(npc.index)) 
	{
		return;
	}
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.10;

}
	
public Action ZsSphynx_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	//Valid attackers only.
	if(attacker <= 0)
		return Plugin_Continue;
		
	ZsSphynx npc = view_as<ZsSphynx>(victim);
	if(npc.m_flReviveZsSphynxTime > GetGameTime(npc.index))
	{
		damage = 0.0;
		return Plugin_Handled;
	}
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	if(!npc.Anger)
	{
		int health = GetEntProp(victim, Prop_Data, "m_iHealth") - RoundToCeil(damage);
		if(health < 1)
		{
			SetEntProp(victim, Prop_Data, "m_iHealth", 1);
			damage = 0.0;
			return Plugin_Handled;
		}
	}
	
	if(i_RaidGrantExtra[npc.index] == ZsSphynx_Xeno_INFECTED)
	{
		if(GetTeam(npc.index) != TFTeam_Red && !b_angered_twice[npc.index] && b_NpcUnableToDie[npc.index])
		{
			if(RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
			{
				GiveProgressDelay(55.0);
				b_angered_twice[npc.index] = true;
				RaidModeTime = 9999999.9;
				RaidBossActive = INVALID_ENT_REFERENCE;
				i_TalkDelayCheck = 5;
			}
		}
		return Plugin_Changed;
	}
	if(GetTeam(npc.index) != TFTeam_Red && !b_angered_twice[npc.index] && i_RaidGrantExtra[npc.index] == 6)
	{
		if(RoundToCeil(damage) >= GetEntProp(npc.index, Prop_Data, "m_iHealth"))
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index));
			b_angered_twice[npc.index] = true;
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
			b_NpcIsInvulnerable[npc.index] = true;
			b_DoNotUnStuck[npc.index] = true;
			b_CantCollidieAlly[npc.index] = true;
			b_CantCollidie[npc.index] = true;
			SetEntityCollisionGroup(npc.index, 24);
			b_ThisEntityIgnoredByOtherNpcsAggro[npc.index] = true; //Make allied npcs ignore him.
			b_NpcIsInvulnerable[npc.index] = true;
			RemoveNpcFromEnemyList(npc.index);
			GiveProgressDelay(55.0);
			damage = 0.0;
			RaidModeTime += 120.0;
			f_TalkDelayCheck = GetGameTime() + 4.0;
			CPrintToChatAll("{lightblue}갓 알락시오스{crimson}: 이제 그만!!!!!!!!");
			return Plugin_Handled;
		}
	}
	return Plugin_Changed;
}

public void ZsSphynx_OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype) 
{
	ZsSphynx npc = view_as<ZsSphynx>(victim);
	float maxhealth = float(ReturnEntityMaxHealth(npc.index));
	float health = float(GetEntProp(npc.index, Prop_Data, "m_iHealth"));
	float Ratio = health / maxhealth;
	if(i_RaidGrantExtra[npc.index] <= 2)
	{
		if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
		{
			npc.g_TimesSummoned = 1;
			RaidModeTime += 5.0;
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			npc.PlaySummonSound();
			//BOOKMARK TODO
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_zombie",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_headcrab",_, RoundToCeil(7.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
		{
			npc.g_TimesSummoned = 2;
			RaidModeTime += 5.0;
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			npc.PlaySummonSound();
			
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_zombie",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_headcrab",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_fast_zombie",_, RoundToCeil(4.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
		{
			npc.g_TimesSummoned = 3;
			RaidModeTime += 5.0;
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			npc.PlaySummonSound();
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_fast_zombie",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_gore_blaster",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_zombie",_, RoundToCeil(5.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 4);
			ZsSphynxSayWords(npc.index);
			npc.g_TimesSummoned = 4;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_skeleton",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_shadow_walker",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_fast_zombie",_, RoundToCeil(8.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_the_shit_slapper", RoundToCeil(10000.0 * MultiGlobalHighHealthBoss), 1, true);		
		}
	}
	else if(i_RaidGrantExtra[npc.index] == 3)
	{
		if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
		{
			npc.g_TimesSummoned = 1;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;

			ZsSphynxSpawnEnemy(npc.index,"npc_zs_headcrabzombie",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_fastheadcrab_zombie",_, RoundToCeil(4.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_runner",_, RoundToCeil(4.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
		{
			npc.g_TimesSummoned = 2;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_headcrabzombie",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_fastheadcrab_zombie",_, RoundToCeil(12.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
		{
			npc.g_TimesSummoned = 3;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_runner",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_gore_blaster",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_headcrabzombie",_, RoundToCeil(5.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 4);
			ZsSphynxSayWords(npc.index);
			npc.g_TimesSummoned = 4;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_fastheadcrab_zombie",_, RoundToCeil(15.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_the_shit_slapper",_, RoundToCeil(2.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_bastardzine",RoundToCeil(10000.0 * MultiGlobalHighHealthBoss), 1, true);		
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_butcher", RoundToCeil(10000.0 * MultiGlobalHealthBoss), RoundToCeil(2.0 * MultiGlobalEnemyBoss), true);				
		}
	}
	else if(i_RaidGrantExtra[npc.index] == 4)
	{
		if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
		{
			npc.g_TimesSummoned = 1;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;

			ZsSphynxSpawnEnemy(npc.index,"npc_zs_zombie_scout",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_runner",_, RoundToCeil(12.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_fastheadcrab_zombie",_, RoundToCeil(4.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zombie_demo_main",_, RoundToCeil(5.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
		{
			npc.g_TimesSummoned = 2;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			
			ZsSphynxSpawnEnemy(npc.index,"npc_zombie_demo_main",_, RoundToCeil(5.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_medic_main",_, RoundToCeil(12.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
		{
			npc.g_TimesSummoned = 3;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			ZsSphynxSpawnEnemy(npc.index,"npc_sniper_main",_, RoundToCeil(6.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_zombie_sniper_jarate",_, RoundToCeil(12.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zombie_heavy_giant_grave",_, RoundToCeil(2.0 * MultiGlobalEnemy));
		}
		else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
		{
			SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 4);
			ZsSphynxSayWords(npc.index);
			npc.g_TimesSummoned = 4;
			RaidModeTime += 5.0;
			npc.PlaySummonSound();
			npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_zombie_soldier",_, RoundToCeil(2.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zs_zombie_soldier_pickaxe",_, RoundToCeil(8.0 * MultiGlobalEnemy));
			ZsSphynxSpawnEnemy(npc.index,"npc_zombie_soldier_giant_grave",RoundToCeil(2500.0 * MultiGlobalHighHealthBoss), 1, true);		
			ZsSphynxSpawnEnemy(npc.index,"npc_spy_boss", RoundToCeil(125000.0 * MultiGlobalHighHealthBoss), 1, true);		
		}
	}
	else
	{
		if(i_RaidGrantExtra[npc.index] == ZsSphynx_Xeno_INFECTED)
		{
			if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
			{
				npc.g_TimesSummoned = 1;
				npc.PlaySummonSound();
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;

				ZsSphynxSpawnEnemy(npc.index,"npc_seaborn_kazimersch_knight",100000, RoundToCeil(6.0 * MultiGlobalEnemy));
				ZsSphynxSpawnEnemy(npc.index,"npc_seaborn_kazimersch_archer",50000, RoundToCeil(12.0 * MultiGlobalEnemy));
				ZsSphynxSpawnEnemy(npc.index,"npc_seaborn_kazimersch_melee_assasin",75000, RoundToCeil(4.0 * MultiGlobalEnemy));
			}
			else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
			{
				npc.g_TimesSummoned = 2;
				npc.PlaySummonSound();
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
				
				ZsSphynxSpawnEnemy(npc.index,"npc_seaborn_vanguard",25000, RoundToCeil(2.0 * MultiGlobalEnemy));
				ZsSphynxSpawnEnemy(npc.index,"npc_seaborn_defender",60000, RoundToCeil(12.0 * MultiGlobalEnemy));
			}
			else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
			{
				npc.g_TimesSummoned = 3;
				npc.PlaySummonSound();
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
				ZsSphynxSpawnEnemy(npc.index,"npc_seaborn_medic",50000, RoundToCeil(10.0 * MultiGlobalEnemy));
				ZsSphynxSpawnEnemy(npc.index,"npc_seaborn_guard",100000, RoundToCeil(10.0 * MultiGlobalEnemy));
				ZsSphynxSpawnEnemy(npc.index,"npc_seaborn_kazimersch_beserker",200000, RoundToCeil(2.0 * MultiGlobalEnemy));
				ZsSphynxSpawnEnemy(npc.index,"npc_pathshaper", RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1);
			}
			else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
			{
				SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 4);
				ZsSphynxSayWords(npc.index);
				npc.g_TimesSummoned = 4;
				npc.PlaySummonSound();
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
				ZsSphynxSpawnEnemy(npc.index,"npc_seaborn_vanguard",50000, RoundToCeil(1.0 * MultiGlobalEnemy));
				ZsSphynxSpawnEnemy(npc.index,"npc_seaborn_kazimersch_longrange",50000, RoundToCeil(10.0 * MultiGlobalEnemy));
				ZsSphynxSpawnEnemy(npc.index,"npc_netherseapredator",70000, RoundToCeil(20.0 * MultiGlobalEnemy));	
				ZsSphynxSpawnEnemy(npc.index,"npc_netherseaspewer",50000, RoundToCeil(20.0 * MultiGlobalEnemy));	
				ZsSphynxSpawnEnemy(npc.index,"npc_isharmla", RoundToCeil(1000000.0 * MultiGlobalHighHealthBoss), 1, true);	
				ZsSphynxSpawnEnemy(npc.index,"npc_seaborn_specialist",7000, RoundToCeil(20.0 * MultiGlobalEnemy));	
			}	
		}
		else
		{
			if(Ratio <= 0.85 && npc.g_TimesSummoned < 1)
			{
				npc.g_TimesSummoned = 1;
				npc.PlaySummonSound();
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;

				ZsSphynxSpawnEnemy(npc.index,"npc_zs_zombie_heavy",75000, RoundToCeil(6.0 * MultiGlobalEnemy));
				ZsSphynxSpawnEnemy(npc.index,"npc_zs_shadow_walker",50000, RoundToCeil(12.0 * MultiGlobalEnemy));
				ZsSphynxSpawnEnemy(npc.index,"npc_zs_skeleton",50000, RoundToCeil(4.0 * MultiGlobalEnemy));
			}
			else if(Ratio <= 0.55 && npc.g_TimesSummoned < 2)
			{
				npc.g_TimesSummoned = 2;
				npc.PlaySummonSound();
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
				
				ZsSphynxSpawnEnemy(npc.index,"npc_medic_main",75000, RoundToCeil(12.0 * MultiGlobalEnemy));
				ZsSphynxSpawnEnemy(npc.index,"npc_medic_healer",75000, RoundToCeil(12.0 * MultiGlobalEnemy));
			}
			else if(Ratio <= 0.35 && npc.g_TimesSummoned < 3)
			{
				npc.g_TimesSummoned = 3;
				npc.PlaySummonSound();
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
				ZsSphynxSpawnEnemy(npc.index,"npc_zombie_demo_main",50000, RoundToCeil(10.0 * MultiGlobalEnemy));
				ZsSphynxSpawnEnemy(npc.index,"npc_kamikaze_demo",100000, RoundToCeil(10.0 * MultiGlobalEnemy));
				ZsSphynxSpawnEnemy(npc.index,"npc_zombie_heavy_giant_grave",250000, RoundToCeil(2.0 * MultiGlobalEnemy));
				ZsSphynxSpawnEnemy(npc.index,"npc_zombie_soldier_giant_grave", RoundToCeil(300000.0 * MultiGlobalHighHealthBoss), 1);
			}
			else if(Ratio <= 0.20 && npc.g_TimesSummoned < 4)
			{
				SetEntProp(npc.index, Prop_Data, "m_iHealth", ReturnEntityMaxHealth(npc.index) / 4);
				ZsSphynxSayWords(npc.index);
				npc.g_TimesSummoned = 4;
				npc.PlaySummonSound();
				npc.m_flDoingSpecial = GetGameTime(npc.index) + 10.0;
				ZsSphynxSpawnEnemy(npc.index,"npc_zs_soldier_barrager", RoundToCeil(400000.0 * MultiGlobalHighHealthBoss), 1, true);
				ZsSphynxSpawnEnemy(npc.index,"npc_major_vulture", RoundToCeil(400000.0 * MultiGlobalHighHealthBoss), 1, true);
				ZsSphynxSpawnEnemy(npc.index,"npc_zs_flesh_creeper", RoundToCeil(250000.0 * MultiGlobalHighHealthBoss), 1, true);
			}			
		}
	}
}

public void ZsSphynx_NPCDeath(int entity)
{
	ZsSphynx npc = view_as<ZsSphynx>(entity);
	if(!BlockLoseSay)
	{
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		
		TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		TE_Particle("pyro_blast_lines", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		npc.PlayDeathSound();
			
		if(i_RaidGrantExtra[npc.index] != ZsSphynx_Xeno_INFECTED)
		{
			switch(GetRandomInt(0,3))
			{
				case 0:
				{
					CPrintToChatAll("{default}: 감염체들을 잠시 몰아내는데에 성공한 것 같습니다.");
				}
				case 1:
				{
					CPrintToChatAll("{default}: 저것과 감염체들이 후퇴를 하고 있습니다.");
				}
				case 2:
				{
					CPrintToChatAll("{default}: 저것이 잠시 물러나고 있습니다. 저것에게 자아라도 있는 것일까요?");
				}
				case 3:
				{
					CPrintToChatAll("{default}: 저것이 회복을 위해서 잠시 물러났습니다.");
				}
			}
		}
		else
		{
			CPrintToChatAll("{green}???{crimson}: 그 짓거리를 반드시 후회하게 해주마.");
			CPrintToChatAll("{default}: 당장은 이곳의 감염이 끝난것 같습니다...아마도...");
		}
	}
	else
	{
		float WorldSpaceVec[3]; WorldSpaceCenter(npc.index, WorldSpaceVec);
		
		TE_Particle("pyro_blast", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		TE_Particle("pyro_blast_lines", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		TE_Particle("pyro_blast_warp", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		TE_Particle("pyro_blast_flash", WorldSpaceVec, NULL_VECTOR, NULL_VECTOR, -1, _, _, _, _, _, _, _, _, _, 0.0);
		EmitCustomToAll("zombiesurvival/internius/blinkarrival.wav", npc.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME * 2.0);
	}
	
	RaidBossActive = INVALID_ENT_REFERENCE;
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);

	for(int EnemyLoop; EnemyLoop < MAXENTITIES; EnemyLoop ++)
	{
		if(IsValidEntity(i_LaserEntityIndex[EnemyLoop]))
		{
			RemoveEntity(i_LaserEntityIndex[EnemyLoop]);
		}		
	}

	Citizen_MiniBossDeath(entity);
}

//BOOKMARK TODO
void ZsSphynxSpawnEnemy(int zssphynx, char[] plugin_name, int health = 0, int count, bool is_a_boss = false)
{
	if(GetTeam(zssphynx) == TFTeam_Red)
	{
		count /= 2;
		if(count < 1)
		{
			count = 1;
		}
		for(int Spawns; Spawns <= count; Spawns++)
		{
			float pos[3]; GetEntPropVector(zssphynx, Prop_Data, "m_vecAbsOrigin", pos);
			float ang[3]; GetEntPropVector(zssphynx, Prop_Data, "m_angRotation", ang);
			
			int summon = NPC_CreateByName(plugin_name, -1, pos, ang, GetTeam(zssphynx));
			if(summon > MaxClients)
			{
				fl_Extra_Damage[summon] = 10.0;
				if(!health)
				{
					health = GetEntProp(summon, Prop_Data, "m_iMaxHealth");
				}
				SetEntProp(summon, Prop_Data, "m_iHealth", health / 10);
				SetEntProp(summon, Prop_Data, "m_iMaxHealth", health / 10);
			}
		}
		return;
	}
		
	Enemy enemy;
	enemy.Index = NPC_GetByPlugin(plugin_name);
	if(health != 0)
	{
		enemy.Health = health;
	}
	enemy.Is_Boss = view_as<int>(is_a_boss);
	enemy.Is_Immune_To_Nuke = true;
	//do not bother outlining.
	enemy.ExtraMeleeRes = 1.0;
	enemy.ExtraRangedRes = 1.0;
	enemy.ExtraSpeed = 1.0;
	enemy.ExtraDamage = 1.0;
	enemy.ExtraSize = 1.0;		
	enemy.Team = GetTeam(zssphynx);
	
	if(!Waves_InFreeplay())
	{
		for(int i; i<count; i++)
		{
			Waves_AddNextEnemy(enemy);
		}
	}
	else
	{
		int postWaves = CurrentRound - Waves_GetMaxRound();
		char npc_classname[60];
		NPC_GetPluginById(i_NpcInternalId[enemy.Index], npc_classname, sizeof(npc_classname));

		Freeplay_AddEnemy(postWaves, enemy, count, true);
		if(count > 0)
		{
			for(int a; a < count; a++)
			{
				Waves_AddNextEnemy(enemy);
			}
		}
	}

	Zombies_Currently_Still_Ongoing += count;
}

void ZsSphynxSelfDefense(ZsSphynx npc, float gameTime)
{
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
		{
			npc.m_iTarget = GetClosestTarget(npc.index);
			npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
		}
	}
	
	//This code is only here so they defend themselves incase any enemy is too close to them. otherwise it is completly disconnected from any other logic.

	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < GetGameTime(npc.index))
		{
			npc.m_flAttackHappens = 0.0;
			
			if(IsValidEnemy(npc.index, npc.m_iTarget))
			{
				int HowManyEnemeisAoeMelee = 64;
				Handle swingTrace;
				float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
				npc.FaceTowards(VecEnemy, 15000.0);
				npc.DoSwingTrace(swingTrace, npc.m_iTarget,_,_,_,1,_,HowManyEnemeisAoeMelee);
				delete swingTrace;
				bool PlaySound = false;
				for (int counter = 1; counter <= HowManyEnemeisAoeMelee; counter++)
				{
					if (i_EntitiesHitAoeSwing_NpcSwing[counter] > 0)
					{
						if(IsValidEntity(i_EntitiesHitAoeSwing_NpcSwing[counter]))
						{
							PlaySound = true;
							int target = i_EntitiesHitAoeSwing_NpcSwing[counter];
							float vecHit[3];
							WorldSpaceCenter(target, vecHit);
										
							float damage = 20.0;
							SDKHooks_TakeDamage(target, npc.index, npc.index, damage * RaidModeScaling, DMG_CLUB, -1, _, vecHit);	
							if(i_RaidGrantExtra[npc.index] == ZsSphynx_Xeno_INFECTED)
								Elemental_AddNervousDamage(target, npc.index, RoundToCeil(damage * RaidModeScaling * 0.1));							
							
							bool Knocked = false;
							
							if(IsValidClient(target))
							{
								if (IsInvuln(target))
								{
									Knocked = true;
									Custom_Knockback(npc.index, target, 900.0, true);
									TF2_AddCondition(target, TFCond_LostFooting, 0.5);
									TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
								}
								else
								{
									if(!HasSpecificBuff(npc.index, "Godly Motivation"))
									{
										TF2_AddCondition(target, TFCond_LostFooting, 0.5);
										TF2_AddCondition(target, TFCond_AirCurrent, 0.5);
									}
								}
							}
										
							if(!Knocked)
								Custom_Knockback(npc.index, target, 150.0, true); 
						}
					}
				}
				if(PlaySound)
				{
					npc.PlayMeleeHitSound();
				}
			}
		}
	}

	if(GetGameTime(npc.index) > npc.m_flNextMeleeAttack)
	{
		if(IsValidEnemy(npc.index, npc.m_iTarget)) 
		{
			float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget );

			float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
			float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);

			if(flDistanceToTarget < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
			{
				int Enemy_I_See;
									
				Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
						
				if(IsValidEntity(Enemy_I_See) && IsValidEnemy(npc.index, Enemy_I_See))
				{
					npc.m_iTarget = Enemy_I_See;

					npc.PlayMeleeSound();

					npc.AddGesture("ACT_MELEE_ATTACK1");
							
					npc.m_flAttackHappens = gameTime + 0.25;

					npc.m_flDoingAnimation = gameTime + 0.85;
					npc.m_flNextMeleeAttack = gameTime + 2.0;
					if(npc.Anger)
					{
						npc.m_flAttackHappens = gameTime + 0.125;
						npc.m_flDoingAnimation = gameTime + 0.85;
						npc.m_flNextMeleeAttack = gameTime + 1.5;
						int layerCount = CBaseAnimatingOverlay(npc.index).GetNumAnimOverlays();
						for(int i; i < layerCount; i++)
						{
							view_as<CClotBody>(npc.index).SetLayerPlaybackRate(i, 2.0);
						}
					}
				}
			}
		}
		else
		{
			npc.m_flGetClosestTargetTime = 0.0;
			if(npc.m_flNextRangedSpecialAttackHappens < gameTime)
				npc.m_iTarget = GetClosestTarget(npc.index);
		}	
	}
}

void ZsSphynxAOEBuff(ZsSphynx npc, float gameTime, bool mute = false)
{
	float pos1[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
	if(npc.m_flZsSphynxBuffEffect < gameTime)
	{
		bool buffed_anyone;
		bool buffedAlly = false;
		for(int entitycount; entitycount<MAXENTITIES; entitycount++) //Check for npcs
		{
			if(IsValidEntity(entitycount) && entitycount != npc.index && (entitycount <= MaxClients || !b_NpcHasDied[entitycount])) //Cannot buff self like this.
			{
				if(GetEntProp(entitycount, Prop_Data, "m_iTeamNum") == GetEntProp(npc.index, Prop_Data, "m_iTeamNum") && IsEntityAlive(entitycount))
				{
					static float pos2[3];
					GetEntPropVector(entitycount, Prop_Data, "m_vecAbsOrigin", pos2);
					if(GetVectorDistance(pos1, pos2, true) < (ZsSphynx_BUFF_MAXRANGE * ZsSphynx_BUFF_MAXRANGE))
					{
						ApplyStatusEffect(npc.index, entitycount, "Godly Motivation", 10.0);
						//Buff this entity.
						buffed_anyone = true;	
						if(entitycount != npc.index)
						{
							buffedAlly = true;
						}
					}
				}
			}
		}
		if(npc.Anger)
			buffed_anyone = true;

		if(buffed_anyone)
		{
			if(buffedAlly)
				f_ZsSphynxCantDieLimit[npc.index] = GetGameTime() + 1.0;

			npc.m_flZsSphynxBuffEffect = gameTime + 10.0;
			if(!NpcStats_IsEnemySilenced(npc.index))
			{
				ApplyStatusEffect(npc.index, npc.index, "Godly Motivation", 5.0);
			}
			else
			{
				ApplyStatusEffect(npc.index, npc.index, "Godly Motivation", 3.0);
			}
			static int r;
			static int g;
			static int b ;
			static int a = 255;
			if(GetTeam(npc.index) != TFTeam_Red)
			{
				r = 220;
				g = 220;
				b = 255;
			}
			else
			{
				r = 255;
				g = 125;
				b = 125;
			}
			static float UserLoc[3];
			GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", UserLoc);
			spawnRing(npc.index, ZsSphynx_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 1.0, 6.0, 6.1, 1);
			spawnRing_Vectors(UserLoc, 0.0, 0.0, 5.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.75, 12.0, 6.1, 1, ZsSphynx_BUFF_MAXRANGE * 2.0);		
			npc.AddGestureViaSequence("g_wave");
			if(!mute)
			{
				spawnRing(npc.index, ZsSphynx_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.8, 6.0, 6.1, 1);
				spawnRing(npc.index, ZsSphynx_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 35.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.7, 6.0, 6.1, 1);
				npc.PlayMeleeWarCry();
			}
		}
		else
		{
			npc.m_flZsSphynxBuffEffect = gameTime + 1.0; //Try again in a second.
		}
	}
}


void ZsSphynxSayWords(int entity)
{
	if(i_RaidGrantExtra[entity] == ZsSphynx_Xeno_INFECTED)
	{
		switch(GetRandomInt(0,2))
		{
			case 0:
			{
				CPrintToChatAll("{green}저것이 제노 감염체들을 불러냅니다.");
			}
			case 1:
			{
				CPrintToChatAll("{green}저것이 주변의 생명체들을 이끌어오고 있습니다...");
			}
			case 2:
			{
				CPrintToChatAll("{green}저것은 혼자가 아닙니다... 감염체든 무엇이든간에.");
			}
		}
	}
	else
	{
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{green}저것이 제노 감염체들을 불러냅니다.");
			}
			case 1:
			{
				CPrintToChatAll("{green}저것이 주변의 생명체들을 이끌어오고 있습니다...");
			}
			case 2:
			{
				CPrintToChatAll("{green}저것은 혼자가 아닙니다... 감염체든 무엇이든간에.");
			}
		}
	}
}

void ZsSphynxSayWordsAngry(int entity)
{
	if(!Waves_InFreeplay())
		RaidModeTime += 30.0;

	if(i_RaidGrantExtra[entity] == ZsSphynx_Xeno_INFECTED)
	{
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{green}저것이 죽은 감염체들을 보며 분노하고 있습니다.");
			}
			case 1:
			{
				CPrintToChatAll("{green}저것이 크게 분노하고 있습니다. 동료애라도 있는 것일까요?");
			}
			case 2:
			{
				CPrintToChatAll("{green}저것의 움직임이 빨라졌습니다. 아무래도 화가 단단히 난것 같군요");
			}
		}
	}
	else
	{
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{green}저것이 죽은 감염체들을 보며 분노하고 있습니다.");
			}
			case 1:
			{
				CPrintToChatAll("{green}저것이 크게 분노하고 있습니다. 동료애라도 있는 것일까요?");
			}
			case 2:
			{
				CPrintToChatAll("{green}저것의 움직임이 빨라졌습니다. 아무래도 화가 단단히 난것 같군요");
			}
		}
	}
}


bool ZsSphynxForceTalk()
{
	if(i_TalkDelayCheck == 11)
	{
		return true;
	}
	if(f_TalkDelayCheck < GetGameTime())
	{
		f_TalkDelayCheck = GetGameTime() + 5.0;
		RaidModeTime += 10.0; //cant afford to delete it, since duo.
		switch(i_TalkDelayCheck)
		{
			case 0:
			{
				ReviveAll(true);
				CPrintToChatAll("{lightblue}갓 알락시오스{default}: 이 부질 없는 싸움을 더는 용납할 수 없다!");
				i_TalkDelayCheck += 1;
			}
			case 1:
			{
				CPrintToChatAll("{lightblue}갓 알락시오스{default}: 반드시 이해해둬라. 적은 {blue}우리가 아니다.{default} 진짜 적은 {blue}바다의 그 놈들, 시본{default}이지.");
				i_TalkDelayCheck += 1;
			}
			case 2:
			{
				CPrintToChatAll("{lightblue}갓 알락시오스{default}: 우리가 이렇게 서로 싸우기만 할수록, 그 놈들이 점점 더 성장해나갈거다.");
				i_TalkDelayCheck += 1;
			}
			case 3:
			{
				CPrintToChatAll("{lightblue}갓 알락시오스{default}: 비록 나와 내 군대는 불멸의 존재이더라도, 그들에게 감염 당하는 것을 버틸 수는 없다.");
				i_TalkDelayCheck += 1;
			}
			case 4:
			{
				CPrintToChatAll("{lightblue}갓 알락시오스{default}: 하지만, 네 능력과 위력을 지금 여기서 느꼈다.");
				i_TalkDelayCheck += 1;
			}
			case 5:
			{
				CPrintToChatAll("{lightblue}갓 알락시오스{default}: 너라면 {blue}시본들의{default} 무기조차도 아무 이상 없이 다룰 수 있을 것이다. 감염조차 되지 않을테니...");
				i_TalkDelayCheck += 1;
			}
			case 6:
			{
				CPrintToChatAll("{lightblue}갓 알락시오스{default}: 그래서 너희의 도움이 필요하다. 너희들이야말로 이 세계를 심해 속 공포로부터 정화할 수 있는 가장 큰 대항책이다.");
				i_TalkDelayCheck += 1;
			}
			case 7:
			{
				CPrintToChatAll("{lightblue}갓 알락시오스{default}: 물론, 우리는 최선을 다해 너를 지원할 것이다. 하나가 되어 다시 한 번 번영하게 되리라.");
				i_TalkDelayCheck += 1;
			}
			case 8:
			{
				CPrintToChatAll("{lightblue}갓 알락시오스{default}: 너희가 그 놈들 사이로 침투하면, 우리가 그 놈들의 주력 병력의 시선을 우리 쪽으로 끌어오겠다.");
				i_TalkDelayCheck += 1;
			}
			case 9:
			{
				CPrintToChatAll("{lightblue}갓 알락시오스{default}: 이 용병들에게 축복을!!! {crimson} 아틀란티스를 위해!!!!.");
				i_TalkDelayCheck = 11;
				for (int client = 1; client <= MaxClients; client++)
				{
					if(IsValidClient(client) && GetClientTeam(client) == 2 && TeutonType[client] != TEUTON_WAITING && PlayerPoints[client] > 500)
					{
						//Items_GiveNamedItem(client, "ZsSphynx's Godly assistance");
						CPrintToChat(client, "{default}무언가 알 수 없는 찬란한 기운이 감돕니다... 당신이 얻은 것: {lightblue}''알락시오스의 신성한 축복''{default}!");
					}
				}
			}
		}
	}
	return false;
}
public void Raidmode_ZsSphynx_Win(int entity)
{
	ZsSphynx npc = view_as<ZsSphynx>(entity);
	func_NPCThink[entity] = INVALID_FUNCTION;
	npc.m_bDissapearOnDeath = true;
	BlockLoseSay = true;
	
	if(i_RaidGrantExtra[npc.index] == ZsSphynx_Xeno_INFECTED)
	{
		CPrintToChatAll("{green}... 예상했던대로, 당신은 실패했습니다. 이곳엔 이제 희망이란 없습니다..");
	}
	else
	{
		switch(GetRandomInt(0,3))
		{
			case 0:
			{
				CPrintToChatAll("{default}... 이제 이곳에 감염되지 않은 생명체는 없습니다...");
			}
			case 1:
			{
				CPrintToChatAll("{default}... 이곳에 더이상 희망이 없는것 같습니다...");
			}
			case 2:
			{
				CPrintToChatAll("{default}... 모든게 끝났습니다. 이 세상엔 오직 감염체들만이 남았습니다...");
			}
			case 3:
			{
				CPrintToChatAll("{default}...");
			}
		}
	}
	i_RaidGrantExtra[entity] = RAIDITEM_INDEX_WIN_COND;
}
