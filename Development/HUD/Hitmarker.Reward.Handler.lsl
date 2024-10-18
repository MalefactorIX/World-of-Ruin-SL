integer hudtext;
list lasthit;
string pass="sameascore";
hittext(string text)
{
    list parse=llCSV2List(text);
    text=llList2String(parse,1);
    string type=llList2String(parse,0);
    vector color=<1.0,1.0,1.0>;//Normal
    if(type=="shield")color=<0.5,0.0,1.0>;
    else if(type=="heal")color=<0.0,1.0,0.0>;//Heal
    else if(type=="resist")color=ZERO_VECTOR;//Blocked/resisted
    else if(type=="kill")color=<1.0,0.0,0.0>;//PK
    ++hudtext;
    if(llGetListLength(lasthit)>3)lasthit=llDeleteSubList(lasthit,0,0);
    lasthit+=text+"\n";
    if(llStringLength((string)lasthit)>254)lasthit=llDeleteSubList(lasthit,0,0);
    llLinkPlaySound(hitmarker,"7b693a3c-2ccd-aeee-1526-992eaed8efae",1.0,0);
    /*vector pos=-llGetLocalPos();
    pos.x=pos.y;
    pos.y=0.0;*/
    llSetLinkPrimitiveParamsFast(prim,[PRIM_TEXT,(string)lasthit,<1.0,1.0,1.0>,1.0,
        PRIM_LINK_TARGET,hitmarker,PRIM_COLOR,-1,color,1.0/*,PRIM_POSITION,pos*/]);
    llResetTime();
    llSetTimerEvent(0.5);
}
cleartext()
{
    hudtext=0;
    lasthit=[];
    /*vector pos=-llGetLocalPos();
    pos.x=pos.y;
    pos.y=0.0;*/
    llSetLinkPrimitiveParamsFast(prim,[PRIM_TEXT,"",<1.0,1.0,1.0>,1.0,
        PRIM_LINK_TARGET,hitmarker,PRIM_COLOR,-1,ZERO_VECTOR,0.0/*,PRIM_POSITION,pos*/]);
    //llSay(0,(string)llGetLocalPos());
    llSetTimerEvent(0.5);
}
key o;
integer dchan;
integer prim;
integer on=1;
integer hear;
boot()
{
    llListenRemove(hear);
    dchan=-(integer)("0x" + llGetSubString(llMD5String(llGetKey(),0), 4, 7));
    hear=llListen(dchan,"","","");
    cleartext();
}
off()
{
    cleartext();
    //llListenRemove(hear);
    llSetTimerEvent(0.0);
}
integer hitmarker;
key qid;
string datatype;
string suffix="_DATA";
default
{
    state_entry()
    {
        integer prims=llGetNumberOfPrims()+1;
        while(prims--)
        {
            string name=llGetLinkName(prims);
            if(name=="relaytext")prim=prims;
            else if(name=="hitmarker")hitmarker=prims;
        }
        o=llGetOwner();
        boot();

    }
    link_message(integer s, integer n, string m, key id)//toggles
    {
        if(id)
        {
            on=n;
            if(on)boot();
            else off();
            llOwnerSay(m);
        }
    }
    listen(integer chan, string name, key id, string m)
    {
        //type,message
        if(on)hittext(m);
        if(llSubStringIndex(llToUpper(m),"SPAWNKILL")>-1)return;//Don't reward spawnkills
        list parse=llCSV2List(m);
        m=llList2String(parse,0);
        if(m=="kill")
        {
            if(qid)return;
            else if(llSameGroup(id))return;//Don't reward teamkills
            datatype="read";
            qid=llReadKeyValue((string)o+suffix);
        }
    }
    dataserver(key id, string data)
    {
        if(id!=qid)return;
        else if((integer)llGetSubString(data,0,0))
        {
            if(datatype=="read")
            {
                datatype="update";
                data=llGetSubString(data,2,-1);
                list parse=llCSV2List(data);
                parse=llListReplaceList(parse,[(integer)llList2String(parse,2)+10],2,2);
                qid=llUpdateKeyValue((string)o+suffix,llList2CSV(parse),1,data);
            }
            else if(datatype=="update")
            {
                llLinksetDataWriteProtected("Data",llGetSubString(data,2,-1),pass);
                qid="";
            }
            else qid="";
        }
        else qid="";
        /*{
            if((integer)llGetSubString(data,2,-1)==14)
            {
                llRegionSayTo(o,0,"No inventory key found. Making you one...");
                qid=llCreateKeyValue((string)o+"_STRATUMINV","10,0,0,0,0,0,0,0,0,0,0,0,0");
            }
            else qid="";
        }*/
    }
    attach(key id)
    {
        if(id)
        {
            if(id==o)
            {
                llSetLinkPrimitiveParamsFast(prim,[PRIM_TEXT,"",<1.0,1.0,1.0>,1.0]);
                if(on)boot();
            }
            else llResetScript();
        }
    }
    timer()
    {
        if(llGetAgentInfo(o)&AGENT_MOUSELOOK)
        {
            vector pos=-llGetLocalPos();
            pos.x=pos.y;
            pos.y=0.0;
            llSetLinkPrimitiveParamsFast(hitmarker,[PRIM_POSITION,pos]);
        }
        else llSetLinkPrimitiveParamsFast(hitmarker,[PRIM_POSITION,ZERO_VECTOR]);
        if(llGetTime()>4.0&&hudtext)cleartext();
        else llSetLinkAlpha(hitmarker,0.0,-1);
    }
}
