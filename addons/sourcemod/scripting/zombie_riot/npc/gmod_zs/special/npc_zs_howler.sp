#pragma semicolon 1
#pragma newdecls required
 
static const char g_DeathSounds[][] = {
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav",
};

static const char g_HurtSounds[][] = {
	"npc/zombie/zombie_pain1.wav",
	"npc/zombie/zombie_pain2.wav",
	"npc/zombie/zombie_pain3.wav",
	"npc/zombie/zombie_pain4.wav",
	"npc/zombie/zombie_pain5.wav",
	"npc/zombie/zombie_pain6.wav",
};

static const char g_IdleSounds[][] = {
	"npc/zombie/zombie_voice_idle1.wav",
	"npc/zombie/zombie_voice_idle2.wav",
	"npc/zombie/zombie_voice_idle3.wav",
	"npc/zombie/zombie_voice_idle4.wav",
	"npc/zombie/zombie_voice_idle5.wav",
	"npc/zombie/zombie_voice_idle6.wav",
	"npc/zombie/zombie_voice_idle7.wav",
	"npc/zombie/zombie_voice_idle8.wav",
	"npc/zombie/zombie_voice_idle9.wav",
	"npc/zombie/zombie_voice_idle10.wav",
	"npc/zombie/zombie_voice_idle11.wav",
	"npc/zombie/zombie_voice_idle12.wav",
	"npc/zombie/zombie_voice_idle13.wav",
	"npc/zombie/zombie_voice_idle14.wav",
};

static const char g_MeleeHitSounds[][] = {
	"npc/fast_zombie/claw_strike1.wav",
	"npc/fast_zombie/claw_strike2.wav",
	"npc/fast_zombie/claw_strike3.wav",
};
static const char g_MeleeAttackSounds[][] = {
	"npc/zombie/zo_attack1.wav",
	"npc/zombie/zo_attack2.wav",
};

static const char g_MeleeMissSounds[][] = {
	"npc/fast_zombie/claw_miss1.wav",
	"npc/fast_zombie/claw_miss2.wav",
};

static const char g_PlayHowlerWarCry[][] = {
	"zombiesurvival/medieval_raid/special_mutation/arkantos_scream_buff.mp3"
};

public void ZSHowler_OnMapStart_NPC()
{
	for (int i = 0; i < (sizeof(g_DeathSounds));	   i++) { PrecacheSound(g_DeathSounds[i]);	   }
	for (int i = 0; i < (sizeof(g_HurtSounds));		i++) { PrecacheSound(g_HurtSounds[i]);		}
	for (int i = 0; i < (sizeof(g_IdleSounds));		i++) { PrecacheSound(g_IdleSounds[i]);		}
	for (int i = 0; i < (sizeof(g_MeleeHitSounds));	i++) { PrecacheSound(g_MeleeHitSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds));	i++) { PrecacheSound(g_MeleeAttackSounds[i]);	}
	for (int i = 0; i < (sizeof(g_MeleeMissSounds));   i++) { PrecacheSound(g_MeleeMissSounds[i]);   }

	PrecacheSound("player/flow.wav");
	PrecacheModel("models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl");
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "ZS Howler");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_zs_howler");
	strcopy(data.Icon, sizeof(data.Icon), "gmod_zs_howler");
	data.IconCustom = true;
	data.Flags = 0;
	data.Category = Type_GmodZS;
	data.Func = ClotSummon;
	NPC_Add(data);
}
#define ZSHOWLER_BUFF_MAXRANGE 500.0

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return ZSHowler(vecPos, vecAng, team);
}

methodmap ZSHowler < CClotBody
{
	property float m_flZSHowlerBuffEffect
	{
		public get()							{ return fl_AttackHappensMaximum[this.index]; }
		public set(float TempValueForProperty) 	{ fl_AttackHappensMaximum[this.index] = TempValueForProperty; }
	}
	public void PlayIdleSound() {
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(3.0, 6.0);
	}
	public void PlayHowlerWarCry() 
	{
		EmitSoundToAll(g_PlayHowlerWarCry[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, 120, _, BOSS_ZOMBIE_VOLUME, 100);
	}
	public void PlayHurtSound() {
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayDeathSound() {
	
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		
	}
	public void PlayMeleeSound() {
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeHitSound() {
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	public void PlayMeleeMissSound() {
		EmitSoundToAll(g_MeleeMissSounds[GetRandomInt(0, sizeof(g_MeleeMissSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public ZSHowler(float vecPos[3], float vecAng[3], int ally)
	{
		ZSHowler npc = view_as<ZSHowler>(CClotBody(vecPos, vecAng, "models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl", "1.75", "15000", ally, false));
		
		i_NpcWeight[npc.index] = 1;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_HL2MP_WALK_ZOMBIE_01");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		npc.m_iWearable1 = npc.EquipItem("weapon_bone", "models/zombie_riot/gmod_zs/zs_zombie_models_1_1.mdl");
		SetVariantString("1.0");
		AcceptEntityInput(npc.m_iWearable1, "SetModelScale");

		npc.m_flNextMeleeAttack = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_NORMAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;	
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		npc.m_flRangedArmor = 0.6;
		
		
		npc.m_flZSHowlerBuffEffect = GetGameTime() + 7.0;
		npc.m_flSpeed = 320.0;
		func_NPCDeath[npc.index] = ZSHowler_NPCDeath;
		func_NPCThink[npc.index] = ZSHowler_ClotThink;
		func_NPCOnTakeDamage[npc.index] = Generic_OnTakeDamage;

		npc.StartPathing();
		
		return npc;
	}
}

public void ZSHowler_ClotThink(int iNPC)
{
    ZSHowler npc = view_as<ZSHowler>(iNPC);
    float gameTime = GetGameTime(npc.index);
    
    // 1. 모델 설정 (투명화 방지)
    SetEntProp(npc.index, Prop_Send, "m_nBody", GetEntProp(npc.index, Prop_Send, "m_nBody"));
    SetVariantInt(32); 
    AcceptEntityInput(iNPC, "SetBodyGroup");

    if(IsValidEntity(npc.m_iWearable1))
    {
        SetEntProp(npc.m_iWearable1, Prop_Send, "m_nBody", 64);
    }
    
    if(npc.m_flNextDelayTime > gameTime) return;
    npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
    npc.Update();
    
    // 2. 타겟팅 로직
    if(npc.m_flGetClosestTargetTime < gameTime)
    {
        int ally = GetClosestAlly(npc.index);
        int enemy = GetClosestTarget(npc.index);
        
        // 버프가 가능하면 아군에게, 아니면 적에게
        if(npc.m_flZSHowlerBuffEffect < gameTime && IsValidAlly(npc.index, ally))
        {
            npc.m_iTarget = ally;
        }
        else
        {
            npc.m_iTarget = enemy;
        }
        
        npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
        npc.StartPathing();
    }
    
    int currentTarget = npc.m_iTarget;
    if(!IsValidEntity(currentTarget) || !IsEntityAlive(currentTarget)) return;

    float vecTarget[3]; WorldSpaceCenter(currentTarget, vecTarget);
    float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
    float distSq = GetVectorDistance(vecTarget, VecSelfNpc, true);

    // 3. [핵심 수정] 이동 명령을 분기 밖으로 뺌
    // 목표가 아군이든 적이든 일단 그 대상을 향해 이동해야 합니다.
    if(distSq < npc.GetLeadRadius())
    {
        float vPredictedPos[3]; PredictSubjectPosition(npc, currentTarget,_,_, vPredictedPos);
        npc.SetGoalVector(vPredictedPos);
    }
    else
    {
        npc.SetGoalEntity(currentTarget);
    }

    // 4. 행동 로직 (버프 또는 공격)
    if(IsValidAlly(npc.index, currentTarget))
    {
        // 아군에게 충분히 근접하면 버프 실행
        if(distSq < (150.0 * 150.0) && npc.m_flZSHowlerBuffEffect < gameTime)
        {
            ZSHowlerAOEBuff(npc, gameTime);
            // 버프 후 즉시 타겟 재탐색 유도 (적으로 전환하기 위함)
            npc.m_flGetClosestTargetTime = 0.0;
        }
    }
    else if(IsValidEnemy(npc.index, currentTarget))
    {
        // 적에게 근접하면 공격 실행
        if(distSq < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED || npc.m_flAttackHappenswillhappen)
        {
            if(npc.m_flNextMeleeAttack < gameTime)
            {
                if (!npc.m_flAttackHappenswillhappen)
                {
                    npc.AddGesture("ACT_GMOD_GESTURE_RANGE_ZOMBIE");
                    npc.PlayMeleeSound();
                    npc.m_flAttackHappens = gameTime + 0.7;
                    npc.m_flAttackHappens_bullshit = gameTime + 0.83;
                    npc.m_flAttackHappenswillhappen = true;
                }
                
                if (npc.m_flAttackHappens < gameTime && npc.m_flAttackHappenswillhappen)
                {
                    Handle swingTrace;
                    npc.FaceTowards(vecTarget, 20000.0);
                    if(npc.DoSwingTrace(swingTrace, currentTarget))
                    {
                        int hit = TR_GetEntityIndex(swingTrace);
                        if(hit > 0)
                        {
                            SDKHooks_TakeDamage(hit, npc.index, npc.index, 100.0, DMG_CLUB, -1, _, _);
                            npc.PlayMeleeHitSound();
                        }
                        else npc.PlayMeleeMissSound();
                    }
                    delete swingTrace;
                    npc.m_flNextMeleeAttack = gameTime + 0.74;
                    npc.m_flAttackHappenswillhappen = false;
                }
            }
        }
    }
	else
	{
		npc.StopPathing();
		
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
    
    npc.PlayIdleSound();
}
void ZSHowlerAOEBuff(ZSHowler npc, float gameTime, bool mute = false)
{
	float pos1[3];
	GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", pos1);
	if(npc.m_flZSHowlerBuffEffect < gameTime)
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
					if(GetVectorDistance(pos1, pos2, true) < (ZSHOWLER_BUFF_MAXRANGE * ZSHOWLER_BUFF_MAXRANGE))
					{
						ApplyStatusEffect(npc.index, entitycount, "War Cry", 10.0);
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

			npc.m_flZSHowlerBuffEffect = gameTime + 10.0;
			if(!NpcStats_IsEnemySilenced(npc.index))
			{
				ApplyStatusEffect(npc.index, npc.index, "War Cry", 5.0);
			}
			else
			{
				ApplyStatusEffect(npc.index, npc.index, "War Cry", 3.0);
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
			spawnRing(npc.index, ALAXIOS_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 1.0, 6.0, 6.1, 1);
			spawnRing_Vectors(UserLoc, 0.0, 0.0, 5.0, 0.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.75, 12.0, 6.1, 1, ALAXIOS_BUFF_MAXRANGE * 2.0);		
			npc.AddGestureViaSequence("g_wave");
			if(!mute)
			{
				spawnRing(npc.index, ZSHOWLER_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 25.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.8, 6.0, 6.1, 1);
				spawnRing(npc.index, ZSHOWLER_BUFF_MAXRANGE * 2.0, 0.0, 0.0, 35.0, "materials/sprites/laserbeam.vmt", r, g, b, a, 1, 0.7, 6.0, 6.1, 1);
				npc.PlayHowlerWarCry();
			}
		}
		else
		{
			npc.m_flZSHowlerBuffEffect = gameTime + 1.0; //Try again in a second.
		}
	}
}
public void ZSHowler_NPCDeath(int entity)
{
	ZSHowler npc = view_as<ZSHowler>(entity);
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();	
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
}