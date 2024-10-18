string cver="SHUDv1.8";//Used to check current version
key qid;//Used to rack dataserver requests
key sync;//Used to track sync requests.
string suffix="_DATA";
string datatype;
string o;
integer hear;
string pass="ded1cc51-1d1f-4eee-b08e-f5d827b436d7";//Used to secure linksetdata
integer hardcore=1;///Will the person automatically respawn on death? (WOR Mode Only)
integer woronly=1;//Overwritten at boot. Tells the hud to skip LLCS checks in the event certain requirements aren't met
boot()
{
    datatype="sync";
    qid=llReadKeyValue(o+suffix);
    llListenRemove(hear);
    integer chan=-(integer)("0x" + llGetSubString(llMD5String(o,0), 3, 6));
    if(chan>0)chan=-chan;//Makes sure the channel stays under 0
    //llSay(0,(string)chan);
    hear=llListen(chan,"","","");
    list rdata=llCSV2List(llLinksetDataRead("RespawnLocation"));
    if(llGetRegionName()==llList2String(rdata,0))
    {
        respawnloc=(vector)llList2String(rdata,2);
        if(respawnloc)llOwnerSay("Respawn location set to "+llList2String(rdata,1)+" at "+(string)respawnloc);
        respawn();
    }
    else llOwnerSay("No valid respawn location stored. You will respawn at the ground until one is set.");
    llcscheck();
    llOwnerSay("Ready\nRemaining Memory: "+(string)llGetFreeMemory());
}
llcscheck()
{
    if(~llGetParcelFlags(<128,128,0.0>)&PARCEL_FLAG_ALLOW_DAMAGE)
    {
        ++woronly;
        llOwnerSay("LLCS-support disabled due to damage being disabled in region center");
    }
    else if((integer)llGetEnv("death_action")!=3&&(integer)llGetEnv("allow_adjust_damage")==0)
    {
        ++woronly;
        llOwnerSay("LLCS-support disabled due to incompatible region settings");
    }
    else
    {
        woronly=0;
        llOwnerSay("LLCS-support enabled");
    }
}
/*
0 UUID: UUID of health meter. (If not found, other huds will ignore damage from the user)
1 LVL: Player levels.
2 EXP: Player EXP.
3 CHP: Current HP
4 MHP: Maximum HP.
5 SHP: Shield HP.
6 MSHP: Maximum Shield HP.
7 MRK: Marksmanship. Determines range-weapon damage.
8 STR: Strength. Determines melee-weapon damage.
9 DEF: Defense. Reduces weapon damage.
10 PWR: Power. Determines non-weapon damage (psionics, magic, etc)
11 RES: Resistance. Reduces non-weapon damage.
12 DGE: Dodge. Chance of evading an attack when hit.
13 PRC: Precision. Reduces the effectiveness of evasion.

Inventory:
0 Date
1 Strats
2 Scraps
3 Wood
4 Oil
5 MCs
6 Nutrients
7 Water
8 CCECs
9 Trinite
*/
float regentime=10.0;
string lastdmg;
damage(string dmg,string oid,integer heal)
{
    if(qid)return;//Don't attempt to process more than 1 request at a time.
    //flag,amt,index,defindex
    list self=llCSV2List(llLinksetDataReadProtected("Data",pass));
    integer chp=(integer)llList2String(self,3);
    if(chp<1)return;//Do not process damage if I'm dead
    //llRegionSayTo(pass,0,"Hit start: "+dmg);
    lastdmg=dmg+","+oid;
    if(heal)datatype="healdamage";
    else datatype="takedamage";
    qid=llReadKeyValue(oid+suffix);
}
npcdamage(string dmg, string npckey)
{
    list self=llCSV2List(llLinksetDataReadProtected("Data",pass));
    integer chp=(integer)llList2String(self,3);
    if(chp<1)return;
    //llRegionSayTo(pass,0,"Hit start: "+dmg);
    lastdmg=dmg;
    datatype="takedamage";
    qid=llReadKeyValue(npckey);
}
healdamage(list parse)
{
    qid="";
    if(llKey2Name(llList2String(parse,0))=="")return;//Not wearing hud
    else if((integer)llList2String(parse,3)<1)return;//Target is downed/dead
    list tdata=llCSV2List(lastdmg);
    list self=llCSV2List(llLinksetDataReadProtected("Data",pass));
    integer dmg=llFloor(((float)llList2String(tdata,0)/100.0)*
        (float)llList2String(parse,(integer)llList2String(tdata,1)));
    if(dmg<1)return;
    integer chp=(integer)llList2String(self,3);
    integer mhp=(integer)llList2String(self,4);
    //string debug="Hit for "+(string)dmg+".\nData: "+lastdmg+"\nPlayer Data: "+llList2CSV(parse);
    string hittext="Healed for "+(string)dmg+" by "+llKey2Name(llList2String(tdata,-1));
    llSetLinkPrimitiveParamsFast(1,[PRIM_TEXT,hittext,<0.0,1.0,0.0>,1.0]);
    string shooter=llList2String(parse,0);
    integer hitmarker=-(integer)("0x" + llGetSubString(llMD5String(shooter,0), 4, 7));
    //llOwnerSay(debug);
    if(chp==mhp)
    {
        hittext=llKey2Name(o)+" is at max HP!";
        llRegionSayTo(shooter,hitmarker,"resist,"+hittext);
        return;
    }
    else if(dmg)
    {
        //llTriggerSound("ebc2cec9-48a4-bdc8-dcc4-84c7aacc2e52",0.2);
        chp+=dmg;
        if(chp>mhp)chp=mhp;
    }
    if(chp<mhp)llRegionSayTo(shooter,hitmarker,"heal,"+llKey2Name(o)+" for "+(string)dmg);
    else llRegionSayTo(shooter,hitmarker,"heal,"+llKey2Name(o)+" is fully healed!");
    self=llListReplaceList(self,[chp,mhp],3,4);
    sync=llUpdateKeyValue(o+suffix,llList2CSV(self),1,llLinksetDataReadProtected("Data",pass));
    llSetTimerEvent(regentime);//Resets regen timer on hit.
}
processdamage(list parse)
{
    qid="";
    //llRegionSayTo(pass,0,"Hit proc: "+llList2CSV(parse));
    string shooter=llList2String(parse,0);
    if(shooter!="NPC")
    {
        if(llKey2Name(shooter)=="")return;//Not wearing hud
        else if((integer)llList2String(parse,3)<1)return;//Target is downed/dead
    }
    list tdata=llCSV2List(lastdmg);
    list self=llCSV2List(llLinksetDataReadProtected("Data",pass));
    integer dmg=llFloor(((float)llList2String(tdata,0)/100.0)*
        (float)llList2String(parse,(integer)llList2String(tdata,1)));
    if(llGetAgentInfo(o)&AGENT_FLYING)dmg=llFloor(dmg*1.5);//Flying vulnerability
    string def="0";
    integer defindex=(integer)llList2String(tdata,2);
    if(defindex>0)def=llList2String(self,defindex);
    integer hitmarker=-(integer)("0x" + llGetSubString(llMD5String(shooter,0), 4, 7));
    //llSay(0,lastdmg+"\nDEF: "+def+"\nATK: "+(string)dmg);
    if(dmg-(integer)def<1)
    {
        //llSay(0,(string)defindex+" | "+def+" | "+llList2CSV(self));
        if(dmg)llRegionSayTo(shooter,hitmarker,"resist,"+llKey2Name(o)+" is undamaged! (DEF: "+def+" / ATK: "+(string)dmg+")");
        return;
    }
    else dmg-=(integer)def;//Applies damage resistance where relevan
    integer dodge=(integer)llList2String(self,12)-(integer)llList2String(parse,13);
    if(dodge>0)
    {
        if(dodge>80&&llGetTime()<5.0)dodge=80;
        if(llFrand(100.0)<dodge)
        {
            if(dodge>80)llResetTime();
            if(shooter!="NPC")llRegionSayTo(shooter,hitmarker,"resist,"+llKey2Name(o)+" dodged the attack!");
            return;
        }
    }
    //llRegionSayTo(pass,0,"Hit confirm: "+(string)dmg);
    integer shp=(integer)llList2String(self,5);
    integer mshp=(integer)llList2String(self,6);
    integer chp=(integer)llList2String(self,3);
    integer mhp=(integer)llList2String(self,4);
    //string debug="Hit for "+(string)dmg+".\nData: "+lastdmg+"\nPlayer Data: "+llList2CSV(parse);
    string hittext;
    if(shooter!="NPC")hittext="Hit for "+(string)dmg+" by "+llKey2Name(llList2String(tdata,-1));
    else hittext="Hit for "+(string)dmg+" by "+llList2String(parse,1);
    llSetLinkPrimitiveParamsFast(1,[PRIM_TEXT,hittext,<1.0,0.5,0.5>,1.0]);
    //llOwnerSay(debug);
    if(shp>0)
    {
        if(shp>dmg)
        {
            llTriggerSound("72a4706b-f53c-9474-06e9-0d188d6315ad",0.2);
            shp-=dmg;
            if(shooter!="NPC")llRegionSayTo(shooter,hitmarker,"shield,"+llKey2Name(o)+" for "+(string)dmg);
            dmg=0;
            if(shp>mshp)shp=mshp;
        }
        else
        {
            llTriggerSound("22fc9638-ee55-f603-bc9d-6e6ec49b8622",1.0);
            dmg-=shp;
            shp=0;
        }
    }
    if(dmg)
    {
        llTriggerSound("ebc2cec9-48a4-bdc8-dcc4-84c7aacc2e52",0.2);
        if(chp>dmg)chp-=dmg;
        else chp=0;
        if(chp>mhp)chp=mhp;
        if(chp)
        {
            if(shooter!="NPC")llRegionSayTo(shooter,hitmarker,"dmg,"+llKey2Name(o)+" for "+(string)dmg);
        }
        else if(shooter!="NPC")
        {
            if(llVecDist(llGetPos(),respawnloc)>40.0)llRegionSayTo(shooter,hitmarker,"kill,[KILL] You downed "+llKey2Name(o));
            else llRegionSayTo(shooter,hitmarker,"kill,[SPAWNKILL] You downed "+llKey2Name(o));
        }
    }

    self=llListReplaceList(self,[chp,mhp,shp,mshp],3,6);
    sync=llUpdateKeyValue(o+suffix,llList2CSV(self),1,llLinksetDataReadProtected("Data",pass));
    if(chp<1)
    {
        dead();
        llLinksetDataWriteProtected("Data",llList2CSV(self),pass);
    }
    else llSetTimerEvent(regentime);//Resets regen timer on hit.
}
dead()
{
    if(hardcore)llSetTimerEvent(0.0);
    else llSetTimerEvent(regentime);
    llRequestPermissions(o,0x414);
}
regen()
{
    llSetLinkPrimitiveParamsFast(1,[PRIM_TEXT,"",ZERO_VECTOR,0.0]);
    list self=llCSV2List(llLinksetDataReadProtected("Data",pass));
    integer chp=(integer)llList2String(self,3);
    integer shp=(integer)llList2String(self,5);
    integer mshp=(integer)llList2String(self,6);
    integer mhp=(integer)llList2String(self,4);
    if(shp<mshp)
    {
        llTriggerSound("444b8265-8dc8-662b-eb29-49a09cb9f219",1.0);
        shp=mshp;
    }
    if(chp<1)
    {
        chp=llFloor((float)mhp*0.05);
        respawn();
    }
    else if(chp<mhp) chp+=llFloor((float)mhp*0.05);
    if(chp>mhp)chp=mhp;
    if(shp>mshp)shp=mshp;
    self=llListReplaceList(self,[chp,mhp,shp,mshp],3,6);
    sync=llUpdateKeyValue(o+suffix,llList2CSV(self),1,llLinksetDataReadProtected("Data",pass));
    if(shp==mshp&&chp==mhp)llSetTimerEvent(0.0);
    else llSetTimerEvent(1.0);
}
vector respawnloc;
string deathanim;
respawn()
{
    if(llGetPermissions())
    {
        if(deathanim)llStopAnimation(deathanim);
        llReleaseControls();
    }
    llRequestExperiencePermissions(o,"");
}
synclsd(list parse)
{
    parse=llListReplaceList(parse,[llGetKey()],0,0);
    llLinksetDataWriteProtected("Data",llList2CSV(parse),pass);
    updatetext();
}
integer slink;
integer hlink;
updatetext()
{
    //llSay(DEBUG_CHANNEL,"textupdate");
    list self=llCSV2List(llLinksetDataReadProtected("Data",pass));
    //llRegionSayTo(pass,0,llList2CSV(self));
    integer shp=(integer)llList2String(self,5);
    integer mshp=(integer)llList2String(self,6);
    integer chp=(integer)llList2String(self,3);
    integer mhp=(integer)llList2String(self,4);
    if(mhp==0||mshp==0)return;//Can't divide by zero
    float hdif=(float)chp/(float)mhp;
    if(hdif>1.0)hdif=1.0;
    float sdif=(float)shp/(float)mshp;
    if(sdif>1.0)sdif=1.0;
    if(chp>0)
        llSetLinkPrimitiveParamsFast(slink,[
        PRIM_TEXT,"SP: "+(string)shp+" / "+(string)mshp,<0.5,0.0,1.0>,htext,
            PRIM_SIZE,<0.24*sdif, 0.036765, 0.029412>,
            PRIM_DESC,(string)shp+","+(string)mshp,
        PRIM_LINK_TARGET,hlink,PRIM_TEXT,"HP: "+(string)chp+" / "+(string)mhp,<1.0,0.0,0.0>,htext,
            PRIM_SIZE,<0.24*hdif, 0.036765, 0.029412>,
            PRIM_DESC,(string)chp+","+(string)mhp]);
    else llSetLinkPrimitiveParamsFast(slink,[PRIM_TEXT,"",ZERO_VECTOR,0.0,PRIM_SIZE,<0.24,0.0,0.0>,PRIM_DESC,"0,0",
        PRIM_LINK_TARGET,hlink,PRIM_TEXT,"[DEAD]\nYou will teleported shortly...",<1.0,0.0,0.0>,1.0,PRIM_SIZE,<0.24,0.0,0.0>,PRIM_DESC,"0,0"]);
}
float htext=0.5;
integer dhear;
respawnselector()
{
    llListenRemove(dhear);
    dhear=llListen(-188,"",o,"");
    list parse=llCSV2List(llLinksetDataRead("Respawns"));
    list buttons;
    integer l=llGetListLength(parse);
    while(l--)
    {
        string item=llList2String(parse,l);
        if((vector)item==ZERO_VECTOR)buttons+=item;
    }
    llDialog(o,"Choose a spawn location",buttons,-188);
}
string cmenu;
menudialog(string menu)
{
    llListenRemove(dhear);
    dhear=llListen(-188,"",o,"");
    if(menu=="main")llDialog(o,"Choose an option",["Show Stats","Hide Stats","Reset","Character"],-188);
    else if(menu=="respawn")llDialog(o,"Choose an option",["RespawnList","RespawnNow","Hardcore"],-188);
    else if(menu=="combat")llDialog(o,"Choose an option",["HIT ON","HIT OFF","HealthText"],-188);
}
default
{
    changed(integer c)
    {
        if(c&CHANGED_REGION)
        {
            llOwnerSay("Region change detected. Rebooting...");
            llResetScript();
        }
    }
    state_entry()
    {
        llSetLinkPrimitiveParamsFast(-1,[PRIM_TEXT,"",ZERO_VECTOR,0.0]);
        integer l=llGetNumberOfPrims()+1;
        while(l--)
        {
            string name=llGetLinkName(l);
            if(name=="sp")slink=l;
            else if(name=="hp")hlink=l;
            //else if(name=="barbg")barbg=l;
        }
        o=(string)llGetOwner();
        datatype="ver";
        qid=llReadKeyValue("STRATUMWEAPONAUTH");
    }
    touch_start(integer t)
    {
        if(llGetLinkName(llDetectedLinkNumber(0))=="menu")
        {
            integer l=llDetectedTouchFace(0);
            cmenu="main";
            if(l)//0 = Equippanel toggle
            {
                if(l==1)menudialog("combat");
                else if(l==2)menudialog("respawn");
                else menudialog("main");
            }
            else llMessageLinked(-4,0,"tpanel","");
        }
    }
    listen(integer chan, string name, key id, string m)
    {
        //llSay(0,m);
        if(chan==-188)
        {
            if(cmenu=="respawn")
            {
                llListenRemove(dhear);
                list parse=llCSV2List(llLinksetDataRead("Respawns"));
                integer n=llListFindList(parse,[m]);
                if(n>-1)respawnloc=(vector)llList2String(parse,n+1);
                if(respawnloc)
                {
                    llLinksetDataWrite("RespawnLocation",llGetRegionName()+","+m+","+(string)respawnloc);
                    llOwnerSay("Respawn location set to "+m+" located at "+(string)respawnloc);
                    llRequestExperiencePermissions(o,"");
                }
                else llOwnerSay("No valid location found. You will respawn at the ground.");
            }
            else if(m=="RespawnList")
            {
                cmenu="respawn";
                datatype="respawn";
                qid=llReadKeyValue(llGetRegionName()+"_RESPAWN");
            }
            else if(m=="RespawnNow")
            {
                if(respawnloc)respawn();
                else llOwnerSay("No respawn location set!\nSelect one from 'RespawnList' before trying to use this feature.");
            }
            else if(m=="HIT ON")llMessageLinked(-4,1,"Hit reports enabled","");
            else if(m=="HIT OFF")llMessageLinked(-4,0,"Hit reports disabled","");
            else if(m=="Hardcore")
            {
                hardcore=!hardcore;
                if(hardcore)llOwnerSay("You will no longer automatically respawn when KO'd");
                else llOwnerSay("You will now automatically respawn after 10 seconds when KO'd");
            }
            else if(m=="HealthText")
            {
                if(htext>0.0)
                {
                    htext=0.0;
                    llOwnerSay("Health floating text disabled");
                }
                else
                {
                    htext=0.5;
                    llOwnerSay("Health floating text enabled");
                }
                updatetext();
            }
            else if(m=="Show Stats")llMessageLinked(-4,1,"showstats","");
            else if(m=="Hide Stats")llMessageLinked(-4,0,"showstats","");
            else if(m=="Reset")llResetScript();
        }
        else
        {
            key oid=id;
            id=llGetOwnerKey(id);
            list parse=llCSV2List(m);
            string type=llList2String(parse,0);
            parse=llDeleteSubList(parse,0,0);
            if(type=="dmg")damage(llList2CSV(parse),(string)id,0);
            else if(type=="npc")
            {
                //llSay(0,m);
                npcdamage(llList2CSV(parse),llList2String(parse,-1));
            }
            //npc,scale,index,resist,NPCKey
            else if(type=="heal")damage(llList2CSV(parse),(string)id,1);
            //Allows external tools to request the links for the SP and HP guages which will allow them to track a target's Shield and HP
            else if(type=="slink")llRegionSayTo(oid,(integer)llList2String(parse,1),(string)llGetLinkKey(slink));
            else if(type=="hlink")llRegionSayTo(oid,(integer)llList2String(parse,1),(string)llGetLinkKey(hlink));
            else if(m=="respawn"&&llVecDist(respawnloc,llGetPos())>8.0)respawn();
            else if(m=="reset")llResetScript();
        }
    }
    run_time_permissions(integer p)
    {
        if(p)
        {
            deathanim=llGetInventoryName(INVENTORY_ANIMATION,llFloor(llFrand(llGetInventoryNumber(INVENTORY_ANIMATION))));
            llTakeControls(CONTROL_FWD|CONTROL_BACK|CONTROL_UP|CONTROL_LEFT|CONTROL_RIGHT|CONTROL_DOWN,1,0);
            llStartAnimation(deathanim);
        }
    }
    experience_permissions(key id)
    {
        if(respawnloc)llTeleportAgent(o,"",respawnloc,<128,128,0.0>);
        else
        {
            vector pos=llGetPos();
            llOwnerSay("No respawn location saved. Teleporting to ground.");
            llTeleportAgent(o,"",<pos.x,pos.y,llGround(ZERO_VECTOR)+1.0>,<128,128,0.0>);
        }
        llSetTimerEvent(0.5);
    }
    attach(key id)
    {
        if(id)llResetScript();
        else llListenRemove(hear);
    }
    dataserver(key id, string data)
    {

        if(id!=qid&&id!=sync)return;
        else if((integer)llGetSubString(data,0,0))
        {
            data=llGetSubString(data,2,-1);
            if(id==sync)
            {
                list parse=llCSV2List(data);
                synclsd(parse);
            }
            else if(datatype=="takedamage")processdamage(llCSV2List(data));
            else if(datatype=="healdamage")healdamage(llCSV2List(data));
            else if(datatype=="respawn")
            {
                qid="";
                llLinksetDataWrite("Respawns",data);
                respawnselector();
            }
            else if(datatype=="ver")
            {
                if(llSubStringIndex(data,cver)<0&&o!=pass)
                {
                    llOwnerSay("[ERROR]Version mismatch.\n Grab a new copy where available and discard this item.");
                }
                else
                {
                    datatype="data";
                    qid=llReadKeyValue(o+suffix);
                }
            }
            else if(datatype=="data")boot();
            else if(datatype=="sync")//Called by boot()
            {
                synclsd(llCSV2List(data));
                sync=llUpdateKeyValue(o+suffix,llLinksetDataReadProtected("Data",pass),1,data);
                //llSay(0,data);
                qid="";
                updatetext();
            }
        }
        else //Cannot read experience data.
        {
            integer error=(integer)llGetSubString(data,2,-1);
            if(datatype=="data"&&error==14)
            {
                llOwnerSay("New player detected, creating data...");
                string output=(string)llGetKey()+",1,0,100,100,100,100,45,50,0,50,0,0,0,0,Cadet,CLASSCadet,0,0,0,0,0,0,0,0,0,0,0,0";
                datatype="data";
                qid=llCreateKeyValue(o+suffix,output);
                return;
            }
            //else if(datatype=="takedamage")return;
            else if(id==qid)llOwnerSay("[ERROR]\n Unable to process data. Reset when possible.\nDatatype: "
                +llToUpper(datatype)
                +"\nReason: "+llToUpper(llGetExperienceErrorMessage(error)));
            else if(id==sync)
            {
                /*llOwnerSay("[ERROR]\n Unable to boot. Reattach when possible.\nDatatype: SYNCUPDATE"
                +"\nReason: "+llToUpper(llGetExperienceErrorMessage(error)));*/
                 llOwnerSay("[ERROR] Player Desynced ["+(string)error+"]. Forcing reset...");
                 llResetScript();
            }
            qid="";
        }
    }
    on_damage(integer d)//https://youtu.be/Rqw4z1nJ5W4?si=L4Lfc8SRSRyv_N3x
    {
        if(woronly)return;//Terminates event if LLCS support doesn't meet requirements.
        list self=llCSV2List(llLinksetDataReadProtected("Data",pass));
        integer hp=(integer)llList2String(self,3);
        integer shp=(integer)llList2String(self,5);
        if(hp<1)
        {
            //while(d--)llAdjustDamage(d,0);//Prevents player from taking damage while waiting for respawn
            return;
        }
        else while(d--)//Note: This runs the list backwards
        {
            list damage=llDetectedDamage(d);
            integer type=llList2Integer(damage,1);
            //curamt,type,orgamt
            if(type>-1)
            {
                integer dmg=llList2Integer(damage,0);
                if(dmg>0)//Prevents healing effects from triggering code.
                {
                    if(shp>0)
                    {
                        string odmg=(string)dmg;
                        if(dmg>=shp)//Subtracts remaining shield from damage
                        {
                            dmg-=shp;
                            shp=0;
                        }
                        else //Shield damage
                        {
                            shp-=dmg;
                            dmg=0;
                        }
                        if(shp<1)llTriggerSound("22fc9638-ee55-f603-bc9d-6e6ec49b8622",1.0);
                        else llTriggerSound("72a4706b-f53c-9474-06e9-0d188d6315ad",0.2);
                        if(llSubStringIndex(llToLower(llDetectedName(d)),"npc")<0)//Do not report NPC damage
                        {
                            key shooter=llDetectedOwner(d);
                            llSetLinkPrimitiveParamsFast(1,[PRIM_TEXT,"[LLCS] Hit for "+odmg+" by "+llKey2Name(shooter),<1.0,0.5,0.5>,1.0]);
                            //integer hitmarker=-(integer)("0x" + llGetSubString(llMD5String(shooter,0), 4, 7));
                            //if(shp>0)llRegionSayTo(shooter,hitmarker,"shield,[LLCS] Hit "+llKey2Name(o)+" for "+odmg);
                            //else if(dmg)llRegionSayTo(shooter,hitmarker,"shield,[SHIELDBREAK]"+llKey2Name(o)+" for "+odmg);
                        }
                        else llSetLinkPrimitiveParamsFast(1,[PRIM_TEXT,"[LLCS] Hit for "+odmg+" by "+llDetectedName(d),<1.0,0.5,0.5>,1.0]);
                    }
                    if(dmg>0)//Checks to see if there is still damage
                    {
                        llTriggerSound("ebc2cec9-48a4-bdc8-dcc4-84c7aacc2e52",0.2);
                        hp-=dmg;//Health damage
                        if(llSubStringIndex(llToLower(llDetectedName(d)),"npc")<0)//Do not report NPC damage
                        {
                            key shooter=llDetectedOwner(d);
                            llSetLinkPrimitiveParamsFast(1,[PRIM_TEXT,"[LLCS] Hit for "+(string)dmg+" by "+llKey2Name(shooter),<1.0,0.5,0.5>,1.0]);
                            //integer hitmarker=-(integer)("0x" + llGetSubString(llMD5String(shooter,0), 4, 7));
                            //if(hp>0)llRegionSayTo(shooter,hitmarker,"dmg,[LLCS] Hit "+llKey2Name(o)+" for "+(string)dmg);
                            //else llRegionSayTo(shooter,hitmarker,"dmg,[KILL]"+llKey2Name(o)+" for "+(string)dmg);
                        }
                         else llSetLinkPrimitiveParamsFast(1,[PRIM_TEXT,"Hit for "+(string)dmg+" by "+llDetectedName(d),<1.0,0.5,0.5>,1.0]);
                    }
                }
            }
            llAdjustDamage(d,0.0);
        }
        if(hp<0)hp=0;//Prevents HP from reporting negative values
        if(shp<0)shp=0;
        if(hp!=(integer)llList2String(self,3)||shp!=(integer)llList2String(self,5))
        {
            if(hp<1)respawn();//Respawn automatically in LLCS mode
            self=llListReplaceList(self,[hp,llList2String(self,4),shp],3,5);
            sync=llUpdateKeyValue(o+suffix,llList2CSV(self),1,llLinksetDataReadProtected("Data",pass));
            llSetTimerEvent(regentime);//Resets regen timer on hit.
        }
    }
    timer()
    {
        regen();
    }
}
