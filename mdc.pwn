

// Define
#define MDC_PAGE_MAIN 						(1)
#define MDC_PAGE_LOOKUP 					(2)
#define MDC_PAGE_WARRANTS					(3)
#define MDC_PAGE_EMERGENCY					(4)
#define MDC_PAGE_ROSTER						(5)
#define MDC_PAGE_DATABASE					(6)
#define MDC_PAGE_CCTV						(7)
#define MDC_PAGE_STAFF						(8)
#define MDC_PAGE_VEHICLEBOLO 		(9)

#define MDC_PAGE_LOOKUP_NAME				(10)
#define MDC_PAGE_LOOKUP_PLATE				(11)
#define MDC_PAGE_LOOKUP_BUILDING			(21)

new PlayerText:MDC_Main[MAX_PLAYERS][18];
new PlayerText:MDC_MainScreen[MAX_PLAYERS][8];

new PlayerText:MDC_LookUp_Name[MAX_PLAYERS][18];
new PlayerText:MDC_LookUp_Vehicle[MAX_PLAYERS][17];
new PlayerText:MDC_AdressDetails[MAX_PLAYERS][14];
new PlayerText:MDC_CrimeHistory[MAX_PLAYERS][24];
new PlayerText:MDC_SelectedCrimeDetails[MAX_PLAYERS][6];
new PlayerText:MDC_ManageLicense[MAX_PLAYERS][34];
new PlayerText:MDC_PenalCode[MAX_PLAYERS][49];

new PlayerText:MDC_Emergency[MAX_PLAYERS][24];
new PlayerText:MDC_EmergencyDetails[MAX_PLAYERS][5];

new PlayerText:MDC_CriminalRecords[MAX_PLAYERS][21];
new PlayerText:MDC_CriminalRecordDetail[MAX_PLAYERS][5];

new PlayerText:MDC_Warrants[MAX_PLAYERS][24];
new PlayerText:MDC_Roster[MAX_PLAYERS][40];
new PlayerText:MDC_CCTV[MAX_PLAYERS][17];
//new PlayerText:MDC_ADRESSICON[MAX_PLAYERS][1];
new PlayerText:MDC_VehicleBolo_Details[MAX_PLAYERS][6];
new PlayerText:MDC_VehicleBolo_List[MAX_PLAYERS][23];

new lastBoloModel[MAX_PLAYERS][24],
		lastBoloPlate[MAX_PLAYERS][24],
		lastBoloCrimes[MAX_PLAYERS][512],
		lastBoloReportShow[MAX_PLAYERS][512],
		lastBoloReport[MAX_PLAYERS][512];

new MDC_PlayerLastSearched[MAX_PLAYERS][24],
		MDC_PlastLastSearched_SQLID[MAX_PLAYERS];

new Player_CCTVPage[MAX_PLAYERS];
new MDC_CallsID[MAX_PLAYERS][7];
new MDC_BolosID[MAX_PLAYERS][21];
new MDC_CriminalDataID[MAX_PLAYERS][MAX_CRIMINALDATA_SHOW];
new MDC_PenalID[MAX_PLAYERS][20];


new MDC_ArrestRecordCount[MAX_PLAYERS] = 0,
		MDC_ArrestRecord[MAX_PLAYERS][31][128];



CMD:mdc(playerid, params[])
{
	if(!IsPoliceFaction(playerid))
		return UnAuthMessage(playerid);

	if(GetPVarInt(playerid, "OnPlayerUseMDC") == 1)
	{
		MDC_Hide(playerid);
		SetPVarInt(playerid, "OnPlayerUseMDC", 0);
		return 1;
	}

	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		if(CarData[vehicleid][carFaction] == -1) return SendErrorMessage(playerid, "Herhangi bir birlik aracı içerisinde değilsin.");
		if(!FactionData[CarData[vehicleid][carFaction]][FactionCopPerms]) return SendClientMessage(playerid, COLOR_ADM, "SERVER: Bu araçta MDC kullanamazsın.");

		if(GetPlayerVehicleSeat(playerid) > 1) return SendErrorMessage(playerid, "Arka koltukta MDC kullanamazsın.");

		SelectTextDraw(playerid, 0x030103FF);
		ShowMDCPage(playerid, MDC_PAGE_MAIN);
		SetPVarInt(playerid, "OnPlayerUseMDC", 1);
		return 1;
	}
	else if(PlayerData[playerid][pInsideEntrance] != -1)
	{
		if(PlayerData[playerid][pFaction] != EntranceData[PlayerData[playerid][pInsideEntrance]][EntranceFaction])
			return SendErrorMessage(playerid, "Bu bina senin birliğine ait değil.");

		SelectTextDraw(playerid, 0x030103FF);
		ShowMDCPage(playerid, MDC_PAGE_MAIN);
		SetPVarInt(playerid, "OnPlayerUseMDC", 1);
	}
	else SendErrorMessage(playerid, "Bu komutu kullanmak için birliğine ait bir binada veya birliğine ait bir araçta olmalısın.");
	return 1;
}


public ClickDynamicPlayerTextdraw(playerid, PlayerText:playertextid)
{
	CallOnPlayerClickPlayerTextDraw(playerid, playertextid);

	if(playertextid == MDC_Main[playerid][4])
	{
			MDC_Hide(playerid);
	}

	if(playertextid == MDC_Main[playerid][10])
	{
			ShowMDCPage(playerid, MDC_PAGE_MAIN);
	}

	if(playertextid == MDC_Main[playerid][11])
	{
			ShowMDCPage(playerid, MDC_PAGE_LOOKUP);
	}

	/*if(playertextid == MDC_Main[playerid][12])
	{
			ShowMDCPage(playerid, MDC_PAGE_WARRANTS);
	}*/

	if(playertextid == MDC_Main[playerid][13])
	{
			ShowMDCPage(playerid, MDC_PAGE_EMERGENCY);
	}

	if(playertextid == MDC_Main[playerid][14])
	{
			ShowMDCPage(playerid, MDC_PAGE_ROSTER);
	}

	if(playertextid == MDC_Main[playerid][15])
	{
			SendErrorMessage(playerid, "MDC içerisinde CCTV kullanama şu anda devre dışı.");
			//ShowMDCPage(playerid, MDC_PAGE_CCTV);
	}

	if(playertextid == MDC_Main[playerid][16])
	{
			ShowMDCPage(playerid, MDC_PAGE_VEHICLEBOLO);
	}


	if(playertextid == MDC_LookUp_Name[playerid][0]) // İsim Seçeneği
	{
			MDC_LOOKUP_SelectOption(playerid, MDC_PAGE_LOOKUP_NAME);
	}

	if(playertextid == MDC_LookUp_Name[playerid][1]) // Plaka Seçeneği
	{
			MDC_LOOKUP_SelectOption(playerid, MDC_PAGE_LOOKUP_PLATE);
	}

	if(playertextid == MDC_LookUp_Name[playerid][17]) // Mekan Seçeneği
	{
			MDC_LOOKUP_SelectOption(playerid, MDC_PAGE_LOOKUP_BUILDING);
	}


	if(playertextid == MDC_PenalCode[playerid][48])
	{
		new page = GetPVarInt(playerid, "penalcodelist_idx");

		MDC_ShowPenalCode(playerid, page + 1);
	}

	if(playertextid == MDC_PenalCode[playerid][37])
	{
		Dialog_Show(playerid, MDC_PenalCode_Filter, DIALOG_STYLE_INPUT, "Filtre Uygula", "Filtrelemek istediğiniz suçlamanın bir kısmını girin veya filtreyi sıfırlamak için boş bırakın.", "Ara", "Vazgeç");
	}

	if(playertextid == MDC_PenalCode[playerid][36])
	{
		PlayerTextDrawSetString(playerid, MDC_PenalCode[playerid][37], "_filtre_uygula_...");
		PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][37], -1802201857);
		PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][37], -1);

		MDC_ShowPenalCode(playerid);
		RefreshChargeButton(playerid);
	}

	if(playertextid == MDC_PenalCode[playerid][47])
	{
		new page = GetPVarInt(playerid, "penalcodelist_idx");

		MDC_ShowPenalCode(playerid, page - 1);
	}

	if(playertextid == MDC_LookUp_Name[playerid][2]) // Bu bast��� o text girme yeri.
	{
			if(GetPVarInt(playerid,"MDC_SearchMode") == 1)
				Dialog_Show(playerid, MDC_LookUp_EnterBox, DIALOG_STYLE_INPUT, "Veri Girin", "Kimi arıyorsunuz?", "Ara", "Vazgeç");

			if(GetPVarInt(playerid,"MDC_SearchMode") == 2)
				Dialog_Show(playerid, MDC_LookUp_EnterBox, DIALOG_STYLE_INPUT, "Veri Girin", "Kimi arıyorsunuz?\nPlaka aramasıysa direkt olarak plakayı gir.\nAra� ID üzerindense, 'id:ARA�ID' şeklinde girmelisin (�rn: id:120)", "Ara", "Vazgeç");
	}
	if(playertextid == MDC_LookUp_Name[playerid][3]) // Refresh butonu
	{
		MDC_LookUp_Refresh(playerid);
	}


	if(playertextid == MDC_LookUp_Name[playerid][9])
	{
		MDC_ShowAddress(playerid, MDC_PlastLastSearched_SQLID[playerid]);
	}

	if(playertextid == MDC_AdressDetails[playerid][5])
	{
		SetAddresMapPosition(playerid, GetPVarFloat(playerid, "ShowAddressID1_X"), GetPVarFloat(playerid, "ShowAddressID1_Y"));
	}

	if(playertextid == MDC_AdressDetails[playerid][6])
	{
		SetAddresMapPosition(playerid, GetPVarFloat(playerid, "ShowAddressID2_X"), GetPVarFloat(playerid, "ShowAddressID2_Y"));
	}

	if(playertextid == MDC_AdressDetails[playerid][7])
	{
		SetAddresMapPosition(playerid, GetPVarFloat(playerid, "ShowAddressID3_X"), GetPVarFloat(playerid, "ShowAddressID3_Y"));
	}

	if(playertextid == MDC_LookUp_Name[playerid][14])
	{

	}

	if(playertextid == MDC_CriminalRecords[playerid][14])
	{
		MDC_HideAfterPage(playerid);
	}



	if(playertextid == MDC_LookUp_Name[playerid][12]) // Penal Code'a gitme butonu
	{
		MDC_ShowPenalCode(playerid);
	}

	if(playertextid == MDC_LookUp_Name[playerid][13]) // Tutuklama Raporu
	{
		new query_warrants[128];
		mysql_format(m_Handle, query_warrants, sizeof(query_warrants), "SELECT id, by_id, reason FROM player_arrest WHERE player_id = %i AND active = 1", MDC_PlastLastSearched_SQLID[playerid]);
		new Cache:cache = mysql_query(m_Handle, query_warrants);

		if(!cache_num_rows())
		{
			Dialog_Show(playerid, MDC_ArrestRecord, DIALOG_STYLE_INPUT, "Tutuklama Kaydı", "Yazmaya başladığınızda tutuklama kaydınız burada gözükecek.", "Devam", "İptal Et");
		}
		else
		{
			new prison_record[1028], by_id, idx;
			cache_get_value_name(0, "reason", prison_record, 1028);
			cache_get_value_name_int(0, "by_id", by_id);
			cache_get_value_name_int(0, "id", idx);

			SetPVarInt(playerid, "AskDeleteRecordID", idx);

			new ask_dialog[1028];
			strcat(ask_dialog, sprintf("{FFFFFF}%s adlı kişinin zaten tutuklama raporu %s tarafandan yazılmış. Silmek ister misin?", MDC_PlayerLastSearched[playerid], ReturnSQLName(by_id)));
			strcat(ask_dialog, sprintf("\n\n{FFFFFF}(( Geçerli tutuklama raporu )):\n{FFFFFF}%s", prison_record));

			Dialog_Show(playerid, MDC_AskDeleteRecord, DIALOG_STYLE_MSGBOX, "Tutuklama Kaydı", ask_dialog, "Evet", "Hayır");
		}
		cache_delete(cache);
	}


	if(playertextid == MDC_LookUp_Name[playerid][10]) // Lisans yönetimi
	{
		MDC_ShowManageLicense(MDC_PlastLastSearched_SQLID[playerid], playerid);
	}

	if(playertextid == MDC_AdressDetails[playerid][0])
	{
		MDC_HideAfterPage(playerid);

		MDC_ReturnLastSearch(playerid);
	}

	if(playertextid == MDC_ManageLicense[playerid][0])
	{
		MDC_HideAfterPage(playerid);

		MDC_ReturnLastSearch(playerid);
	}

	if(playertextid == MDC_PenalCode[playerid][16])
	{
		MDC_HideAfterPage(playerid);

		PlayerTextDrawSetString(playerid, MDC_PenalCode[playerid][37], "_filtre_uygula_...");
		PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][37], -1802201857);
		PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][37], -1);

		MDC_ReturnLastSearch(playerid);
	}

	if(playertextid == MDC_ManageLicense[playerid][6]) // Sürücü Lisansı iptal etme
	{
		foreach(new pl : Player)
		{
			if(strlen(MDC_PlayerLastSearched[playerid]) == strlen(ReturnName(pl, 0)))
			{
				if(PlayerData[pl][pDriversLicense] == false)
					return SendErrorMessage(playerid, "Bu kişi bir ehliyete sahip değil.");

				PlayerData[pl][pDriversLicense] = false;
			}
		}
		new query[256];
		format(query, sizeof(query), "SELECT * FROM `players` WHERE `Name` = '%s'", MDC_PlayerLastSearched[playerid]);
		new Cache:cache = mysql_query(m_Handle, query);

		new dl;
		if(cache_num_rows())
		{
			cache_get_value_name_int(0, "DriversLicense", dl);
			cache_delete(cache);
		}

		if(dl == 0)
			return SendErrorMessage(playerid, "Bu kişi bir ehliyete sahip değil.");

		mysql_format(m_Handle, query, sizeof(query), "UPDATE players SET DriversLicense = 0 WHERE id = %i", MDC_PlastLastSearched_SQLID[playerid]);
		mysql_tquery(m_Handle, query);
		MDC_ShowManageLicense(MDC_PlastLastSearched_SQLID[playerid], playerid);
		SendLawMessage(PlayerData[playerid][pFaction], COLOR_COP, sprintf("** HQ Duyurusu: %s %s, %s adlı kişinin ehliyetini iptal etti. **", Player_GetFactionRank(playerid), ReturnName(playerid, 1), MDC_PlayerLastSearched[playerid]));
	}

	if(playertextid == MDC_ManageLicense[playerid][7]) // Sürücü Lisansı uyarma
	{
		foreach(new pl : Player)
		{
			if(strlen(MDC_PlayerLastSearched[playerid]) == strlen(ReturnName(pl, 0)))
			{
				if(PlayerData[pl][DriversLicenseWarning] == 2)
					{
						PlayerData[pl][pDriversLicense] = false;
						PlayerData[pl][DriversLicenseWarning] = 0;
						SaveSQLInt(PlayerData[pl][pSQLID], "players", "DriversLicense", PlayerData[pl][pDriversLicense]);
						SaveSQLInt(PlayerData[pl][pSQLID], "players", "DriversLicenseWarning", PlayerData[pl][DriversLicenseWarning]);
						MDC_ShowManageLicense(MDC_PlastLastSearched_SQLID[playerid], playerid);
						SendLawMessage(PlayerData[playerid][pFaction], COLOR_COP, sprintf("** HQ Duyurusu: %s %s, %s adlı kişinin ehliyetine ���nc� uyar� sebebiyle el koydu. **", Player_GetFactionRank(playerid), ReturnName(playerid, 1), MDC_PlayerLastSearched[playerid]));

						return 1;
					}

				if(PlayerData[pl][pDriversLicense] != true)
					return SendErrorMessage(playerid, "Ehliyeti olmayan birisine uyarı puanı veremezsiniz.");

				PlayerData[pl][DriversLicenseWarning] +=1;
			}
		}

		new query_properties[128];
		format(query_properties, sizeof(query_properties), "SELECT * FROM `players` WHERE `Name` = '%s'", MDC_PlayerLastSearched[playerid]);
		new Cache:cache = mysql_query(m_Handle, query_properties);

		new warnings, dl;
		if(cache_num_rows())
		{
			cache_get_value_name_int(0, "DriversLicenseWarning", warnings);
			cache_get_value_name_int(0, "DriversLicense", dl);
			cache_delete(cache);
		}

		if(dl == 0)
			return SendErrorMessage(playerid, "Ehliyeti olmayan birisine uyarı puanı veremezsiniz.");

		mysql_format(m_Handle, query_properties, sizeof(query_properties), "UPDATE players SET DriversLicenseWarning = %d WHERE id = %i", warnings+1, MDC_PlastLastSearched_SQLID[playerid]);
		mysql_tquery(m_Handle, query_properties);
		MDC_ShowManageLicense(MDC_PlastLastSearched_SQLID[playerid], playerid);
		SendLawMessage(PlayerData[playerid][pFaction], COLOR_COP, sprintf("** HQ Duyurusu: %s %s, %s adlı kişinin ehliyetine uyarı puanı verdi. **", Player_GetFactionRank(playerid), ReturnName(playerid, 1), MDC_PlayerLastSearched[playerid]));
	}


	if(playertextid == MDC_ManageLicense[playerid][14]) // Medikal Lisans iptal etme
	{
		foreach(new pl : Player)
		{
			if(strlen(MDC_PlayerLastSearched[playerid]) == strlen(ReturnName(pl, 0)))
			{
				if(PlayerData[pl][pMedicalLicense] == false)
					return SendErrorMessage(playerid, "Bu kişi bir medikal lisansına sahip değil.");

				PlayerData[pl][pMedicalLicense] = false;
			}
		}
		new query[256];
		format(query, sizeof(query), "SELECT * FROM `players` WHERE `Name` = '%s'", MDC_PlayerLastSearched[playerid]);
		new Cache:cache = mysql_query(m_Handle, query);

		new dl;
		if(cache_num_rows())
		{
			cache_get_value_name_int(0, "MedicalLicense", dl);
			cache_delete(cache);
		}

		if(dl == 0)
			return SendErrorMessage(playerid, "Bu kişi bir medikal lisansa sahip değil.");

		mysql_format(m_Handle, query, sizeof(query), "UPDATE players SET MedicalLicense = 0 WHERE id = %i", MDC_PlastLastSearched_SQLID[playerid]);
		mysql_tquery(m_Handle, query);
		MDC_ShowManageLicense(MDC_PlastLastSearched_SQLID[playerid], playerid);
		SendLawMessage(PlayerData[playerid][pFaction], COLOR_COP, sprintf("** HQ Duyurusu: %s %s, %s adlı kişinin medikal lisansını iptal etti. **", Player_GetFactionRank(playerid), ReturnName(playerid, 1), MDC_PlayerLastSearched[playerid]));
	}

	if(playertextid == MDC_ManageLicense[playerid][30])
	{
		foreach(new pl : Player)
		{
			if(strlen(MDC_PlayerLastSearched[playerid]) == strlen(ReturnName(pl, 0)))
			{
				if(PlayerData[pl][pMedicalLicense] == true)
					return SendErrorMessage(playerid, "Bu kişi zaten bir medikal lisansa sahip.");

				PlayerData[pl][pMedicalLicense] = true;
			}
		}
		new query[256];
		format(query, sizeof(query), "SELECT * FROM `players` WHERE `Name` = '%s'", MDC_PlayerLastSearched[playerid]);
		new Cache:cache = mysql_query(m_Handle, query);

		new dl;
		if(cache_num_rows())
		{
			cache_delete(cache);
			cache_get_value_name_int(0, "MedicalLicense", dl);
		}

		if(dl == 1)
		{
			SendErrorMessage(playerid, "Bu kişi zaten bir medikal lisansa sahip.");
			return 1;
		}

		mysql_format(m_Handle, query, sizeof(query), "UPDATE players SET MedicalLicense = 1 WHERE id = %i", MDC_PlastLastSearched_SQLID[playerid]);
		mysql_tquery(m_Handle, query);
		MDC_ShowManageLicense(MDC_PlastLastSearched_SQLID[playerid], playerid);
		SendLawMessage(PlayerData[playerid][pFaction], COLOR_COP, sprintf("** HQ Duyurusu: %s %s, %s adlı kişinin medikal lisansı verdi. **", Player_GetFactionRank(playerid), ReturnName(playerid, 1), MDC_PlayerLastSearched[playerid]));
	}

	if(playertextid == MDC_ManageLicense[playerid][21]) // Silah lisansı verme
	{
		if(13 > PlayerData[playerid][pFactionRank])
			return SendErrorMessage(playerid, "Bu komutu SGT1+ üzeri kullanabilir.");

		foreach(new pl : Player)
		{
			if(strlen(MDC_PlayerLastSearched[playerid]) == strlen(ReturnName(pl, 0)))
			{
				if(PlayerData[pl][pWeaponsLicense] == true)
					return SendErrorMessage(playerid, "Bu kişi zaten silah lisansına sahip.");

				PlayerData[pl][pWeaponsLicense] = true;
			}
		}
		new query[256];
		format(query, sizeof(query), "SELECT * FROM `players` WHERE `Name` = '%s'", MDC_PlayerLastSearched[playerid]);
		new Cache:cache = mysql_query(m_Handle, query);

		new dl;
		if(cache_num_rows())
		{
			cache_get_value_name_int(0, "WeaponsLicense", dl);
			cache_delete(cache);
		}

		if(dl == 1)
			return SendErrorMessage(playerid, "Bu kişi zaten silah lisansına sahip.");

		mysql_format(m_Handle, query, sizeof(query), "UPDATE players SET WeaponsLicense = 1 WHERE id = %i", MDC_PlastLastSearched_SQLID[playerid]);
		mysql_tquery(m_Handle, query);

		MDC_ShowManageLicense(MDC_PlastLastSearched_SQLID[playerid], playerid);
		SendLawMessage(PlayerData[playerid][pFaction], COLOR_COP, sprintf("** HQ Duyurusu: %s %s, %s adlı kişiye silah lisansı verdi. **", Player_GetFactionRank(playerid), ReturnName(playerid, 1), MDC_PlayerLastSearched[playerid]));
	}

	if(playertextid == MDC_ManageLicense[playerid][20]) // Silah lisans� iptal
	{
		if(13 > PlayerData[playerid][pFactionRank])
			return SendErrorMessage(playerid, "Bu komutu SGT1+ üzeri kullanabilir.");

		foreach(new pl : Player)
		{
			if(strlen(MDC_PlayerLastSearched[playerid]) == strlen(ReturnName(pl, 0)))
			{
				if(PlayerData[pl][pWeaponsLicense] == false)
					return SendErrorMessage(playerid, "Bu kişi silah lisansına sahip değil.");

				PlayerData[pl][pWeaponsLicense] = false;
			}
		}
		new query[256];
		format(query, sizeof(query), "SELECT * FROM `players` WHERE `Name` = '%s'", MDC_PlayerLastSearched[playerid]);
		new Cache:cache = mysql_query(m_Handle, query);

		new dl;
		if(cache_num_rows())
		{
			cache_get_value_name_int(0, "WeaponsLicense", dl);
			cache_delete(cache);
		}

		if(dl == 0)
			return SendErrorMessage(playerid, "Bu kişi silah lisansına sahip değil.");

		mysql_format(m_Handle, query, sizeof(query), "UPDATE players SET WeaponsLicense = 0 WHERE id = %i", MDC_PlastLastSearched_SQLID[playerid]);
		mysql_tquery(m_Handle, query);
		MDC_ShowManageLicense(MDC_PlastLastSearched_SQLID[playerid], playerid);
		SendLawMessage(PlayerData[playerid][pFaction], COLOR_COP, sprintf("** HQ Duyurusu: %s %s, %s adlı kişinin silah lisansını iptal etti. **", Player_GetFactionRank(playerid), ReturnName(playerid, 1), MDC_PlayerLastSearched[playerid]));
	}

	if(playertextid == MDC_PenalCode[playerid][0]) // Penal Code geri gelme butonu, geri döndükten sonra en son kimi aratt��� tekrar ��kmal�.
	{
		MDC_HideAfterPage(playerid);

		MDC_ReturnLastSearch(playerid);
	}

	for(new is = 17; is < 36; is++)
	{
	  if(playertextid == MDC_PenalCode[playerid][is]) // Penal Code listeden suç seçme ve detaylarını görme
		{
			RefreshChargeButton(playerid);
 			MDC_SelectCharges(playerid, MDC_PenalID[playerid][is-17]);
			SetPVarInt(playerid, "lastPenalCodeID", MDC_PenalID[playerid][is-17]);
		}
	}

	if(playertextid == MDC_PenalCode[playerid][46])
	{
		MDC_AddCharge(playerid, GetPVarInt(playerid, "lastPenalCodeID"));
	}

	if(playertextid == MDC_PenalCode[playerid][38])
	{
		if(GetPVarInt(playerid, "chargeATT") == 0)
		{
			PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][38]);
			SetPVarInt(playerid, "chargeATT", 1);
			PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][38], 0x54744DFF);
			PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][38]);
		}else
		{
			PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][38]);
			SetPVarInt(playerid, "chargeATT", 0);
			PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][38], -1802201857);
			PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][38]);
		}
	}

	if(playertextid == MDC_PenalCode[playerid][39])
	{
		if(GetPVarInt(playerid, "chargeSOL") == 0)
		{
			PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][39]);
			SetPVarInt(playerid, "chargeSOL", 1);
			PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][39], 0x54744DFF);
			PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][39]);
		}else
		{
			PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][39]);
			SetPVarInt(playerid, "chargeSOL", 0);
			PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][39], -1802201857);
			PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][39]);
		}
	}

	if(playertextid == MDC_PenalCode[playerid][40])
	{
		if(GetPVarInt(playerid, "chargeGOV") == 0)
		{
			PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][42]);
			PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][40]);
			SetPVarInt(playerid, "chargeGOV", 1);
			PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][40], 0x54744DFF);
			PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][40]);
			PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][42], 0);
			PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][42]);

			SetPVarInt(playerid, "chargeTime", CalculateChargeTime(playerid, GetPVarInt(playerid, "lastPenalCodeID")));
			EditChargeDescription(playerid, GetPVarInt(playerid, "lastPenalCodeID"));
		}else
		{
			PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][40]);
			PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][42]);
			SetPVarInt(playerid, "chargeGOV", 0);
			PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][40], -1802201857);
			PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][40]);
			PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][42], 1);
			PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][42]);

			SetPVarInt(playerid, "chargeTime", CalculateChargeTime(playerid, GetPVarInt(playerid, "lastPenalCodeID")));
			EditChargeDescription(playerid, GetPVarInt(playerid, "lastPenalCodeID"));
		}
	}

	if(playertextid == MDC_PenalCode[playerid][41])
	{
		if(GetPVarInt(playerid, "chargeCAC") == 0)
		{
			PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][41]);
			SetPVarInt(playerid, "chargeCAC", 1);
			PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][41], 0x54744DFF);
			PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][41]);
		}else
		{
			PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][41]);
			SetPVarInt(playerid, "chargeCAC", 0);
			PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][41], -1802201857);
			PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][41]);
		}
	}

	if(playertextid == MDC_PenalCode[playerid][42])
	{
		if(GetPVarInt(playerid, "chargeAAF") == 0)
		{
			PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][40]);
			PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][42]);
			SetPVarInt(playerid, "chargeAAF", 1);
			PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][42], 0x54744DFF);
			PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][42]);
			PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][40], 0);
			PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][40]);

			SetPVarInt(playerid, "chargeTime", CalculateChargeTime(playerid, GetPVarInt(playerid, "lastPenalCodeID")));
			EditChargeDescription(playerid, GetPVarInt(playerid, "lastPenalCodeID"));
		}else
		{
			PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][40]);
			PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][42]);
			SetPVarInt(playerid, "chargeAAF", 0);
			PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][42], -1802201857);
			PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][42]);
			PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][40], 1);
			PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][40]);

			SetPVarInt(playerid, "chargeTime", CalculateChargeTime(playerid, GetPVarInt(playerid, "lastPenalCodeID")));
			EditChargeDescription(playerid, GetPVarInt(playerid, "lastPenalCodeID"));
		}
	}


	if(playertextid == MDC_Emergency[playerid][4] || playertextid == MDC_Emergency[playerid][9] || playertextid == MDC_Emergency[playerid][14] || playertextid == MDC_Emergency[playerid][19]) // İhbar detayı görme
	{
		//MDC_HideAfterPage(playerid);
		ShowEmergencyCallDetail(playerid, playertextid);
	}

	if(playertextid == MDC_Emergency[playerid][3] || playertextid == MDC_Emergency[playerid][8] || playertextid == MDC_Emergency[playerid][13] || playertextid == MDC_Emergency[playerid][18]) // ihbar el koyma
	{
		HandleEmergency(playerid, playertextid);
	}

	if(playertextid == MDC_Emergency[playerid][20]) // ileri tuşu
	{
		new page = GetPVarInt(playerid, "emergencylist_idx");

		ShowEmergencyCalls(playerid, page + 1);
	}

	if(playertextid == MDC_Emergency[playerid][21]) // geri tuşu
	{
		new page = GetPVarInt(playerid, "emergencylist_idx");

		if(page == 0)
			return 1;

		ShowEmergencyCalls(playerid, page - 1);
	}

	if(playertextid == MDC_EmergencyDetails[playerid][4]) // ihbar detayından geri dönme butonu
	{
		for(new is = 0; is < 5; is++)
		{
	 		PlayerTextDrawHide(playerid, MDC_EmergencyDetails[playerid][is]);
		}
		ShowEmergencyCalls(playerid, GetPVarInt(playerid, "emergencylist_idx"));
	}


	if(playertextid == MDC_LookUp_Name[playerid][11]) // Sorgulanan kişinin ceza kayıtlarına gider
	{
		Show_CriminalData(playerid);
	}

	if(playertextid == MDC_CrimeHistory[playerid][21])
	{
		new page = GetPVarInt(playerid, "criminaldatalist_idx");
		Show_CriminalData(playerid, page + 1);
	}

	if(playertextid == MDC_CrimeHistory[playerid][22])
	{
		new page = GetPVarInt(playerid, "criminaldatalist_idx");
		Show_CriminalData(playerid, page - 1);
	}

	if(playertextid == MDC_CrimeHistory[playerid][23]) // Sorgulanan ceza kayıtlarından geri gider
	{
		MDC_HideAfterPage(playerid);
		MDC_ReturnLastSearch(playerid);
	}

	for(new id = 1; id < 21; id++)
	{
	  if(playertextid == MDC_CrimeHistory[playerid][id]) // Sorgulanan kişinin ceza kayıtlarından bir tanesine basma butonlarından
		{
			MDC_HideAfterPage(playerid);
			Show_CriminalDataDetail(playerid, MDC_CriminalDataID[playerid][id-1]);
		}
	}

	if(playertextid == MDC_SelectedCrimeDetails[playerid][4]) // Sorgulanan kişinin suç kayıtlarından seçilmiş suçun detayından geri dönme tuşu
	{
		Show_CriminalData(playerid);
	}

	if(playertextid == MDC_SelectedCrimeDetails[playerid][5])
	{
		new prison_string[1028];
		GetPVarString(playerid, "lastPrisonRecord", prison_string, sizeof(prison_string));

		Dialog_Show(playerid, DIALOG_DEFAULT, DIALOG_STYLE_MSGBOX, "Tutuklama Kayd�", prison_string, "Tamam", "");
	}

	if(playertextid == MDC_VehicleBolo_List[playerid][0])
	{

		format(lastBoloModel[playerid], 24, "");
		format(lastBoloPlate[playerid], 24, "");
		format(lastBoloCrimes[playerid], 512, "");
		format(lastBoloReport[playerid], 512, "");
		format(lastBoloReportShow[playerid], 512, "");

		new dialog[512], str[512];
		format(str, sizeof(str), "{FFFFFF}                   {8D8DFF}Los Santos Police Department{FFFFFF}                   {FFFFFF} {FFFFFF}");
		strcat(dialog, str);
		format(str, sizeof(str), "\n{FFFFFF}                   {FF8282}BOLO KAYDI{FFFFFF}                   {FFFFFF} {FFFFFF}");
		strcat(dialog, str);
		format(str, sizeof(str), "\n\n{FFFFFF}Arac�n Modeli ve rengi nedir?\n�rnek: Siyah Tampa");
		strcat(dialog, str);
		Dialog_Show(playerid, MDC_AddVehicleBolo_Model, DIALOG_STYLE_INPUT, "BOLO KAYDI", dialog, "Devam", "�ptal Et");
	}

	for(new is = 0; is < 6; is++)
	{
		if(playertextid == MDC_VehicleBolo_Details[playerid][is])
		{

		}
	}

	if(playertextid == MDC_VehicleBolo_List[playerid][22])
	{

		new page = GetPVarInt(playerid, "vbololist_idx");
		Show_VehicleBolos(playerid, page + 1);
	}

	if(playertextid == MDC_VehicleBolo_List[playerid][21])
	{

		new page = GetPVarInt(playerid, "vbololist_idx");
		Show_VehicleBolos(playerid, page - 1);
	}

	if(playertextid == MDC_VehicleBolo_Details[playerid][0])
	{
		new boloid = GetPVarInt(playerid, "boloLastID");

		new query[512];
		mysql_format(m_Handle, query, sizeof(query), "DELETE FROM vehicle_bolos WHERE id = %d", boloid);
		mysql_tquery(m_Handle, query);

		Show_VehicleBolos(playerid);
	}


	if(playertextid == MDC_VehicleBolo_Details[playerid][1])
	{
		Show_VehicleBolos(playerid, GetPVarInt(playerid, "vbololist_idx"));
	}

	for(new is = 1; is < 21; is++)
	{
		if(playertextid == MDC_VehicleBolo_List[playerid][is])
		{
			MDC_HideAfterPage(playerid);
			ShowVehicleBoloDetails(playerid, is);
		}
	}
	return 1;
}
stock RefreshChargeButton(playerid)
{
	SetPVarInt(playerid, "chargeGOV", 0);
	SetPVarInt(playerid, "chargeAAF", 0);
	SetPVarInt(playerid, "chargeSOL", 0);
	SetPVarInt(playerid, "chargeATT", 0);
	SetPVarInt(playerid, "chargeCAC", 0);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][38], -1802201857);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][39], -1802201857);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][40], -1802201857);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][41], -1802201857);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][42], -1802201857);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][42], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][40], 1);
	return 1;
}

stock MDC_AddCharge(playerid, charge)
{
	new gov = GetPVarInt(playerid, "chargeGOV");
	new aaf = GetPVarInt(playerid, "chargeAAF");
	new att = GetPVarInt(playerid, "chargeATT");
	new sol = GetPVarInt(playerid, "chargeSOL");
	new cac = GetPVarInt(playerid, "chargeCAC");

	new query[1028];
	mysql_format(m_Handle, query, sizeof(query), "INSERT INTO player_charges (type, player_dbid, issuer, active, minute, charge_name, charge_id, gov, aaf, att, sol, cac, time) VALUES (1, %d, %d, 1, %d,'%e', %d, %d, %d, %d, %d, %d, %d)", MDC_PlastLastSearched_SQLID[playerid], PlayerData[playerid][pSQLID], CalculateChargeTime(playerid, charge), ReturnChargeName(charge), charge, gov, aaf, att, sol, cac, gettime());
	mysql_tquery(m_Handle, query);

	MDC_ShowPenalCode(playerid);

	SendLawMessage(PlayerData[playerid][pFaction], COLOR_COP, sprintf("** HQ Duyurusu: %s %s, %s adlı kişi üzerinde %d dakikalık suçlamada bulundu. **", Player_GetFactionRank(playerid), ReturnName(playerid, 1), MDC_PlayerLastSearched[playerid], CalculateChargeTime(playerid, charge)));
	RefreshChargeButton(playerid);
	return 1;
}

CalculateChargeTime(playerid, charge)
{
	new time = ReturnChargeTime(charge);
	new gov = GetPVarInt(playerid, "chargeGOV");
	new aaf = GetPVarInt(playerid, "chargeAAF");

	if(gov == 1)
	{
		time = time + (time * 66 / 100);
	}
	if(aaf == 1)
	{
		time = time/2;
	}
	return time;
}

ReturnChargeName(id)
{
	new query[129], penal[64];
	mysql_format(m_Handle, query, sizeof(query), "SELECT penal FROM penalcode_list WHERE id = %i", id);
	new Cache: cache = mysql_query(m_Handle, query);
	cache_get_value_name(0, "penal", penal, sizeof(penal));
	cache_delete(cache);
	return penal;
}

ReturnChargeTime(id)
{
	new query[129];
	mysql_format(m_Handle, query, sizeof(query), "SELECT minute FROM penalcode_list WHERE id = %i", id);
	new Cache: cache = mysql_query(m_Handle, query);

	new charge_time;
	cache_get_value_name_int(0, "minute", charge_time);
	cache_delete(cache);
	return charge_time;
}

Server:ShowVehicleBoloDetails(playerid, i)
{
	new id = MDC_BolosID[playerid][i - 1];
	SetPVarInt(playerid, "boloLastID", id);

	new vbolo_details[256];
	format(vbolo_details, 256, "#%d~n~%s_%s~n~%s~n~%s~n~%s", id, Player_GetFactionRank(playerid), GetBoloAuthor(id), GetBoloModel(id), GetBoloPlate(id), GetFullTime(GetBoloDate(id)));
	PlayerTextDrawSetString(playerid, MDC_VehicleBolo_Details[playerid][3], FixWord256(vbolo_details));

	new vbolo_crimes[256];
	format(vbolo_crimes, 256, "%s", GetBoloCrime(id));
	PlayerTextDrawSetString(playerid, MDC_VehicleBolo_Details[playerid][4], FixWord256(vbolo_crimes));

	new vbolo_report[256];
	format(vbolo_report, 256, "%s", GetBoloReport(id));
	PlayerTextDrawSetString(playerid, MDC_VehicleBolo_Details[playerid][5], FixWord256(vbolo_report));

	for(new is = 0; is < 6; is++)
	{
		PlayerTextDrawShow(playerid, MDC_VehicleBolo_Details[playerid][is]);
	}
	return 1;
}

GetBoloReport(id)
{
	new query[75], n_text[256];
	mysql_format(m_Handle, query, sizeof(query), "SELECT report FROM vehicle_bolos WHERE id = %i LIMIT 1", id);
	new Cache: cache = mysql_query(m_Handle, query);
	cache_get_value_name(0, "report", n_text);
	cache_delete(cache);
	return n_text;
}

GetBoloCrime(id)
{
	new query[75], n_text[256];
	mysql_format(m_Handle, query, sizeof(query), "SELECT crimes FROM vehicle_bolos WHERE id = %i LIMIT 1", id);
	new Cache: cache = mysql_query(m_Handle, query);
	cache_get_value_name(0, "crimes", n_text);
	cache_delete(cache);
	return n_text;
}

GetBoloPlate(id)
{
	new query[75], n_text[32];
	mysql_format(m_Handle, query, sizeof(query), "SELECT plate FROM vehicle_bolos WHERE id = %i LIMIT 1", id);
	new Cache: cache = mysql_query(m_Handle, query);
	cache_get_value_name(0, "plate", n_text);
	cache_delete(cache);
	return n_text;
}

GetBoloModel(id)
{
	new query[75], n_text[64];
	mysql_format(m_Handle, query, sizeof(query), "SELECT model FROM vehicle_bolos WHERE id = %i LIMIT 1", id);
	new Cache: cache = mysql_query(m_Handle, query);
	cache_get_value_name(0, "model", n_text);
	cache_delete(cache);
	return n_text;
}

GetBoloDate(id)
{
	new query[75], n_time;
	mysql_format(m_Handle, query, sizeof(query), "SELECT time FROM vehicle_bolos WHERE id = %i LIMIT 1", id);
	new Cache: cache = mysql_query(m_Handle, query);
	cache_get_value_name_int(0, "time", n_time);
	cache_delete(cache);
	return n_time;
}

GetBoloAuthor(id)
{
	new query[75], n_text[24];
	mysql_format(m_Handle, query, sizeof(query), "SELECT author FROM vehicle_bolos WHERE id = %i LIMIT 1", id);
	new Cache: cache = mysql_query(m_Handle, query);
	cache_get_value_name(0, "author", n_text);
	cache_delete(cache);
	return n_text;
}

Dialog:MDC_AskDeleteRecord(playerid, response, listitem, inputtext[])
{
	new id = GetPVarInt(playerid, "AskDeleteRecordID");
	if(response)
	{
		new query[64];
		mysql_format(m_Handle, query, sizeof(query), "DELETE FROM player_arrest WHERE id = %d", id);
		mysql_tquery(m_Handle, query);
	}
	return 1;
}

Dialog:MDC_ArrestRecord(playerid, response, listitem, inputtext[])
{
	if(response)
	{
			MDC_ArrestRecordCount[playerid] = 0;

			strcat(MDC_ArrestRecord[playerid][MDC_ArrestRecordCount[playerid]], inputtext);
			strcat(MDC_ArrestRecord[playerid][MDC_ArrestRecordCount[playerid]], "\n");
			MDC_ArrestRecordCount[playerid]+=1;

			new str_dialog[512];
			strcat(str_dialog, sprintf("{FFFFFF}%s için tutuklama kaydı.\niptal etmek için {FF6347}iptal{FFFFFF}, tamamlamak için {33AA33}bitir {FFFFFF}yaz.\n", MDC_PlayerLastSearched[playerid]));
			strcat(str_dialog, "\n\n");

			for(new is; is < MDC_ArrestRecordCount[playerid]; is++)
			{
					strcat(str_dialog, MDC_ArrestRecord[playerid][is]);
			}
			Dialog_Show(playerid, MDC_ArrestRecord_Add, DIALOG_STYLE_INPUT, sprintf("Tutuklama Kaydı (5 satırdan %d)", MDC_ArrestRecordCount[playerid]), str_dialog, "İleri", "Geri Al");
			return 1;
	}
	return 1;
}

Dialog:MDC_ArrestRecord_Add(playerid, response, listitem, inputtext[])
{
	if(response)
	{
			if(strfind(inputtext, "iptal", true) != -1)
			{
				for(new is; is < MDC_ArrestRecordCount[playerid]; is++)
				{
					format(MDC_ArrestRecord[playerid][is], 128, "");
				}

				MDC_ArrestRecordCount[playerid] = 0;
				return 1;
			}


			if(strfind(inputtext, "bitir", true) != -1)
			{
				CreateArrestRecord(playerid);
				return 1;
			}

			new str_dialog[512];

			if(MDC_ArrestRecordCount[playerid] > 4)
			{
				strcat(str_dialog, "Daha fazla ekleyemezsin.\n");
				strcat(str_dialog, sprintf("{FFFFFF}%s için tutuklama kaydı.\niptal etmek için {FF6347}iptal{FFFFFF}, tamamlamak için {33AA33}bitir {FFFFFF}yaz.\n", MDC_PlayerLastSearched[playerid]));
				strcat(str_dialog, "\n\n");
				for(new is; is < MDC_ArrestRecordCount[playerid]; is++)
				{
					strcat(str_dialog, MDC_ArrestRecord[playerid][is]);
					strcat(str_dialog, "\n");
				}
				Dialog_Show(playerid, MDC_ArrestRecord_Add, DIALOG_STYLE_INPUT, sprintf("Tutuklama Kaydı (5 satırdan %d)", MDC_ArrestRecordCount[playerid]), str_dialog, "İleri", "Geri Al");
				return 1;
			}

			strcat(MDC_ArrestRecord[playerid][MDC_ArrestRecordCount[playerid]], inputtext);
			strcat(MDC_ArrestRecord[playerid][MDC_ArrestRecordCount[playerid]], "\n");
			MDC_ArrestRecordCount[playerid]+=1;

			strcat(str_dialog, sprintf("{FFFFFF}%s için tutuklama kaydı.\niptal etmek için {FF6347}iptal{FFFFFF}, tamamlamak için {33AA33}bitir {FFFFFF}yaz.\n", MDC_PlayerLastSearched[playerid]));
			strcat(str_dialog, "\n\n");
			for(new is; is < MDC_ArrestRecordCount[playerid]; is++)
			{
				strcat(str_dialog, MDC_ArrestRecord[playerid][is]);
			}
			Dialog_Show(playerid, MDC_ArrestRecord_Add, DIALOG_STYLE_INPUT, sprintf("Tutuklama Kaydı (5 satırdan %d)", MDC_ArrestRecordCount[playerid]), str_dialog, "İleri", "Geri Al");
			return 1;
	}
	else
	{
		MDC_ArrestRecordCount[playerid] -=1;
		format(MDC_ArrestRecord[playerid][MDC_ArrestRecordCount[playerid]], 128, "");

		if(MDC_ArrestRecordCount[playerid] > 0)
		{
			new str_dialog[512];
			strcat(str_dialog, sprintf("{FFFFFF}%s için tutuklama kaydı.\niptal etmek için {FF6347}iptal{FFFFFF}, tamamlamak için {33AA33}bitir {FFFFFF}yaz.\n", MDC_PlayerLastSearched[playerid]));
			strcat(str_dialog, "\n\n");

			for(new is; is < MDC_ArrestRecordCount[playerid]; is++)
			{
					strcat(str_dialog, MDC_ArrestRecord[playerid][is]);
			}

			Dialog_Show(playerid, MDC_ArrestRecord_Add, DIALOG_STYLE_INPUT, sprintf("Tutuklama Kaydı (5 satırdan %d)", MDC_ArrestRecordCount[playerid]), str_dialog, "İleri", "Geri Al");
			return 1;
		}

		for(new is; is < 6; is++)
		{
				format(MDC_ArrestRecord[playerid][is], 128, "");
		}
	}
	return 1;
}

Server:CreateArrestRecord(playerid)
{
	new str_entry[5 * 128];

	for(new is; is < MDC_ArrestRecordCount[playerid]; is++)
	{
			strcat(str_entry, MDC_ArrestRecord[playerid][is]);
			format(MDC_ArrestRecord[playerid][is], 128, "");
	}

	MDC_ArrestRecordCount[playerid] = 0;

	new query[1028];
	mysql_format(m_Handle, query, sizeof(query), "INSERT INTO player_arrest (by_id, player_id, reason, time, active) VALUES (%d, %d, '%e', %i, %i)", PlayerData[playerid][pSQLID], MDC_PlastLastSearched_SQLID[playerid], str_entry, gettime(), 1);
	mysql_tquery(m_Handle, query);
	return 1;
}

Dialog:MDC_PenalCode_Filter(playerid, response, listitem, inputtext[])
{
	if(!response) return 1;

	if(strlen(inputtext) < 3)
	{
		Dialog_Show(playerid, MDC_PenalCode_Filter, DIALOG_STYLE_INPUT, "Filtre Uygula", "Bulmak istediğiniz şeyi 3 kelime ile bulamazsanız.\nFiltrelemek istediğiniz suçlamanın bir kısmını girin veya filtreyi sıfırlamak için boş bırakın.", "Ara", "Vazgeç");
		return 1;
	}

	new query[512];
	mysql_format(m_Handle, query, sizeof(query), "SELECT penal, id, category, category_name FROM penalcode_list WHERE selectable = 1");
	new Cache:cache = mysql_query(m_Handle, query);

	MDC_HideAfterPage(playerid);

	PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][37]);
	PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][36]);
	PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][16]);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][37], -1802201857);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][37], -1);

	new searchbox[128];
	if(ContainsInvalidCharactersMDC(inputtext))
	{
		MDC_ShowPenalCode(playerid);
		RefreshChargeButton(playerid);

		PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][37]);

		format(searchbox, sizeof(searchbox), "Hata: Gecersiz girdi formati.");

		PlayerTextDrawSetString(playerid, MDC_PenalCode[playerid][37], searchbox);
		PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][37], 0x9E1729FF);
		PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][37], 0xFFFFFFFF);
		PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][37]);
		return 1;
	}
	else
	{
		PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][37], 0xFFFFFFFF);
		PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][37], 0x232323FF);

		format(searchbox, sizeof(searchbox), "%s", inputtext);
		PlayerTextDrawSetString(playerid, MDC_PenalCode[playerid][37], FixWord128(searchbox));
		PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][37]);
	}

	new countdown = 0, strtext = 17, lastcategory = -1, penalid = -1;

	for(new i = 0, j = cache_num_rows(); i < j; i++)
	{
		if(countdown > 12)
			return 1;

		new id, penal[128], category;

			cache_get_value_name_int(i, "id", id);
			cache_get_value_name(i, "penal", penal, 128);

			if(strfind(penal, inputtext, true) != -1)
			{

				cache_get_value_name_int(i, "category", category);

				if(category != lastcategory)
				{
					if (countdown + 2 > 15)
						return 1;

					new category_name[128];
					cache_get_value_name(i, "category_name", category_name, 128);

					if(strlen(category_name) > 34)
					{
						format(category_name, sizeof(category_name), "%.33s...", category_name);
					}


					PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][strtext], 0);
					PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][strtext], -1);
					PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][strtext], 0x333333FF);
					PlayerTextDrawSetString(playerid, MDC_PenalCode[playerid][strtext], FixWord128(category_name));
					PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][strtext]);
					strtext+=1;
					penalid+=1;
				}

				if(strlen(penal) > 34)
				{
					format(penal, sizeof(penal), "%.33s...", penal);
				}

				PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][strtext], 1);
				PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][strtext], -1802201857);
				PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][strtext], -1);
				PlayerTextDrawSetString(playerid, MDC_PenalCode[playerid][strtext], FixWord128(penal));
				PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][strtext]);
				penalid+=1;
				MDC_PenalID[playerid][penalid] = id;

				countdown = countdown + 1;
				strtext+=1;
				lastcategory = category;
		}
	}

	if(countdown == 0)
	{
			format(searchbox, sizeof(searchbox), "Hata: Eslesme bulunamadi.");

			PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][37]);
			PlayerTextDrawSetString(playerid, MDC_PenalCode[playerid][37], searchbox);
			PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][37], 0x9E1729FF);
			PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][37], 0xFFFFFFFF);
			PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][37]);
			return 1;
	}

	cache_delete(cache);
	return 1;
}


Dialog:MDC_AddVehicleBolo_Model(playerid, response, listitem, inputtext[])
{
	if(!response) return 0;


	format(lastBoloModel[playerid], 24, "%s", inputtext);
	// MDC_LookUp_EnterBox
	new dialog[1028], str[1028];
	format(str, sizeof(str), "{FFFFFF}                   {8D8DFF}Los Santos Police Department{FFFFFF}                   {FFFFFF} {FFFFFF}");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF}                   {FF8282}BOLO KAYDI{FFFFFF}                   {FFFFFF} {FFFFFF}");
	strcat(dialog, str);
	format(str, sizeof(str), "\n\n{FF6347}Araç Modeli:");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloModel[playerid]);
	strcat(dialog, str);
	format(str, sizeof(str), "\n\n{FFFFFF}Aracın plakası nedir?");
	strcat(dialog, str);

	Dialog_Show(playerid, MDC_AddVehicleBolo_Plate, DIALOG_STYLE_INPUT, "BOLO KAYDI", dialog, "Devam", "İptal Et");
	return 1;
}

Dialog:MDC_AddVehicleBolo_Plate(playerid, response, listitem, inputtext[])
{

	if(!response) return 0;

	format(lastBoloPlate[playerid], 24, "%s", inputtext);
	new dialog[1028], str[1028];
	format(str, sizeof(str), "{FFFFFF}                   {8D8DFF}Los Santos Police Department{FFFFFF}                   {FFFFFF} {FFFFFF}");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF}                   {FF8282}BOLO KAYDI{FFFFFF}                   {FFFFFF} {FFFFFF}");
	strcat(dialog, str);
	format(str, sizeof(str), "\n\n{FF6347}Araç Modeli:");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloModel[playerid]);
	strcat(dialog, str);
	format(str, sizeof(str), "\n\n{FF6347}Araç Plakası:");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloPlate[playerid]);
	strcat(dialog, str);
	format(str, sizeof(str), "\n\n{FFFFFF}BOLO ne için?");
	strcat(dialog, str);

	Dialog_Show(playerid, MDC_ABolo_Charges, DIALOG_STYLE_INPUT, "BOLO KAYDI", dialog, "Devam", "İptal Et");
	return 1;
}

Dialog:MDC_ABolo_Charges(playerid, response, listitem, inputtext[])
{
	if(!response) return 0;

	if(strlen(inputtext) > 70)
	{
		new dialog[1028], str[1028];
		format(str, sizeof(str), "{FFFFFF}                   {8D8DFF}Los Santos Police Department{FFFFFF}                   {FFFFFF} {FFFFFF}");
		strcat(dialog, str);
		format(str, sizeof(str), "\n{FFFFFF}                   {FF8282}BOLO KAYDI{FFFFFF}                   {FFFFFF} {FFFFFF}");
		strcat(dialog, str);
		format(str, sizeof(str), "\n\n{FF6347}Araç Modeli:");
		strcat(dialog, str);
		format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloModel[playerid]);
		strcat(dialog, str);
		format(str, sizeof(str), "\n\n{FF6347}Araç Plakası:");
		strcat(dialog, str);
		format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloPlate[playerid]);
		strcat(dialog, str);
		format(str, sizeof(str), "\n\n{FFFFFF}BOLO ne için?");
		strcat(dialog, str);

		format(str, sizeof(str), "\n\n{BF0000}Açıklama 70 karakteden fazla olamaz.");
		strcat(dialog, str);

		Dialog_Show(playerid, MDC_ABolo_Charges, DIALOG_STYLE_INPUT, "BOLO KAYDI", dialog, "Devam", "İptal Et");
		return 1;
	}

	format(lastBoloCrimes[playerid], 128, "%s", inputtext);
	new dialog[1028], str[1028];
	format(str, sizeof(str), "{FFFFFF}                   {8D8DFF}Los Santos Police Department{FFFFFF}                   {FFFFFF} {FFFFFF}");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF}                   {FF8282}BOLO KAYDI{FFFFFF}                   {FFFFFF} {FFFFFF}");
	strcat(dialog, str);
	format(str, sizeof(str), "\n\n{FF6347}Ara� Modeli:");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloModel[playerid]);
	strcat(dialog, str);
	format(str, sizeof(str), "\n\n{FF6347}Ara� Plakas�:");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloPlate[playerid]);
	strcat(dialog, str);
	format(str, sizeof(str), "\n\n{FF6347}Ara� Su�lar�:");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloCrimes[playerid]);
	strcat(dialog, str);
	format(str, sizeof(str), "\n\n{FFFFFF}ARA� BOLO'sunun rapor i�eri�ini giriniz. Rapor i�in olay�n tamam�n� yazmal�s�n�z.\nRapor c�mleler halinde eklenir. C�mle bitti�i zaman {008000}ENTER {FFFFFF}tu�una basarak alt sat�ra inin.");
	strcat(dialog, str);

	Dialog_Show(playerid, MDC_AddBolo_Report, DIALOG_STYLE_INPUT, "BOLO KAYDI", dialog, "Devam", "�ptal Et");
	return 1;
}
Server:SaveBolo(author[], plate[], model[], crimes[], report[])
{
	new query[1028];
	mysql_format(m_Handle, query, sizeof(query), "INSERT INTO vehicle_bolos (author, plate, model, crimes, report, time) VALUES ('%e', '%e', '%e', '%e', '%e', %i)", author, plate, model, crimes, report, gettime());
	mysql_tquery(m_Handle, query);
	return 1;
}
Dialog:MDC_AddBolo_Report(playerid, response, listitem, inputtext[])
{
	if(!response) return 0;

	if(strlen(inputtext) > 70)
	{
		new dialog[1028], str[1028];
		format(str, sizeof(str), "{FFFFFF}                   {8D8DFF}Los Santos Police Department{FFFFFF}                   {FFFFFF} {FFFFFF}");
		strcat(dialog, str);
		format(str, sizeof(str), "\n{FFFFFF}                   {FF8282}BOLO KAYDI{FFFFFF}                   {FFFFFF} {FFFFFF}");
		strcat(dialog, str);
		format(str, sizeof(str), "\n\n{FF6347}Ara� Modeli:");
		strcat(dialog, str);
		format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloModel[playerid]);
		strcat(dialog, str);
		format(str, sizeof(str), "\n\n{FF6347}Ara� Plakas�:");
		strcat(dialog, str);
		format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloPlate[playerid]);
		strcat(dialog, str);
		format(str, sizeof(str), "\n\n{FF6347}Ara� Su�lar�:");
		strcat(dialog, str);
		format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloCrimes[playerid]);
		strcat(dialog, str);

		format(str, sizeof(str), "\n\n{FFFFFF}ARA� BOLO'sunun rapor i�eri�ini giriniz. Rapor i�in olay�n tamam�n� yazmal�s�n�z.\nRapor c�mleler halinde eklenir. C�mle bitti�i zaman {008000}ENTER {FFFFFF}tu�una basarak alt sat�ra inin.\nE�er rapor detaylar� bittiyse BOLO olu�turmak i�in kutucu�a {008000}'bitti' {FFFFFF}yazman�z yeterli.");
		strcat(dialog, str);

		format(str, sizeof(str), "\n\n{BF0000}Raporun bir c�mlesi 70 harften uzun olamaz.");
		strcat(dialog, str);

		Dialog_Show(playerid, MDC_AddBolo_Report, DIALOG_STYLE_INPUT, "BOLO KAYDI", dialog, "Devam", "�ptal Et");
		return 1;
	}

	strcat(lastBoloReportShow[playerid], inputtext);
	strcat(lastBoloReport[playerid], inputtext);

	new dialog[1028], str[1028];
	format(str, sizeof(str), "{FFFFFF}                   {8D8DFF}Los Santos Police Department{FFFFFF}                   {FFFFFF} {FFFFFF}");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF}                   {FF8282}BOLO KAYDI{FFFFFF}                   {FFFFFF} {FFFFFF}");
	strcat(dialog, str);
	format(str, sizeof(str), "\n\n{FF6347}Ara� Modeli:");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloModel[playerid]);
	strcat(dialog, str);
	format(str, sizeof(str), "\n\n{FF6347}Ara� Plakas�:");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloPlate[playerid]);
	strcat(dialog, str);
	format(str, sizeof(str), "\n\n{FF6347}Ara� Su�lar�:");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloCrimes[playerid]);
	strcat(dialog, str);
	format(str, sizeof(str), "\n\n{FF6347}Ara� Raporu:");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloReportShow[playerid]);
	strcat(dialog, str);

	format(str, sizeof(str), "\n\n{FFFFFF}ARA� BOLO'sunun rapor i�eri�ini giriniz. Rapor i�in olay�n tamam�n� yazmal�s�n�z.\nRapor c�mleler halinde eklenir. C�mle bitti�i zaman {008000}ENTER {FFFFFF}tu�una basarak alt sat�ra inin.\nE�er rapor detaylar� bittiyse BOLO olu�turmak i�in kutucu�a {008000}'bitti' {FFFFFF}yazman�z yeterli.");
	strcat(dialog, str);

	Dialog_Show(playerid, MDC_AddBolo_ReportOrDone, DIALOG_STYLE_INPUT, "BOLO KAYDI", dialog, "Devam", "�ptal Et");
	return 1;
}

Dialog:MDC_AddBolo_ReportOrDone(playerid, response, listitem, inputtext[])
{
	if(!response) return 0;

	if(strlen(inputtext) > 70)
	{
		new dialog[1028], str[1028];
		format(str, sizeof(str), "{FFFFFF}                   {8D8DFF}Los Santos Police Department{FFFFFF}                   {FFFFFF} {FFFFFF}");
		strcat(dialog, str);
		format(str, sizeof(str), "\n{FFFFFF}                   {FF8282}BOLO KAYDI{FFFFFF}                   {FFFFFF} {FFFFFF}");
		strcat(dialog, str);
		format(str, sizeof(str), "\n\n{FF6347}Ara� Modeli:");
		strcat(dialog, str);
		format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloModel[playerid]);
		strcat(dialog, str);
		format(str, sizeof(str), "\n\n{FF6347}Ara� Plakas�:");
		strcat(dialog, str);
		format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloPlate[playerid]);
		strcat(dialog, str);
		format(str, sizeof(str), "\n\n{FF6347}Ara� Su�lar�:");
		strcat(dialog, str);
		format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloCrimes[playerid]);
		strcat(dialog, str);
		format(str, sizeof(str), "\n\n{FF6347}Ara� Raporu:");
		strcat(dialog, str);
		format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloReportShow[playerid]);
		strcat(dialog, str);

		format(str, sizeof(str), "\n\n{FFFFFF}ARA� BOLO'sunun rapor i�eri�ini giriniz. Rapor i�in olay�n tamam�n� yazmal�s�n�z.\nRapor c�mleler halinde eklenir. C�mle bitti�i zaman {008000}ENTER {FFFFFF}tu�una basarak alt sat�ra inin.\nE�er rapor detaylar� bittiyse BOLO olu�turmak i�in kutucu�a {008000}'bitti' {FFFFFF}yazman�z yeterli.");
		strcat(dialog, str);

		format(str, sizeof(str), "\n\n{BF0000}Raporun bir c�mlesi 70 harften uzun olamaz.");
		strcat(dialog, str);

		Dialog_Show(playerid, MDC_AddBolo_ReportOrDone, DIALOG_STYLE_INPUT, "BOLO KAYDI", dialog, "Devam", "�ptal Et");
		return 1;
	}

	if(strmatch(inputtext, "bitti"))
	{
		SaveBolo(ReturnName(playerid), lastBoloPlate[playerid], lastBoloModel[playerid], lastBoloCrimes[playerid], lastBoloReport[playerid]);
		Show_VehicleBolos(playerid);

		format(lastBoloModel[playerid], 24, "");
		format(lastBoloPlate[playerid], 24, "");
		format(lastBoloCrimes[playerid], 512, "");
		format(lastBoloReport[playerid], 512, "");
		format(lastBoloReportShow[playerid], 512, "");
		return 1;
	}

	strcat(lastBoloReportShow[playerid], "\n");
	strcat(lastBoloReportShow[playerid], inputtext);

	strcat(lastBoloReport[playerid], "~n~");
	strcat(lastBoloReport[playerid], inputtext);

	new dialog[1028], str[1028];
	format(str, sizeof(str), "{FFFFFF}                   {8D8DFF}Los Santos Police Department{FFFFFF}                   {FFFFFF} {FFFFFF}");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF}                   {FF8282}BOLO KAYDI{FFFFFF}                   {FFFFFF} {FFFFFF}");
	strcat(dialog, str);
	format(str, sizeof(str), "\n\n{FF6347}Ara� Modeli:");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloModel[playerid]);
	strcat(dialog, str);
	format(str, sizeof(str), "\n\n{FF6347}Ara� Plakas�:");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloPlate[playerid]);
	strcat(dialog, str);
	format(str, sizeof(str), "\n\n{FF6347}Ara� Su�lar�:");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloCrimes[playerid]);
	strcat(dialog, str);
	format(str, sizeof(str), "\n\n{FF6347}Ara� Raporu:");
	strcat(dialog, str);
	format(str, sizeof(str), "\n{FFFFFF} {FFFFFF} {FFFFFF} {FFFFFF}%s", lastBoloReportShow[playerid]);
	strcat(dialog, str);

	format(str, sizeof(str), "\n\n{FFFFFF}ARA� BOLO'sunun rapor i�eri�ini giriniz. Rapor i�in olay�n tamam�n� yazmal�s�n�z.\nRapor c�mleler halinde eklenir. C�mle bitti�i zaman {008000}ENTER {FFFFFF}tu�una basarak alt sat�ra inin.\nE�er rapor detaylar� bittiyse BOLO olu�turmak i�in kutucu�a {008000}'bitti' {FFFFFF}yazman�z yeterli.");
	strcat(dialog, str);

	Dialog_Show(playerid, MDC_AddBolo_ReportOrDone, DIALOG_STYLE_INPUT, "BOLO KAYDI", dialog, "Devam", "�ptal Et");
	return 1;
}

Server:ShowMDCPage(playerid, page)
{
	PlayerTextDrawSetString(playerid, MDC_Main[playerid][7], sprintf("%s", MDC_GetPageName(playerid, page)));
  MDC_SideMenuColours(playerid, page);
	MDC_HideAfterPage(playerid);

    PlayerTextDrawSetString(playerid, MDC_Main[playerid][8], GetName(playerid));

    for(new is; is < 18; is++)
    {
        PlayerTextDrawShow(playerid, MDC_Main[playerid][is]);
    }

    switch(page)
    {
        case MDC_PAGE_MAIN:
        {
						PlayerTextDrawSetPreviewModel(playerid, MDC_MainScreen[playerid][0], PlayerData[playerid][pSkin]);
						PlayerTextDrawSetString(playerid, MDC_MainScreen[playerid][3], sprintf("%s_%s", Player_GetFactionRank(playerid), ReturnName(playerid)));

						new
						   warrants_count;

						foreach(new i : Player)
						{
								if(PlayerData[i][pActiveListing] == 1) warrants_count++;
						}

						PlayerTextDrawSetString(playerid, MDC_MainScreen[playerid][7], sprintf("%d %d", MembersOnline(playerid), warrants_count));
						PlayerTextDrawSetString(playerid, MDC_MainScreen[playerid][6], sprintf("%d %d %d",TotalWarants, TotalJailees, TotalFines));

      			for(new is; is < 8; is++)
            {
                PlayerTextDrawShow(playerid, MDC_MainScreen[playerid][is]);
            }
        }

        case MDC_PAGE_LOOKUP:
        {
					   for(new is; is < 4; is++)
					     {
					        PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][is]);
							PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][17]);
					    }
        }

				case MDC_PAGE_WARRANTS:
				{
					for(new is; is < 24; is++)
					{
					   	PlayerTextDrawShow(playerid, MDC_Warrants[playerid][is]);
					}
				}

				case MDC_PAGE_EMERGENCY:
				{

					ShowEmergencyCalls(playerid);
				}

				case MDC_PAGE_ROSTER:
				{
					//Show_Roster(playerid);
				}


				case MDC_PAGE_CCTV:
				{
					ShowCCTV_List(playerid);
				}


				case MDC_PAGE_VEHICLEBOLO:
				{
					Show_VehicleBolos(playerid);
				}
    }

    return 1;
}

Show_CriminalData(playerid, page = 0)
{
	SetPVarInt(playerid, "criminaldatalist_idx", page);

	new query[256];
	mysql_format(m_Handle, query, sizeof(query), "SELECT id, type, time, charge_name, gov, aaf, att, sol, cac FROM player_charges WHERE player_dbid = %i ORDER BY time DESC LIMIT %i, 21", MDC_PlastLastSearched_SQLID[playerid], page*MAX_CRIMINALDATA_SHOW);
	mysql_tquery(m_Handle, query, "SQL_ListCriminal", "ii", playerid, page);
	return 1;
}

Server:SQL_ListCriminal(playerid, page)
{
	MDC_HideAfterPage(playerid);

	if(!cache_num_rows())
	{
			MDC_ReturnLastSearch(playerid);
			SendErrorMessage(playerid, "Bu ki�inin sab�ka kayd�nda hi�bir �ey yok.");
			return 1;
	}

	if(page < 0)
		return 1;

	PlayerTextDrawShow(playerid, MDC_CrimeHistory[playerid][23]);

	// MDC_CrimeHistory[playerid][21]
	new strtext = 1, countdown = 0;
	new type, time, charge_name[256];

	for(new i = 0, j = cache_num_rows(); i < j; i++)
	{

		new rows = cache_num_rows();

		if(rows > MAX_CRIMINALDATA_SHOW)
		{
			PlayerTextDrawShow(playerid, MDC_CrimeHistory[playerid][21]);
			PlayerTextDrawShow(playerid, MDC_CrimeHistory[playerid][22]);
		}

		if(page == 0)
		{
				PlayerTextDrawHide(playerid, MDC_CrimeHistory[playerid][22]);
			}

		if(page != 0)
		{
				PlayerTextDrawShow(playerid, MDC_CrimeHistory[playerid][22]);
		}

		if(strtext > 20)
			return 1;


		cache_get_value_name_int(i, "id", MDC_CriminalDataID[playerid][countdown]);
		cache_get_value_name_int(i, "type", type);
		cache_get_value_name_int(i, "time", time);


		if(type == 1)
		{
			new gov, aaf, att, sol, cac;
			cache_get_value_name_int(i, "gov", gov);
			cache_get_value_name_int(i, "aaf", aaf);
			cache_get_value_name_int(i, "att", att);
			cache_get_value_name_int(i, "sol", sol);
			cache_get_value_name_int(i, "cac", cac);

			new sub_charge[256];
			cache_get_value_name(i, "charge_name", sub_charge, 256);

			format(charge_name, sizeof(charge_name), "%s__%s", GetFullDate(time), sub_charge);

			if(gov == 1)
			{
				strcat(charge_name, " / Gov. Calisani");
			}

			if(aaf == 1)
			{
				strcat(charge_name, " / Yardim Yataklik");
			}

			if(att == 1)
			{
				strcat(charge_name, " / Te�ebb�s");
			}

			if(sol == 1)
			{
				strcat(charge_name, " / Azmettirme");
			}

			if(cac == 1)
			{
				strcat(charge_name, " / Suc Ortakligi");
			}
		}

		if(type == 1)
		{
			PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][strtext], 0xFFFFFFFF);
			PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][strtext], 0x656565FF);
		}

		if(type == 2)
		{
			format(charge_name, sizeof(charge_name), "%s__Hapis");
			PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][strtext], 0xAA2124FF);
			PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][strtext], 0xBAC1CAFF);
		}

		if(strlen(charge_name) > 80)
		{
			format(charge_name, sizeof(charge_name), "%.79s...", charge_name);
		}

		PlayerTextDrawSetString(playerid, MDC_CrimeHistory[playerid][strtext], FixWord256(charge_name));
		PlayerTextDrawShow(playerid, MDC_CrimeHistory[playerid][strtext]);
		strtext+=1;
		countdown+=1;
	}

	return 1;
}

Server:Show_CriminalDataDetail(playerid, criminal)
{
	PlayerTextDrawShow(playerid, MDC_SelectedCrimeDetails[playerid][4]);

	new query[512];
	mysql_format(m_Handle, query, sizeof(query), "SELECT type, player_dbid, time, issuer, charge_name, gov, aaf, att, sol, cac, prison_record FROM player_charges WHERE id = %i", criminal);
	new Cache: cache = mysql_query(m_Handle, query);

	new type;
	new str_detail[512];
	cache_get_value_name_int(0, "type", type); // MDC_SelectedCrimeDetails[playerid][2]

	if(type == 1) // Islem_No~n~Isim~n~Uygulayan~n~Tarih~n~Tur
	{
		new gov, aaf, att, sol, cac;
		new db, issuer, charge_name[128], time;

		cache_get_value_name_int(0, "player_dbid", db);
		cache_get_value_name_int(0, "issuer", issuer);
		cache_get_value_name_int(0, "time", time);
		cache_get_value_name_int(0, "gov", gov);
		cache_get_value_name_int(0, "aaf", aaf);
		cache_get_value_name_int(0, "att", att);
		cache_get_value_name_int(0, "sol", sol);
		cache_get_value_name_int(0, "cac", cac);

		cache_get_value_name(0, "charge_name", charge_name);

		if(gov == 1)
		{
			strcat(charge_name, " / GOV");
		}

		if(aaf == 1)
		{
			strcat(charge_name, " / AAF");
		}

		if(att == 1)
		{
			strcat(charge_name, " / ATT");
		}

		if(sol == 1)
		{
			strcat(charge_name, " / SOL");
		}

		if(cac == 1)
		{
			strcat(charge_name, " / CAC");
		}

		strcat(str_detail, sprintf("#00%d~n~", criminal));
		strcat(str_detail, sprintf("%s~n~", ReturnSQLName(db)));
		strcat(str_detail, sprintf("%s~n~", ReturnSQLName(issuer)));
		strcat(str_detail, sprintf("%s~n~Normal", GetFullTime(time)));

		PlayerTextDrawSetString(playerid, MDC_SelectedCrimeDetails[playerid][3], FixWord128(charge_name));
		PlayerTextDrawSetString(playerid, MDC_SelectedCrimeDetails[playerid][2], FixWord512(str_detail));

		PlayerTextDrawShow(playerid, MDC_SelectedCrimeDetails[playerid][0]);
		PlayerTextDrawShow(playerid, MDC_SelectedCrimeDetails[playerid][1]);
		PlayerTextDrawShow(playerid, MDC_SelectedCrimeDetails[playerid][3]);
		PlayerTextDrawShow(playerid, MDC_SelectedCrimeDetails[playerid][2]);
	}
	if(type == 2)
	{
		new db, issuer, charge_name[512], time, prison_record[1028];
		cache_get_value_name_int(0, "player_dbid", db);
		cache_get_value_name_int(0, "issuer", issuer);
		cache_get_value_name_int(0, "time", time);
		cache_get_value_name(0, "charge_name", charge_name);
		cache_get_value_name(0, "prison_record", prison_record);
		SetPVarString(playerid, "lastPrisonRecord", prison_record);

		strcat(str_detail, sprintf("#00%d~n~", criminal));
		strcat(str_detail, sprintf("%s~n~", ReturnSQLName(db)));
		strcat(str_detail, sprintf("%s~n~", ReturnSQLName(issuer)));
		strcat(str_detail, sprintf("%s~n~~r~Hapis", GetFullTime(time)));

		PlayerTextDrawSetString(playerid, MDC_SelectedCrimeDetails[playerid][3], FixWord512(charge_name));
		PlayerTextDrawSetString(playerid, MDC_SelectedCrimeDetails[playerid][2], FixWord512(str_detail));

		PlayerTextDrawShow(playerid, MDC_SelectedCrimeDetails[playerid][0]);
		PlayerTextDrawShow(playerid, MDC_SelectedCrimeDetails[playerid][1]);
		PlayerTextDrawShow(playerid, MDC_SelectedCrimeDetails[playerid][3]);
		PlayerTextDrawShow(playerid, MDC_SelectedCrimeDetails[playerid][2]);
		PlayerTextDrawShow(playerid, MDC_SelectedCrimeDetails[playerid][5]);
	}
	cache_delete(cache);
	return 1;
}

/*Show_Roster(playerid, page = 0)
{
	MDC_HideAfterPage(playerid);

	SetPVarInt(playerid, "rosterlist_idx", page);

	new count = 0, f = GetPatrolID(playerid);

	for(new i = 0; i != MAX_PATROL; i++)
	{
			if (!PatrolInfo[f][i][patrulExists])                    continue;

			new unit_name[256], unit_players[128];
			format(unit_name, sizeof(unit_name), "%s", PatrolInfo[f][i][patrulName]);

			new patrol1 = PatrolInfo[f][i][patrulOfficer][0];
			new patrol2 = PatrolInfo[f][i][patrulOfficer][1];

			new p_count;
			if(patrol1 != INVALID_PLAYER_ID && pLoggedIn[patrol1] == true)
			{
				strcat(unit_players, sprintf("%s", ReturnLastName(patrol1)));
				p_count = p_count + 1;
			}

			if(patrol2 != INVALID_PLAYER_ID && pLoggedIn[patrol2] == true)
			{
				if(p_count != 0) strcat(unit_players, ",_");
				strcat(unit_players, sprintf("%s", ReturnLastName(patrol2)));
			}

			PlayerTextDrawSetString(playerid, MDC_Roster[playerid][count], FixWord256(unit_name));
			PlayerTextDrawShow(playerid, MDC_Roster[playerid][count]);
			count = count + 1;
			PlayerTextDrawSetString(playerid, MDC_Roster[playerid][count], FixWord128(unit_players));
			PlayerTextDrawShow(playerid, MDC_Roster[playerid][count]);
			count = count + 1;
	}

	if (!count)
	{
			PlayerTextDrawSetString(playerid, MDC_Roster[playerid][0], "_Su anda aktif devriye yok..");
			PlayerTextDrawShow(playerid, MDC_Roster[playerid][0]);
	}

	new query[256];
	mysql_format(m_Handle, query, sizeof(query), "SELECT unit, unit_players FROM roster_list LIMIT %i, 20", page*MAX_ROSTER_SHOW);
	mysql_tquery(m_Handle, query, "SQL_RosterList", "ii", playerid, page);
	return 1;
}

Server:SQL_RosterList(playerid, page) // 38 geri, 39 ileri
{
	// MDC_Roster[playerid][17]

	new countdown = 0, strtext = 0;
	new unit[256];
	new player_string[256];

	for(new i = 0, j = cache_num_rows(); i < j; i++)
	{
			new rows = cache_num_rows();

			if(rows > MAX_ROSTER_SHOW)
			{
				PlayerTextDrawShow(playerid, MDC_Roster[playerid][38]);
				PlayerTextDrawShow(playerid, MDC_Roster[playerid][39]);
			}

			if(page == 0)
				{
					PlayerTextDrawHide(playerid, MDC_Roster[playerid][38]);
				}

			if(page != 0)
			{
					PlayerTextDrawShow(playerid, MDC_Roster[playerid][38]);
			}

				cache_get_value_name(i, "unit", unit, 256);
				cache_get_value_name(i, "unit_players", player_string, 256);

				if(strtext < 37)
				{
					PlayerTextDrawSetString(playerid, MDC_Roster[playerid][strtext], FixWord256(unit));
					PlayerTextDrawShow(playerid, MDC_Roster[playerid][strtext]);
					strtext+=1;

					PlayerTextDrawSetString(playerid, MDC_Roster[playerid][strtext], FixWord256(player_string));
					PlayerTextDrawShow(playerid, MDC_Roster[playerid][strtext]);
					strtext+=1;
				}
				countdown+=1;
	}

	if(countdown == 0)
	{
		PlayerTextDrawSetString(playerid, MDC_Roster[playerid][0], FixWord256("Liste bo�."));
		PlayerTextDrawShow(playerid, MDC_Roster[playerid][strtext]);
	}
	return 1;
}
*/

Show_VehicleBolos(playerid, page = 0)
{
	if(page < 0)
		return 1;

	SetPVarInt(playerid, "vbololist_idx", page);
	MDC_HideAfterPage(playerid);

	PlayerTextDrawShow(playerid, MDC_VehicleBolo_List[playerid][0]);

	new query[256];
	mysql_format(m_Handle, query, sizeof(query), "SELECT id, author, plate, model, crimes, report, time FROM vehicle_bolos ORDER BY time DESC LIMIT %i, 21", page*MAX_BOLO_SHOW);
	mysql_tquery(m_Handle, query, "SQL_VehicleBolos", "ii", playerid, page);
	return 1;
}

Server:SQL_VehicleBolos(playerid, page)
{
	new countdown = 0, strtext = 1;
	new plate[24], model[64];
	new bolo_string[256];


	for(new i = 0, j = cache_num_rows(); i < j; i++)
	{
			new rows = cache_num_rows();

			if(rows > MAX_BOLO_SHOW)
			{
				PlayerTextDrawShow(playerid, MDC_VehicleBolo_List[playerid][22]);
				PlayerTextDrawShow(playerid, MDC_VehicleBolo_List[playerid][21]);
			}

			if(page == 0)
				{
					PlayerTextDrawHide(playerid, MDC_VehicleBolo_List[playerid][21]);
				}

			if(page != 0)
				{
					PlayerTextDrawShow(playerid, MDC_VehicleBolo_List[playerid][21]);
				}

			if(countdown > 20)
				return 1;

			cache_get_value_name_int(i, "id", MDC_BolosID[playerid][countdown]);
			cache_get_value_name(i, "plate", plate, 24);
			cache_get_value_name(i, "model", model, 64);

			if(strtext == 20)
				return 1;

			format(bolo_string, sizeof(bolo_string), "%s, %s", plate, model);
			PlayerTextDrawSetString(playerid, MDC_VehicleBolo_List[playerid][strtext], FixWord256(bolo_string));
			PlayerTextDrawShow(playerid, MDC_VehicleBolo_List[playerid][strtext]);

			countdown++;
			strtext+=1;
	}

	return 1;
}

ShowCCTV_List(playerid)
{
	new
		countdown = 0, sub[90];

	PlayerTextDrawSetString(playerid, MDC_CCTV[playerid][16], "CCTV LISTESI");
	PlayerTextDrawShow(playerid, MDC_CCTV[playerid][16]);

	foreach(new i : Cameras)
	{
		if(countdown > 13)
		{
			PlayerTextDrawShow(playerid, MDC_CCTV[playerid][14]);
			PlayerTextDrawShow(playerid, MDC_CCTV[playerid][15]);
			return 1;
		}

		format(sub, sizeof(sub), "%s_-[%s]~n~", CameraData[i][CameraName], GetStreet(CameraData[i][CameraLocation][0], CameraData[i][CameraLocation][1], CameraData[i][CameraLocation][2]));
		PlayerTextDrawSetString(playerid, MDC_CCTV[playerid][countdown], sub);
		PlayerTextDrawShow(playerid, MDC_CCTV[playerid][countdown]);
		Player_CCTVPage[playerid] = 1;
		countdown++;
	}
	return 1;
}


/*GetNinerCaller(id)
{
	new query[75], niner_caller[32];
	mysql_format(m_Handle, query, sizeof(query), "SELECT niner_by FROM niner WHERE id = %i LIMIT 1", id);
	new Cache: cache = mysql_query(m_Handle, query);
	cache_get_value_name(0, "niner_by", niner_caller);
	cache_delete(cache);
	return niner_caller;
}

GetNinerCallerNumber(id)
{
	new query[75], number;
	mysql_format(m_Handle, query, sizeof(query), "SELECT niner_number FROM niner WHERE id = %i LIMIT 1", id);
	new Cache: cache = mysql_query(m_Handle, query);
	cache_get_value_name_int(0, "niner_number", number);
	cache_delete(cache);
	return number;
}

GetNinerDate(id)
{
	new query[75], n_time;
	mysql_format(m_Handle, query, sizeof(query), "SELECT niner_time FROM niner WHERE id = %i LIMIT 1", id);
	new Cache: cache = mysql_query(m_Handle, query);
	cache_get_value_name_int(0, "niner_time", n_time);
	cache_delete(cache);
	return n_time;
}

GetNinerLocation(id)
{
	new query[75], n_text[32];
	mysql_format(m_Handle, query, sizeof(query), "SELECT niner_location FROM niner WHERE id = %i LIMIT 1", id);
	new Cache: cache = mysql_query(m_Handle, query);
	cache_get_value_name(0, "niner_location", n_text);
	cache_delete(cache);
	return n_text;
}

GetNinerText(id)
{
	new query[75], n_text[256];
	mysql_format(m_Handle, query, sizeof(query), "SELECT niner_text FROM niner WHERE id = %i LIMIT 1", id);
	new Cache: cache = mysql_query(m_Handle, query);
	cache_get_value_name(0, "niner_text", n_text);
	cache_delete(cache);
	return n_text;
}

GetNinerStatus(id)
{
	new query[75], n_text[256];
	mysql_format(m_Handle, query, sizeof(query), "SELECT niner_status FROM niner WHERE id = %i LIMIT 1", id);
	new Cache: cache = mysql_query(m_Handle, query);
	cache_get_value_name(0, "niner_status", n_text);
	cache_delete(cache);
	return n_text;
}*/

HandleEmergency(playerid, PlayerText:tid)
{
	new e_id = -1;
	switch (tid)
	{
		case 187: e_id = MDC_CallsID[playerid][0];
		case 192: e_id = MDC_CallsID[playerid][1];
		case 197: e_id = MDC_CallsID[playerid][2];
		case 202: e_id = MDC_CallsID[playerid][3];
	}

	new handle_text[64];
	format(handle_text, sizeof(handle_text), "�lgilenildi - %s", ReturnName(playerid));

	if(PlayerData[playerid][pCallsign] != -1)
	{
		strcat(handle_text, sprintf("_(%s)", EkipBilgi[PlayerData[playerid][pCallsign]][ekipkodu]));
	}

	new query[256];
	mysql_format(m_Handle, query, sizeof(query), "UPDATE niner SET niner_status = '%e' WHERE id = %i", handle_text, e_id);
	mysql_tquery(m_Handle, query);

	MDC_HideAfterPage(playerid);
	ShowEmergencyCalls(playerid, GetPVarInt(playerid, "emergencylist_idx"));
	return 1;
}

/*ShowEmergencyCallDetail(playerid, PlayerText:tid)
{
	new e_id = -1;

	switch (tid)
	{
		case 197: e_id = MDC_CallsID[playerid][0];
		case 202: e_id = MDC_CallsID[playerid][1];
		case 207: e_id = MDC_CallsID[playerid][2];
		case 212: e_id = MDC_CallsID[playerid][3];
	}

	new e_details1[256];
	format(e_details1, sizeof(e_details1), "%s~n~%d~n~%s~n~~n~%s", GetNinerCaller(e_id), GetNinerCallerNumber(e_id), GetFullTime(GetNinerDate(e_id)), GetNinerStatus(e_id));

	new niner_text[128];
	format(niner_text, sizeof(niner_text), "%s",GetNinerText(e_id));

	new e_details2[256];
	format(e_details2, sizeof(e_details2), "Los_Santos_Police_Department~n~~n~~n~~n~%s~n~~n~~n~~n~_%.72s~n~%s", GetNinerLocation(e_id), niner_text, niner_text[72]);

	PlayerTextDrawSetString(playerid, MDC_EmergencyDetails[playerid][0], sprintf("Cagri_#%d~n~~n~~n~Arayan:~n~TelefonNo:~n~Tarih:~n~~n~Durum:~n~", e_id));
	PlayerTextDrawSetString(playerid, MDC_EmergencyDetails[playerid][2], FixPenalCodeWord(e_details1));
	PlayerTextDrawSetString(playerid, MDC_EmergencyDetails[playerid][3], FixPenalCodeWord(e_details2));

	for(new is = 0; is < 5; is++)
	{
		PlayerTextDrawShow(playerid, MDC_EmergencyDetails[playerid][is]);
	}

	return 1;
}*/

ShowEmergencyCallDetail(playerid, PlayerText:tid)
{
	new e_id = -1;

	switch (tid)
	{
		case 188: e_id = MDC_CallsID[playerid][0];
		case 193: e_id = MDC_CallsID[playerid][1];
		case 198: e_id = MDC_CallsID[playerid][2];
		case 203: e_id = MDC_CallsID[playerid][3];
	}

	new mes[512];

    format(mes, sizeof(mes), "{B4B5B7}911-�A�RI B�LG�S� - #%i\n\n\
	Arayan:\t\t%s\n\
	Telefon Numaras�:\t%i\n\
	Vaka:\t\t%s\n\
	Lokasyon:\t%s\n\
	Tarih:\t\t\t%s\n\n\
	Durum:\t\t\t%s", GetEmergencyStatusInt(e_id, "id"), GetEmergencyStatusName(e_id, "niner_by"), GetEmergencyStatusInt(e_id, "niner_number"), GetEmergencyStatusName(e_id, "niner_text"), GetEmergencyStatusName(e_id, "niner_location"), GetFullTime(GetEmergencyStatusInt(e_id, "niner_time")), GetEmergencyStatusName(e_id, "niner_status"));
    
	SetPVarInt(playerid, "lastEmergencyID", e_id);
    Dialog_Show(playerid, MDCCall2, DIALOG_STYLE_MSGBOX, "{8D8DFF}MDC - �A�RI B�LG�S�", mes, "Se�enekler", "Geri");
	return 1;
}

Dialog:MDCCall2(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
		SetPVarInt(playerid, "lastEmergencyID", 0);
		return 1;
	}

    Dialog_Show(playerid, MDCCallRespond, DIALOG_STYLE_LIST, "{8D8DFF}MDC - �A�RI B�LG�S�", "- �a�r�y� �stlen\n- �a�r�y� Sil", "Se�", "Geri");
	return 1;
}

Dialog:MDCCallRespond(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
		SetPVarInt(playerid, "lastEmergencyID", 0);
		return 1;
	}
	
	if(!listitem)
	{
		new e_id = GetPVarInt(playerid, "lastEmergencyID");

		if(strlen(GetEmergencyStatusName(e_id, "niner_status")) != strlen("Kontrol edilmemi�"))
		{
			SendErrorMessage(playerid, "Bu �a�r�y� bir ba�kas� �stlenmi�.");
			return 1;
		}
	
		new handle_text[64];
		format(handle_text, sizeof(handle_text), "�lgilenildi - %s", ReturnName(playerid));

		if(PlayerData[playerid][pCallsign] != -1)
		{
			strcat(handle_text, sprintf("_(%s)", EkipBilgi[PlayerData[playerid][pCallsign]][ekipkodu]));
		}

		new query[256];
		mysql_format(m_Handle, query, sizeof(query), "UPDATE niner SET niner_status = '%e' WHERE id = %i", handle_text, e_id);
		mysql_tquery(m_Handle, query);

		MDC_HideAfterPage(playerid);
		ShowEmergencyCalls(playerid, GetPVarInt(playerid, "emergencylist_idx"));
		SetPVarInt(playerid, "lastEmergencyID", 0);
		SendClientMessageEx(playerid, COLOR_COP, "%d numaral� �a�r�y� �stlendiniz.", e_id);

		MDC_HideAfterPage(playerid);
		ShowEmergencyCalls(playerid, GetPVarInt(playerid, "emergencylist_idx"));
	}
	else
	{
		new e_id = GetPVarInt(playerid, "lastEmergencyID");
		new query[256];
		mysql_format(m_Handle, query, sizeof(query), "DELETE FROM niner WHERE id = %i", e_id);
		mysql_tquery(m_Handle, query);
		SetPVarInt(playerid, "lastEmergencyID", 0);
		SendClientMessageEx(playerid, COLOR_COP, "%d numaral� �a�r�y� sildiniz.", e_id);

		MDC_HideAfterPage(playerid);
		ShowEmergencyCalls(playerid, GetPVarInt(playerid, "emergencylist_idx"));
	}
	return 1;
}

ShowEmergencyCalls(playerid, page = 0)
{
	if(page < 0)
		return 1;

	MDC_HideAfterPage(playerid);

	SetPVarInt(playerid, "emergencylist_idx", page);

	new query[256];
	mysql_format(m_Handle, query, sizeof(query), "SELECT id, niner_by, niner_number, niner_location, niner_text, niner_status, niner_time FROM niner ORDER BY niner_time DESC LIMIT %i, 5", page*MAX_EMERGENCY_SHOW);
	mysql_tquery(m_Handle, query, "SQL_EmergencyCalls", "ii", playerid, page);
	return 1;
}

Server:SQL_EmergencyCalls(playerid, page)
{
	new strtext = 2;
	new countdown = 0;
	new n_name[25];
	new n_number;
	new niner_location[33];
	new niner_text[256];
	new niner_status[64];
	new niner_time;
	new n_list_string[256];


	for(new i = 0, j = cache_num_rows(); i < j; i++)
	{
			new rows = cache_num_rows();
			if(rows > MAX_EMERGENCY_SHOW)
			{
				PlayerTextDrawShow(playerid, MDC_Emergency[playerid][20]);
				PlayerTextDrawShow(playerid, MDC_Emergency[playerid][21]);
			}

			if(page == 0)
				{
					PlayerTextDrawHide(playerid, MDC_Emergency[playerid][21]);
				}

			if(page != 0)
				{
					PlayerTextDrawShow(playerid, MDC_Emergency[playerid][21]);
				}

			if(countdown == 4)
				return 1;

			cache_get_value_name_int(i, "id", MDC_CallsID[playerid][countdown]);
			cache_get_value_name_int(i, "niner_number", n_number);
			cache_get_value_name(i, "niner_by", n_name, 25);
			cache_get_value_name(i, "niner_location", niner_location, 33);
			cache_get_value_name(i, "niner_text", niner_text, 256);
			cache_get_value_name(i, "niner_status", niner_status, 64);
			cache_get_value_name_int(i, "niner_time", niner_time);

			format(n_list_string, sizeof(n_list_string), "#%d_%s~n~%s~n~%s~n~%.21s...~n~%s~n~%s", n_number, n_name, n_name, niner_location, niner_text, GetFullTime(niner_time), FixWord64(niner_status));

			PlayerTextDrawSetString(playerid, MDC_Emergency[playerid][strtext], FixPenalCodeWord(n_list_string));
			PlayerTextDrawShow(playerid, MDC_Emergency[playerid][strtext-1]);
			PlayerTextDrawShow(playerid, MDC_Emergency[playerid][strtext-2]);
			PlayerTextDrawShow(playerid, MDC_Emergency[playerid][strtext]);
			PlayerTextDrawShow(playerid, MDC_Emergency[playerid][strtext+2]);


			if(strlen(niner_status) == strlen("Kontrol edilmemi�"))
			{
				PlayerTextDrawShow(playerid, MDC_Emergency[playerid][strtext+1]);
			}

			countdown = countdown + 1;
			strtext = strtext + 5;
	}

	// 21 geri tu�u
	return 1;
}



stock MDC_LOOKUP_SelectOption(playerid, option)
{
	for(new i = 0; i < 2; i++)
	{
			PlayerTextDrawBoxColor(playerid, MDC_LookUp_Name[playerid][i], 0xAAAAAAFF);
			PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][i], 0x333333FF);
			PlayerTextDrawBoxColor(playerid, MDC_LookUp_Name[playerid][17], 0xAAAAAAFF);
			PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][17], 0x333333FF);
	}

	switch(option)
	{
		case MDC_PAGE_LOOKUP_NAME:
		{
			PlayerTextDrawHide(playerid, MDC_LookUp_Name[playerid][0]);
			PlayerTextDrawBoxColor(playerid, MDC_LookUp_Name[playerid][0], 0x333333FF);
			PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][0], 0xAAAAAAFF);
			PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][0]);
			PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][1]);
			PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][17]);
			SetPVarInt(playerid, "MDC_SearchMode", 1);
		}
		case MDC_PAGE_LOOKUP_PLATE:
		{
			PlayerTextDrawHide(playerid, MDC_LookUp_Name[playerid][1]);
			PlayerTextDrawBoxColor(playerid, MDC_LookUp_Name[playerid][1], 0x333333FF);
			PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][1], 0xAAAAAAFF);
			PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][1]);
			PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][0]);
			PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][17]);
			SetPVarInt(playerid, "MDC_SearchMode", 2);
		}
		case MDC_PAGE_LOOKUP_BUILDING:
		{
			PlayerTextDrawHide(playerid, MDC_LookUp_Name[playerid][17]);
			PlayerTextDrawBoxColor(playerid, MDC_LookUp_Name[playerid][17], 0x333333FF);
			PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][17], 0xAAAAAAFF);
			PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][1]);
			PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][0]);
			PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][17]);
			SetPVarInt(playerid, "MDC_SearchMode", 3);
		}
	}
	return 1;
}

stock MDC_SideMenuColours(playerid, page)
{
    for(new i = 10; i < 18; i++)
    {
        PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][i], 0xAAAAAAFF);
				PlayerTextDrawColor(playerid, MDC_Main[playerid][i], 0x333333FF);
    }

    switch(page)
    {
        case MDC_PAGE_MAIN:
				{
				PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][10], 0x333333FF);
				PlayerTextDrawColor(playerid, MDC_Main[playerid][10], 0xAAAAAAFF);
				}
        case MDC_PAGE_LOOKUP:
				{
				PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][11], 0x333333FF);
				PlayerTextDrawColor(playerid, MDC_Main[playerid][11], 0xAAAAAAFF);
				}
			  /*case MDC_PAGE_WARRANTS:
				{
				PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][12], 0x333333FF);
				PlayerTextDrawColor(playerid, MDC_Main[playerid][12], 0xAAAAAAFF);
				}*/
				case MDC_PAGE_EMERGENCY:
				{
				PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][13], 0x333333FF);
				PlayerTextDrawColor(playerid, MDC_Main[playerid][13], 0xAAAAAAFF);
				}
				case MDC_PAGE_ROSTER:
				{
				PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][14], 0x333333FF);
				PlayerTextDrawColor(playerid, MDC_Main[playerid][14], 0xAAAAAAFF);
				}
				case MDC_PAGE_CCTV:
				{
				PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][15], 0x333333FF);
				PlayerTextDrawColor(playerid, MDC_Main[playerid][15], 0xAAAAAAFF);
				}
				case MDC_PAGE_VEHICLEBOLO:
				{
				PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][16], 0x333333FF);
				PlayerTextDrawColor(playerid, MDC_Main[playerid][16], 0xAAAAAAFF);
				}
    }

    return 1;
}

MDC_GetPageName(playerid, page)
{
	new factionstats;
	new factionid = PlayerData[playerid][pFaction];

	if(strfind(FactionData[factionid][FactionName], "Los Santos Sheriff Department", true) != -1)
	{
		factionstats = 2;
		PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][1], 324608767);
	}
	else
	{
		factionstats = 1;
		PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][1], 203444479);
	}

	new pagename[128];
	switch(page)
	{
		case MDC_PAGE_MAIN: format(pagename, 128, sprintf("%s", factionstats != 2 ? ("Los Santos Police Department") : ("Los Santos Sheriff Department")));
		case MDC_PAGE_LOOKUP: format(pagename, 128, sprintf("%s_~>~_Sorgula", factionstats != 2 ? ("POLICE") : ("SHERIFF")));
		case MDC_PAGE_WARRANTS: format(pagename, 128, sprintf("%s_~>~_Aranmalar", factionstats != 2 ? ("POLICE") : ("SHERIFF")));
		case MDC_PAGE_EMERGENCY: format(pagename, 128, sprintf("%s_~>~_Cagrilar", factionstats != 2 ? ("POLICE") : ("SHERIFF")));
		case MDC_PAGE_ROSTER: format(pagename, 128, sprintf("%s_~>~_Liste", factionstats != 2 ? ("POLICE") : ("SHERIFF")));
		case MDC_PAGE_DATABASE: format(pagename, 128, sprintf("%s_~>~_Veritabani", factionstats != 2 ? ("POLICE") : ("SHERIFF")));
		case MDC_PAGE_CCTV: format(pagename, 128, sprintf("%s_~>~_CCTV", factionstats != 2 ? ("POLICE") : ("SHERIFF")));
		case MDC_PAGE_STAFF: format(pagename, 128, sprintf("%s_~>~_Yetkili", factionstats != 2 ? ("POLICE") : ("SHERIFF")));
		case MDC_PAGE_VEHICLEBOLO: format(pagename, 128, sprintf("%s_~>~_ARAC_BOLOLARI", factionstats != 2 ? ("POLICE") : ("SHERIFF")));
	}
	return pagename;
}

stock GetCrimeMinute(chargeid)
{
	new query[75], minute;
	mysql_format(m_Handle, query, sizeof(query), "SELECT minute FROM penalcode WHERE id = %i LIMIT 1", chargeid);
	new Cache: cache = mysql_query(m_Handle, query);
	cache_get_value_name_int(0, "minute", minute);
	cache_delete(cache);
	return minute;
}

stock GetCategoryName(category)
{
	new query[128], detail[256];
	mysql_format(m_Handle, query, sizeof(query), "SELECT category_name FROM penalcode_category WHERE id = %i LIMIT 1", category);
	new Cache: cache = mysql_query(m_Handle, query);
	cache_get_value_name(0, "category_name", detail);
	cache_delete(cache);
	return detail;
}

stock GetCrimeName(chargeid)
{
	new query[75], detail[256];
	mysql_format(m_Handle, query, sizeof(query), "SELECT crime FROM penalcode WHERE id = %i LIMIT 1", chargeid);
	new Cache: cache = mysql_query(m_Handle, query);
	cache_get_value_name(0, "crime", detail);
	cache_delete(cache);
	return detail;
}


stock MDC_ShowAddress(playerid, playerdbid, page = 0)
{
	if(page < 0)
		return 1;

	MDC_HideAfterPage(playerid);

	SetPVarInt(playerid, "showadresslist_idx", page);

	new query[256];
	mysql_format(m_Handle, query, sizeof(query), "SELECT * FROM properties WHERE OwnerSQL = %d LIMIT %i, 4", playerdbid, page*MAX_ADRESSLIST_SHOW);
	mysql_tquery(m_Handle, query, "SQL_ShowAddress", "iii", playerid, playerdbid, page);
	return 1;
}

Server:SQL_ShowAddress(playerid, playerdbid, page)
{

	new Float:houseX, Float:houseY, Float:houseZ;
	new id, textdrawstr = 5;
	new countdown = 0;

	for(new i = 0, j = cache_num_rows(); i < j; i++)
	{
		countdown = countdown + 1;

		if(textdrawstr > 7)
			return 1;

		cache_get_value_name_int(i, "id", id);
		cache_get_value_name_float(i, "ExteriorX", houseX);
		cache_get_value_name_float(i, "ExteriorY", houseY);
		cache_get_value_name_float(i, "ExteriorZ", houseZ);

		SetPVarFloat(playerid, sprintf("ShowAddressID%d_X", countdown), houseX);
		SetPVarFloat(playerid, sprintf("ShowAddressID%d_Y", countdown), houseY);

		if(countdown == 1)
		{
			PlayerTextDrawSetString(playerid, MDC_AdressDetails[playerid][2], sprintf("%i_%s~n~%s~n~%s_%d~n~San_Andreas", id, GetStreet(houseX, houseY, houseZ), GetZoneName(houseX, houseY, houseZ), GetCityName(houseX, houseY, houseZ), ReturnAreaCode(GetZoneID(houseX, houseY, houseZ))));
			SetAddresMapPosition(playerid, GetPVarFloat(playerid, "ShowAddressID1_X"), GetPVarFloat(playerid, "ShowAddressID1_Y"));
		}

		PlayerTextDrawSetString(playerid, MDC_AdressDetails[playerid][textdrawstr], sprintf("-__%s_%i", GetStreet(houseX, houseY, houseZ), id));
		PlayerTextDrawShow(playerid, MDC_AdressDetails[playerid][textdrawstr]);

		textdrawstr = textdrawstr + 1;
	}


	if(countdown > 1)
	{
		PlayerTextDrawShow(playerid, MDC_AdressDetails[playerid][4]);
	}

	/*if(countdown > 4)
	{
		PlayerTextDrawShow(playerid, MDC_AdressDetails[playerid][10]);
	}

	if(page != 0)
	{
		PlayerTextDrawShow(playerid, MDC_AdressDetails[playerid][11]);
	}*/

	PlayerTextDrawShow(playerid, MDC_AdressDetails[playerid][0]);
	PlayerTextDrawShow(playerid, MDC_AdressDetails[playerid][1]);
	PlayerTextDrawShow(playerid, MDC_AdressDetails[playerid][2]);
	return 1;
}

stock MDC_SelectCharges(playerid, chargeid)
{
	for(new is = 38; is < 47; is++)
	{
		PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][is]);
	}

	for(new is = 38; is < 47; is++)
	{
		PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][is]);
	}

	SetPVarInt(playerid, "chargeTime", ReturnChargeTime(chargeid));
	EditChargeDescription(playerid, chargeid);
	return 1;
}

EditChargeDescription(playerid, chargeid)
{
	new charge_desc[1028];

	PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][45]);

	if(ReturnChargeFine(chargeid) == 0)
	{
		new sub_str[256];

		if(GetPVarInt(playerid, "chargeTime") > 4000)
		{
			format(sub_str, sizeof(sub_str), "%s, M�ebbet hapis cezas�yla cezaland�r�lan bir su�.", ReturnChargeName(chargeid));
		}
		else
		{
			format(sub_str, sizeof(sub_str), "%s, %d dakika hapis cezas�yla cezaland�r�lan bir su�.", ReturnChargeName(chargeid), GetPVarInt(playerid, "chargeTime"));
		}

		if(strlen(sub_str) > 55)
		{
			new sub_str2[256];
			strcat(sub_str2, sprintf("%.54s~n~", sub_str));
			strcat(sub_str2, sprintf("%s", sub_str[54]));
			strcat(charge_desc, sub_str2);
		}
		else
		{
			strcat(charge_desc, sub_str);
		}
	}
	else
	{
		new sub_str[256];
		format(sub_str, sizeof(sub_str), "%s, $%s para cezas�yla cezaland�r�lan bir su�.", ReturnChargeName(chargeid), MoneyFormat(GetPVarInt(playerid, "chargeTime")));

		if(strlen(sub_str) > 55)
		{
			new sub_str2[256];
			strcat(sub_str2, sprintf("%.54s~n~", sub_str));
			strcat(sub_str2, sprintf("%s", sub_str[54]));
			strcat(charge_desc, sub_str2);
		}
		else
		{
			strcat(charge_desc, sub_str);
		}
		PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][46]);
	}

	strcat(charge_desc, "~n~~n~~n~");
	strcat(charge_desc, ReturnChargeDescription(chargeid));

	PlayerTextDrawSetString(playerid, MDC_PenalCode[playerid][45], FixChargeDescription(charge_desc));
	PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][45]);
	return 1;
}

stock FixChargeDescription(string[1028])
{
	format(string, 1028, "%s", string);

	ReplaceText(string, " ", "_");
	ReplaceText(string, "�", "g");
	ReplaceText(string, "�", "G");
	ReplaceText(string, "�", "u");
	ReplaceText(string, "�", "U");
	ReplaceText(string, "�", "s");
	ReplaceText(string, "�", "S");
	ReplaceText(string, "�", "c");
	ReplaceText(string, "�", "C");
	ReplaceText(string, "�", "o");
	ReplaceText(string, "�", "O");
	ReplaceText(string, "�", "i");
	ReplaceText(string, "�", "I");
  return string;
}

ReturnChargeFine(id)
{
	new query[129];
	mysql_format(m_Handle, query, sizeof(query), "SELECT type_fine FROM penalcode_list WHERE id = %i", id);
	new Cache: cache = mysql_query(m_Handle, query);
	new charge_time;
	cache_get_value_name_int(0, "type_fine", charge_time);
	cache_delete(cache);
	return charge_time;
}

GetEmergencyStatusInt(id, text[])
{
	new query[129];
	mysql_format(m_Handle, query, sizeof(query), "SELECT %s FROM niner WHERE id = %i", text, id);
	new Cache: cache = mysql_query(m_Handle, query);
	new text2;
	cache_get_value_name_int(0, text, text2);
	cache_delete(cache);
	return text2;
}

GetEmergencyStatusName(id, text[])
{
	new query[129];
	mysql_format(m_Handle, query, sizeof(query), "SELECT %s FROM niner WHERE id = %i", text, id);
	new Cache: cache = mysql_query(m_Handle, query);
	new text2[256];
	cache_get_value_name(0, text, text2);
	cache_delete(cache);
	return text2;
}

stock ReturnChargeDescription(id)
{
    new player_name[1028], query[100];
    mysql_format(m_Handle, query, sizeof(query), "SELECT penal_desc FROM penalcode_list WHERE id = %i LIMIT 1", id);
    new Cache: cache = mysql_query(m_Handle, query);
    if(!cache_num_rows()) player_name = "Yok";
    else cache_get_value_name(0, "penal_desc", player_name);
    cache_delete(cache);
    return player_name;
}

stock MDC_ShowPenalCode(playerid, page = 0)
{
	if(page < 0)
		return 1;

	MDC_HideAfterPage(playerid);

	SetPVarInt(playerid, "penalcodelist_idx", page);

	new query[256];
	mysql_format(m_Handle, query, sizeof(query), "SELECT id, penal, color, bgcolor, selectable FROM penalcode_list LIMIT %i, 20", page*MAX_PENAL_SHOW);
	mysql_tquery(m_Handle, query, "SQL_PenalCode", "ii", playerid, page);
	return 1;
}


Server:SQL_PenalCode(playerid, page)
{
	// MDC_PenalCode
	new id, penal[256], color, bgcolor, selectable, strtext = 17;

	PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][16]);
	PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][36]);
	PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][37]);

	for(new i = 0, j = cache_num_rows(); i < j; i++)
	{
		new rows = cache_num_rows();

		if(rows > MAX_PENAL_SHOW)
		{
			PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][48]);
		}

		if(page == 0)
		{
			PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][47]);
		}

		if(page != 0)
		{
			PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][47]);
		}

		if(strtext > 35)
			return 1;

		cache_get_value_name_int(i, "id", id);
		cache_get_value_name_int(i, "color", color);
		cache_get_value_name_int(i, "bgcolor", bgcolor);
		cache_get_value_name_int(i, "selectable", selectable);
		cache_get_value_name(i, "penal", penal, 256);

		MDC_PenalID[playerid][i] = id;

		if(strlen(penal) > 34)
		{
			format(penal, sizeof(penal), "%.33s...", penal);
		}

		PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][strtext], selectable);
		PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][strtext], color);
		PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][strtext], bgcolor);
		PlayerTextDrawSetString(playerid, MDC_PenalCode[playerid][strtext], FixWord256(penal));
		PlayerTextDrawShow(playerid, MDC_PenalCode[playerid][strtext]);
		strtext+=1;
	}
	return 1;
}

stock MDC_ShowManageLicense(playerdbid, playerid)
{
	MDC_HideAfterPage(playerid);

	foreach(new players : Player)
	{
		if(PlayerData[players][pSQLID] == playerdbid)
		{
			PlayerTextDrawSetString(playerid, MDC_ManageLicense[playerid][5], sprintf("%s~n~%d", (PlayerData[players][pDriversLicense] != true) ? ("Mevcut_Degil") : ("Mevcut"), PlayerData[players][DriversLicenseWarning]));
			PlayerTextDrawSetString(playerid, MDC_ManageLicense[playerid][19], sprintf("%s", (PlayerData[players][pWeaponsLicense] != true) ? ("Mevcut_Degil") : ("Mevcut")));
			PlayerTextDrawSetString(playerid, MDC_ManageLicense[playerid][13], sprintf("%s", (PlayerData[players][pMedicalLicense] != true) ? ("Mevcut_Degil") : ("Mevcut")));

			for(new is; is < 34; is++)
			{
				PlayerTextDrawShow(playerid, MDC_ManageLicense[playerid][is]);
			}
			return 1;
		}
	}

	new query_properties[128];
	mysql_format(m_Handle, query_properties, sizeof(query_properties), "SELECT * FROM players WHERE id = %i", playerdbid);

	new DriverLicenses, WeaponsLicenses, DriverWarning, licensewarning, driverlicensesus, MedicalLicense;
	if(cache_num_rows())
	{
		cache_get_value_name_int(0, "DriversLicense", DriverLicenses);
		cache_get_value_name_int(0, "DriversLicenseWarning", DriverWarning);

		cache_get_value_name_int(0, "WeaponsLicense", WeaponsLicenses);
		cache_get_value_name_int(0, "DriversLicenseWarning", licensewarning);
		cache_get_value_name_int(0, "DriversLicenseSuspend", driverlicensesus);
		cache_get_value_name_int(0, "MedicalLicense", MedicalLicense);
	}

	PlayerTextDrawSetString(playerid, MDC_ManageLicense[playerid][5], sprintf("%s~n~%d", (DriverLicenses != 1) ? ("Mevcut_Degil") : ("Mevcut"), licensewarning));
	PlayerTextDrawSetString(playerid, MDC_ManageLicense[playerid][19], sprintf("%s", (WeaponsLicenses != 1) ? ("Mevcut_Degil") : ("Mevcut")));
	PlayerTextDrawSetString(playerid, MDC_ManageLicense[playerid][13], sprintf("%s", (MedicalLicense != 1) ? ("Mevcut_Degil") : ("Mevcut")));

	for(new is; is < 34; is++)
	{
		PlayerTextDrawShow(playerid, MDC_ManageLicense[playerid][is]);
	}
	return 1;
}


Dialog:MDC_LookUp_EnterBox(playerid, response, listitem, inputtext[])
{
	if(!response) return 1;

	 if(response)
	{
			new sorgu[144];
			if(GetPVarInt(playerid,"MDC_SearchMode") == 1)
			{
				format(sorgu, sizeof(sorgu), "SELECT * FROM `players` WHERE `Name` = '%s'", inputtext);
				mysql_tquery(m_Handle, sorgu, "KisiSorgula", "sdd", inputtext, playerid, 0);
			}

			if(GetPVarInt(playerid,"MDC_SearchMode") == 2)
			{
				if(strfind(inputtext, "id", true) != -1)
				{
					MDC_SearchVehicleWithID(playerid, inputtext);
					return 1;
				}
			format(sorgu, sizeof(sorgu), "SELECT * FROM `vehicles` WHERE `Plate` = '%s'", inputtext);
			mysql_tquery(m_Handle, sorgu, "KisiSorgula", "sdd", inputtext, playerid, 1);
			}
	}
  return 1;
}

forward MDC_SearchVehicleWithID(playerid, text[]); public MDC_SearchVehicleWithID(playerid, text[])
{
	new text2[2][12];
	split(text, text2, ':');
	new vehid = strval(text2[1]);

	if(!IsValidVehicle(vehid))
	{
		Dialog_Show(playerid, MDC_LookUp_EnterBox, DIALOG_STYLE_INPUT, "Veri Girin", "HATA: Bu ID'ye ait bir ara� bulunamad�.\n\nKimi ar�yorsunuz?\nPlaka aramas�ysa direkt olarak plakay� gir.\nAra� ID �zerindense, 'id:ARA�ID' �eklinde girmelisin (�rn: id:120)", "Ara", "Vazge�");
		return 1;
	}

	for(new i = 0; i < sizeof dmv_vehicles; i++) if(vehid == dmv_vehicles[i])
	{
		Dialog_Show(playerid, MDC_LookUp_EnterBox, DIALOG_STYLE_INPUT, "Veri Girin", "HATA: Bu ID'ye ait bir ara� bulunamad�.\n\nKimi ar�yorsunuz?\nPlaka aramas�ysa direkt olarak plakay� gir.\nAra� ID �zerindense, 'id:ARA�ID' �eklinde girmelisin (�rn: id:120)", "Ara", "Vazge�");
		return 1;
	}

	if(vehid < 12)
	{
		Dialog_Show(playerid, MDC_LookUp_EnterBox, DIALOG_STYLE_INPUT, "Veri Girin", "HATA: Bu ID'ye ait bir ara� bulunamad�.\n\nKimi ar�yorsunuz?\nPlaka aramas�ysa direkt olarak plakay� gir.\nAra� ID �zerindense, 'id:ARA�ID' �eklinde girmelisin (�rn: id:120)", "Ara", "Vazge�");
		return 1;
	}

	for(new is = 4; is < 18; is++)
	{
		PlayerTextDrawHide(playerid, MDC_LookUp_Name[playerid][is]);
		PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][17]);
	}

	Hide_PageAttachement(playerid);

	PlayerTextDrawSetString(playerid, MDC_LookUp_Name[playerid][4], sprintf("id:%d", vehid)); // aranma bo�lu�unun metni elleme
	PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][4]);

	PlayerTextDrawSetPreviewModel(playerid, MDC_LookUp_Vehicle[playerid][0], CarData[vehid][carModel]); // veritaban�ndan ara� modeli �ek mustafa
	PlayerTextDrawSetPreviewVehCol(playerid, MDC_LookUp_Vehicle[playerid][0], CarData[vehid][carColor1], CarData[vehid][carColor2]); // burda ise veritaban�ndan arac�n rengi
	PlayerTextDrawShow(playerid, MDC_LookUp_Vehicle[playerid][0]);
	PlayerTextDrawShow(playerid, MDC_LookUp_Vehicle[playerid][5]);

	new vehicle_details[72];
	format(vehicle_details, sizeof(vehicle_details), "%s~n~%s~n~%s~n~~r~Level_%d~n~%s", ReturnVehicleModelName(GetVehicleModel(vehid)), CarData[vehid][carPlates], ReturnSQLName(CarData[vehid][carOwnerID]), CarData[vehid][carInsurance], CarData[vehid][carImpounded] != 1 ? ("~l~Hayir") : ("~r~Evet"));
	PlayerTextDrawSetString(playerid, MDC_LookUp_Vehicle[playerid][10], vehicle_details);
	PlayerTextDrawShow(playerid, MDC_LookUp_Vehicle[playerid][10]);
	return 1;
}

forward KisiSorgula(text[], playerid, secenek); public KisiSorgula(text[], playerid, secenek)
{
	new rows, fields;
	cache_get_row_count(rows);
	cache_get_field_count(fields);
	if(!rows)
	{
		switch(secenek)
		{
			case 0:
				Dialog_Show(playerid, MDC_LookUp_EnterBox, DIALOG_STYLE_INPUT, "Veri Girin", "HATA: Bu isimle kay�tl� vatanda� bulunamad�.\n\nKimi ar�yorsunuz?", "Ara", "Vazge�");

			case 1:
			{

					Dialog_Show(playerid, MDC_LookUp_EnterBox, DIALOG_STYLE_INPUT, "Veri Girin", "HATA: Bu plakayla kay�tl� ara� bulunamad�.\n\nKimi ar�yorsunuz?\nPlaka aramas�ysa direkt olarak plakay� gir.\nAra� ID �zerindense, 'id:ARA�ID' �eklinde girmelisin (�rn: id:120)", "Ara", "Vazge�");
			}
		}
		return true;
	}

	format(MDC_PlayerLastSearched[playerid], 24, text);
	for(new is = 4; is < 18; is++)
	{
		PlayerTextDrawHide(playerid, MDC_LookUp_Name[playerid][is]);
		PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][17]);
	}

	Hide_PageAttachement(playerid);

	PlayerTextDrawSetString(playerid, MDC_LookUp_Name[playerid][4], text); // aranma bo�lu�unun metni elleme
	PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][4]);

	switch(GetPVarInt(playerid,"MDC_SearchMode"))
	{
		case 1:
		{
			new Skin;
			new Name[24];
			new playerNumber;
			new JailTimes;
			new playerdbid;

			cache_get_value_name_int(0, "id", playerdbid);
			cache_get_value_name_int(0, "Skin", Skin);
			cache_get_value_name(0, "Name", Name);
			cache_get_value_name_int(0, "PhoneNumber", playerNumber);

			cache_get_value_name_int(0, "JailTimes", JailTimes);

			new
				primary[600], sub[128];

			format(sub, sizeof(sub), "%s~n~", Name);
			strcat(primary, sub);

			format(sub, sizeof(sub), "%d~n~", playerNumber);
			strcat(primary, sub);


			if(JailTimes != 0)
			{
				format(sub, sizeof(sub), "%d_kere_hapis~n~", JailTimes);
				strcat(primary, sub);
			}else
			{
				format(sub, sizeof(sub), "Yok~n~");
				strcat(primary, sub);
			}

			new count = 0, licenses[32], dl, wl, ml;
			cache_get_value_name_int(0, "DriversLicense", dl);
			cache_get_value_name_int(0, "WeaponsLicense", wl);
			cache_get_value_name_int(0, "MedicalLicense", ml);
			if (dl == 1)
			{
						count++;
					format(licenses, sizeof(licenses), "Surucu");
			}

			if (wl == 1)
			{
						if (count > 0) format(licenses, sizeof(licenses), "%s,_", licenses);
					format(licenses, sizeof(licenses), "%sSilah", licenses);
						count++;
			}

			if (ml == 1)
			{
						if (count > 0) format(licenses, sizeof(licenses), "%s,_", licenses);
					format(licenses, sizeof(licenses), "%sMedikal", licenses);
						count++;
			}

			strcat(primary, licenses);


			format(sub, sizeof(sub), "~n~%s", FixWord256(GetPlayerAdressList(playerdbid)));
			strcat(primary, sub);

			PlayerTextDrawSetString(playerid, MDC_LookUp_Name[playerid][8], primary);

			PlayerTextDrawSetPreviewModel(playerid, MDC_LookUp_Name[playerid][5], Skin); // burada �ekilen skin database skin ile de�i�ecek

			format(MDC_PlayerLastSearched[playerid], 24, "%s", Name);
			MDC_PlastLastSearched_SQLID[playerid] = playerdbid;

			new query[512];
			mysql_format(m_Handle, query, sizeof(query), "SELECT gov, aaf, att, sol, cac, active, type, charge_name FROM player_charges WHERE player_dbid = %d AND active = 1 AND type = 1 ORDER BY time DESC LIMIT 5", MDC_PlastLastSearched_SQLID[playerid]);
			mysql_tquery(m_Handle, query, "SQL_CriminalPreview", "i", playerid);

			for(new is = 4; is < 18; is++)
			{
				PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][is]);
			}

			PlayerTextDrawHide(playerid, MDC_LookUp_Name[playerid][9]);

			if(GetPlayerAdress(playerdbid) == 1)
			{
				PlayerTextDrawSetString(playerid, MDC_LookUp_Name[playerid][9], "]_Bu_Oyuncu_Eve_Sahip,_Listelemek_icin_tiklayin");
				PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][9]);
			}

			if(GetPlayerAdress(playerdbid) > 1)
			{
				PlayerTextDrawSetString(playerid,  MDC_LookUp_Name[playerid][9], "]_Bu_Oyuncu_Birden_Fazla_Adrese_Sahip,_Listelemek_icin_tiklayin");
				PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][9]);
			}

		}
		case 2:
		{

			new vModel, vColor1, vColor2, carPlate[24], ownerid, carInsur, carimpound;

			cache_get_value_name_int(0, "ModelID", vModel);
			cache_get_value_name_int(0, "Color1", vColor1);
			cache_get_value_name_int(0, "Color2", vColor2);
			cache_get_value_name(0, "Plate", carPlate, 24);
			cache_get_value_name_int(0, "OwnerID", ownerid);
			cache_get_value_name_int(0, "Insurance", carInsur);
			cache_get_value_name_int(0, "Impounded", carimpound);

			PlayerTextDrawSetString(playerid, MDC_LookUp_Name[playerid][4], carPlate); // aranma bo�lu�unun metni elleme
			PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][4]);


			PlayerTextDrawSetPreviewModel(playerid, MDC_LookUp_Vehicle[playerid][0], vModel); // veritaban�ndan ara� modeli �ek mustafa
			PlayerTextDrawSetPreviewVehCol(playerid, MDC_LookUp_Vehicle[playerid][0], vColor1, vColor2); // burda ise veritaban�ndan arac�n rengi
			PlayerTextDrawShow(playerid, MDC_LookUp_Vehicle[playerid][0]);
			PlayerTextDrawShow(playerid, MDC_LookUp_Vehicle[playerid][5]);

			new vehicle_details[72];
			format(vehicle_details, sizeof(vehicle_details), "%s~n~%s~n~%s~n~~r~Level_%d~n~%s", ReturnVehicleModelName(vModel),  carPlate, ReturnSQLName(ownerid), carInsur, (carimpound != 1) ? ("~l~HAYIR") : ("~r~Evet"));
			PlayerTextDrawSetString(playerid, MDC_LookUp_Vehicle[playerid][10], vehicle_details);
			PlayerTextDrawShow(playerid, MDC_LookUp_Vehicle[playerid][10]);
		}
	}
	return 1;
}

Server:SQL_CriminalPreview(playerid)
{
	new records[512], charge_name[128], gov, aaf, att, sol, cac;

	for(new i = 0, j = cache_num_rows(); i < j; i++)
	{
		cache_get_value_name_int(i, "gov", gov);
		cache_get_value_name_int(i, "aaf", aaf);
		cache_get_value_name_int(i, "att", att);
		cache_get_value_name_int(i, "sol", sol);
		cache_get_value_name_int(i, "cac", cac);
		cache_get_value_name(i, "charge_name", charge_name, 128);


		if(gov == 1)
		{
			strcat(charge_name, " / GOV");
		}

		if(aaf == 1)
		{
			strcat(charge_name, " / AAF");
		}

		if(att == 1)
		{
			strcat(charge_name, " / ATT");
		}

		if(sol == 1)
		{
			strcat(charge_name, " / SOL");
		}

		if(cac == 1)
		{
			strcat(charge_name, " / CAC");
		}

		if(strlen(charge_name) > 45)
		{
			format(charge_name, sizeof(charge_name), "- %.44s...", charge_name);
		}
		else
		{
			format(charge_name, sizeof(charge_name), "- %s", charge_name);
		}

		strcat(records, charge_name);
		strcat(records, "~n~");
	}

	if(!cache_num_rows())
	{
		strcat(records, sprintf("Bu ki�inin �zerinde aktif su�lama yok."));
	}

	PlayerTextDrawSetString(playerid, MDC_LookUp_Name[playerid][14], FixWord512(records));
	PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][14]);
}


GetPlayerAdress(playerdbid)
{
	new countdown = 0;

		new query_properties[128];
		mysql_format(m_Handle, query_properties, sizeof(query_properties), "SELECT * FROM properties WHERE OwnerSQL = %i", playerdbid);
		new Cache:cache = mysql_query(m_Handle, query_properties);

		if(!cache_num_rows())
		{
			cache_delete(cache);
		}
		else
		{
			for(new i = 0; i < cache_num_rows(); i++)
			{
				countdown+= 1;
			}
			cache_delete(cache);
			return countdown;
		}
	return countdown;
}

GetPlayerAdressList(playerdbid)
{
	new str[256];

		new query_properties[128], gethouseadress[1287];
		mysql_format(m_Handle, query_properties, sizeof(query_properties), "SELECT * FROM properties WHERE OwnerSQL = %i", playerdbid);
		new Cache:cache = mysql_query(m_Handle, query_properties);

		if(!cache_num_rows())
		{
			format(gethouseadress, sizeof(gethouseadress), "Yok");
		}
		else
		{
			new Float:houseX, Float:houseY, Float:houseZ;
			cache_get_value_name_float(0, "ExteriorX", houseX);
			cache_get_value_name_float(0, "ExteriorY", houseY);
			cache_get_value_name_float(0, "ExteriorZ", houseZ);

			format(str, sizeof(str), "%s~n~%s~n~%s_%i", GetStreet(houseX, houseY, houseZ), GetZoneName(houseX, houseY, houseZ), GetCityName(houseX, houseY, houseZ), ReturnAreaCode(GetZoneID(houseX, houseY, houseZ)));
		}
	cache_delete(cache);
	return str;
}

stock MDC_LookUp_Refresh(playerid)
{
	for(new is = 0; is < 17; is++)
	{
		PlayerTextDrawHide(playerid, MDC_LookUp_Vehicle[playerid][is]);
	}


	for(new is = 4; is < 18;is++)
	{
		PlayerTextDrawHide(playerid, MDC_LookUp_Name[playerid][is]);
		PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][17]);
	}

	for(new is = 0; is < 49; is++)
	{
		PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][is]);
	}

	for(new is = 0; is < 34; is++)
	{
		PlayerTextDrawHide(playerid, MDC_ManageLicense[playerid][is]);
	}
	return 1;
}


stock MDC_Hide(playerid)
{
	for(new is; is < 18; is++)
	{
		PlayerTextDrawHide(playerid, MDC_Main[playerid][is]);
	}

	for(new is; is < 23; is++)
	{
		PlayerTextDrawHide(playerid, MDC_VehicleBolo_List[playerid][is]);
	}

	for(new is; is < 6; is++)
	{
		PlayerTextDrawHide(playerid, MDC_VehicleBolo_Details[playerid][is]);
	}

	for(new is; is < 8; is++)
	{
		PlayerTextDrawHide(playerid, MDC_MainScreen[playerid][is]);
	}

	for(new is; is < 18; is++)
	{
		PlayerTextDrawHide(playerid, MDC_LookUp_Name[playerid][is]);
	}


	for(new is; is < 17; is++)
	{
		PlayerTextDrawHide(playerid, MDC_CCTV[playerid][is]);
	}

	for(new is = 0; is < 17; is++)
	{
		PlayerTextDrawHide(playerid, MDC_LookUp_Vehicle[playerid][is]);
	}

	for(new is = 0; is < 14; is++)
	{
		PlayerTextDrawHide(playerid, MDC_AdressDetails[playerid][is]);
	}

	for(new is = 0; is < 34; is++)
	{
		PlayerTextDrawHide(playerid, MDC_ManageLicense[playerid][is]);
	}

	for(new is = 0; is < 5; is++)
	{
	 	PlayerTextDrawHide(playerid, MDC_EmergencyDetails[playerid][is]);
	}

	for(new is = 0; is < 49; is++)
	{
		PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][is]);
	}

	for(new is; is < 24; is++)
	{
		PlayerTextDrawHide(playerid, MDC_Emergency[playerid][is]);
	}

	for(new is; is < 24; is++)
	{
		PlayerTextDrawHide(playerid, MDC_Warrants[playerid][is]);
	}

	for(new is; is < 40; is++)
	{
		PlayerTextDrawHide(playerid, MDC_Roster[playerid][is]);
	}

	for(new is = 0; is < 24; is++)
	{
	 	PlayerTextDrawHide(playerid, MDC_CrimeHistory[playerid][is]);
	}

	for(new is = 0; is < 6; is++)
	{
	 	PlayerTextDrawHide(playerid, MDC_SelectedCrimeDetails[playerid][is]);
	}


	SetPVarInt(playerid, "MDC_SearchMode", 0);
	CancelSelectTextDraw(playerid);
	return 1;
}
stock MDC_ReturnLastSearch(playerid)
{
	PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][0]);
	PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][1]);
	PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][2]);
	PlayerTextDrawShow(playerid, MDC_LookUp_Name[playerid][3]);

	new sorgu[256];
	format(sorgu, sizeof(sorgu), "SELECT * FROM `players` WHERE `Name` = '%s'", MDC_PlayerLastSearched[playerid]);
	mysql_tquery(m_Handle, sorgu, "KisiSorgula", "sdd", MDC_PlayerLastSearched[playerid], playerid, 0);
	return 1;
}

stock MDC_HideAfterPage(playerid)
{
	for(new is; is < 8; is++)
	{
		PlayerTextDrawHide(playerid, MDC_MainScreen[playerid][is]);
	}

	for(new is; is < 5; is++)
	{
		PlayerTextDrawHide(playerid, MDC_CriminalRecordDetail[playerid][is]);
	}

	for(new is; is < 21; is++)
	{
		PlayerTextDrawHide(playerid, MDC_CriminalRecords[playerid][is]);
	}

	for(new is; is < 8; is++)
	{
		PlayerTextDrawHide(playerid, MDC_MainScreen[playerid][is]);
	}

	for(new is; is < 6; is++)
	{
		PlayerTextDrawHide(playerid, MDC_VehicleBolo_Details[playerid][is]);
	}

	for(new is; is < 23; is++)
	{
		PlayerTextDrawHide(playerid, MDC_VehicleBolo_List[playerid][is]);
	}

	for(new is; is < 18; is++)
	{
		PlayerTextDrawHide(playerid, MDC_LookUp_Name[playerid][is]);
	}

	for(new is = 0; is < 17; is++)
	{
		PlayerTextDrawHide(playerid, MDC_LookUp_Vehicle[playerid][is]);
	}

	for(new is = 0; is < 24; is++)
	{
	 	PlayerTextDrawHide(playerid, MDC_CrimeHistory[playerid][is]);
	}

	for(new is = 0; is < 6; is++)
	{
	 	PlayerTextDrawHide(playerid, MDC_SelectedCrimeDetails[playerid][is]);
	}

	for(new is = 0; is < 14; is++)
	{
		PlayerTextDrawHide(playerid, MDC_AdressDetails[playerid][is]);
	}

	for(new is; is < 17; is++)
	{
		PlayerTextDrawHide(playerid, MDC_CCTV[playerid][is]);
	}

	for(new is = 0; is < 34; is++)
	{
		PlayerTextDrawHide(playerid, MDC_ManageLicense[playerid][is]);
	}

	for(new is = 0; is < 49; is++)
	{
		PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][is]);
	}

	for(new is; is < 24; is++)
	{
		PlayerTextDrawHide(playerid, MDC_Emergency[playerid][is]);
	}
	for(new is; is < 24; is++)
	{
		PlayerTextDrawHide(playerid, MDC_Warrants[playerid][is]);
	}

	for(new is; is < 40; is++)
	{
		PlayerTextDrawHide(playerid, MDC_Roster[playerid][is]);
	}
	for(new is = 0; is < 5; is++)
	{
	 		PlayerTextDrawHide(playerid, MDC_EmergencyDetails[playerid][is]);
	}
}

GetName(playerid)
{
	new isim[24];

	GetPlayerName(playerid, isim, 24);
  return isim;
}

FixPenalCodeWord(string[256])
{
	ReplaceText(string, "�", "g");
	ReplaceText(string, "�", "G");
	ReplaceText(string, "�", "u");
	ReplaceText(string, "�", "U");
	ReplaceText(string, "�", "s");
	ReplaceText(string, "�", "S");
	ReplaceText(string, "�", "c");
	ReplaceText(string, "�", "C");
	ReplaceText(string, "�", "o");
	ReplaceText(string, "�", "O");
	ReplaceText(string, "�", "i");
	ReplaceText(string, "�", "I");
  return string;
}

stock FixWord128(string[128])
{
	format(string, 128, "%s", string);
	metinfix(string, ' ', '_');

	ReplaceText(string, "�", "g");
	ReplaceText(string, "�", "G");
	ReplaceText(string, "�", "u");
	ReplaceText(string, "�", "U");
	ReplaceText(string, "�", "s");
	ReplaceText(string, "�", "S");
	ReplaceText(string, "�", "c");
	ReplaceText(string, "�", "C");
	ReplaceText(string, "�", "o");
	ReplaceText(string, "�", "O");
	ReplaceText(string, "�", "i");
	ReplaceText(string, "�", "I");
  return string;
}

stock FixWord256(string[256])
{
	format(string, 256, "%s", string);
	metinfix(string, ' ', '_');

	ReplaceText(string, "�", "g");
	ReplaceText(string, "�", "G");
	ReplaceText(string, "�", "u");
	ReplaceText(string, "�", "U");
	ReplaceText(string, "�", "s");
	ReplaceText(string, "�", "S");
	ReplaceText(string, "�", "c");
	ReplaceText(string, "�", "C");
	ReplaceText(string, "�", "o");
	ReplaceText(string, "�", "O");
	ReplaceText(string, "�", "i");
	ReplaceText(string, "�", "I");
  return string;
}

stock FixWord64(string[64])
{
	format(string, 64, "%s", string);
	metinfix(string, ' ', '_');

	ReplaceText(string, "�", "g");
	ReplaceText(string, "�", "G");
	ReplaceText(string, "�", "u");
	ReplaceText(string, "�", "U");
	ReplaceText(string, "�", "s");
	ReplaceText(string, "�", "S");
	ReplaceText(string, "�", "c");
	ReplaceText(string, "�", "C");
	ReplaceText(string, "�", "o");
	ReplaceText(string, "�", "O");
	ReplaceText(string, "�", "i");
	ReplaceText(string, "�", "I");
  return string;
}

stock FixWord512(string[512])
{
	format(string, 512, "%s", string);
	metinfix(string, ' ', '_');

	ReplaceText(string, "�", "g");
	ReplaceText(string, "�", "G");
	ReplaceText(string, "�", "u");
	ReplaceText(string, "�", "U");
	ReplaceText(string, "�", "s");
	ReplaceText(string, "�", "S");
	ReplaceText(string, "�", "c");
	ReplaceText(string, "�", "C");
	ReplaceText(string, "�", "o");
	ReplaceText(string, "�", "O");
	ReplaceText(string, "�", "i");
	ReplaceText(string, "�", "I");
  return string;
}

stock FixWord1028(string[1028])
{
	format(string, 1028, "%s", string);
	metinfix(string, ' ', '_');

	ReplaceText(string, "�", "g");
	ReplaceText(string, "�", "G");
	ReplaceText(string, "�", "u");
	ReplaceText(string, "�", "U");
	ReplaceText(string, "�", "s");
	ReplaceText(string, "�", "S");
	ReplaceText(string, "�", "c");
	ReplaceText(string, "�", "C");
	ReplaceText(string, "�", "o");
	ReplaceText(string, "�", "O");
	ReplaceText(string, "�", "i");
	ReplaceText(string, "�", "I");
  return string;
}



metinfix(string[], find, replace)
{
    for(new i=0; string[i]; i++)
    {
        if(string[i] == find)
        {
            string[i] = replace;
        }
    }
}


stock UI_MDC(playerid)
{
	MDC_Main[playerid][0] = CreatePlayerTextDraw(playerid, 148.300369, 150.643173, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Main[playerid][0], 0.000000, 32.372245);
	PlayerTextDrawTextSize(playerid, MDC_Main[playerid][0], 527.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Main[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_Main[playerid][0], -1);
	PlayerTextDrawUseBox(playerid, MDC_Main[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][0], -522329857);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Main[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Main[playerid][0], 255);
	PlayerTextDrawFont(playerid, MDC_Main[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Main[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][0], 0);

	MDC_Main[playerid][1] = CreatePlayerTextDraw(playerid, 149.900421, 153.836624, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Main[playerid][1], 0.000000, 0.954244);
	PlayerTextDrawTextSize(playerid, MDC_Main[playerid][1], 525.299926, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Main[playerid][1], 1);
	PlayerTextDrawColor(playerid, MDC_Main[playerid][1], -1);
	PlayerTextDrawUseBox(playerid, MDC_Main[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][1], 203444479);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Main[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Main[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_Main[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Main[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][1], 0);

	MDC_Main[playerid][2] = CreatePlayerTextDraw(playerid, 517.399047, 154.023117, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Main[playerid][2], 0.000000, 0.910245);
	PlayerTextDrawTextSize(playerid, MDC_Main[playerid][2], 525.198242, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Main[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_Main[playerid][2], -1);
	PlayerTextDrawUseBox(playerid, MDC_Main[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][2], -1407049473);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Main[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Main[playerid][2], 255);
	PlayerTextDrawFont(playerid, MDC_Main[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Main[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][2], 0);

	MDC_Main[playerid][3] = CreatePlayerTextDraw(playerid, 506.500030, 154.023117, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Main[playerid][3], 0.000000, 0.910245);
	PlayerTextDrawTextSize(playerid, MDC_Main[playerid][3], 514.300903, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Main[playerid][3], 1);
	PlayerTextDrawColor(playerid, MDC_Main[playerid][3], -1);
	PlayerTextDrawUseBox(playerid, MDC_Main[playerid][3], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][3], 610587135);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Main[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Main[playerid][3], 255);
	PlayerTextDrawFont(playerid, MDC_Main[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Main[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][3], 0);

	MDC_Main[playerid][4] = CreatePlayerTextDraw(playerid, 521.400390, 151.480117, "x");
	PlayerTextDrawLetterSize(playerid, MDC_Main[playerid][4], 0.258399, 1.291378);
	PlayerTextDrawTextSize(playerid, MDC_Main[playerid][4], 13.0, 7.000000);
	PlayerTextDrawAlignment(playerid, MDC_Main[playerid][4], 2);
	PlayerTextDrawColor(playerid, MDC_Main[playerid][4], -1);
	PlayerTextDrawUseBox(playerid, MDC_Main[playerid][4], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][4], 560254720);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Main[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Main[playerid][4], 560254720);
	PlayerTextDrawFont(playerid, MDC_Main[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Main[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][4], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Main[playerid][4], true);

	MDC_Main[playerid][5] = CreatePlayerTextDraw(playerid, 510.402587, 151.480117, "-");
	PlayerTextDrawLetterSize(playerid, MDC_Main[playerid][5], 0.258399, 1.291378);
	PlayerTextDrawAlignment(playerid, MDC_Main[playerid][5], 2);
	PlayerTextDrawColor(playerid, MDC_Main[playerid][5], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Main[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Main[playerid][5], 560254720);
	PlayerTextDrawFont(playerid, MDC_Main[playerid][5], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Main[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][5], 0);

	MDC_Main[playerid][6] = CreatePlayerTextDraw(playerid, 151.199172, 154.113464, "hud:radar_emmetgun");
	PlayerTextDrawLetterSize(playerid, MDC_Main[playerid][6], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_Main[playerid][6], 9.539989, 8.000000);
	PlayerTextDrawAlignment(playerid, MDC_Main[playerid][6], 1);
	PlayerTextDrawColor(playerid, MDC_Main[playerid][6], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Main[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Main[playerid][6], 255);
	PlayerTextDrawFont(playerid, MDC_Main[playerid][6], 4);
	PlayerTextDrawSetProportional(playerid, MDC_Main[playerid][6], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][6], 0);

	MDC_Main[playerid][7] = CreatePlayerTextDraw(playerid, 163.800292, 153.680297, "MDC_PageName");
	PlayerTextDrawLetterSize(playerid, MDC_Main[playerid][7], 0.204399, 0.927954);
	PlayerTextDrawTextSize(playerid, MDC_Main[playerid][7], 284.700103, -0.099999);
	PlayerTextDrawAlignment(playerid, MDC_Main[playerid][7], 1);
	PlayerTextDrawColor(playerid, MDC_Main[playerid][7], -1329999105);
	PlayerTextDrawUseBox(playerid, MDC_Main[playerid][7], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][7], -1329999360);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Main[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Main[playerid][7], 255);
	PlayerTextDrawFont(playerid, MDC_Main[playerid][7], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Main[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][7], 0);

	MDC_Main[playerid][8] = CreatePlayerTextDraw(playerid, 501.600402, 153.680282, "CharacterName1");
	PlayerTextDrawLetterSize(playerid, MDC_Main[playerid][8], 0.204399, 0.927954);
	PlayerTextDrawAlignment(playerid, MDC_Main[playerid][8], 3);
	PlayerTextDrawColor(playerid, MDC_Main[playerid][8], -2037207046);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Main[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Main[playerid][8], 255);
	PlayerTextDrawFont(playerid, MDC_Main[playerid][8], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Main[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][8], 0);

	MDC_Main[playerid][9] = CreatePlayerTextDraw(playerid, 223.900009, 168.595565, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Main[playerid][9], 0.000000, 30.160011);
	PlayerTextDrawTextSize(playerid, MDC_Main[playerid][9], 224.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Main[playerid][9], 1);
	PlayerTextDrawColor(playerid, MDC_Main[playerid][9], -1);
	PlayerTextDrawUseBox(playerid, MDC_Main[playerid][9], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][9], -1229736193);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Main[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Main[playerid][9], 255);
	PlayerTextDrawFont(playerid, MDC_Main[playerid][9], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Main[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][9], 0);

	MDC_Main[playerid][10] = CreatePlayerTextDraw(playerid, 184.000213, 168.693344, "Ana_Ekran");
	PlayerTextDrawLetterSize(playerid, MDC_Main[playerid][10], 0.198597, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_Main[playerid][10], 10.559998, 68.000000);
	PlayerTextDrawAlignment(playerid, MDC_Main[playerid][10], 2);
	PlayerTextDrawColor(playerid, MDC_Main[playerid][10], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_Main[playerid][10], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][10], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Main[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Main[playerid][10], 255);
	PlayerTextDrawFont(playerid, MDC_Main[playerid][10], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Main[playerid][10], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][10], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Main[playerid][10], true);

	MDC_Main[playerid][11] = CreatePlayerTextDraw(playerid, 183.900177, 184.394302, "Sorgula");
	PlayerTextDrawLetterSize(playerid, MDC_Main[playerid][11], 0.198597, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_Main[playerid][11], 10.559998, 68.000000);
	PlayerTextDrawAlignment(playerid, MDC_Main[playerid][11], 2);
	PlayerTextDrawColor(playerid, MDC_Main[playerid][11], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_Main[playerid][11], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][11], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Main[playerid][11], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Main[playerid][11], 255);
	PlayerTextDrawFont(playerid, MDC_Main[playerid][11], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Main[playerid][11], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][11], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Main[playerid][11], true);


	MDC_Main[playerid][13] = CreatePlayerTextDraw(playerid, 184.300170, 200.196243, "CAGRILAR");
	PlayerTextDrawLetterSize(playerid, MDC_Main[playerid][13], 0.198597, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_Main[playerid][13], 10.559998, 68.000000);
	PlayerTextDrawAlignment(playerid, MDC_Main[playerid][13], 2);
	PlayerTextDrawColor(playerid, MDC_Main[playerid][13], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_Main[playerid][13], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][13], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][13], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Main[playerid][13], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Main[playerid][13], 255);
	PlayerTextDrawFont(playerid, MDC_Main[playerid][13], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Main[playerid][13], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][13], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Main[playerid][13], true);

	MDC_Main[playerid][14] = CreatePlayerTextDraw(playerid, 184.300170, 232.998779, " ");

	MDC_Main[playerid][16] = CreatePlayerTextDraw(playerid, 184.300170, 248.998779, "ARAC BOLO");
	PlayerTextDrawLetterSize(playerid, MDC_Main[playerid][16], 0.198597, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_Main[playerid][16], 10.559998, 68.000000);
	PlayerTextDrawAlignment(playerid, MDC_Main[playerid][16], 2);
	PlayerTextDrawColor(playerid, MDC_Main[playerid][16], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_Main[playerid][16], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Main[playerid][16], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][16], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Main[playerid][16], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Main[playerid][16], 255);
	PlayerTextDrawFont(playerid, MDC_Main[playerid][16], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Main[playerid][16], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Main[playerid][16], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Main[playerid][16], true);


	MDC_MainScreen[playerid][0] = CreatePlayerTextDraw(playerid, 242.199951, 165.951248, "");
	PlayerTextDrawLetterSize(playerid, MDC_MainScreen[playerid][0], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_MainScreen[playerid][0], 241.000000, 206.000000);
	PlayerTextDrawAlignment(playerid, MDC_MainScreen[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_MainScreen[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, MDC_MainScreen[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_MainScreen[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_MainScreen[playerid][0], -522330112);
	PlayerTextDrawFont(playerid, MDC_MainScreen[playerid][0], 5);
	PlayerTextDrawSetProportional(playerid, MDC_MainScreen[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, MDC_MainScreen[playerid][0], 0);
	PlayerTextDrawFont(playerid, MDC_MainScreen[playerid][0], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawSetPreviewModel(playerid, MDC_MainScreen[playerid][0], 285);
	PlayerTextDrawSetPreviewRot(playerid, MDC_MainScreen[playerid][0], 0.000000, 0.000000, 0.000000, 0.899999);

	MDC_MainScreen[playerid][1] = CreatePlayerTextDraw(playerid, 229.900390, 258.163177, "box");
	PlayerTextDrawLetterSize(playerid, MDC_MainScreen[playerid][1], 0.000000, 18.012247);
	PlayerTextDrawTextSize(playerid, MDC_MainScreen[playerid][1], 514.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_MainScreen[playerid][1], 1);
	PlayerTextDrawColor(playerid, MDC_MainScreen[playerid][1], 16777215);
	PlayerTextDrawUseBox(playerid, MDC_MainScreen[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, MDC_MainScreen[playerid][1], -522329857);
	PlayerTextDrawSetShadow(playerid, MDC_MainScreen[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_MainScreen[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_MainScreen[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_MainScreen[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, MDC_MainScreen[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_MainScreen[playerid][1], 0);

	MDC_MainScreen[playerid][2] = CreatePlayerTextDraw(playerid, 230.300003, 255.311096, "box");
	PlayerTextDrawLetterSize(playerid, MDC_MainScreen[playerid][2], 0.000000, 1.040012);
	PlayerTextDrawTextSize(playerid, MDC_MainScreen[playerid][2], 524.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_MainScreen[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_MainScreen[playerid][2], -1);
	PlayerTextDrawUseBox(playerid, MDC_MainScreen[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, MDC_MainScreen[playerid][2], -1229736193);
	PlayerTextDrawSetShadow(playerid, MDC_MainScreen[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_MainScreen[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_MainScreen[playerid][2], 255);
	PlayerTextDrawFont(playerid, MDC_MainScreen[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, MDC_MainScreen[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, MDC_MainScreen[playerid][2], 0);

	MDC_MainScreen[playerid][3] = CreatePlayerTextDraw(playerid, 366.200317, 255.426940, "Rank_CharacterName");
	PlayerTextDrawLetterSize(playerid, MDC_MainScreen[playerid][3], 0.204399, 0.927954);
	PlayerTextDrawAlignment(playerid, MDC_MainScreen[playerid][3], 2);
	PlayerTextDrawColor(playerid, MDC_MainScreen[playerid][3], 757674239);
	PlayerTextDrawSetShadow(playerid, MDC_MainScreen[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_MainScreen[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_MainScreen[playerid][3], 255);
	PlayerTextDrawFont(playerid, MDC_MainScreen[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, MDC_MainScreen[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, MDC_MainScreen[playerid][3], 0);

	MDC_MainScreen[playerid][4] = CreatePlayerTextDraw(playerid, 233.300308, 272.749176, "AKTIF_PERSONELLER AKTIF_ARANMALAR");
	PlayerTextDrawLetterSize(playerid, MDC_MainScreen[playerid][4], 0.223998, 1.127063);
	PlayerTextDrawTextSize(playerid, MDC_MainScreen[playerid][4], 241.000000, 206.000000);
	PlayerTextDrawAlignment(playerid, MDC_MainScreen[playerid][4], 1);
	PlayerTextDrawColor(playerid, MDC_MainScreen[playerid][4], 757674239);
	PlayerTextDrawSetShadow(playerid, MDC_MainScreen[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_MainScreen[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_MainScreen[playerid][4], 255);
	PlayerTextDrawFont(playerid, MDC_MainScreen[playerid][4], 2);
	PlayerTextDrawSetProportional(playerid, MDC_MainScreen[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_MainScreen[playerid][4], 0);

	MDC_MainScreen[playerid][5] = CreatePlayerTextDraw(playerid, 384.299316, 272.737884, "SON_ARANMALAR SON_TUTUKLAMALAR SON_CEZALAR");
	PlayerTextDrawLetterSize(playerid, MDC_MainScreen[playerid][5], 0.223998, 1.127063);
	PlayerTextDrawTextSize(playerid, MDC_MainScreen[playerid][5], 241.000000, 206.000000);
	PlayerTextDrawAlignment(playerid, MDC_MainScreen[playerid][5], 1);
	PlayerTextDrawColor(playerid, MDC_MainScreen[playerid][5], 757674239);
	PlayerTextDrawSetShadow(playerid, MDC_MainScreen[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, MDC_MainScreen[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_MainScreen[playerid][5], 255);
	PlayerTextDrawFont(playerid, MDC_MainScreen[playerid][5], 2);
	PlayerTextDrawSetProportional(playerid, MDC_MainScreen[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, MDC_MainScreen[playerid][5], 0);

	MDC_MainScreen[playerid][6] = CreatePlayerTextDraw(playerid, 492.701934, 272.742401, "3 5 7");
	PlayerTextDrawLetterSize(playerid, MDC_MainScreen[playerid][6], 0.223998, 1.127063);
	PlayerTextDrawTextSize(playerid, MDC_MainScreen[playerid][6], 241.000000, 206.000000);
	PlayerTextDrawAlignment(playerid, MDC_MainScreen[playerid][6], 1);
	PlayerTextDrawColor(playerid, MDC_MainScreen[playerid][6], -1667654401);
	PlayerTextDrawSetShadow(playerid, MDC_MainScreen[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, MDC_MainScreen[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_MainScreen[playerid][6], 255);
	PlayerTextDrawFont(playerid, MDC_MainScreen[playerid][6], 2);
	PlayerTextDrawSetProportional(playerid, MDC_MainScreen[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, MDC_MainScreen[playerid][6], 0);

	MDC_MainScreen[playerid][7] = CreatePlayerTextDraw(playerid, 338.502441, 272.724365, "3 5");
	PlayerTextDrawTextSize(playerid, MDC_MainScreen[playerid][7], 241.000000, 206.000000);
	PlayerTextDrawLetterSize(playerid, MDC_MainScreen[playerid][7], 0.223998, 1.127063);
	PlayerTextDrawAlignment(playerid, MDC_MainScreen[playerid][7], 1);
	PlayerTextDrawColor(playerid, MDC_MainScreen[playerid][7], -1667654401);
	PlayerTextDrawSetShadow(playerid, MDC_MainScreen[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, MDC_MainScreen[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_MainScreen[playerid][7], 255);
	PlayerTextDrawFont(playerid, MDC_MainScreen[playerid][7], 2);
	PlayerTextDrawSetProportional(playerid, MDC_MainScreen[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, MDC_MainScreen[playerid][7], 0);

	MDC_LookUp_Name[playerid][0] = CreatePlayerTextDraw(playerid, 254.199676, 177.730865, "ISIM");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Name[playerid][0], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Name[playerid][0], 10.559998, 39.000000);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Name[playerid][0], 2);
	PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][0], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_LookUp_Name[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, MDC_LookUp_Name[playerid][0], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Name[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Name[playerid][0], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][0], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Name[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][0], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_LookUp_Name[playerid][0], true);

	MDC_LookUp_Name[playerid][1] = CreatePlayerTextDraw(playerid, 297.202301, 177.730865, "PLAKA");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Name[playerid][1], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Name[playerid][1], 10.559998, 39.000000);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Name[playerid][1], 2);
	PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][1], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_LookUp_Name[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, MDC_LookUp_Name[playerid][1], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Name[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Name[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][1], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Name[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][1], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_LookUp_Name[playerid][1], true);

	MDC_LookUp_Name[playerid][2] = CreatePlayerTextDraw(playerid, 325.199707, 177.908264, "box");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Name[playerid][2], 0.000000, 1.030997);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Name[playerid][2], 464.000000, 10.000000);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Name[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][2], -1);
	PlayerTextDrawUseBox(playerid, MDC_LookUp_Name[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, MDC_LookUp_Name[playerid][2], -1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Name[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Name[playerid][2], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Name[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][2], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_LookUp_Name[playerid][2], true);

	MDC_LookUp_Name[playerid][3] = CreatePlayerTextDraw(playerid, 489.901702, 177.437606, "YENILE");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Name[playerid][3], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Name[playerid][3], 10.559998, 39.000000);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Name[playerid][3], 2);
	PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][3], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_LookUp_Name[playerid][3], 1);
	PlayerTextDrawBoxColor(playerid, MDC_LookUp_Name[playerid][3], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Name[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Name[playerid][3], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][3], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Name[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][3], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_LookUp_Name[playerid][3], true);

	MDC_LookUp_Name[playerid][4] = CreatePlayerTextDraw(playerid, 327.800292, 177.355590, "SearchedText");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Name[playerid][4], 0.241199, 1.002665);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Name[playerid][4], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][4], 255);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Name[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Name[playerid][4], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Name[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][4], 0);

	MDC_LookUp_Name[playerid][5] = CreatePlayerTextDraw(playerid, 146.900390, 183.111587, "");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Name[playerid][5], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Name[playerid][5], 239.000000, 196.000000);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Name[playerid][5], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][5], -1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Name[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Name[playerid][5], 0);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][5], 5);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Name[playerid][5], 0);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][5], 0);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][5], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawSetPreviewModel(playerid, MDC_LookUp_Name[playerid][5], 301);
	PlayerTextDrawSetPreviewRot(playerid, MDC_LookUp_Name[playerid][5], 0.000000, 0.000000, 30.000000, 1.000000);

	MDC_LookUp_Name[playerid][6] = CreatePlayerTextDraw(playerid, 230.500396, 273.403350, "box");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Name[playerid][6], 0.000000, 12.439991);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Name[playerid][6], 497.499908, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Name[playerid][6], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][6], 255);
	PlayerTextDrawUseBox(playerid, MDC_LookUp_Name[playerid][6], 1);
	PlayerTextDrawBoxColor(playerid, MDC_LookUp_Name[playerid][6], -572662273);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Name[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Name[playerid][6], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][6], 1);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Name[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][6], 0);

	MDC_LookUp_Name[playerid][7] = CreatePlayerTextDraw(playerid, 302.699981, 202.675979, "ISIM:~n~NUMARA:~n~SABIKA:~n~LISANSLAR:~n~ADRESLER:");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Name[playerid][7], 0.167198, 1.012622);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Name[playerid][7], 348.000000, 150.000000);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Name[playerid][7], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][7], 1044266751);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Name[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Name[playerid][7], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][7], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Name[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][7], 0);

	MDC_LookUp_Name[playerid][8] = CreatePlayerTextDraw(playerid, 368.303985, 202.675979, "SearchedName~n~SearchedNumber~n~SearchedPriors~n~SearchedLicenses~n~SearchedAddresses~n~~r~Bu_kisi_araniyor.");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Name[playerid][8],0.167198, 1.012622);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Name[playerid][8], 10.559998, 68.000000);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Name[playerid][8], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][8], -1717986817);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Name[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Name[playerid][8], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][8], 1);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Name[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][8], 0);

	MDC_LookUp_Name[playerid][9] = CreatePlayerTextDraw(playerid, 233.501403, 275.013336, "]_Bu_Oyuncu_Birden_Fazla_Adrese_Sahip,_Listelemek_icin_tiklayin");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Name[playerid][9], 0.187795, 0.982931);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Name[playerid][9], 517.000000, 9.0);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Name[playerid][9], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][9], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_LookUp_Name[playerid][9], 1);
	PlayerTextDrawBoxColor(playerid, MDC_LookUp_Name[playerid][9], -57089);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Name[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Name[playerid][9], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][9], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Name[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][9], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_LookUp_Name[playerid][9], true);

	MDC_LookUp_Name[playerid][10] = CreatePlayerTextDraw(playerid, 233.401428, 289.951171, "~>~_Lisanslari_Yonet");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Name[playerid][10], 0.187795, 0.982931);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Name[playerid][10], 373.000000, 9.0);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Name[playerid][10], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][10], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_LookUp_Name[playerid][10], 1);
	PlayerTextDrawBoxColor(playerid, MDC_LookUp_Name[playerid][10], -1431655681);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Name[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Name[playerid][10], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][10], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Name[playerid][10], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][10], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_LookUp_Name[playerid][10], true);

	MDC_LookUp_Name[playerid][11] = CreatePlayerTextDraw(playerid, 447.804534, 289.639862, "~y~]_~w~SABIKA_KAYDI_~y~]_");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Name[playerid][11], 0.187795, 0.982931);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Name[playerid][11], 10.559998, 140.000000);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Name[playerid][11], 2);
	PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][11], -1);
	PlayerTextDrawUseBox(playerid, MDC_LookUp_Name[playerid][11], 1);
	PlayerTextDrawBoxColor(playerid, MDC_LookUp_Name[playerid][11], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Name[playerid][11], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Name[playerid][11], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][11], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Name[playerid][11], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][11], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_LookUp_Name[playerid][11], true);

	MDC_LookUp_Name[playerid][12] = CreatePlayerTextDraw(playerid, 233.401428, 303.752014, "~>~_Islem_Uygula");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Name[playerid][12], 0.187795, 0.982931);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Name[playerid][12], 373.000000, 9.0);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Name[playerid][12], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][12], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_LookUp_Name[playerid][12], 1);
	PlayerTextDrawBoxColor(playerid, MDC_LookUp_Name[playerid][12], -1431655681);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][12], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Name[playerid][12], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Name[playerid][12], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][12], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Name[playerid][12], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][12], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_LookUp_Name[playerid][12], true);

	MDC_LookUp_Name[playerid][13] = CreatePlayerTextDraw(playerid, 233.401428, 317.552856, "~>~_Tutuklama_Raporu_Yaz");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Name[playerid][13], 0.187795, 0.982931);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Name[playerid][13], 373.000000, 9.0);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Name[playerid][13], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][13], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_LookUp_Name[playerid][13], 1);
	PlayerTextDrawBoxColor(playerid, MDC_LookUp_Name[playerid][13], -1431655681);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][13], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Name[playerid][13], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Name[playerid][13], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][13], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Name[playerid][13], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][13], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_LookUp_Name[playerid][13], true);

	MDC_LookUp_Name[playerid][14] = CreatePlayerTextDraw(playerid, 383.303619, 302.513458, "CriminalRecord1");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Name[playerid][14], 0.167198, 1.012622);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Name[playerid][14], 373.000000, 9.0);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Name[playerid][14], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][14], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][14], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Name[playerid][14], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Name[playerid][14], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][14], 1);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Name[playerid][14], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][14], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_LookUp_Name[playerid][14], true);

	MDC_LookUp_Name[playerid][15] = CreatePlayerTextDraw(playerid, 492.299896, 359.664031, "");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Name[playerid][15], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Name[playerid][15], 8.779994, 9.320007);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Name[playerid][15], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][15], -2139062017);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][15], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Name[playerid][15], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Name[playerid][15], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][15], 4);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Name[playerid][15], 0);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][15], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_LookUp_Name[playerid][15], false);

	MDC_LookUp_Name[playerid][16] = CreatePlayerTextDraw(playerid, 502.800537, 359.664031, "");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Name[playerid][16], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Name[playerid][16], 8.779994, 9.320007);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Name[playerid][16], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Name[playerid][16], -2139062017);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][16], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Name[playerid][16], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Name[playerid][16], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Name[playerid][16], 4);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Name[playerid][16], 0);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Name[playerid][16], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_LookUp_Name[playerid][16], false);

	MDC_LookUp_Name[playerid][17] = CreatePlayerTextDraw(playerid, 340.604949, 177.730865, "");

	MDC_LookUp_Vehicle[playerid][0] = CreatePlayerTextDraw(playerid, 229.500122, 176.753524, "");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Vehicle[playerid][0], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Vehicle[playerid][0], 78.000000, 79.000000);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Vehicle[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Vehicle[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Vehicle[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Vehicle[playerid][0], 0);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][0], 5);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Vehicle[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][0], 0);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][0], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawSetPreviewModel(playerid, MDC_LookUp_Vehicle[playerid][0], 406);
	PlayerTextDrawSetPreviewRot(playerid, MDC_LookUp_Vehicle[playerid][0], 0.000000, 0.000000, 90.000000, 1.000000);
	PlayerTextDrawSetPreviewVehCol(playerid, MDC_LookUp_Vehicle[playerid][0], 1, 1);

	MDC_LookUp_Vehicle[playerid][1] = CreatePlayerTextDraw(playerid, 229.500213, 224.907669, "");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Vehicle[playerid][1], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Vehicle[playerid][1], 78.000000, 79.000000);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Vehicle[playerid][1], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Vehicle[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Vehicle[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Vehicle[playerid][1], 0);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][1], 5);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Vehicle[playerid][1], 0);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][1], 0);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][1], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawSetPreviewModel(playerid, MDC_LookUp_Vehicle[playerid][1], 406);
	PlayerTextDrawSetPreviewRot(playerid, MDC_LookUp_Vehicle[playerid][1], 0.000000, 0.000000, 90.000000, 1.000000);
	PlayerTextDrawSetPreviewVehCol(playerid, MDC_LookUp_Vehicle[playerid][1], 1, 1);

	MDC_LookUp_Vehicle[playerid][2] = CreatePlayerTextDraw(playerid, 228.599945, 276.157653, "");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Vehicle[playerid][2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Vehicle[playerid][2], 78.000000, 79.000000);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Vehicle[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Vehicle[playerid][2], -1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Vehicle[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Vehicle[playerid][2], 0);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][2], 5);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Vehicle[playerid][2], 0);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][2], 0);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][2], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawSetPreviewModel(playerid, MDC_LookUp_Vehicle[playerid][2], 406);
	PlayerTextDrawSetPreviewRot(playerid, MDC_LookUp_Vehicle[playerid][2], 0.000000, 0.000000, 90.000000, 1.000000);
	PlayerTextDrawSetPreviewVehCol(playerid, MDC_LookUp_Vehicle[playerid][2], 1, 1);

	MDC_LookUp_Vehicle[playerid][3] = CreatePlayerTextDraw(playerid, 229.599975, 328.540191, "");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Vehicle[playerid][3], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Vehicle[playerid][3], 78.000000, 79.000000);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Vehicle[playerid][3], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Vehicle[playerid][3], -1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Vehicle[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Vehicle[playerid][3], 0);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][3], 5);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Vehicle[playerid][3], 0);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][3], 0);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][3], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawSetPreviewModel(playerid, MDC_LookUp_Vehicle[playerid][3], 406);
	PlayerTextDrawSetPreviewRot(playerid, MDC_LookUp_Vehicle[playerid][3], 0.000000, 0.000000, 90.000000, 1.000000);
	PlayerTextDrawSetPreviewVehCol(playerid, MDC_LookUp_Vehicle[playerid][3], 1, 1);

	MDC_LookUp_Vehicle[playerid][4] = CreatePlayerTextDraw(playerid, 229.599990, 379.278747, "");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Vehicle[playerid][4], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_LookUp_Vehicle[playerid][4], 78.000000, 79.000000);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Vehicle[playerid][4], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Vehicle[playerid][4], -1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Vehicle[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Vehicle[playerid][4], 0);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][4], 5);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Vehicle[playerid][4], 0);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][4], 0);
		PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][4], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawSetPreviewModel(playerid, MDC_LookUp_Vehicle[playerid][4], 406);
	PlayerTextDrawSetPreviewRot(playerid, MDC_LookUp_Vehicle[playerid][4], 0.000000, 0.000000, 90.000000, 1.000000);
	PlayerTextDrawSetPreviewVehCol(playerid, MDC_LookUp_Vehicle[playerid][4], 1, 1);

	MDC_LookUp_Vehicle[playerid][5] = CreatePlayerTextDraw(playerid, 319.200164, 194.977767, "MODEL:~n~PLAKA:~n~SAHIP:~n~SIGORTA:~n~HACIZ");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Vehicle[playerid][5], 0.190799, 0.962844);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Vehicle[playerid][5], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Vehicle[playerid][5], 255);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Vehicle[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Vehicle[playerid][5], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][5], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Vehicle[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][5], 0);

	MDC_LookUp_Vehicle[playerid][6] = CreatePlayerTextDraw(playerid, 319.200164, 243.479080, "MODEL:~n~PLAKA:~n~SAHIP:~n~SIGORTA:~n~HACIZ");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Vehicle[playerid][6], 0.190799, 0.962844);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Vehicle[playerid][6], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Vehicle[playerid][6], 255);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Vehicle[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Vehicle[playerid][6], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][6], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Vehicle[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][6], 0);

	MDC_LookUp_Vehicle[playerid][7] = CreatePlayerTextDraw(playerid, 319.200164, 291.778900, "MODEL:~n~PLAKA:~n~SAHIP:~n~SIGORTA:~n~HACIZ");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Vehicle[playerid][7], 0.190799, 0.962844);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Vehicle[playerid][7], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Vehicle[playerid][7], 255);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Vehicle[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Vehicle[playerid][7], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][7], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Vehicle[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][7], 0);

	MDC_LookUp_Vehicle[playerid][8] = CreatePlayerTextDraw(playerid, 319.200164, 341.880859, "MODEL:~n~PLAKA:~n~SAHIP:~n~SIGORTA:~n~HACIZ");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Vehicle[playerid][8], 0.190799, 0.962844);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Vehicle[playerid][8], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Vehicle[playerid][8], 255);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Vehicle[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Vehicle[playerid][8], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][8], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Vehicle[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][8], 0);

	MDC_LookUp_Vehicle[playerid][9] = CreatePlayerTextDraw(playerid, 319.200164, 392.978363, "MODEL:~n~PLAKA:~n~SAHIP:~n~SIGORTA:~n~HACIZ");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Vehicle[playerid][9], 0.190799, 0.962844);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Vehicle[playerid][9], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Vehicle[playerid][9], 255);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Vehicle[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Vehicle[playerid][9], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][9], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Vehicle[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][9], 0);

	MDC_LookUp_Vehicle[playerid][10] = CreatePlayerTextDraw(playerid, 360.599945, 194.977767, "aracmodel~n~aracplaka~n~aracsahip~n~aracsigorta~n~arachaciz");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Vehicle[playerid][10], 0.190799, 0.962844);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Vehicle[playerid][10], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Vehicle[playerid][10], -2139062017);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Vehicle[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Vehicle[playerid][10], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][10], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Vehicle[playerid][10], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][10], 0);

	MDC_LookUp_Vehicle[playerid][11] = CreatePlayerTextDraw(playerid, 360.599945, 243.277832, "aracmodel~n~aracplaka~n~aracsahip~n~aracsigorta~n~arachaciz");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Vehicle[playerid][11], 0.190799, 0.962844);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Vehicle[playerid][11], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Vehicle[playerid][11], -2139062017);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Vehicle[playerid][11], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Vehicle[playerid][11], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][11], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Vehicle[playerid][11], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][11], 0);

	MDC_LookUp_Vehicle[playerid][12] = CreatePlayerTextDraw(playerid, 360.599945, 291.577667, "aracmodel~n~aracplaka~n~aracsahip~n~aracsigorta~n~arachaciz");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Vehicle[playerid][12], 0.190799, 0.962844);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Vehicle[playerid][12], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Vehicle[playerid][12], -2139062017);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][12], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Vehicle[playerid][12], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Vehicle[playerid][12], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][12], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Vehicle[playerid][12], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][12], 0);

	MDC_LookUp_Vehicle[playerid][13] = CreatePlayerTextDraw(playerid, 360.599945, 342.177398, "aracmodel~n~aracplaka~n~aracsahip~n~aracsigorta~n~arachaciz");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Vehicle[playerid][13], 0.190799, 0.962844);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Vehicle[playerid][13], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Vehicle[playerid][13], -2139062017);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][13], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Vehicle[playerid][13], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Vehicle[playerid][13], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][13], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Vehicle[playerid][13], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][13], 0);

	MDC_LookUp_Vehicle[playerid][14] = CreatePlayerTextDraw(playerid, 360.199951, 392.279357, "aracmodel~n~aracplaka~n~aracsahip~n~aracsigorta~n~arachaciz");
	PlayerTextDrawLetterSize(playerid, MDC_LookUp_Vehicle[playerid][14], 0.190799, 0.962844);
	PlayerTextDrawAlignment(playerid, MDC_LookUp_Vehicle[playerid][14], 1);
	PlayerTextDrawColor(playerid, MDC_LookUp_Vehicle[playerid][14], -2139062017);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][14], 0);
	PlayerTextDrawSetOutline(playerid, MDC_LookUp_Vehicle[playerid][14], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_LookUp_Vehicle[playerid][14], 255);
	PlayerTextDrawFont(playerid, MDC_LookUp_Vehicle[playerid][14], 2);
	PlayerTextDrawSetProportional(playerid, MDC_LookUp_Vehicle[playerid][14], 1);
	PlayerTextDrawSetShadow(playerid, MDC_LookUp_Vehicle[playerid][14], 0);


	MDC_AdressDetails[playerid][0] = CreatePlayerTextDraw(playerid, 236.201202, 167.593261, "~<~_Geri_Git");
	PlayerTextDrawLetterSize(playerid, MDC_AdressDetails[playerid][0], 0.231199, 1.122133);
	PlayerTextDrawTextSize(playerid, MDC_AdressDetails[playerid][0], 290.000488, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_AdressDetails[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_AdressDetails[playerid][0], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_AdressDetails[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, MDC_AdressDetails[playerid][0], 84215040);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_AdressDetails[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_AdressDetails[playerid][0], 255);
	PlayerTextDrawFont(playerid, MDC_AdressDetails[playerid][0], 2);
	PlayerTextDrawSetProportional(playerid, MDC_AdressDetails[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][0], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_AdressDetails[playerid][0], true);

	MDC_AdressDetails[playerid][1] = CreatePlayerTextDraw(playerid, 228.300003, 186.304260, "Birincil_Adres");
	PlayerTextDrawLetterSize(playerid, MDC_AdressDetails[playerid][1], 0.208399, 1.117155);
	PlayerTextDrawAlignment(playerid, MDC_AdressDetails[playerid][1], 1);
	PlayerTextDrawColor(playerid, MDC_AdressDetails[playerid][1], 1583243007);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_AdressDetails[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_AdressDetails[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_AdressDetails[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, MDC_AdressDetails[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][1], 0);

	MDC_AdressDetails[playerid][2] = CreatePlayerTextDraw(playerid, 233.400314, 196.004852, "secondaryAddress~n~addressCity~n~addressCounty~n~addressCountry");
	PlayerTextDrawLetterSize(playerid, MDC_AdressDetails[playerid][2], 0.208399, 1.117155);
	PlayerTextDrawAlignment(playerid, MDC_AdressDetails[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_AdressDetails[playerid][2], -1515870721);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_AdressDetails[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_AdressDetails[playerid][2], 255);
	PlayerTextDrawFont(playerid, MDC_AdressDetails[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, MDC_AdressDetails[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][2], 0);

	MDC_AdressDetails[playerid][3] = CreatePlayerTextDraw(playerid, 369.399383, 166.349380, "samaps:gtasamapbit4");
	PlayerTextDrawLetterSize(playerid, MDC_AdressDetails[playerid][3], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_AdressDetails[playerid][3], 131.000000, 138.000000);
	PlayerTextDrawAlignment(playerid, MDC_AdressDetails[playerid][3], 1);
	PlayerTextDrawColor(playerid, MDC_AdressDetails[playerid][3], -1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_AdressDetails[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_AdressDetails[playerid][3], 255);
	PlayerTextDrawFont(playerid, MDC_AdressDetails[playerid][3], 4);
	PlayerTextDrawSetProportional(playerid, MDC_AdressDetails[playerid][3], 0);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][3], 0);

	MDC_AdressDetails[playerid][4] = CreatePlayerTextDraw(playerid, 228.300003, 240.007537, "Diger_Adresler");
	PlayerTextDrawLetterSize(playerid, MDC_AdressDetails[playerid][4], 0.208399, 1.117155);
	PlayerTextDrawAlignment(playerid, MDC_AdressDetails[playerid][4], 1);
	PlayerTextDrawColor(playerid, MDC_AdressDetails[playerid][4], 1583243007);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_AdressDetails[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_AdressDetails[playerid][4], 255);
	PlayerTextDrawFont(playerid, MDC_AdressDetails[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, MDC_AdressDetails[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][4], 0);

	MDC_AdressDetails[playerid][5] = CreatePlayerTextDraw(playerid, 232.400238, 253.739410, "-_adressNumber1");
	PlayerTextDrawLetterSize(playerid, MDC_AdressDetails[playerid][5], 0.208399, 1.117155);
	PlayerTextDrawTextSize(playerid, MDC_AdressDetails[playerid][5], 359.000000, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_AdressDetails[playerid][5], 1);
	PlayerTextDrawColor(playerid, MDC_AdressDetails[playerid][5], -1515870721);
	PlayerTextDrawUseBox(playerid, MDC_AdressDetails[playerid][5], 1);
	PlayerTextDrawBoxColor(playerid, MDC_AdressDetails[playerid][5], -1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, MDC_AdressDetails[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_AdressDetails[playerid][5], 255);
	PlayerTextDrawFont(playerid, MDC_AdressDetails[playerid][5], 1);
	PlayerTextDrawSetProportional(playerid, MDC_AdressDetails[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][5], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_AdressDetails[playerid][5], true);

	MDC_AdressDetails[playerid][6] = CreatePlayerTextDraw(playerid, 232.400238, 269.640380, "-_adressNumber2");
	PlayerTextDrawLetterSize(playerid, MDC_AdressDetails[playerid][6], 0.208399, 1.117155);
	PlayerTextDrawTextSize(playerid, MDC_AdressDetails[playerid][6], 359.000000, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_AdressDetails[playerid][6], 1);
	PlayerTextDrawColor(playerid, MDC_AdressDetails[playerid][6], -1515870721);
	PlayerTextDrawUseBox(playerid, MDC_AdressDetails[playerid][6], 1);
	PlayerTextDrawBoxColor(playerid, MDC_AdressDetails[playerid][6], -1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, MDC_AdressDetails[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_AdressDetails[playerid][6], 255);
	PlayerTextDrawFont(playerid, MDC_AdressDetails[playerid][6], 1);
	PlayerTextDrawSetProportional(playerid, MDC_AdressDetails[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][6], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_AdressDetails[playerid][6], true);

	MDC_AdressDetails[playerid][7] = CreatePlayerTextDraw(playerid, 232.400238, 285.641357, "-_adressNumber3");
	PlayerTextDrawLetterSize(playerid, MDC_AdressDetails[playerid][7], 0.208399, 1.117155);
	PlayerTextDrawTextSize(playerid, MDC_AdressDetails[playerid][7], 359.000000, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_AdressDetails[playerid][7], 1);
	PlayerTextDrawColor(playerid, MDC_AdressDetails[playerid][7], -1515870721);
	PlayerTextDrawUseBox(playerid, MDC_AdressDetails[playerid][7], 1);
	PlayerTextDrawBoxColor(playerid, MDC_AdressDetails[playerid][7], -1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, MDC_AdressDetails[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_AdressDetails[playerid][7], 255);
	PlayerTextDrawFont(playerid, MDC_AdressDetails[playerid][7], 1);
	PlayerTextDrawSetProportional(playerid, MDC_AdressDetails[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][7], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_AdressDetails[playerid][7], true);

	MDC_AdressDetails[playerid][8] = CreatePlayerTextDraw(playerid, 232.400238, 301.842346, "-_adressNumber4");
	PlayerTextDrawLetterSize(playerid, MDC_AdressDetails[playerid][8], 0.208399, 1.117155);
	PlayerTextDrawTextSize(playerid, MDC_AdressDetails[playerid][8], 359.000000, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_AdressDetails[playerid][8], 1);
	PlayerTextDrawColor(playerid, MDC_AdressDetails[playerid][8], -1515870721);
	PlayerTextDrawUseBox(playerid, MDC_AdressDetails[playerid][8], 1);
	PlayerTextDrawBoxColor(playerid, MDC_AdressDetails[playerid][8], -1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, MDC_AdressDetails[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_AdressDetails[playerid][8], 255);
	PlayerTextDrawFont(playerid, MDC_AdressDetails[playerid][8], 1);
	PlayerTextDrawSetProportional(playerid, MDC_AdressDetails[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][8], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_AdressDetails[playerid][8], true);

	MDC_AdressDetails[playerid][9] = CreatePlayerTextDraw(playerid, 232.400238, 317.943328, "-_adressNumber5");
	PlayerTextDrawLetterSize(playerid, MDC_AdressDetails[playerid][9], 0.208399, 1.117155);
	PlayerTextDrawTextSize(playerid, MDC_AdressDetails[playerid][9], 359.000000, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_AdressDetails[playerid][9], 1);
	PlayerTextDrawColor(playerid, MDC_AdressDetails[playerid][9], -1515870721);
	PlayerTextDrawUseBox(playerid, MDC_AdressDetails[playerid][9], 1);
	PlayerTextDrawBoxColor(playerid, MDC_AdressDetails[playerid][9], -1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, MDC_AdressDetails[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_AdressDetails[playerid][9], 255);
	PlayerTextDrawFont(playerid, MDC_AdressDetails[playerid][9], 1);
	PlayerTextDrawSetProportional(playerid, MDC_AdressDetails[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][9], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_AdressDetails[playerid][9], true);

	MDC_AdressDetails[playerid][10] = CreatePlayerTextDraw(playerid, 348.399841, 332.408905, "LD_BEAT:right");
	PlayerTextDrawLetterSize(playerid, MDC_AdressDetails[playerid][10], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_AdressDetails[playerid][10], 13.000000, 12.000000);
	PlayerTextDrawAlignment(playerid, MDC_AdressDetails[playerid][10], 1);
	PlayerTextDrawColor(playerid, MDC_AdressDetails[playerid][10], -1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, MDC_AdressDetails[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_AdressDetails[playerid][10], 255);
	PlayerTextDrawFont(playerid, MDC_AdressDetails[playerid][10], 4);
	PlayerTextDrawSetProportional(playerid, MDC_AdressDetails[playerid][10], 0);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][10], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_AdressDetails[playerid][10], true);

	MDC_AdressDetails[playerid][11] = CreatePlayerTextDraw(playerid, 338.399841, 332.408905, "LD_BEAT:left");
	PlayerTextDrawLetterSize(playerid, MDC_AdressDetails[playerid][11], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_AdressDetails[playerid][11], 13.000000, 12.000000);
	PlayerTextDrawAlignment(playerid, MDC_AdressDetails[playerid][11], 1);
	PlayerTextDrawColor(playerid, MDC_AdressDetails[playerid][11], -1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, MDC_AdressDetails[playerid][11], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_AdressDetails[playerid][11], 255);
	PlayerTextDrawFont(playerid, MDC_AdressDetails[playerid][11], 4);
	PlayerTextDrawSetProportional(playerid, MDC_AdressDetails[playerid][11], 0);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][11], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_AdressDetails[playerid][11], true);

	MDC_AdressDetails[playerid][12] = CreatePlayerTextDraw(playerid, 369.399383, 304.250640, "samaps:gtasamapbit3");
	PlayerTextDrawLetterSize(playerid, MDC_AdressDetails[playerid][12], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_AdressDetails[playerid][12], 131.000000, 138.000000);
	PlayerTextDrawAlignment(playerid, MDC_AdressDetails[playerid][12], 1);
	PlayerTextDrawColor(playerid, MDC_AdressDetails[playerid][12], -1);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][12], 0);
	PlayerTextDrawSetOutline(playerid, MDC_AdressDetails[playerid][12], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_AdressDetails[playerid][12], 255);
	PlayerTextDrawFont(playerid, MDC_AdressDetails[playerid][12], 4);
	PlayerTextDrawSetProportional(playerid, MDC_AdressDetails[playerid][12], 0);
	PlayerTextDrawSetShadow(playerid, MDC_AdressDetails[playerid][12], 0);

	MDC_ManageLicense[playerid][0] = CreatePlayerTextDraw(playerid, 236.201202, 167.593261, "~<~_Geri_Git");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][0], 0.231196, 1.122133);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][0], 290.000488, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][0], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_ManageLicense[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, MDC_ManageLicense[playerid][0], 84215040);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][0], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][0], 2);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][0], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_ManageLicense[playerid][0], true);

	MDC_ManageLicense[playerid][1] = CreatePlayerTextDraw(playerid, 233.099624, 196.366577, "box");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][1], 0.000000, 7.030000);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][1], 364.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][1], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][1], -1);
	PlayerTextDrawUseBox(playerid, MDC_ManageLicense[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, MDC_ManageLicense[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][1], 0);

	MDC_ManageLicense[playerid][2] = CreatePlayerTextDraw(playerid, 233.399856, 196.659851, "_________Surucu_Lisansi");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][2], 0.149997, 0.873242);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][2], 364.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][2], -1);
	PlayerTextDrawUseBox(playerid, MDC_ManageLicense[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, MDC_ManageLicense[playerid][2], 859803647);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][2], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][2], 2);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][2], 0);

	MDC_ManageLicense[playerid][3] = CreatePlayerTextDraw(playerid, 232.599426, 194.010894, "LD_BEAT:chit");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][3], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][3], 18.000000, 23.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][3], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][3], -1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][3], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][3], 4);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][3], 0);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][3], 0);

	MDC_ManageLicense[playerid][4] = CreatePlayerTextDraw(playerid, 254.200042, 207.624465, "Durum:~n~Uyarilar:");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][4], 0.185199, 1.012621);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][4], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][4], 1920103167);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][4], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][4], 0);

	MDC_ManageLicense[playerid][5] = CreatePlayerTextDraw(playerid, 294.802520, 207.624465, "playerDriverLicenses~n~playerDrLicenWarnings");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][5], 0.185199, 1.012621);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][5], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][5], 1920103167);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][5], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][5], 1);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][5], 0);

	MDC_ManageLicense[playerid][6] = CreatePlayerTextDraw(playerid, 254.299896, 248.258010, "IPTAL ET");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][6], 0.180799, 0.962844);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][6], 10.000000, 39.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][6], 2);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][6], -1);
	PlayerTextDrawUseBox(playerid, MDC_ManageLicense[playerid][6], 1);
	PlayerTextDrawBoxColor(playerid, MDC_ManageLicense[playerid][6], 2115512063);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][6], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][6], 2);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][6], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_ManageLicense[playerid][6], true);

	MDC_ManageLicense[playerid][7] = CreatePlayerTextDraw(playerid, 297.502532, 248.258010, "UYAR");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][7], 0.180799, 0.962844);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][7], 10.000000, 39.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][7], 2);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][7], -1);
	PlayerTextDrawUseBox(playerid, MDC_ManageLicense[playerid][7], 1);
	PlayerTextDrawBoxColor(playerid, MDC_ManageLicense[playerid][7], 572662527);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][7], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][7], 2);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][7], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_ManageLicense[playerid][7], true);

	MDC_ManageLicense[playerid][9] = CreatePlayerTextDraw(playerid, 233.099624, 275.771423, "box");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][9], 0.000000, 7.030000);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][9], 364.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][9], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][9], -1);
	PlayerTextDrawUseBox(playerid, MDC_ManageLicense[playerid][9], 1);
	PlayerTextDrawBoxColor(playerid, MDC_ManageLicense[playerid][9], -1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][9], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][9], 1);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][9], 0);

	MDC_ManageLicense[playerid][10] = CreatePlayerTextDraw(playerid, 233.399856, 275.864685, "___________MEDIKAL_LISANS");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][10], 0.149997, 0.873242);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][10], 364.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][10], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][10], -1);
	PlayerTextDrawUseBox(playerid, MDC_ManageLicense[playerid][10], 1);
	PlayerTextDrawBoxColor(playerid, MDC_ManageLicense[playerid][10], 859803647);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][10], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][10], 2);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][10], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][10], 0);

	MDC_ManageLicense[playerid][11] = CreatePlayerTextDraw(playerid, 234.099304, 270.486694, "hud:radar_girlfriend");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][11], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][11], 17.000000, 19.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][11], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][11], -1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][11], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][11], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][11], 4);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][11], 0);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][11], 0);

	MDC_ManageLicense[playerid][12] = CreatePlayerTextDraw(playerid, 254.400146, 287.734161, "Durum:");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][12], 0.185199, 1.012621);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][12], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][12], 1920103167);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][12], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][12], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][12], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][12], 1);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][12], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][12], 0);

	MDC_ManageLicense[playerid][13] = CreatePlayerTextDraw(playerid, 294.802307, 287.716247, "playerPilotLicense");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][13], 0.185199, 1.012621);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][13], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][13], 1920103167);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][13], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][13], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][13], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][13], 1);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][13], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][13], 0);

	MDC_ManageLicense[playerid][14] = CreatePlayerTextDraw(playerid, 254.299957, 327.151947, "IPTAL ET");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][14], 0.180799, 0.962844);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][14], 10.000000, 39.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][14], 2);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][14], -1);
	PlayerTextDrawUseBox(playerid, MDC_ManageLicense[playerid][14], 1);
	PlayerTextDrawBoxColor(playerid, MDC_ManageLicense[playerid][14], 2115512063);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][14], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][14], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][14], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][14], 2);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][14], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][14], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_ManageLicense[playerid][14], true);

	MDC_ManageLicense[playerid][15] = CreatePlayerTextDraw(playerid, 379.004516, 196.968887, "box");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][15], 0.000000, 6.959003);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][15], 510.770843, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][15], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][15], -1);
	PlayerTextDrawUseBox(playerid, MDC_ManageLicense[playerid][15], 1);
	PlayerTextDrawBoxColor(playerid, MDC_ManageLicense[playerid][15], -1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][15], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][15], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][15], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][15], 1);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][15], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][15], 0);

	MDC_ManageLicense[playerid][16] = CreatePlayerTextDraw(playerid, 379.008209, 196.757614, "_________SILAH_LISANSI");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][16], 0.149997, 0.873242);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][16], 510.910644, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][16], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][16], -1);
	PlayerTextDrawUseBox(playerid, MDC_ManageLicense[playerid][16], 1);
	PlayerTextDrawBoxColor(playerid, MDC_ManageLicense[playerid][16], 859803647);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][16], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][16], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][16], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][16], 2);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][16], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][16], 0);

	MDC_ManageLicense[playerid][17] = CreatePlayerTextDraw(playerid, 378.000976, 193.724411, "LD_BEAT:chit");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][17], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][17], 18.000000, 23.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][17], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][17], -1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][17], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][17], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][17], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][17], 4);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][17], 0);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][17], 0);

	MDC_ManageLicense[playerid][18] = CreatePlayerTextDraw(playerid, 401.801727, 207.626724, "Durum:");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][18], 0.185199, 1.012621);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][18], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][18], 1920103167);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][18], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][18], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][18], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][18], 1);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][18], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][18], 0);

	MDC_ManageLicense[playerid][19] = CreatePlayerTextDraw(playerid, 444.404418, 207.724472, "playerGLicense");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][19], 0.185199, 1.012621);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][19], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][19], 1920103167);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][19], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][19], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][19], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][19], 1);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][19], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][19], 0);

	MDC_ManageLicense[playerid][20] = CreatePlayerTextDraw(playerid, 401.400909, 248.255752, "IPTAL ET");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][20], 0.180799, 0.962844);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][20], 10.000000, 39.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][20], 2);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][20], -1);
	PlayerTextDrawUseBox(playerid, MDC_ManageLicense[playerid][20], 1);
	PlayerTextDrawBoxColor(playerid, MDC_ManageLicense[playerid][20], 2115512063);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][20], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][20], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][20], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][20], 2);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][20], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][20], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_ManageLicense[playerid][20], true);

	MDC_ManageLicense[playerid][21] = CreatePlayerTextDraw(playerid, 445.403594, 248.255752, "VER");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][21], 0.180799, 0.962844);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][21], 10.000000, 39.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][21], 2);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][21], -1);
	PlayerTextDrawUseBox(playerid, MDC_ManageLicense[playerid][21], 1);
	PlayerTextDrawBoxColor(playerid, MDC_ManageLicense[playerid][21], 8388863);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][21], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][21], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][21], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][21], 2);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][21], 1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][21], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_ManageLicense[playerid][21], true);


	MDC_ManageLicense[playerid][28] = CreatePlayerTextDraw(playerid, 236.699539, 198.008880, "hud:radar_impound");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][28], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][28], 10.000000, 14.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][28], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][28], -1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][28], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][28], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][28], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][28], 4);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][28], 0);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][28], 0);

	MDC_ManageLicense[playerid][29] = CreatePlayerTextDraw(playerid, 382.700439, 199.629272, "hud:radar_ammugun");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][29], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][29], 9.000000, 11.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][29], 1);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][29], -1);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][29], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][29], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][29], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][29], 4);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][29], 0);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][29], 0);

	MDC_ManageLicense[playerid][30] = CreatePlayerTextDraw(playerid, 297.502532, 327.151947, "VER");
	PlayerTextDrawLetterSize(playerid, MDC_ManageLicense[playerid][30], 0.180799, 0.962844);
	PlayerTextDrawTextSize(playerid, MDC_ManageLicense[playerid][30], 10.000000, 39.000000);
	PlayerTextDrawAlignment(playerid, MDC_ManageLicense[playerid][30], 2);
	PlayerTextDrawColor(playerid, MDC_ManageLicense[playerid][30], -1);
	PlayerTextDrawUseBox(playerid, MDC_ManageLicense[playerid][30], 1);
	PlayerTextDrawBoxColor(playerid, MDC_ManageLicense[playerid][30], 8388863);
	PlayerTextDrawSetShadow(playerid, MDC_ManageLicense[playerid][30], 0);
	PlayerTextDrawSetOutline(playerid, MDC_ManageLicense[playerid][30], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_ManageLicense[playerid][30], 255);
	PlayerTextDrawFont(playerid, MDC_ManageLicense[playerid][30], 2);
	PlayerTextDrawSetProportional(playerid, MDC_ManageLicense[playerid][30], 1);
	PlayerTextDrawSetShadow(playerid,MDC_ManageLicense[playerid][30], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_ManageLicense[playerid][30], true);

	MDC_PenalCode[playerid][16] = CreatePlayerTextDraw(playerid, 229.100463, 168.324035, "~<~_geri_don");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][16], 0.201388, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][16], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][16], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][16], 1465341951);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][16], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][16], -1886417152);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][16], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][16], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][16], 2);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][16], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][16], true);

	MDC_PenalCode[playerid][17] = CreatePlayerTextDraw(playerid, 229.100463, 181.224212, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][17], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][17], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][17], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][17], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][17], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][17], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][17], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][17], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][17], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][17], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][17], true);

	MDC_PenalCode[playerid][18] = CreatePlayerTextDraw(playerid, 229.100463, 194.624206, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][18], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][18], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][18], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][18], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][18], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][18], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][18], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][18], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][18], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][18], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][18], true);

	MDC_PenalCode[playerid][19] = CreatePlayerTextDraw(playerid, 229.100463, 207.824340, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][19], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][19], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][19], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][19], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][19], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][19], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][19], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][19], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][19], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][19], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][19], true);

	MDC_PenalCode[playerid][20] = CreatePlayerTextDraw(playerid, 229.100463, 221.024475, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][20], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][20], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][20], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][20], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][20], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][20], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][20], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][20], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][20], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][20], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][20], true);

	MDC_PenalCode[playerid][21] = CreatePlayerTextDraw(playerid, 229.100463, 234.224609, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][21], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][21], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][21], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][21], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][21], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][21], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][21], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][21], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][21], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][21], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][21], true);

	MDC_PenalCode[playerid][22] = CreatePlayerTextDraw(playerid, 229.100463, 247.424743, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][22], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][22], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][22], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][22], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][22], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][22], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][22], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][22], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][22], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][22], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][22], true);

	MDC_PenalCode[playerid][23] = CreatePlayerTextDraw(playerid, 229.100463, 260.624633, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][23], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][23], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][23], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][23], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][23], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][23], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][23], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][23], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][23], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][23], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][23], true);

	MDC_PenalCode[playerid][24] = CreatePlayerTextDraw(playerid, 229.100463, 273.824096, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][24], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][24], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][24], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][24], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][24], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][24], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][24], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][24], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][24], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][24], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][24], true);

	MDC_PenalCode[playerid][25] = CreatePlayerTextDraw(playerid, 229.100463, 286.723571, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][25], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][25], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][25], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][25], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][25], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][25], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][25], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][25], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][25], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][25], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][25], true);

	MDC_PenalCode[playerid][26] = CreatePlayerTextDraw(playerid, 229.100463, 299.923034, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][26], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][26], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][26], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][26], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][26], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][26], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][26], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][26], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][26], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][26], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][26], true);

	MDC_PenalCode[playerid][27] = CreatePlayerTextDraw(playerid, 229.100463, 313.122497, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][27], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][27], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][27], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][27], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][27], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][27], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][27], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][27], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][27], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][27], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][27], true);

	MDC_PenalCode[playerid][28] = CreatePlayerTextDraw(playerid, 229.100463, 326.321960, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][28], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][28], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][28], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][28], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][28], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][28], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][28], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][28], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][28], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][28], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][28], true);

	MDC_PenalCode[playerid][29] = CreatePlayerTextDraw(playerid, 229.100463, 339.521423, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][29], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][29], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][29], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][29], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][29], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][29], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][29], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][29], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][29], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][29], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][29], true);

	MDC_PenalCode[playerid][30] = CreatePlayerTextDraw(playerid, 229.100463, 352.720886, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][30], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][30], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][30], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][30], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][30], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][30], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][30], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][30], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][30], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][30], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][30], true);

	MDC_PenalCode[playerid][31] = CreatePlayerTextDraw(playerid, 229.100463, 366.220336, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][31], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][31], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][31], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][31], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][31], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][31], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][31], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][31], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][31], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][31], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][31], true);

	MDC_PenalCode[playerid][32] = CreatePlayerTextDraw(playerid, 229.100463, 379.419799, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][32], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][32], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][32], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][32], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][32], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][32], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][32], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][32], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][32], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][32], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][32], true);

	MDC_PenalCode[playerid][33] = CreatePlayerTextDraw(playerid, 229.100463, 392.319274, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][33], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][33], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][33], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][33], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][33], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][33], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][33], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][33], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][33], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][33], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][33], true);

	MDC_PenalCode[playerid][34] = CreatePlayerTextDraw(playerid, 229.100463, 405.320068, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][34], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][34], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][34], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][34], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][34], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][34], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][34], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][34], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][34], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][34], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][34], true);

	MDC_PenalCode[playerid][35] = CreatePlayerTextDraw(playerid, 229.100463, 418.220855, "PENAL1");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][35], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][35], 345.200531, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][35], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][35], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][35], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][35], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][35], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][35], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][35], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][35], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][35], true);

	MDC_PenalCode[playerid][36] = CreatePlayerTextDraw(playerid, 483.201202, 181.224212, "_temizle");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][36], 0.198390, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][36], 521.778503, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][36], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][36], 858993663);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][36], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][36], -1431655681);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][36], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][36], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][36], 2);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][36], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][36], true);

	MDC_PenalCode[playerid][37] = CreatePlayerTextDraw(playerid, 351.200744, 181.224212, "_filtre_uygula_...");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][37], 0.198390, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][37], 477.299926, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][37], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][37], -1802201857);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][37], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][37], -1);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][37], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][37], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][37], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][37], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][37], true);

	MDC_PenalCode[playerid][38] = CreatePlayerTextDraw(playerid, 350.900817, 194.224273, "ATT");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][38], 0.198390, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][38], 363.000000, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][38], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][38], -1802201857);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][38], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][38], -1802202112);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][38], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][38], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][38], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][38], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][38], true);

	MDC_PenalCode[playerid][39] = CreatePlayerTextDraw(playerid, 367.450439, 194.224273, "SOL");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][39], 0.198390, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][39], 379.549621, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][39], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][39], -1802201857);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][39], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][39], -1802202112);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][39], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][39], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][39], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][39], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][39], true);

	MDC_PenalCode[playerid][40] = CreatePlayerTextDraw(playerid, 383.949890, 194.224273, "GOV");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][40], 0.198390, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][40], 399.069091, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][40], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][40], -1802201857);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][40], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][40], -1802202112);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][40], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][40], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][40], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][40], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][40], true);

	MDC_PenalCode[playerid][41] = CreatePlayerTextDraw(playerid, 403.299438, 194.224273, "CAC");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][41], 0.198390, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][41], 416.000000, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][41], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][41], -1802201857);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][41], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][41], -1802202112);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][41], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][41], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][41], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][41], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][41], true);

	MDC_PenalCode[playerid][42] = CreatePlayerTextDraw(playerid, 420.399322, 194.224273, "AAF");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][42], 0.198390, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][42], 433.099884, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][42], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][42], -1802201857);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][42], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][42], -1802202112);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][42], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][42], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][42], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][42], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][42], true);

	MDC_PenalCode[playerid][43] = CreatePlayerTextDraw(playerid, 437.499206, 194.224273, "GNG");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][43], 0.198390, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][43], 451.000000, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][43], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][43], -1802201857);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][43], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][43], -1802202112);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][43], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][43], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][43], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][43], 1);

	MDC_PenalCode[playerid][44] = CreatePlayerTextDraw(playerid, 455.499084, 194.224273, "FTF");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][44], 0.198390, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][44], 468.999877, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][44], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][44], -1802201857);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][44], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][44], -1802202112);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][44], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][44], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][44], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][44], 1);

	MDC_PenalCode[playerid][45] = CreatePlayerTextDraw(playerid, 352.100646, 207.524322, "desc");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][45], 0.178387, 0.892929);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][45], 522.890014, 1.550000);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][45], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][45], 255);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][45], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][45], -1994712320);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][45], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][45], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][45], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][45], 1);

	MDC_PenalCode[playerid][46] = CreatePlayerTextDraw(playerid, 443.100891, 418.473205, "__~>~_Suclamayi_Uygula");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][46], 0.162387, 0.922930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][46], 523.498962, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][46], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][46], -1);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][46], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][46], -1994712065);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][46], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][46], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][46], 2);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][46], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][46], true);

	MDC_PenalCode[playerid][47] = CreatePlayerTextDraw(playerid, 229.100463, 431.120788, "_~<~");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][47], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][47], 245.000000, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][47], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][47], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][47], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][47], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][47], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][47], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][47], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][47], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][47], true);

	MDC_PenalCode[playerid][48] = CreatePlayerTextDraw(playerid, 329.200256, 431.120788, "__~>~");
	PlayerTextDrawLetterSize(playerid, MDC_PenalCode[playerid][48], 0.178387, 0.972930);
	PlayerTextDrawTextSize(playerid, MDC_PenalCode[playerid][48], 345.099792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_PenalCode[playerid][48], 1);
	PlayerTextDrawColor(playerid, MDC_PenalCode[playerid][48], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_PenalCode[playerid][48], 1);
	PlayerTextDrawBoxColor(playerid, MDC_PenalCode[playerid][48], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_PenalCode[playerid][48], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_PenalCode[playerid][48], 255);
	PlayerTextDrawFont(playerid, MDC_PenalCode[playerid][48], 1);
	PlayerTextDrawSetProportional(playerid, MDC_PenalCode[playerid][48], 1);
	PlayerTextDrawSetSelectable(playerid, MDC_PenalCode[playerid][48], true);


	MDC_Emergency[playerid][0] = CreatePlayerTextDraw(playerid, 232.399871, 183.855056, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][0], 0.000000, 5.840000);
	PlayerTextDrawTextSize(playerid, MDC_Emergency[playerid][0], 519.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][0], -1);
	PlayerTextDrawUseBox(playerid, MDC_Emergency[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Emergency[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][0], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][0], 0);

	MDC_Emergency[playerid][1] = CreatePlayerTextDraw(playerid, 234.199844, 185.278533, "Arayan:~n~Servis:~n~Lokasyon:~n~Aciklama:~n~Tarih:~n~Durum:");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][1], 0.207999, 0.928355);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][1], 1);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][1], 1179010303);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][1], 0);

	MDC_Emergency[playerid][2] = CreatePlayerTextDraw(playerid, 279.702606, 185.278533, "caller1~n~service1~n~location1~n~situation1~n~time1~n~status1");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][2], 0.207999, 0.928355);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][2], -1431655937);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][2], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][2], 0);

	MDC_Emergency[playerid][3] = CreatePlayerTextDraw(playerid, 453.997863, 227.698638, "Ustlen");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][3], 0.151199, 0.803555);
	PlayerTextDrawTextSize(playerid, MDC_Emergency[playerid][3], 10.000000, 40.000000);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][3], 2);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][3], -1);
	PlayerTextDrawUseBox(playerid, MDC_Emergency[playerid][3], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Emergency[playerid][3], -2145901825);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][3], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][3], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][3], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Emergency[playerid][3], true);

	MDC_Emergency[playerid][4] = CreatePlayerTextDraw(playerid, 497.700561, 227.698638, "Detaylar");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][4], 0.151199, 0.803555);
	PlayerTextDrawTextSize(playerid, MDC_Emergency[playerid][4], 10.000000, 40.000000);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][4], 2);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][4], -1);
	PlayerTextDrawUseBox(playerid, MDC_Emergency[playerid][4], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Emergency[playerid][4], 255);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][4], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][4], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][4], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Emergency[playerid][4], true);

	MDC_Emergency[playerid][5] = CreatePlayerTextDraw(playerid, 231.999893, 242.116699, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][5], 0.000000, 5.840000);
	PlayerTextDrawTextSize(playerid, MDC_Emergency[playerid][5], 518.399902, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][5], 1);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][5], -1);
	PlayerTextDrawUseBox(playerid, MDC_Emergency[playerid][5], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Emergency[playerid][5], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][5], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][5], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][5], 0);

	MDC_Emergency[playerid][6] = CreatePlayerTextDraw(playerid, 234.199813, 243.347793, "Arayan:~n~Servis:~n~Lokasyon:~n~Aciklama:~n~Tarih:~n~Durum:");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][6], 0.207999, 0.928355);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][6], 1);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][6], 1179010303);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][6], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][6], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][6], 0);

	MDC_Emergency[playerid][7] = CreatePlayerTextDraw(playerid, 278.702423, 243.354522, "caller2~n~service2~n~location2~n~situation2~n~time2~n~status2");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][7], 0.207999, 0.928355);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][7], 1);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][7], -1431655937);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][7], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][7], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][7], 0);

	MDC_Emergency[playerid][8] = CreatePlayerTextDraw(playerid, 454.497711, 285.753479, "Ustlen");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][8], 0.151199, 0.803555);
	PlayerTextDrawTextSize(playerid, MDC_Emergency[playerid][8], 10.000000, 40.000000);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][8], 2);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][8], -1);
	PlayerTextDrawUseBox(playerid, MDC_Emergency[playerid][8], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Emergency[playerid][8], -2145901825);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][8], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][8], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][8], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Emergency[playerid][8], true);

	MDC_Emergency[playerid][9] = CreatePlayerTextDraw(playerid, 497.800628, 285.803894, "Detaylar");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][9], 0.151199, 0.803555);
	PlayerTextDrawTextSize(playerid, MDC_Emergency[playerid][9], 10.869999, 39.000000);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][9], 2);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][9], -1);
	PlayerTextDrawUseBox(playerid, MDC_Emergency[playerid][9], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Emergency[playerid][9], 255);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][9], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][9], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][9], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Emergency[playerid][9], true);

	MDC_Emergency[playerid][10] = CreatePlayerTextDraw(playerid, 231.999923, 300.499481, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][10], 0.000000, 5.840000);
	PlayerTextDrawTextSize(playerid, MDC_Emergency[playerid][10], 518.399902, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][10], 1);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][10], -1);
	PlayerTextDrawUseBox(playerid, MDC_Emergency[playerid][10], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Emergency[playerid][10], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][10], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][10], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][10], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][10], 0);

	MDC_Emergency[playerid][11] = CreatePlayerTextDraw(playerid, 234.199768, 301.557617, "Arayan:~n~Servis:~n~Lokasyon:~n~Aciklama:~n~Tarih:~n~Durum:");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][11], 0.207999, 0.928355);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][11], 1);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][11], 1179010303);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][11], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][11], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][11], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][11], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][11], 0);

	MDC_Emergency[playerid][12] = CreatePlayerTextDraw(playerid, 278.702178, 302.039581, "caller3~n~service3~n~location3~n~situation3~n~time3~n~status3");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][12], 0.207999, 0.928355);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][12], 1);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][12], -1431655937);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][12], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][12], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][12], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][12], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][12], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][12], 0);

	MDC_Emergency[playerid][13] = CreatePlayerTextDraw(playerid, 453.997711, 344.116027, "Ustlen");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][13], 0.151199, 0.803555);
	PlayerTextDrawTextSize(playerid, MDC_Emergency[playerid][13], 10.000000, 40.000000);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][13], 2);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][13], -1);
	PlayerTextDrawUseBox(playerid, MDC_Emergency[playerid][13], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Emergency[playerid][13], -2145901825);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][13], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][13], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][13], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][13], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][13], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][13], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Emergency[playerid][13], true);

	MDC_Emergency[playerid][14] = CreatePlayerTextDraw(playerid, 497.700622, 343.984527, "Detaylar");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][14], 0.151199, 0.803555);
	PlayerTextDrawTextSize(playerid, MDC_Emergency[playerid][14], 10.000000, 40.000000);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][14], 2);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][14], -1);
	PlayerTextDrawUseBox(playerid, MDC_Emergency[playerid][14], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Emergency[playerid][14], 255);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][14], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][14], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][14], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][14], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][14], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][14], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Emergency[playerid][14], true);

	MDC_Emergency[playerid][15] = CreatePlayerTextDraw(playerid, 232.199905, 358.629638, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][15], 0.000000, 5.840000);
	PlayerTextDrawTextSize(playerid, MDC_Emergency[playerid][15], 519.019775, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][15], 1);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][15], -1);
	PlayerTextDrawUseBox(playerid, MDC_Emergency[playerid][15], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Emergency[playerid][15], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][15], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][15], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][15], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][15], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][15], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][15], 0);

	MDC_Emergency[playerid][16] = CreatePlayerTextDraw(playerid, 234.199554, 358.908782, "Arayan:~n~Servis:~n~Lokasyon:~n~Aciklama:~n~Sure:~n~Durum:");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][16], 0.207999, 0.928355);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][16], 1);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][16], 1179010303);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][16], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][16], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][16], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][16], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][16], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][16], 0);

	MDC_Emergency[playerid][17] = CreatePlayerTextDraw(playerid, 278.702392, 359.795349, "caller4~n~service4~n~location4~n~situation4~n~time4~n~status4");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][17], 0.207999, 0.928355);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][17], 1);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][17], -1431655937);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][17], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][17], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][17], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][17], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][17], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][17], 0);

	MDC_Emergency[playerid][18] = CreatePlayerTextDraw(playerid, 453.897216, 402.484436, "Ustlen");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][18], 0.151199, 0.803555);
	PlayerTextDrawTextSize(playerid, MDC_Emergency[playerid][18], 10.000000, 40.000000);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][18], 2);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][18], -1);
	PlayerTextDrawUseBox(playerid, MDC_Emergency[playerid][18], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Emergency[playerid][18], -2145901825);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][18], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][18], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][18], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][18], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][18], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][18], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Emergency[playerid][18], true);

	MDC_Emergency[playerid][19] = CreatePlayerTextDraw(playerid, 497.600708, 402.260589, "Detaylar");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][19], 0.151199, 0.803555);
	PlayerTextDrawTextSize(playerid, MDC_Emergency[playerid][19], 10.000000, 40.000000);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][19], 2);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][19], -1);
	PlayerTextDrawUseBox(playerid, MDC_Emergency[playerid][19], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Emergency[playerid][19], 255);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][19], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][19], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][19], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][19], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][19], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][19], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Emergency[playerid][19], true);

	MDC_Emergency[playerid][20] = CreatePlayerTextDraw(playerid, 456.299560, 417.986206, "~>~");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][20], 0.327599, 1.246577);
	PlayerTextDrawTextSize(playerid, MDC_Emergency[playerid][20], 10.000000, 40.000000);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][20], 2);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][20], -1);
	PlayerTextDrawUseBox(playerid, MDC_Emergency[playerid][20], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Emergency[playerid][20], 1987475199);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][20], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][20], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][20], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][20], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][20], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][20], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Emergency[playerid][20], true);

	MDC_Emergency[playerid][21] = CreatePlayerTextDraw(playerid, 295.598083, 417.905151, "~<~");
	PlayerTextDrawLetterSize(playerid, MDC_Emergency[playerid][21], 0.327599, 1.246577);
	PlayerTextDrawTextSize(playerid, MDC_Emergency[playerid][21], 10.000000, 40.000000);
	PlayerTextDrawAlignment(playerid, MDC_Emergency[playerid][21], 2);
	PlayerTextDrawColor(playerid, MDC_Emergency[playerid][21], -1);
	PlayerTextDrawUseBox(playerid, MDC_Emergency[playerid][21], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Emergency[playerid][21], 1987475199);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][21], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Emergency[playerid][21], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Emergency[playerid][21], 255);
	PlayerTextDrawFont(playerid, MDC_Emergency[playerid][21], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Emergency[playerid][21], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Emergency[playerid][21], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Emergency[playerid][21], true);

	MDC_Warrants[playerid][0] = CreatePlayerTextDraw(playerid, 289.103332, 183.955062, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][0], 0.000000, 6.728005);
	PlayerTextDrawTextSize(playerid, MDC_Warrants[playerid][0], 501.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][0], -1);
	PlayerTextDrawUseBox(playerid, MDC_Warrants[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Warrants[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][0], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][0], 0);

	MDC_Warrants[playerid][1] = CreatePlayerTextDraw(playerid, 232.402648, 183.943847, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][1], 0.000000, 6.720008);
	PlayerTextDrawTextSize(playerid, MDC_Warrants[playerid][1], 279.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][1], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][1], -1);
	PlayerTextDrawUseBox(playerid, MDC_Warrants[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Warrants[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][1], 0);

	MDC_Warrants[playerid][2] = CreatePlayerTextDraw(playerid, 226.499847, 185.875701, "");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_Warrants[playerid][2], 56.000000, 56.000000);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][2], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][2], 2565888);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][2], 5);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][2], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][2], 0);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][2], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawSetPreviewModel(playerid, MDC_Warrants[playerid][2], 295);
	PlayerTextDrawSetPreviewRot(playerid, MDC_Warrants[playerid][2], 0.000000, 0.000000, 0.000000, 1.000000);

	MDC_Warrants[playerid][3] = CreatePlayerTextDraw(playerid, 293.100036, 187.215606, "Aranan:~n~Aranma_Sebebi:");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][3], 0.183599, 0.843377);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][3], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][3], 572465919);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][3], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][3], 0);

	MDC_Warrants[playerid][4] = CreatePlayerTextDraw(playerid, 354.500305, 187.215606, "wantedName(20)~n~-wantedReason1~n~-wantedReason2~n~-wantedReason3~n~-wantedReason4~n~-wantedReason5");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][4], 0.183599, 0.843377);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][4], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][4], -1313885441);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][4], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][4], 0);

	MDC_Warrants[playerid][5] = CreatePlayerTextDraw(playerid, 472.700378, 235.420318, "Kaldir");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][5], 0.175799, 0.797244);
	PlayerTextDrawTextSize(playerid, MDC_Warrants[playerid][5], 499.100067, 10.000000);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][5], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][5], -1);
	PlayerTextDrawUseBox(playerid, MDC_Warrants[playerid][5], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Warrants[playerid][5], -2145901825);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][5], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][5], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][5], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Warrants[playerid][5], true);

	MDC_Warrants[playerid][6] = CreatePlayerTextDraw(playerid, 442.098510, 235.420318, "__Ekle");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][6], 0.175799, 0.797244);
	PlayerTextDrawTextSize(playerid, MDC_Warrants[playerid][6], 468.498199, 10.000000);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][6], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][6], -1);
	PlayerTextDrawUseBox(playerid, MDC_Warrants[playerid][6], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Warrants[playerid][6], 8388863);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][6], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][6], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][6], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Warrants[playerid][6], true);

	MDC_Warrants[playerid][7] = CreatePlayerTextDraw(playerid, 289.103332, 253.659317, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][7], 0.000000, 6.728005);
	PlayerTextDrawTextSize(playerid, MDC_Warrants[playerid][7], 501.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][7], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][7], -1);
	PlayerTextDrawUseBox(playerid, MDC_Warrants[playerid][7], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Warrants[playerid][7], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][7], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][7], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][7], 0);

	MDC_Warrants[playerid][8] = CreatePlayerTextDraw(playerid, 232.401214, 253.711578, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][8], 0.000000, 6.720008);
	PlayerTextDrawTextSize(playerid, MDC_Warrants[playerid][8], 280.398559, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][8], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][8], -1);
	PlayerTextDrawUseBox(playerid, MDC_Warrants[playerid][8], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Warrants[playerid][8], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][8], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][8], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][8], 0);

	MDC_Warrants[playerid][9] = CreatePlayerTextDraw(playerid, 226.499588, 252.511672, "");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][9], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_Warrants[playerid][9], 56.000000, 56.000000);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][9], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][9], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][9], 2565888);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][9], 5);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][9], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][9], 0);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][9], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawSetPreviewModel(playerid, MDC_Warrants[playerid][9], 26);
	PlayerTextDrawSetPreviewRot(playerid, MDC_Warrants[playerid][9], 0.000000, 0.000000, 0.000000, 1.000000);

	MDC_Warrants[playerid][10] = CreatePlayerTextDraw(playerid, 293.199951, 256.135101, "Aranan:~n~Aranma_Sebebi:");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][10], 0.183599, 0.843377);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][10], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][10], 572465919);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][10], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][10], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][10], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][10], 0);

	MDC_Warrants[playerid][11] = CreatePlayerTextDraw(playerid, 354.500305, 255.619781, "wantedName(20)~n~-wantedReason1~n~-wantedReason2~n~-wantedReason3~n~-wantedReason4~n~-wantedReason5");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][11], 0.183599, 0.843377);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][11], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][11], -1313885441);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][11], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][11], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][11], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][11], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][11], 0);

	MDC_Warrants[playerid][12] = CreatePlayerTextDraw(playerid, 472.700408, 304.626342, "Kaldir");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][12], 0.175799, 0.797244);
	PlayerTextDrawTextSize(playerid, MDC_Warrants[playerid][12], 498.400024, 10.000000);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][12], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][12], -1);
	PlayerTextDrawUseBox(playerid, MDC_Warrants[playerid][12], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Warrants[playerid][12], -2145901825);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][12], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][12], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][12], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][12], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][12], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][12], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Warrants[playerid][12], true);

	MDC_Warrants[playerid][13] = CreatePlayerTextDraw(playerid, 442.198455, 304.554260, "__Ekle");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][13], 0.175799, 0.797244);
	PlayerTextDrawTextSize(playerid, MDC_Warrants[playerid][13], 468.699981, 10.000000);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][13], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][13], -1);
	PlayerTextDrawUseBox(playerid, MDC_Warrants[playerid][13], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Warrants[playerid][13], 8388863);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][13], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][13], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][13], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][13], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][13], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][13], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Warrants[playerid][13], true);

	MDC_Warrants[playerid][14] = CreatePlayerTextDraw(playerid, 289.103210, 323.660827, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][14], 0.000000, 6.728005);
	PlayerTextDrawTextSize(playerid, MDC_Warrants[playerid][14], 500.451293, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][14], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][14], -1);
	PlayerTextDrawUseBox(playerid, MDC_Warrants[playerid][14], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Warrants[playerid][14], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][14], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][14], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][14], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][14], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][14], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][14], 0);

	MDC_Warrants[playerid][15] = CreatePlayerTextDraw(playerid, 232.401077, 323.640960, "box");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][15], 0.000000, 6.720008);
	PlayerTextDrawTextSize(playerid, MDC_Warrants[playerid][15], 279.999877, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][15], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][15], -1);
	PlayerTextDrawUseBox(playerid, MDC_Warrants[playerid][15], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Warrants[playerid][15], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][15], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][15], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][15], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][15], 0);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][15], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][15], 0);

	MDC_Warrants[playerid][16] = CreatePlayerTextDraw(playerid, 226.399230, 323.079376, "");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][16], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, MDC_Warrants[playerid][16], 56.000000, 56.000000);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][16], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][16], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][16], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][16], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][16], 2565888);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][16], 5);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][16], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][16], 0);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][16], TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawSetPreviewModel(playerid, MDC_Warrants[playerid][16], 67);
	PlayerTextDrawSetPreviewRot(playerid, MDC_Warrants[playerid][16], 0.000000, 0.000000, 0.000000, 1.000000);

	MDC_Warrants[playerid][17] = CreatePlayerTextDraw(playerid, 293.100036, 326.562347, "Aranan:~n~Aranma_Sebebi:");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][17], 0.183599, 0.843377);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][17], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][17], 572465919);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][17], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][17], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][17], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][17], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][17], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][17], 0);

	MDC_Warrants[playerid][18] = CreatePlayerTextDraw(playerid, 354.500213, 325.580810, "wantedName(20)~n~-wantedReason1~n~-wantedReason2~n~-wantedReason3~n~-wantedReason4~n~-wantedReason5");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][18], 0.183599, 0.843377);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][18], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][18], -1313885441);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][18], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][18], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][18], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][18], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][18], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][18], 0);

	MDC_Warrants[playerid][19] = CreatePlayerTextDraw(playerid, 473.100341, 374.658050, "Kaldir");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][19], 0.175799, 0.797244);
	PlayerTextDrawTextSize(playerid, MDC_Warrants[playerid][19], 498.799926, 10.000000);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][19], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][19], -1);
	PlayerTextDrawUseBox(playerid, MDC_Warrants[playerid][19], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Warrants[playerid][19], -2145901825);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][19], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][19], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][19], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][19], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][19], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][19], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Warrants[playerid][19], true);

	MDC_Warrants[playerid][20] = CreatePlayerTextDraw(playerid, 441.398345, 374.608612, "__Ekle");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][20], 0.175799, 0.797244);
	PlayerTextDrawTextSize(playerid, MDC_Warrants[playerid][20], 468.999877, 10.000000);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][20], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][20], -1);
	PlayerTextDrawUseBox(playerid, MDC_Warrants[playerid][20], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Warrants[playerid][20], 8388863);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][20], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][20], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][20], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][20], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][20], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][20], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Warrants[playerid][20], true);

	MDC_Warrants[playerid][21] = CreatePlayerTextDraw(playerid, 478.100006, 390.257904, "~<~");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][21], 0.161599, 0.991467);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][21], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][21], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][21], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][21], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][21], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][21], 0);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][21], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][21], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Warrants[playerid][21], true);

	MDC_Warrants[playerid][22] = CreatePlayerTextDraw(playerid, 490.500762, 390.257904, "~>~");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][22], 0.161599, 0.991467);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][22], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][22], -1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][22], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][22], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][22], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][22], 0);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][22], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][22], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Warrants[playerid][22], true);

	MDC_Warrants[playerid][23] = CreatePlayerTextDraw(playerid, 431.000488, 169.157714, "~>~YENI_ARANMA_OLUSTUR");
	PlayerTextDrawLetterSize(playerid, MDC_Warrants[playerid][23], 0.137799, 0.946578);
	PlayerTextDrawTextSize(playerid, MDC_Warrants[playerid][23], 501.000305, 10.000000);
	PlayerTextDrawAlignment(playerid, MDC_Warrants[playerid][23], 1);
	PlayerTextDrawColor(playerid, MDC_Warrants[playerid][23], -1);
	PlayerTextDrawUseBox(playerid, MDC_Warrants[playerid][23], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Warrants[playerid][23], -2139062017);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][23], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Warrants[playerid][23], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Warrants[playerid][23], 255);
	PlayerTextDrawFont(playerid, MDC_Warrants[playerid][23], 2);
	PlayerTextDrawSetProportional(playerid, MDC_Warrants[playerid][23], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Warrants[playerid][23], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Warrants[playerid][23], true);

	MDC_Roster[playerid][0] = CreatePlayerTextDraw(playerid, 230.400512, 181.774856, "BOLO1");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][0], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][0], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][0], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][0], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][0], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][0], 0);

	MDC_Roster[playerid][1] = CreatePlayerTextDraw(playerid, 522.999755, 181.774856, "BOLO1_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][1], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][1], 817.874023, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][1], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][1], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][1], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][1], 0);

	MDC_Roster[playerid][2] = CreatePlayerTextDraw(playerid, 230.400512, 194.674911, "BOLO2");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][2], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][2], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][2], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][2], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][2], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][2], 0);

	MDC_Roster[playerid][3] = CreatePlayerTextDraw(playerid, 522.999755, 194.674911, "BOLO2_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][3], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][3], 818.320007, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][3], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][3], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][3], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][3], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][3], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][3], 0);

	MDC_Roster[playerid][4] = CreatePlayerTextDraw(playerid, 230.400512, 207.574935, "BOLO3");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][4], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][4], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][4], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][4], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][4], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][4], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][4], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][4], 0);

	MDC_Roster[playerid][5] = CreatePlayerTextDraw(playerid, 522.999755, 207.574935, "BOLO3_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][5], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][5], 816.172851, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][5], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][5], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][5], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][5], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][5], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][5], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][5], 0);

	MDC_Roster[playerid][6] = CreatePlayerTextDraw(playerid, 230.400512, 220.525024, "BOLO4");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][6], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][6], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][6], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][6], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][6], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][6], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][6], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][6], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][6], 0);

	MDC_Roster[playerid][7] = CreatePlayerTextDraw(playerid, 522.999755, 220.525024, "BOLO4_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][7], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][7], 635.721862, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][7], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][7], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][7], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][7], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][7], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][7], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][7], 0);

	MDC_Roster[playerid][8] = CreatePlayerTextDraw(playerid, 230.400512, 233.574996, "BOLO5");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][8], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][8], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][8], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][8], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][8], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][8], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][8], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][8], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][8], 0);

	MDC_Roster[playerid][9] = CreatePlayerTextDraw(playerid, 522.999755, 233.574996, "BOLO5_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][9], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][9], 651.069213, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][9], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][9], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][9], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][9], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][9], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][9], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][9], 0);

	MDC_Roster[playerid][10] = CreatePlayerTextDraw(playerid, 230.400512, 247.025115, "BOLO6");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][10], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][10], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][10], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][10], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][10], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][10], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][10], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][10], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][10], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][10], 0);

	MDC_Roster[playerid][11] = CreatePlayerTextDraw(playerid, 522.999755, 247.025115, "BOLO6_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][11], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][11], 634.121276, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][11], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][11], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][11], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][11], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][11], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][11], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][11], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][11], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][11], 0);

	MDC_Roster[playerid][12] = CreatePlayerTextDraw(playerid, 230.400512, 260.425201, "BOLO7");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][12], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][12], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][12], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][12], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][12], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][12], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][12], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][12], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][12], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][12], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][12], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][12], 0);

	MDC_Roster[playerid][13] = CreatePlayerTextDraw(playerid, 522.999755, 260.425201, "BOLO7_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][13], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][13], 607.318176, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][13], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][13], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][13], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][13], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][13], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][13], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][13], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][13], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][13], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][13], 0);

	MDC_Roster[playerid][14] = CreatePlayerTextDraw(playerid, 230.400512, 273.425201, "BOLO8");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][14], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][14], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][14], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][14], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][14], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][14], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][14], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][14], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][14], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][14], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][14], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][14], 0);

	MDC_Roster[playerid][15] = CreatePlayerTextDraw(playerid, 522.999755, 273.425201, "BOLO8_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][15], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][15], 627.819396, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][15], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][15], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][15], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][15], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][15], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][15], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][15], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][15], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][15], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][15], 0);

	MDC_Roster[playerid][16] = CreatePlayerTextDraw(playerid, 230.400512, 286.925567, "BOLO9");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][16], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][16], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][16], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][16], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][16], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][16], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][16], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][16], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][16], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][16], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][16], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][16], 0);

	MDC_Roster[playerid][17] = CreatePlayerTextDraw(playerid, 522.999755, 286.925567, "BOLO9_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][17], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][17], 622.370971, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][17], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][17], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][17], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][17], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][17], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][17], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][17], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][17], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][17], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][17], 0);

	MDC_Roster[playerid][18] = CreatePlayerTextDraw(playerid, 230.400512, 300.276428, "BOLO10");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][18], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][18], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][18], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][18], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][18], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][18], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][18], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][18], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][18], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][18], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][18], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][18], 0);

	MDC_Roster[playerid][19] = CreatePlayerTextDraw(playerid, 522.999755, 300.276428, "BOLO10_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][19], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][19], 645.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][19], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][19], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][19], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][19], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][19], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][19], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][19], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][19], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][19], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][19], 0);

	MDC_Roster[playerid][20] = CreatePlayerTextDraw(playerid, 230.400512, 313.727050, "BOLO11");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][20], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][20], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][20], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][20], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][20], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][20], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][20], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][20], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][20], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][20], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][20], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][20], 0);

	MDC_Roster[playerid][21] = CreatePlayerTextDraw(playerid,522.999755, 313.727050, "BOLO11_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][21], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][21], 636.116882, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][21], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][21], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][21], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][21], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][21], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][21], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][21], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][21], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][21], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][21], 0);

	MDC_Roster[playerid][22] = CreatePlayerTextDraw(playerid, 230.400512, 327.127624, "BOLO12");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][22], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][22], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][22], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][22], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][22], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][22], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][22], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][22], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][22], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][22], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][22], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][22], 0);

	MDC_Roster[playerid][23] = CreatePlayerTextDraw(playerid, 522.999755, 327.127624, "BOLO12_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][23], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][23], 632.369018, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][23], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][23], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][23], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][23], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][23], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][23], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][23], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][23], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][23], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][23], 0);

	MDC_Roster[playerid][24] = CreatePlayerTextDraw(playerid, 230.400512, 340.227539, "BOLO13");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][24], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][24], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][24], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][24], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][24], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][24], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][24], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][24], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][24], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][24], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][24], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][24], 0);

	MDC_Roster[playerid][25] = CreatePlayerTextDraw(playerid, 522.999755, 340.227539, "BOLO13_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][25], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][25], 660.819396, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][25], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][25], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][25], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][25], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][25], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][25], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][25], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][25], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][25], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][25], 0);

	MDC_Roster[playerid][26] = CreatePlayerTextDraw(playerid, 230.400512, 353.527099, "BOLO14");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][26], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][26], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][26], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][26], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][26], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][26], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][26], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][26], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][26], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][26], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][26], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][26], 0);

	MDC_Roster[playerid][27] = CreatePlayerTextDraw(playerid, 522.999755, 353.527099, "BOLO14_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][27], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][27], 643.721252, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][27], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][27], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][27], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][27], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][27], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][27], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][27], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][27], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][27], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][27], 0);

	MDC_Roster[playerid][28] = CreatePlayerTextDraw(playerid, 230.400512, 366.527801, "BOLO15");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][28], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][28], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][28], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][28], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][28], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][28], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][28], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][28], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][28], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][28], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][28], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][28], 0);

	MDC_Roster[playerid][29] = CreatePlayerTextDraw(playerid, 522.999755, 366.527801, "BOLO15_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][29], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][29], 642.273437, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][29], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][29], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][29], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][29], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][29], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][29], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][29], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][29], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][29], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][29], 0);

	MDC_Roster[playerid][30] = CreatePlayerTextDraw(playerid, 230.400512, 380.027709, "BOLO16");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][30], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][30], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][30], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][30], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][30], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][30], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][30], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][30], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][30], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][30], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][30], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][30], 0);

	MDC_Roster[playerid][31] = CreatePlayerTextDraw(playerid, 522.999755, 380.027709, "BOLO16_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][31], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][31], 637.000000, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][31], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][31], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][31], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][31], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][31], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][31], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][31], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][31], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][31], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][31], 0);

	MDC_Roster[playerid][32] = CreatePlayerTextDraw(playerid, 230.400512, 393.527618, "BOLO17");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][32], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][32], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][32], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][32], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][32], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][32], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][32], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][32], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][32], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][32], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][32], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][32], 0);

	MDC_Roster[playerid][33] = CreatePlayerTextDraw(playerid, 522.999755, 393.527618, "BOLO17_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][33], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][33], 639.573364, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][33], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][33], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][33], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][33], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][33], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][33], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][33], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][33], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][33], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][33], 0);

	MDC_Roster[playerid][34] = CreatePlayerTextDraw(playerid, 230.400512, 407.027526, "BOLO18");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][34], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][34], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][34], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][34], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][34], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][34], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][34], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][34], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][34], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][34], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][34], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][34], 0);

	MDC_Roster[playerid][35] = CreatePlayerTextDraw(playerid, 522.999755, 407.027526, "BOLO18_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][35], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][35], 626.973022, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][35], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][35], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][35], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][35], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][35], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][35], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][35], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][35], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][35], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][35], 0);

	MDC_Roster[playerid][36] = CreatePlayerTextDraw(playerid, 230.400512, 420.527435, "BOLO19");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][36], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][36], 525.270263, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][36], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][36], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][36], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][36], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][36], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][36], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][36], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][36], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][36], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][36], 0);

	MDC_Roster[playerid][37] = CreatePlayerTextDraw(playerid, 522.999755, 420.527435, "BOLO19_TEXT");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][37], 0.209391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][37], 637.773315, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][37], 3);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][37], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][37], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][37], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][37], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][37], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][37], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][37], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][37], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][37], 0);

	MDC_Roster[playerid][38] = CreatePlayerTextDraw(playerid, 499.299896, 167.596420, "~<~");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][38], 0.180991, 0.992885);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][38], 505.909973, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][38], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][38], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][38], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][38], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][38], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][38], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][38], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][38], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][38], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][38], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Roster[playerid][38], true);

	MDC_Roster[playerid][39] = CreatePlayerTextDraw(playerid, 510.099822, 167.596420, "~>~");
	PlayerTextDrawLetterSize(playerid, MDC_Roster[playerid][39], 0.180991, 0.992885);
	PlayerTextDrawTextSize(playerid, MDC_Roster[playerid][39], 516.710083, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_Roster[playerid][39], 1);
	PlayerTextDrawColor(playerid, MDC_Roster[playerid][39], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_Roster[playerid][39], 1);
	PlayerTextDrawBoxColor(playerid, MDC_Roster[playerid][39], 0);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][39], 0);
	PlayerTextDrawSetOutline(playerid, MDC_Roster[playerid][39], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_Roster[playerid][39], 255);
	PlayerTextDrawFont(playerid, MDC_Roster[playerid][39], 1);
	PlayerTextDrawSetProportional(playerid, MDC_Roster[playerid][39], 1);
	PlayerTextDrawSetShadow(playerid, MDC_Roster[playerid][39], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_Roster[playerid][39], true);


	MDC_EmergencyDetails[playerid][0] = CreatePlayerTextDraw(playerid, 235.599990, 192.986648, "Cagri_#No~n~~n~~n~Arayan:~n~TelefonNo:~n~Tarih:~n~Cagrilan_Servis:~n~Durum:~n~");
	PlayerTextDrawLetterSize(playerid, MDC_EmergencyDetails[playerid][0], 0.202799, 1.067377);
	PlayerTextDrawAlignment(playerid, MDC_EmergencyDetails[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_EmergencyDetails[playerid][0], 1431655935);
	PlayerTextDrawSetShadow(playerid, MDC_EmergencyDetails[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_EmergencyDetails[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_EmergencyDetails[playerid][0], 255);
	PlayerTextDrawFont(playerid, MDC_EmergencyDetails[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, MDC_EmergencyDetails[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, MDC_EmergencyDetails[playerid][0], 0);

	MDC_EmergencyDetails[playerid][1] = CreatePlayerTextDraw(playerid, 235.599472, 290.466003, "Konusma_dokumu_-_servis:~n~~n~~n~~n~Konusma_Dokumu_-_lokasyon:~n~~n~~n~~n~Konusma_Dokumu_-_aciklama:");
	PlayerTextDrawLetterSize(playerid, MDC_EmergencyDetails[playerid][1], 0.202799, 1.067377);
	PlayerTextDrawAlignment(playerid, MDC_EmergencyDetails[playerid][1], 1);
	PlayerTextDrawColor(playerid, MDC_EmergencyDetails[playerid][1], 1431655935);
	PlayerTextDrawSetShadow(playerid, MDC_EmergencyDetails[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_EmergencyDetails[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_EmergencyDetails[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_EmergencyDetails[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, MDC_EmergencyDetails[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_EmergencyDetails[playerid][1], 0);

	MDC_EmergencyDetails[playerid][2] = CreatePlayerTextDraw(playerid, 301.604003, 221.888412, "callerName~n~callerNumber~n~callerDate~n~callerService~n~callerSituation");
	PlayerTextDrawLetterSize(playerid, MDC_EmergencyDetails[playerid][2], 0.202799, 1.067377);
	PlayerTextDrawAlignment(playerid, MDC_EmergencyDetails[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_EmergencyDetails[playerid][2], -1970631937);
	PlayerTextDrawSetShadow(playerid, MDC_EmergencyDetails[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_EmergencyDetails[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_EmergencyDetails[playerid][2], 255);
	PlayerTextDrawFont(playerid, MDC_EmergencyDetails[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, MDC_EmergencyDetails[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, MDC_EmergencyDetails[playerid][2], 0);

	MDC_EmergencyDetails[playerid][3] = CreatePlayerTextDraw(playerid, 235.599472, 298.666503, "transcriptService~n~~n~~n~~n~transcriptLocation~n~~n~~n~~n~transcriptSituation");
	PlayerTextDrawLetterSize(playerid, MDC_EmergencyDetails[playerid][3], 0.202799, 1.067377);
	PlayerTextDrawAlignment(playerid, MDC_EmergencyDetails[playerid][3], 1);
	PlayerTextDrawColor(playerid, MDC_EmergencyDetails[playerid][3], -1970631937);
	PlayerTextDrawSetShadow(playerid, MDC_EmergencyDetails[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_EmergencyDetails[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_EmergencyDetails[playerid][3], 255);
	PlayerTextDrawFont(playerid, MDC_EmergencyDetails[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, MDC_EmergencyDetails[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, MDC_EmergencyDetails[playerid][3], 0);

	MDC_EmergencyDetails[playerid][4] = CreatePlayerTextDraw(playerid, 236.201202, 167.593261, "~<~_Geri_Git");
	PlayerTextDrawLetterSize(playerid, MDC_EmergencyDetails[playerid][4], 0.231199, 1.122133);
	PlayerTextDrawTextSize(playerid, MDC_EmergencyDetails[playerid][4], 290.000488, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_EmergencyDetails[playerid][4], 1);
	PlayerTextDrawColor(playerid, MDC_EmergencyDetails[playerid][4], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_EmergencyDetails[playerid][4], 1);
	PlayerTextDrawBoxColor(playerid, MDC_EmergencyDetails[playerid][4], 84215040);
	PlayerTextDrawSetShadow(playerid, MDC_EmergencyDetails[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_EmergencyDetails[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_EmergencyDetails[playerid][4], 255);
	PlayerTextDrawFont(playerid, MDC_EmergencyDetails[playerid][4], 2);
	PlayerTextDrawSetProportional(playerid, MDC_EmergencyDetails[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_EmergencyDetails[playerid][4], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_EmergencyDetails[playerid][4], true);

	MDC_CrimeHistory[playerid][0] = CreatePlayerTextDraw(playerid, 234.000061, 192.986663, "box");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][0], 0.000000, 25.288013);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][0], 519.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][0], -1);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][0], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][0], 0);

	MDC_CrimeHistory[playerid][1] = CreatePlayerTextDraw(playerid, 235.300109, 194.484497, "2020-00-00___Crime1");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][1], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][1], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][1], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][1], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][1], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][1], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][1], true);

	MDC_CrimeHistory[playerid][2] = CreatePlayerTextDraw(playerid, 235.300109, 206.085205, "2020-00-00___Crime2");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][2], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][2], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][2], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][2], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][2], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][2], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][2], true);

	MDC_CrimeHistory[playerid][3] = CreatePlayerTextDraw(playerid, 235.300109, 217.885925, "2020-00-00___Crime3");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][3], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][3], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][3], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][3], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][3], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][3], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][3], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][3], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][3], true);

	MDC_CrimeHistory[playerid][4] = CreatePlayerTextDraw(playerid, 235.300109, 229.686645, "2020-00-00___Crime4");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][4], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][4], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][4], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][4], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][4], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][4], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][4], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][4], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][4], true);

	MDC_CrimeHistory[playerid][5] = CreatePlayerTextDraw(playerid, 235.300109, 241.387359, "2020-00-00___Crime5");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][5], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][5], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][5], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][5], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][5], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][5], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][5], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][5], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][5], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][5], true);

	MDC_CrimeHistory[playerid][6] = CreatePlayerTextDraw(playerid, 235.300109, 253.088073, "2020-00-00___Crime6");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][6], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][6], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][6], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][6], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][6], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][6], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][6], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][6], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][6], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][6], true);

	MDC_CrimeHistory[playerid][7] = CreatePlayerTextDraw(playerid, 235.300109, 264.588775, "2020-00-00___Crime7");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][7], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][7], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][7], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][7], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][7], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][7], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][7], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][7], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][7], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][7], true);

	MDC_CrimeHistory[playerid][8] = CreatePlayerTextDraw(playerid, 235.300109, 276.189483, "2020-00-00___Crime8");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][8], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][8], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][8], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][8], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][8], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][8], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][8], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][8], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][8], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][8], true);

	MDC_CrimeHistory[playerid][9] = CreatePlayerTextDraw(playerid, 235.300109, 287.890197, "2020-00-00___Crime9");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][9], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][9], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][9], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][9], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][9], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][9], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][9], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][9], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][9], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][9], true);

	MDC_CrimeHistory[playerid][10] = CreatePlayerTextDraw(playerid, 235.300109, 299.490905, "2020-00-00___Crime10");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][10], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][10], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][10], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][10], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][10], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][10], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][10], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][10], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][10], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][10], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][10], true);

	MDC_CrimeHistory[playerid][11] = CreatePlayerTextDraw(playerid, 235.300109, 311.091613, "2020-00-00___Crime11");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][11], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][11], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][11], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][11], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][11], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][11], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][11], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][11], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][11], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][11], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][11], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][11], true);

	MDC_CrimeHistory[playerid][12] = CreatePlayerTextDraw(playerid, 235.300109, 322.592315, "2020-00-00___Crime12");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][12], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][12], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][12], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][12], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][12], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][12], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][12], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][12], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][12], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][12], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][12], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][12], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][12], true);

	MDC_CrimeHistory[playerid][13] = CreatePlayerTextDraw(playerid, 235.300109, 333.993011, "2020-00-00___Crime13");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][13], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][13], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][13], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][13], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][13], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][13], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][13], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][13], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][13], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][13], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][13], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][13], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][13], true);

	MDC_CrimeHistory[playerid][14] = CreatePlayerTextDraw(playerid, 235.300109, 345.393707, "2020-00-00___Crime14");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][14], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][14], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][14], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][14], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][14], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][14], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][14], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][14], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][14], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][14], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][14], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][14], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][14], true);

	MDC_CrimeHistory[playerid][15] = CreatePlayerTextDraw(playerid, 235.300109, 356.494384, "2020-00-00___Crime15");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][15], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][15], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][15], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][15], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][15], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][15], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][15], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][15], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][15], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][15], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][15], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][15], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][15], true);

	MDC_CrimeHistory[playerid][16] = CreatePlayerTextDraw(playerid, 235.300109, 367.895080, "2020-00-00___Crime16");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][16], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][16], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][16], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][16], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][16], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][16], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][16], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][16], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][16], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][16], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][16], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][16], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][16], true);

	MDC_CrimeHistory[playerid][17] = CreatePlayerTextDraw(playerid, 235.300109, 379.395782, "2020-00-00___Crime17");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][17], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][17], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][17], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][17], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][17], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][17], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][17], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][17], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][17], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][17], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][17], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][17], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][17], true);

	MDC_CrimeHistory[playerid][18] = CreatePlayerTextDraw(playerid, 235.300109, 390.696472, "2020-00-00___Crime18");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][18], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][18], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][18], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][18], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][18], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][18], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][18], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][18], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][18], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][18], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][18], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][18], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][18], true);

	MDC_CrimeHistory[playerid][19] = CreatePlayerTextDraw(playerid, 235.300109, 402.097167, "2020-00-00___Crime19");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][19], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][19], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][19], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][19], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][19], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][19], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][19], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][19], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][19], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][19], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][19], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][19], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][19], true);

	MDC_CrimeHistory[playerid][20] = CreatePlayerTextDraw(playerid, 235.300109, 413.597869, "2020-00-00___Crime20");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][20], 0.201999, 0.873244);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][20], 517.399902, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][20], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][20], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][20], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][20], 255);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][20], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][20], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][20], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][20], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][20], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][20], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][20], true);

	MDC_CrimeHistory[playerid][21] = CreatePlayerTextDraw(playerid, 507.199890, 426.444427, "~>~");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][21], 0.231199, 1.122133);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][21], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][21], -1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][21], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][21], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][21], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][21], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][21], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][21], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][21], true);

	MDC_CrimeHistory[playerid][22] = CreatePlayerTextDraw(playerid, 492.799011, 426.444427, "~<~");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][22], 0.231199, 1.122133);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][22], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][22], -1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][22], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][22], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][22], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][22], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][22], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][22], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][22], true);

	MDC_CrimeHistory[playerid][23] = CreatePlayerTextDraw(playerid, 236.201202, 167.593261, "~<~_Geri_Git");
	PlayerTextDrawLetterSize(playerid, MDC_CrimeHistory[playerid][23], 0.231199, 1.122133);
	PlayerTextDrawTextSize(playerid, MDC_CrimeHistory[playerid][23], 290.000488, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_CrimeHistory[playerid][23], 1);
	PlayerTextDrawColor(playerid, MDC_CrimeHistory[playerid][23], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_CrimeHistory[playerid][23], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CrimeHistory[playerid][23], 84215040);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][23], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CrimeHistory[playerid][23], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CrimeHistory[playerid][23], 255);
	PlayerTextDrawFont(playerid, MDC_CrimeHistory[playerid][23], 2);
	PlayerTextDrawSetProportional(playerid, MDC_CrimeHistory[playerid][23], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CrimeHistory[playerid][23], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CrimeHistory[playerid][23], true);

	MDC_SelectedCrimeDetails[playerid][0] = CreatePlayerTextDraw(playerid, 233.899719, 194.502502, "Islem_No~n~Isim~n~Uygulayan~n~Tarih~n~Tur");
	PlayerTextDrawLetterSize(playerid, MDC_SelectedCrimeDetails[playerid][0], 0.219999, 1.097244);
	PlayerTextDrawAlignment(playerid, MDC_SelectedCrimeDetails[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_SelectedCrimeDetails[playerid][0], 1330597887);
	PlayerTextDrawSetShadow(playerid, MDC_SelectedCrimeDetails[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_SelectedCrimeDetails[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_SelectedCrimeDetails[playerid][0], 255);
	PlayerTextDrawFont(playerid, MDC_SelectedCrimeDetails[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, MDC_SelectedCrimeDetails[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, MDC_SelectedCrimeDetails[playerid][0], 0);

	MDC_SelectedCrimeDetails[playerid][1] = CreatePlayerTextDraw(playerid, 233.899734, 274.956924, "Aciklama");
	PlayerTextDrawLetterSize(playerid, MDC_SelectedCrimeDetails[playerid][1], 0.219999, 1.097244);
	PlayerTextDrawAlignment(playerid, MDC_SelectedCrimeDetails[playerid][1], 1);
	PlayerTextDrawColor(playerid, MDC_SelectedCrimeDetails[playerid][1], 1330597887);
	PlayerTextDrawSetShadow(playerid, MDC_SelectedCrimeDetails[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_SelectedCrimeDetails[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_SelectedCrimeDetails[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_SelectedCrimeDetails[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, MDC_SelectedCrimeDetails[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_SelectedCrimeDetails[playerid][1], 0);

	MDC_SelectedCrimeDetails[playerid][2] = CreatePlayerTextDraw(playerid, 286.900756, 194.591247, "#_criminalNo~n~criminalName~n~criminialIssuier~n~criminalDate");
	PlayerTextDrawLetterSize(playerid, MDC_SelectedCrimeDetails[playerid][2], 0.219999, 1.097244);
	PlayerTextDrawAlignment(playerid, MDC_SelectedCrimeDetails[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_SelectedCrimeDetails[playerid][2], -1532713729);
	PlayerTextDrawSetShadow(playerid, MDC_SelectedCrimeDetails[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_SelectedCrimeDetails[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_SelectedCrimeDetails[playerid][2], 255);
	PlayerTextDrawFont(playerid, MDC_SelectedCrimeDetails[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, MDC_SelectedCrimeDetails[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, MDC_SelectedCrimeDetails[playerid][2], 0);

	MDC_SelectedCrimeDetails[playerid][3] = CreatePlayerTextDraw(playerid, 233.899734, 286.157592, "criminalQuote");
	PlayerTextDrawLetterSize(playerid, MDC_SelectedCrimeDetails[playerid][3], 0.219999, 1.097244);
	PlayerTextDrawAlignment(playerid, MDC_SelectedCrimeDetails[playerid][3], 1);
	PlayerTextDrawColor(playerid, MDC_SelectedCrimeDetails[playerid][3], -1532713729);
	PlayerTextDrawSetShadow(playerid, MDC_SelectedCrimeDetails[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_SelectedCrimeDetails[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_SelectedCrimeDetails[playerid][3], 255);
	PlayerTextDrawFont(playerid, MDC_SelectedCrimeDetails[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, MDC_SelectedCrimeDetails[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, MDC_SelectedCrimeDetails[playerid][3], 0);

	MDC_SelectedCrimeDetails[playerid][4] = CreatePlayerTextDraw(playerid, 236.201202, 167.593261, "~<~_Geri_Git");
	PlayerTextDrawLetterSize(playerid, MDC_SelectedCrimeDetails[playerid][4], 0.231199, 1.122133);
	PlayerTextDrawTextSize(playerid, MDC_SelectedCrimeDetails[playerid][4], 290.000488, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_SelectedCrimeDetails[playerid][4], 1);
	PlayerTextDrawColor(playerid, MDC_SelectedCrimeDetails[playerid][4], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_SelectedCrimeDetails[playerid][4], 1);
	PlayerTextDrawBoxColor(playerid, MDC_SelectedCrimeDetails[playerid][4], 84215040);
	PlayerTextDrawSetShadow(playerid, MDC_SelectedCrimeDetails[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_SelectedCrimeDetails[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_SelectedCrimeDetails[playerid][4], 255);
	PlayerTextDrawFont(playerid, MDC_SelectedCrimeDetails[playerid][4], 2);
	PlayerTextDrawSetProportional(playerid, MDC_SelectedCrimeDetails[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_SelectedCrimeDetails[playerid][4], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_SelectedCrimeDetails[playerid][4], true);

	MDC_SelectedCrimeDetails[playerid][5] = CreatePlayerTextDraw(playerid, 233.899734, 256.157592, "~>~Tutuklama_kaydini_gor");
	PlayerTextDrawLetterSize(playerid, MDC_SelectedCrimeDetails[playerid][5], 0.231199, 1.122133);
	PlayerTextDrawTextSize(playerid, MDC_SelectedCrimeDetails[playerid][5], 370.000488, 9.000000);
	PlayerTextDrawAlignment(playerid, MDC_SelectedCrimeDetails[playerid][5], 1);
	PlayerTextDrawColor(playerid, MDC_SelectedCrimeDetails[playerid][5], -2139062017);
	PlayerTextDrawUseBox(playerid, MDC_SelectedCrimeDetails[playerid][5], 1);
	PlayerTextDrawBoxColor(playerid, MDC_SelectedCrimeDetails[playerid][5], 84215040);
	PlayerTextDrawSetShadow(playerid, MDC_SelectedCrimeDetails[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, MDC_SelectedCrimeDetails[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_SelectedCrimeDetails[playerid][5], 255);
	PlayerTextDrawFont(playerid, MDC_SelectedCrimeDetails[playerid][5], 2);
	PlayerTextDrawSetProportional(playerid, MDC_SelectedCrimeDetails[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, MDC_SelectedCrimeDetails[playerid][5], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_SelectedCrimeDetails[playerid][5], true);

	MDC_CCTV[playerid][0] = CreatePlayerTextDraw(playerid, 232.500411, 193.457519, "camera1");
	PlayerTextDrawLetterSize(playerid, MDC_CCTV[playerid][0], 0.190595, 1.201953);
	PlayerTextDrawTextSize(playerid, MDC_CCTV[playerid][0], 522.000000, 10.559998);
	PlayerTextDrawAlignment(playerid, MDC_CCTV[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_CCTV[playerid][0], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CCTV[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CCTV[playerid][0], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CCTV[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CCTV[playerid][0], 255);
	PlayerTextDrawFont(playerid, MDC_CCTV[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CCTV[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][0], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CCTV[playerid][0], true);

	MDC_CCTV[playerid][1] = CreatePlayerTextDraw(playerid, 232.500411, 210.158538, "camera2");
	PlayerTextDrawLetterSize(playerid, MDC_CCTV[playerid][1], 0.190595, 1.201953);
	PlayerTextDrawTextSize(playerid, MDC_CCTV[playerid][1], 522.000000, 10.559998);
	PlayerTextDrawAlignment(playerid, MDC_CCTV[playerid][1], 1);
	PlayerTextDrawColor(playerid, MDC_CCTV[playerid][1], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CCTV[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CCTV[playerid][1], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CCTV[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CCTV[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_CCTV[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CCTV[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][1], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CCTV[playerid][1], true);

	MDC_CCTV[playerid][2] = CreatePlayerTextDraw(playerid, 232.500411, 226.959564, "camera3");
	PlayerTextDrawLetterSize(playerid, MDC_CCTV[playerid][2], 0.190595, 1.201953);
	PlayerTextDrawTextSize(playerid, MDC_CCTV[playerid][2], 522.000000, 10.559998);
	PlayerTextDrawAlignment(playerid, MDC_CCTV[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_CCTV[playerid][2], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CCTV[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CCTV[playerid][2], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CCTV[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CCTV[playerid][2], 255);
	PlayerTextDrawFont(playerid, MDC_CCTV[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CCTV[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][2], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CCTV[playerid][2], true);

	MDC_CCTV[playerid][3] = CreatePlayerTextDraw(playerid, 232.500411, 243.460571, "camera4");
	PlayerTextDrawLetterSize(playerid, MDC_CCTV[playerid][3], 0.190595, 1.201953);
	PlayerTextDrawTextSize(playerid, MDC_CCTV[playerid][3], 522.000000, 10.559998);
	PlayerTextDrawAlignment(playerid, MDC_CCTV[playerid][3], 1);
	PlayerTextDrawColor(playerid, MDC_CCTV[playerid][3], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CCTV[playerid][3], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CCTV[playerid][3], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CCTV[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CCTV[playerid][3], 255);
	PlayerTextDrawFont(playerid, MDC_CCTV[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CCTV[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][3], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CCTV[playerid][3], true);

	MDC_CCTV[playerid][4] = CreatePlayerTextDraw(playerid, 232.500411, 260.361602, "camera5");
	PlayerTextDrawLetterSize(playerid, MDC_CCTV[playerid][4], 0.190595, 1.201953);
	PlayerTextDrawTextSize(playerid, MDC_CCTV[playerid][4], 522.000000, 10.559998);
	PlayerTextDrawAlignment(playerid, MDC_CCTV[playerid][4], 1);
	PlayerTextDrawColor(playerid, MDC_CCTV[playerid][4], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CCTV[playerid][4], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CCTV[playerid][4], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CCTV[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CCTV[playerid][4], 255);
	PlayerTextDrawFont(playerid, MDC_CCTV[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CCTV[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][4], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CCTV[playerid][4], true);

	MDC_CCTV[playerid][5] = CreatePlayerTextDraw(playerid, 232.500411, 277.262634, "camera6");
	PlayerTextDrawLetterSize(playerid, MDC_CCTV[playerid][5], 0.190595, 1.201953);
	PlayerTextDrawTextSize(playerid, MDC_CCTV[playerid][5], 522.000000, 10.559998);
	PlayerTextDrawAlignment(playerid, MDC_CCTV[playerid][5], 1);
	PlayerTextDrawColor(playerid, MDC_CCTV[playerid][5], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CCTV[playerid][5], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CCTV[playerid][5], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CCTV[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CCTV[playerid][5], 255);
	PlayerTextDrawFont(playerid, MDC_CCTV[playerid][5], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CCTV[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][5], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CCTV[playerid][5], true);

	MDC_CCTV[playerid][6] = CreatePlayerTextDraw(playerid, 232.500411, 294.163665, "camera7");
	PlayerTextDrawLetterSize(playerid, MDC_CCTV[playerid][6], 0.190595, 1.201953);
	PlayerTextDrawTextSize(playerid, MDC_CCTV[playerid][6], 522.000000, 10.559998);
	PlayerTextDrawAlignment(playerid, MDC_CCTV[playerid][6], 1);
	PlayerTextDrawColor(playerid, MDC_CCTV[playerid][6], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CCTV[playerid][6], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CCTV[playerid][6], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CCTV[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CCTV[playerid][6], 255);
	PlayerTextDrawFont(playerid, MDC_CCTV[playerid][6], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CCTV[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][6], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CCTV[playerid][6], true);

	MDC_CCTV[playerid][7] = CreatePlayerTextDraw(playerid, 232.500411, 311.264709, "camera8");
	PlayerTextDrawLetterSize(playerid, MDC_CCTV[playerid][7], 0.190595, 1.201953);
	PlayerTextDrawTextSize(playerid, MDC_CCTV[playerid][7], 522.000000, 10.559998);
	PlayerTextDrawAlignment(playerid, MDC_CCTV[playerid][7], 1);
	PlayerTextDrawColor(playerid, MDC_CCTV[playerid][7], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CCTV[playerid][7], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CCTV[playerid][7], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CCTV[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CCTV[playerid][7], 255);
	PlayerTextDrawFont(playerid, MDC_CCTV[playerid][7], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CCTV[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][7], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CCTV[playerid][7], true);

	MDC_CCTV[playerid][8] = CreatePlayerTextDraw(playerid, 232.500411, 328.365753, "camera9");
	PlayerTextDrawLetterSize(playerid, MDC_CCTV[playerid][8], 0.190595, 1.201953);
	PlayerTextDrawTextSize(playerid, MDC_CCTV[playerid][8], 522.000000, 10.559998);
	PlayerTextDrawAlignment(playerid, MDC_CCTV[playerid][8], 1);
	PlayerTextDrawColor(playerid, MDC_CCTV[playerid][8], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CCTV[playerid][8], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CCTV[playerid][8], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CCTV[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CCTV[playerid][8], 255);
	PlayerTextDrawFont(playerid, MDC_CCTV[playerid][8], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CCTV[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][8], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CCTV[playerid][8], true);

	MDC_CCTV[playerid][9] = CreatePlayerTextDraw(playerid, 232.500411, 345.566802, "camera10");
	PlayerTextDrawLetterSize(playerid, MDC_CCTV[playerid][9], 0.190595, 1.201953);
	PlayerTextDrawTextSize(playerid, MDC_CCTV[playerid][9], 522.000000, 10.559998);
	PlayerTextDrawAlignment(playerid, MDC_CCTV[playerid][9], 1);
	PlayerTextDrawColor(playerid, MDC_CCTV[playerid][9], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CCTV[playerid][9], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CCTV[playerid][9], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CCTV[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CCTV[playerid][9], 255);
	PlayerTextDrawFont(playerid, MDC_CCTV[playerid][9], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CCTV[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][9], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CCTV[playerid][9], true);

	MDC_CCTV[playerid][10] = CreatePlayerTextDraw(playerid, 232.500411, 362.567840, "camera11");
	PlayerTextDrawLetterSize(playerid, MDC_CCTV[playerid][10], 0.190595, 1.201953);
	PlayerTextDrawTextSize(playerid, MDC_CCTV[playerid][10], 522.000000, 10.559998);
	PlayerTextDrawAlignment(playerid, MDC_CCTV[playerid][10], 1);
	PlayerTextDrawColor(playerid, MDC_CCTV[playerid][10], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CCTV[playerid][10], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CCTV[playerid][10], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CCTV[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CCTV[playerid][10], 255);
	PlayerTextDrawFont(playerid, MDC_CCTV[playerid][10], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CCTV[playerid][10], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][10], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CCTV[playerid][10], true);

	MDC_CCTV[playerid][11] = CreatePlayerTextDraw(playerid, 232.500411, 379.768890, "camera12");
	PlayerTextDrawLetterSize(playerid, MDC_CCTV[playerid][11], 0.190595, 1.201953);
	PlayerTextDrawTextSize(playerid, MDC_CCTV[playerid][11], 522.000000, 10.559998);
	PlayerTextDrawAlignment(playerid, MDC_CCTV[playerid][11], 1);
	PlayerTextDrawColor(playerid, MDC_CCTV[playerid][11], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CCTV[playerid][11], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CCTV[playerid][11], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CCTV[playerid][11], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CCTV[playerid][11], 255);
	PlayerTextDrawFont(playerid, MDC_CCTV[playerid][11], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CCTV[playerid][11], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][11], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CCTV[playerid][11], true);

	MDC_CCTV[playerid][12] = CreatePlayerTextDraw(playerid, 232.500411, 397.169952, "camera13");
	PlayerTextDrawLetterSize(playerid, MDC_CCTV[playerid][12], 0.190595, 1.201953);
	PlayerTextDrawTextSize(playerid, MDC_CCTV[playerid][12], 522.000000, 10.559998);
	PlayerTextDrawAlignment(playerid, MDC_CCTV[playerid][12], 1);
	PlayerTextDrawColor(playerid, MDC_CCTV[playerid][12], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CCTV[playerid][12], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CCTV[playerid][12], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][12], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CCTV[playerid][12], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CCTV[playerid][12], 255);
	PlayerTextDrawFont(playerid, MDC_CCTV[playerid][12], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CCTV[playerid][12], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][12], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CCTV[playerid][12], true);

	MDC_CCTV[playerid][13] = CreatePlayerTextDraw(playerid, 232.500411, 414.170989, "camera14");
	PlayerTextDrawLetterSize(playerid, MDC_CCTV[playerid][13], 0.190595, 1.201953);
	PlayerTextDrawTextSize(playerid, MDC_CCTV[playerid][13], 522.000000, 10.559998);
	PlayerTextDrawAlignment(playerid, MDC_CCTV[playerid][13], 1);
	PlayerTextDrawColor(playerid, MDC_CCTV[playerid][13], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CCTV[playerid][13], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CCTV[playerid][13], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][13], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CCTV[playerid][13], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CCTV[playerid][13], 255);
	PlayerTextDrawFont(playerid, MDC_CCTV[playerid][13], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CCTV[playerid][13], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][13], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CCTV[playerid][13], true);

	MDC_CCTV[playerid][14] = CreatePlayerTextDraw(playerid, 513.599548, 427.542236, "~>~");
	PlayerTextDrawLetterSize(playerid, MDC_CCTV[playerid][14], 0.377199, 1.390933);
	PlayerTextDrawAlignment(playerid, MDC_CCTV[playerid][14], 1);
	PlayerTextDrawColor(playerid, MDC_CCTV[playerid][14], -1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][14], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CCTV[playerid][14], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CCTV[playerid][14], 255);
	PlayerTextDrawFont(playerid, MDC_CCTV[playerid][14], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CCTV[playerid][14], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][14], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CCTV[playerid][14], true);

	MDC_CCTV[playerid][15] = CreatePlayerTextDraw(playerid, 340.099365, 427.542236, "~<~");
	PlayerTextDrawLetterSize(playerid, MDC_CCTV[playerid][15], 0.377199, 1.390933);
	PlayerTextDrawAlignment(playerid, MDC_CCTV[playerid][15], 1);
	PlayerTextDrawColor(playerid, MDC_CCTV[playerid][15], -1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][15], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CCTV[playerid][15], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CCTV[playerid][15], 255);
	PlayerTextDrawFont(playerid, MDC_CCTV[playerid][15], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CCTV[playerid][15], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][15], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CCTV[playerid][15], true);

	MDC_CCTV[playerid][16] = CreatePlayerTextDraw(playerid, 522.900024, 181.142288, "10/10");
	PlayerTextDrawLetterSize(playerid, MDC_CCTV[playerid][16], 0.234799, 0.937955);
	PlayerTextDrawAlignment(playerid, MDC_CCTV[playerid][16], 3);
	PlayerTextDrawColor(playerid, MDC_CCTV[playerid][16], 993737727);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][16], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CCTV[playerid][16], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CCTV[playerid][16], 255);
	PlayerTextDrawFont(playerid, MDC_CCTV[playerid][16], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CCTV[playerid][16], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CCTV[playerid][16], 0);

	MDC_VehicleBolo_Details[playerid][0] = CreatePlayerTextDraw(playerid, 409.100311, 168.324035, "ARAC_BOLOSUNU_SIL");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_Details[playerid][0], 0.198597, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_Details[playerid][0], 525.199462, 10.559998);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_Details[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_Details[playerid][0], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_Details[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_Details[playerid][0], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_Details[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_Details[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_Details[playerid][0], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_Details[playerid][0], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_Details[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_Details[playerid][0], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_Details[playerid][0], true);

	MDC_VehicleBolo_Details[playerid][1] = CreatePlayerTextDraw(playerid, 229.799316, 168.324035, "~<~_ARAC_BOLOLARINA_GERI_DON");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_Details[playerid][1], 0.159395, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_Details[playerid][1], 340.199462, 10.559998);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_Details[playerid][1], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_Details[playerid][1], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_Details[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_Details[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_Details[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_Details[playerid][1], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_Details[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_Details[playerid][1], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_Details[playerid][1], true);

	MDC_VehicleBolo_Details[playerid][2] = CreatePlayerTextDraw(playerid, 237.499359, 193.624176, "BOLO_ID~n~Olusturan~n~Model~n~Plaka~n~Tarih~n~~n~Suclar~n~~n~~n~~n~Rapor");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_Details[playerid][2], 0.218595, 0.908263);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_Details[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_Details[playerid][2], 858993663);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_Details[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_Details[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_Details[playerid][2], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_Details[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_Details[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_Details[playerid][2], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_Details[playerid][2], false);

	MDC_VehicleBolo_Details[playerid][3] = CreatePlayerTextDraw(playerid, 286.999633, 193.624176, "id~n~createdBy~n~Model~n~Plate~n~Date");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_Details[playerid][3], 0.218595, 0.908263);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_Details[playerid][3], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_Details[playerid][3], -1684300801);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_Details[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_Details[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_Details[playerid][3], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_Details[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_Details[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_Details[playerid][3], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_Details[playerid][3], false);

	MDC_VehicleBolo_Details[playerid][4] = CreatePlayerTextDraw(playerid, 244.099395, 251.924499, "boloCrimes");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_Details[playerid][4], 0.218595, 0.908263);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_Details[playerid][4], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_Details[playerid][4], -1684300801);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_Details[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_Details[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_Details[playerid][4], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_Details[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_Details[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_Details[playerid][4], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_Details[playerid][4], false);

	MDC_VehicleBolo_Details[playerid][5] = CreatePlayerTextDraw(playerid, 244.099395, 286.024688, "N/A");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_Details[playerid][5], 0.218595, 0.908263);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_Details[playerid][5], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_Details[playerid][5], -1684300801);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_Details[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_Details[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_Details[playerid][5], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_Details[playerid][5], 1);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_Details[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_Details[playerid][5], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_Details[playerid][5], false);

	MDC_VehicleBolo_List[playerid][0] = CreatePlayerTextDraw(playerid, 479.449951, 168.124023, "Yeni_bolo_olustur");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][0], 0.159395, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][0], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][0], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][0], 858994175);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][0], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][0], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][0], true);

	MDC_VehicleBolo_List[playerid][1] = CreatePlayerTextDraw(playerid, 230.400512, 181.774856, "BOLO1");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][1], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][1], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][1], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][1], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][1], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][1], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][1], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][1], true);

	MDC_VehicleBolo_List[playerid][2] = CreatePlayerTextDraw(playerid, 230.400512, 194.324890, "bolo2");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][2], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][2], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][2], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][2], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][2], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][2], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][2], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][2], true);

	MDC_VehicleBolo_List[playerid][3] = CreatePlayerTextDraw(playerid, 230.400512, 207.324890, "bolo3");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][3], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][3], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][3], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][3], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][3], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][3], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][3], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][3], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][3], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][3], true);

	MDC_VehicleBolo_List[playerid][4] = CreatePlayerTextDraw(playerid, 230.400512, 220.324890, "bolo4");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][4], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][4], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][4], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][4], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][4], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][4], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][4], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][4], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][4], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][4], true);

	MDC_VehicleBolo_List[playerid][5] = CreatePlayerTextDraw(playerid, 230.400512, 233.324890, "bolo5");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][5], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][5], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][5], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][5], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][5], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][5], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][5], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][5], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][5], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][5], true);

	MDC_VehicleBolo_List[playerid][6] = CreatePlayerTextDraw(playerid, 230.400512, 246.225021, "bolo6");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][6], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][6], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][6], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][6], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][6], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][6], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][6], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][6], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][6], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][6], true);

	MDC_VehicleBolo_List[playerid][7] = CreatePlayerTextDraw(playerid, 230.400512, 259.125000, "bolo7");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][7], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][7], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][7], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][7], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][7], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][7], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][7], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][7], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][7], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][7], true);

	MDC_VehicleBolo_List[playerid][8] = CreatePlayerTextDraw(playerid, 230.400512, 272.024475, "bolo8");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][8], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][8], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][8], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][8], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][8], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][8], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][8], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][8], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][8], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][8], true);

	MDC_VehicleBolo_List[playerid][9] = CreatePlayerTextDraw(playerid, 230.400512, 285.223937, "bolo9");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][9], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][9], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][9], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][9], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][9], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][9], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][9], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][9], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][9], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][9], true);

	MDC_VehicleBolo_List[playerid][10] = CreatePlayerTextDraw(playerid, 230.400512, 298.123413, "bolo10");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][10], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][10], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][10], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][10], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][10], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][10], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][10], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][10], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][10], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][10], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][10], true);

	MDC_VehicleBolo_List[playerid][11] = CreatePlayerTextDraw(playerid, 230.400512, 311.022888, "bolo11");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][11], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][11], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][11], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][11], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][11], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][11], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][11], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][11], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][11], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][11], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][11], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][11], true);

	MDC_VehicleBolo_List[playerid][12] = CreatePlayerTextDraw(playerid, 230.400512, 323.922363, "bolo12");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][12], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][12], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][12], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][12], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][12], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][12], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][12], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][12], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][12], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][12], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][12], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][12], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][12], true);

	MDC_VehicleBolo_List[playerid][13] = CreatePlayerTextDraw(playerid, 230.400512, 336.821838, "bolo13");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][13], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][13], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][13], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][13], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][13], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][13], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][13], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][13], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][13], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][13], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][13], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][13], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][13], true);

	MDC_VehicleBolo_List[playerid][14] = CreatePlayerTextDraw(playerid, 230.400512, 349.721313, "bolo14");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][14], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][14], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][14], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][14], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][14], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][14], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][14], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][14], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][14], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][14], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][14], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][14], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][14], true);

	MDC_VehicleBolo_List[playerid][15] = CreatePlayerTextDraw(playerid, 230.400512, 362.620788, "bolo15");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][15], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][15], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][15], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][15], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][15], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][15], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][15], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][15], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][15], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][15], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][15], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][15], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][15], true);

	MDC_VehicleBolo_List[playerid][16] = CreatePlayerTextDraw(playerid, 230.400512, 375.520263, "bolo16");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][16], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][16], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][16], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][16], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][16], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][16], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][16], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][16], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][16], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][16], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][16], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][16], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][16], true);

	MDC_VehicleBolo_List[playerid][17] = CreatePlayerTextDraw(playerid, 230.400512, 388.719726, "bolo17");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][17], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][17], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][17], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][17], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][17], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][17], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][17], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][17], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][17], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][17], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][17], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][17], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][17], true);

	MDC_VehicleBolo_List[playerid][18] = CreatePlayerTextDraw(playerid, 230.400512, 401.319213, "bolo18");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][18], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][18], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][18], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][18], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][18], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][18], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][18], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][18], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][18], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][18], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][18], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][18], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][18], true);

	MDC_VehicleBolo_List[playerid][19] = CreatePlayerTextDraw(playerid, 230.400512, 413.918701, "bolo19");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][19], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][19], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][19], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][19], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][19], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][19], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][19], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][19], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][19], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][19], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][19], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][19], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][19], true);

	MDC_VehicleBolo_List[playerid][20] = CreatePlayerTextDraw(playerid, 230.400512, 426.818176, "bolo20");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][20], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][20], 525.349792, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][20], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][20], 1683842303);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][20], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][20], -1431459073);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][20], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][20], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][20], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][20], 2);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][20], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][20], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][20], true);

	MDC_VehicleBolo_List[playerid][21] = CreatePlayerTextDraw(playerid, 450.650329, 168.124023, "~<~");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][21], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][21], 459.200073, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][21], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][21], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][21], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][21], 1683842048);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][21], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][21], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][21], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][21], 1);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][21], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][21], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][21], true);

	MDC_VehicleBolo_List[playerid][22] = CreatePlayerTextDraw(playerid, 463.050354, 168.124023, "~>~");
	PlayerTextDrawLetterSize(playerid, MDC_VehicleBolo_List[playerid][22], 0.159391, 0.982930);
	PlayerTextDrawTextSize(playerid, MDC_VehicleBolo_List[playerid][22], 471.600097, 10.0);
	PlayerTextDrawAlignment(playerid, MDC_VehicleBolo_List[playerid][22], 1);
	PlayerTextDrawColor(playerid, MDC_VehicleBolo_List[playerid][22], -1431655681);
	PlayerTextDrawUseBox(playerid, MDC_VehicleBolo_List[playerid][22], 1);
	PlayerTextDrawBoxColor(playerid, MDC_VehicleBolo_List[playerid][22], 1683842048);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][22], 0);
	PlayerTextDrawSetOutline(playerid, MDC_VehicleBolo_List[playerid][22], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_VehicleBolo_List[playerid][22], 255);
	PlayerTextDrawFont(playerid, MDC_VehicleBolo_List[playerid][22], 1);
	PlayerTextDrawSetProportional(playerid, MDC_VehicleBolo_List[playerid][22], 1);
	PlayerTextDrawSetShadow(playerid, MDC_VehicleBolo_List[playerid][22], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_VehicleBolo_List[playerid][22], true);

	MDC_CriminalRecords[playerid][0] = CreatePlayerTextDraw(playerid, 230.000274, 168.693344, "~<~_geri_don");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][0], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][0], 279.999694, 1.889997);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][0], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][0], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][0], 2);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][0], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][0], true);

	MDC_CriminalRecords[playerid][1] = CreatePlayerTextDraw(playerid, 498.251281, 422.393188, "~<~");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][1], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][1], 507.213378, 1.889997);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][1], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][1], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][1], 0);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][1], 2);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][1], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][1], true);

	MDC_CriminalRecords[playerid][2] = CreatePlayerTextDraw(playerid, 511.252075, 422.393188, "~>~");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][2], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][2], 520.211669, 1.889997);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][2], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][2], 0);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][2], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][2], 2);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][2], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][2], true);

	MDC_CriminalRecords[playerid][3] = CreatePlayerTextDraw(playerid, 232.350402, 184.843185, "box");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][3], 0.000000, 25.920318);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][3], 519.970031, 0.000000);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][3], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][3], -1);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][3], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][3], -1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][3], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][3], 0);

	MDC_CriminalRecords[playerid][4] = CreatePlayerTextDraw(playerid, 232.400405, 185.143493, "1");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][4], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][4], 519.601501, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][4], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][4], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][4], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][4], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][4], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][4], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][4], true);

	MDC_CriminalRecords[playerid][5] = CreatePlayerTextDraw(playerid, 232.400405, 199.044342, "2");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][5], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][5], 519.601501, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][5], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][5], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][5], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][5], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][5], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][5], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][5], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][5], true);

	MDC_CriminalRecords[playerid][6] = CreatePlayerTextDraw(playerid, 232.400405, 213.044464, "3");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][6], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][6], 519.601501, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][6], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][6], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][6], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][6], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][6], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][6], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][6], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][6], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][6], true);

	MDC_CriminalRecords[playerid][7] = CreatePlayerTextDraw(playerid, 232.400405, 226.895309, "4");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][7], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][7], 519.601501, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][7], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][7], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][7], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][7], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][7], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][7], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][7], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][7], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][7], true);

	MDC_CriminalRecords[playerid][8] = CreatePlayerTextDraw(playerid, 232.400405, 240.846160, "5");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][8], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][8], 519.601501, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][8], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][8], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][8], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][8], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][8], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][8], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][8], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][8], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][8], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][8], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][8], true);

	MDC_CriminalRecords[playerid][9] = CreatePlayerTextDraw(playerid, 232.400405, 254.847015, "6");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][9], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][9], 519.601501, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][9], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][9], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][9], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][9], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][9], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][9], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][9], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][9], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][9], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][9], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][9], true);

	MDC_CriminalRecords[playerid][10] = CreatePlayerTextDraw(playerid, 232.400405, 268.743988, "7");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][10], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][10], 519.601501, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][10], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][10], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][10], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][10], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][10], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][10], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][10], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][10], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][10], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][10], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][10], true);

	MDC_CriminalRecords[playerid][11] = CreatePlayerTextDraw(playerid, 232.400405, 282.690582, "8");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][11], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][11], 519.601501, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][11], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][11], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][11], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][11], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][11], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][11], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][11], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][11], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][11], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][11], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][11], true);

	MDC_CriminalRecords[playerid][12] = CreatePlayerTextDraw(playerid, 232.400405, 296.637176, "9");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][12], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][12], 519.601501, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][12], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][12], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][12], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][12], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][12], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][12], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][12], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][12], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][12], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][12], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][12], true);

	MDC_CriminalRecords[playerid][13] = CreatePlayerTextDraw(playerid, 232.400405, 310.433807, "10");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][13], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][13], 519.601501, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][13], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][13], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][13], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][13], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][13], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][13], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][13], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][13], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][13], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][13], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][13], true);

	MDC_CriminalRecords[playerid][14] = CreatePlayerTextDraw(playerid, 232.400405, 324.530364, "11");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][14], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][14], 519.601501, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][14], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][14], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][14], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][14], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][14], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][14], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][14], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][14], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][14], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][14], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][14], true);

	MDC_CriminalRecords[playerid][15] = CreatePlayerTextDraw(playerid, 232.400405, 338.426971, "12");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][15], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][15], 519.601501, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][15], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][15], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][15], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][15], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][15], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][15], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][15], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][15], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][15], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][15], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][15], true);

	MDC_CriminalRecords[playerid][16] = CreatePlayerTextDraw(playerid, 232.400405, 352.423553, "13");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][16], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][16], 519.601501, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][16], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][16], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][16], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][16], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][16], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][16], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][16], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][16], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][16], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][16], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][16], true);

	MDC_CriminalRecords[playerid][17] = CreatePlayerTextDraw(playerid, 232.400405, 366.320159, "14");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][17], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][17], 519.601501, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][17], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][17], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][17], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][17], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][17], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][17], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][17], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][17], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][17], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][17], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][17], true);

	MDC_CriminalRecords[playerid][18] = CreatePlayerTextDraw(playerid, 232.400405, 380.216766, "15");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][18], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][18], 519.601501, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][18], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][18], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][18], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][18], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][18], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][18], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][18], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][18], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][18], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][18], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][18], true);

	MDC_CriminalRecords[playerid][19] = CreatePlayerTextDraw(playerid, 232.400405, 394.163360, "16");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][19], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][19], 519.601501, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][19], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][19], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][19], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][19], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][19], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][19], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][19], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][19], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][19], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][19], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][19], true);

	MDC_CriminalRecords[playerid][20] = CreatePlayerTextDraw(playerid, 232.400405, 408.109954, "17");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecords[playerid][20], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecords[playerid][20], 519.601501, 1.559998);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecords[playerid][20], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecords[playerid][20], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecords[playerid][20], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecords[playerid][20], -1381323265);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][20], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecords[playerid][20], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecords[playerid][20], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecords[playerid][20], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecords[playerid][20], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecords[playerid][20], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecords[playerid][20], true);

	MDC_CriminalRecordDetail[playerid][0] = CreatePlayerTextDraw(playerid, 230.000274, 168.693344, "~<~_geri_don");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecordDetail[playerid][0], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecordDetail[playerid][0], 279.999694, 1.889997);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecordDetail[playerid][0], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecordDetail[playerid][0], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecordDetail[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecordDetail[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecordDetail[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecordDetail[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecordDetail[playerid][0], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecordDetail[playerid][0], 2);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecordDetail[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecordDetail[playerid][0], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecordDetail[playerid][0], true);

	MDC_CriminalRecordDetail[playerid][1] = CreatePlayerTextDraw(playerid, 230.000274, 184.893096, "Dosya_ID~n~Isim~n~Isleyen~n~Tarih~n~Tur");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecordDetail[playerid][1], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecordDetail[playerid][1], 279.999694, 1.889997);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecordDetail[playerid][1], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecordDetail[playerid][1], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecordDetail[playerid][1], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecordDetail[playerid][1], 0);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecordDetail[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecordDetail[playerid][1], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecordDetail[playerid][1], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecordDetail[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecordDetail[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecordDetail[playerid][1], 0);

	MDC_CriminalRecordDetail[playerid][2] = CreatePlayerTextDraw(playerid, 271.400817, 184.893096, "id~n~name~n~issuer~n~date~n~type");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecordDetail[playerid][2], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecordDetail[playerid][2], 321.402221, 1.889997);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecordDetail[playerid][2], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecordDetail[playerid][2], -1566268161);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecordDetail[playerid][2], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecordDetail[playerid][2], 0);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecordDetail[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecordDetail[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecordDetail[playerid][2], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecordDetail[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecordDetail[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecordDetail[playerid][2], 0);

	MDC_CriminalRecordDetail[playerid][3] = CreatePlayerTextDraw(playerid, 230.000274, 251.093292, "~>~_Tum_kaydi_gormek_icin_tiklayin.");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecordDetail[playerid][3], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecordDetail[playerid][3], 343.000000, 1.889997);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecordDetail[playerid][3], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecordDetail[playerid][3], -1532516353);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecordDetail[playerid][3], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecordDetail[playerid][3], 0);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecordDetail[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecordDetail[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecordDetail[playerid][3], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecordDetail[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecordDetail[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecordDetail[playerid][3], 0);
	PlayerTextDrawSetSelectable(playerid, MDC_CriminalRecordDetail[playerid][3], true);

	MDC_CriminalRecordDetail[playerid][4] = CreatePlayerTextDraw(playerid, 230.000274, 240.593261, "Tutuklama_Kaydi_(Martin tarafindan yazildi)");
	PlayerTextDrawLetterSize(playerid, MDC_CriminalRecordDetail[playerid][4], 0.198596, 1.092442);
	PlayerTextDrawTextSize(playerid, MDC_CriminalRecordDetail[playerid][4], 498.000000, 1.889997);
	PlayerTextDrawAlignment(playerid, MDC_CriminalRecordDetail[playerid][4], 1);
	PlayerTextDrawColor(playerid, MDC_CriminalRecordDetail[playerid][4], 892483071);
	PlayerTextDrawUseBox(playerid, MDC_CriminalRecordDetail[playerid][4], 1);
	PlayerTextDrawBoxColor(playerid, MDC_CriminalRecordDetail[playerid][4], 0);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecordDetail[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, MDC_CriminalRecordDetail[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, MDC_CriminalRecordDetail[playerid][4], 255);
	PlayerTextDrawFont(playerid, MDC_CriminalRecordDetail[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, MDC_CriminalRecordDetail[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, MDC_CriminalRecordDetail[playerid][4], 0);
	return 1;
}

stock SetAddresMapPosition(playerid, Float:X, Float:Y)
{
	PlayerTextDrawDestroy(playerid, MDC_AdressDetails[playerid][13]);

	new
			Float:map_kY = -0.04595376,
			Float:map_kX = 0.0469,

			Float:map_sX = 333.999420,
			Float:map_sY = 299.8809,

			Float:corX, Float:corY;

	if(X > 0.000)
	{
		PlayerTextDrawSetString(playerid, MDC_AdressDetails[playerid][3], "samaps:gtasamapbit2");
		PlayerTextDrawSetString(playerid, MDC_AdressDetails[playerid][12], "samaps:gtasamapbit4");

		map_kX = 0.0425;
		map_sX = 369.800;

		corX = X * map_kX + map_sX;
		corY = Y * map_kY + map_sY;
	}
	else
	{
		PlayerTextDrawSetString(playerid, MDC_AdressDetails[playerid][3], "samaps:gtasamapbit1");
		PlayerTextDrawSetString(playerid, MDC_AdressDetails[playerid][12], "samaps:gtasamapbit3");

		map_kX = -0.0425;
		map_sX = 495.2644;

		corX = map_sX - X * map_kX;
		corY = Y * map_kY + map_sY;
	}

	PlayerTextDrawShow(playerid, MDC_AdressDetails[playerid][3]);
	PlayerTextDrawShow(playerid, MDC_AdressDetails[playerid][12]);

	MDC_AdressDetails[playerid][13] = CreatePlayerTextDraw(playerid, corX, corY, "hud:radar_propertyG");
	PlayerTextDrawTextSize(playerid, MDC_AdressDetails[playerid][13], 7.000000, 7.000000);
	PlayerTextDrawFont(playerid, MDC_AdressDetails[playerid][13], 4);

	PlayerTextDrawShow(playerid, MDC_AdressDetails[playerid][13]);
	return 1;
}


Hide_PageAttachement(playerid)
{
	for(new is = 0; is < 49; is++)
	{
		PlayerTextDrawHide(playerid, MDC_PenalCode[playerid][is]);
	}

	for(new is = 0; is < 17; is++)
	{
		PlayerTextDrawHide(playerid, MDC_LookUp_Vehicle[playerid][is]);
	}

	for(new is = 0; is < 34; is++)
	{
		PlayerTextDrawHide(playerid, MDC_ManageLicense[playerid][is]);
	}

	for(new is = 0; is < 34; is++)
	{
		PlayerTextDrawHide(playerid, MDC_ManageLicense[playerid][is]);
	}

	for(new is = 0; is < 23; is++)
	{
		PlayerTextDrawHide(playerid, MDC_VehicleBolo_List[playerid][is]);
	}

	for(new is = 0; is < 6; is++)
	{
		PlayerTextDrawHide(playerid, MDC_VehicleBolo_Details[playerid][is]);
	}
	return 1;
}

/*Dialog:DIALOG_ALPRLOG(playerid, response, listitem, inputtext[])
{
	if(!response) return 0;
	if(response)
	{
		cmd_mdc(playerid, " ");
		new id = strval(inputtext);
		MDC_HideAfterPage(playerid);
		ShowMDCPage(playerid, MDC_PAGE_LOOKUP);
		MDC_LOOKUP_SelectOption(playerid, MDC_PAGE_LOOKUP_PLATE);

		new sorgu[256];
		format(sorgu, sizeof(sorgu), "SELECT * FROM `vehicles` WHERE `Plate` = '%s'", 0);
		mysql_tquery(m_Handle, sorgu, "KisiSorgula", "sdd", VehicleBolo[id][vBoloPlate], playerid, 1);
	}
	return 1;
}*/

MembersOnline(playerid)
{
    new count = 0;
    foreach(new i : Player)
    {
				if(PlayerData[i][pFaction] == PlayerData[playerid][pFaction] && PlayerData[i][pLAWduty])
				{
					count++;
				}
    }
    return count;
}
