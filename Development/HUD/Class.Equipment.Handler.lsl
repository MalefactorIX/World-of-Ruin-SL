integer epanel;
integer epon;
tpanel()
{
    epon=!epon;
    llSetLinkAlpha(epanel,epon,-1);
}
key qid;//Used to rack dataserver requests
string suffix="_DATA";
string esuffix="_EQUIPMENT";
string datatype;
string o;
string pass="sameasbefore";//Used to secure linksetdata
loadclass(string data)
{
    list parse=llCSV2List(data);
    integer l=llGetListLength(parse);
    integer i=4;//Starts with max HP
    string current=llLinksetDataReadProtected("Data",pass);
    list self=llCSV2List(current);
    list leveldata=llParseString2List(llList2String(self,0),[";"],[""]);
    integer index=(integer)llList2String(parse,0);
    integer level=(integer)llList2String(llParseString2List(llList2String(self,1),[";"],[""]),index);
    //llSay(0,llList2CSV(self));
    while(i<l)
    {
        if(i==5)++i;//Skips current shield
        list stat=llParseString2List(llList2String(parse,i),[";"],[""]);
        float scale=(float)llList2String(stat,0);
        if(llGetListLength(stat)>1)scale=scale+(level*(integer)llList2String(stat,1));
        if(scale<0.0)scale=0.0;//Do not let a stat go below 0.
        self=llListReplaceList(self,[llFloor(scale)],i,i);
        ++i;
    }
    //llSay(0,llDumpList2String(self,","));
    //index=level index
    //parse,1 = Class Name (ie. Medic)
    //parse,2 = Class DataKey (ie. CLASSMedic)
    llOwnerSay("Setting class to "+llList2String(parse,1));
    llLinksetDataWriteProtected("ClassInfo",(string)index+","
        +llList2String(parse,1)+","
        +llList2String(parse,2),pass);
    self=llListReplaceList(self,llCSV2List(llLinksetDataReadProtected("ClassInfo",pass)),14,16);//Updates class information
    datatype="classload";
    synclsd(self);
    qid=llUpdateKeyValue(o+suffix,llLinksetDataReadProtected("Data",pass),1,current);
}
loadequip(string current)//Loads equipment stats
{
    list process=["HelmetInfo","ArmorInfo","LegInfo","AccInfo"];//Defines what keys to pull data from
    integer l=3;
    list self=llCSV2List(current);
    while(llGetListLength(self)<30)self+="0";//Corrects list length if it is too short.
    @start;
    string data=llLinksetDataReadProtected(llList2String(process,l),pass);
    if(llStringLength(data)&&data!="null")
    {
        list parse=llCSV2List(data);
        integer l=llGetListLength(parse);
        integer i=4;//Starts with max HP
        list leveldata=llParseString2List(llList2String(self,0),[";"],[""]);
        integer index=(integer)llList2String(parse,0);
        integer level=(integer)llList2String(llParseString2List(llList2String(self,1),[";"],[""]),index);
        //llSay(0,llList2CSV(self));
        while(i<l)
        {
            if(i==5)++i;//Skips current shield
            list stat=llParseString2List(llList2String(parse,i),[";"],[""]);
            float scale=(float)llList2String(stat,0);
            if(llGetListLength(stat)>1)scale=scale+(level*(integer)llList2String(stat,1));
            if(scale<0.0)scale=0.0;//Do not let a stat go below 0.
            self=llListReplaceList(self,[llFloor(scale)],i,i);
            ++i;
        }
        //llSay(0,llDumpList2String(self,","));
        string item=llList2String(parse,0);
        integer n=llSubStringIndex(item,";");
        string itemname=llGetSubString(item,n+1,-1);
        string ilevel=llList2String(parse,1);
        llOwnerSay("Equipping "+itemname+" [Lvl "+ilevel+"]");
        integer a;
        integer b;
        if(llSubStringIndex(item,"HELMET")>-1)
        {
            a=17;
            b=18;
        }
        else if(llSubStringIndex(item,"ARMOR")>-1)
        {
            a=19;
            b=20;
        }
        else if(llSubStringIndex(item,"LEGS")>-1)
        {
            a=21;
            b=22;
        }
        else if(llSubStringIndex(item,"MISC")>-1)
        {
            a=23;
            b=24;
        }
        self=llListReplaceList(self,[ilevel,llGetSubString(item,0,n-1)],a,b);
        /*ITEMS
        17 HELMET Level: Level for helmet item
        18 HELMET Key: Experience key used to pull stats for item
        19 ARMOR Level: Level for armor item
        20 ARMOR Key: Experience key used to pull stats for item
        21 LEG Level: Level for leg attachment item
        22 LEG Key: Experience key used to pull stats for item
        23 MISC Level: Level for MISC/Accessory item
        24 MISC Key: Experience key used to pull stats for item*/
    }
    if(l--)jump start;
    datatype="equipupdate";
    synclsd(self);
    qid=llUpdateKeyValue(o+suffix,llLinksetDataReadProtected("Data",pass),1,current);
}
synclsd(list parse)
{
    parse=llListReplaceList(parse,[llGetKey()],0,0);
    llLinksetDataWriteProtected("Data",llList2CSV(parse),pass);
}
/*
0 Item Experience Key;Name
1 LVL: Item Level
2 DESC: Item description
3 CHP: DO NOT SET
4 MHP: Maximum HP.
5 SHP: DO NOT SET
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
8 AECs
9 Trinite
*/
//Equipment
integer hear;
integer dialoghear;
menu(list data, string type)
{
    integer l=llGetListLength(data);
    integer s=llStringLength(type);//To cut off prefix
    integer chan=llFloor(llFrand(-10000.0))-100;
    llListenRemove(dialoghear);
    while(l--)
    {
        string item=llList2String(data,l);
        if(llSubStringIndex(item,type)<0)data=llDeleteSubList(data,l,l);//Delete invalid options
        else
        {
            string entry=llList2String(llParseString2List(item,[";"],[]),0);
            data=llListReplaceList(data,[llGetSubString(entry,s,-1)],l,l);
        }
    }
    if(llGetListLength(data))
    {
        dialoghear=llListen(chan,"",o,"");
        llDialog(o,"Pick an item to equip",data,chan);
    }
    else llOwnerSay("You have no items of that type!");
}
integer staticchan;//API channel
default
{
    state_entry()
    {
        integer l=llGetNumberOfPrims()+1;
        while(l--)
        {
            if(llGetLinkName(l)=="equip")epanel=l;
        }
        o=llGetOwner();
        staticchan=-(integer)("0x" + llGetSubString(llMD5String(o,0), 3, 6));
        llListen(staticchan,"","","");
        datatype="equipcheck";
        qid=llReadKeyValue((string)o+esuffix);
        tpanel();
        llOwnerSay("Equipment Handler: "+(string)llGetFreeMemory()+"kb free");
    }
    attach(key id)
    {
        if(id)
        {
            if(id!=o)llResetScript();
            else
            {
                datatype="equipcheck";
                qid=llReadKeyValue((string)o+esuffix);
            }
        }
    }
    touch_start(integer t)
    {
        if(epon<1)return;
        else if(llDetectedLinkNumber(0)==epanel)
        {
            integer panel=llDetectedTouchFace(0);
            //llSay(0,(string)panel);
            if(panel<4)
            {
                list menuop=["HELMET","ARMOR","LEGS","MISC"];
                string data=llList2String(menuop,panel);
                datatype="menu"+data;
                qid=llReadKeyValue((string)o+esuffix);
            }
        }
    }
    listen(integer chan, string name, key id, string m)
    {
        //key oid=id;
        //id=llGetOwnerKey(id);
        if(chan==staticchan)//API messages
        {
            list parse=llCSV2List(m);
            string type=llList2String(parse,0);
            if(type=="class")
            {
                //llOwnerSay("Class update request recieved...");
                datatype="getclass";
                qid=llReadKeyValue(llList2String(parse,1));
            }
        }
        else //Dialog box
        {
            if(llGetSubString(datatype,0,3)=="menu")//We picked an item, get info to confirm.
            {
                m=llGetSubString(datatype,4,-1)+m;
                datatype="iteminfo";
                qid=llReadKeyValue(m);
            }
            else if(m=="EQUIP")
            {
                string info=llLinksetDataReadProtected("Iteminfo",pass);
                string item=llGetSubString(info,0,llSubStringIndex(info,";")-1);
                llSay(0,item);
                if(llSubStringIndex(item,"HELMET")>-1)llLinksetDataWriteProtected("HelmetInfo",info,pass);
                else if(llSubStringIndex(item,"ARMOR")>-1)llLinksetDataWriteProtected("ArmorInfo",info,pass);
                else if(llSubStringIndex(item,"LEGS")>-1)llLinksetDataWriteProtected("LegsInfo",info,pass);
                else if(llSubStringIndex(item,"MISC")>-1)llLinksetDataWriteProtected("AccInfo",info,pass);
                else
                {
                    llSay(0,"ERROR: Cannot read item type");
                    return;
                }
                datatype="getlvl"+item;//Pulls item level from player's equipment storage
                qid=llReadKeyValue((string)o+esuffix);
            }
            else llListenRemove(dialoghear);
        }
    }
    dataserver(key id, string data)
    {
        if(qid!=id)return;
        else if((integer)llGetSubString(data,0,0))
        {
            data=llGetSubString(data,2,-1);
            if(datatype=="getclass")loadclass(data);
            else if(datatype=="classload")loadequip(data);//Load equipment after class
            else if(llGetSubString(datatype,0,3)=="menu")menu(llCSV2List(data),llGetSubString(datatype,4,-1));
            else if(datatype=="iteminfo")//Load item name and description and request confirmation. Preload stats for item.
            {
                llLinksetDataWriteProtected("Iteminfo",data,pass);//Store to call later.
                list parse=llCSV2List(data);
                string text="Name: "+llList2String(llParseString2List(llList2String(parse,0),[";"],[]),1)
                    +"\n[Desc]\n"+llList2String(parse,2);
                integer chan=llFloor(llFrand(-10000.0))-100;
                llListenRemove(dialoghear);
                dialoghear=llListen(chan,"",o,"");
                llDialog(o,text,["EQUIP","CANCEL"],chan);
            }
            else if(llGetSubString(datatype,0,5)=="getlvl")
            {
                string name=llGetSubString(datatype,6,-1);
                list parse=llCSV2List(data);
                integer l=llGetListLength(parse);
                while(l--)//Goes through all equipment to see if we have what we need
                {
                    string item=llList2String(parse,l);
                    if(llSubStringIndex(item,name)>-1)
                    {
                        l=0;
                        parse=llParseString2List(item,[";"],[""]);
                        item=llList2String(parse,1);//Just reusing this variable. It's the item level
                        string info=llLinksetDataReadProtected("Iteminfo",pass);
                        parse=llCSV2List(info);
                        parse=llListReplaceList(parse,[item],1,1);
                        info=llList2CSV(parse);
                        if(llSubStringIndex(item,"HELMET")>-1)llLinksetDataWriteProtected("HelmetInfo",info,pass);
                        else if(llSubStringIndex(item,"ARMOR")>-1)llLinksetDataWriteProtected("ArmorInfo",info,pass);
                        else if(llSubStringIndex(item,"LEGS")>-1)llLinksetDataWriteProtected("LegsInfo",info,pass);
                        else if(llSubStringIndex(item,"MISC")>-1)llLinksetDataWriteProtected("AccInfo",info,pass);
                    }
                    else if(l<1)
                    {
                        llOwnerSay("You do not have that item!");
                        return;
                    }
                }
                loadclass(llLinksetDataReadProtected("ClassInfo",pass));//Triggers full reload
            }
        }
        else
        {
            data=llGetSubString(data,2,-1);
            if(datatype=="equipcheck"&&data=="14")
            {
                datatype="newuser";
                llOwnerSay("No equipment information found. Issuing items...");
                qid=llCreateKeyValue((string)llGetOwner()+"_EQUIPMENT","HELMETExo;1;1,HELMETSkin;1;1,HELMETMetal;1;1,ARMORMuscles;1;1,ARMORFat;1;1,ARMORSkinny;1;1,LEGSFurry;1;1,LEGSNormal;1;1,LEGSRobot;1;1");
            }
            else llOwnerSay("[Class/Equip Error] "+data+"\nDatatype: "+llToUpper(datatype));
        }
    }
    link_message(integer s, integer n, string m, key id)
    {
        if(id)return;
        else if(m=="tpanel")tpanel();
        else if(m=="updatestats")loadclass(llLinksetDataReadProtected("ClassInfo",pass));
    }
}
