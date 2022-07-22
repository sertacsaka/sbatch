SET DEFINE OFF;
Insert into SB_CONDITION_ARRAYS
   (A_ID, A_ORDER_ID, C_FROM_ID, C_TO_ID)
 Values
   (1, 1, 1, 26);
COMMIT;

SET DEFINE OFF;
Insert into SB_CONDITIONS
   (C_ID, C_BOUNDS, CONDITION, DESCRIPTION)
 Values
   (1, '0', 'a.account_type is null', 'account_type tanimli degil');
Insert into SB_CONDITIONS
   (C_ID, C_BOUNDS, CONDITION, DESCRIPTION)
 Values
   (2, '0', 'a.account_segment is null', 'account_segment tanimli degil');
Insert into SB_CONDITIONS
   (C_ID, C_BOUNDS, CONDITION, DESCRIPTION)
 Values
   (3, '1', 'a.region = ''0''', 'Yerli uye');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, CONDITION, DESCRIPTION)
 Values
   (4, 3, '0', 'a.invoice_pattern in (<BORC_DONEMI_1>)', 'Sadece son donemden borclu');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, DESCRIPTION)
 Values
   (5, 3, '0', 'Son iki donem icinden borcu yok, son 2 donem haric borcu ihmal edilebilir limit altinda');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, CONDITION)
 Values
   (6, 5, '0', 'a.invoice_pattern not in (<<BORC_DONEMLERI_SON_2>>)');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, CONDITION)
 Values
   (7, 5, '0', 'a.oit_except_last2_underl = ''1''');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, DESCRIPTION)
 Values
   (8, 3, '0', 'Kurumsal tipte ve borcu limit altinda');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, CONDITION)
 Values
   (9, 8, '0', 'a.account_type = <ACC_TYPE_CORPORATE>');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, CONDITION)
 Values
   (10, 8, '0', 'a.limit_asimi = ''0''');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, DESCRIPTION)
 Values
   (11, 3, '0', 'Kurumsal tipte degil, sadece son 2 donem icinden ve borclu sayilan donemlerden limit altinda borcu var');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, CONDITION)
 Values
   (12, 11, '0', 'a.account_type = <ACC_TYPE_INDIVIDUAL>');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, CONDITION)
 Values
   (13, 11, '0', 'a.account_segment in (<<ACC_SEGMENTLERI_LOCAL_INDIVIDUAL>>)');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, CONDITION)
 Values
   (14, 11, '0', 'a.invoice_pattern in (<<BORC_DONEMLERI_SON_2>>)');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, CONDITION)
 Values
   (15, 11, '0', 'a.limit_asimi = ''0''');
Insert into SB_CONDITIONS
   (C_ID, C_BOUNDS, CONDITION, DESCRIPTION)
 Values
   (16, '1', 'a.region = ''1''', 'yabanci uye');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, DESCRIPTION)
 Values
   (17, 16, '0', 'Sadece son donemden borclu ve borcu limit altinda');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, CONDITION)
 Values
   (18, 17, '0', 'a.invoice_pattern in (<BORC_DONEMI_1>)');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, CONDITION)
 Values
   (19, 17, '0', 'a.limit_asimi = ''0''');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, DESCRIPTION)
 Values
   (20, 16, '0', 'Kurumsal tipte, son donem borcu yok ve borcu limit altinda');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, CONDITION)
 Values
   (21, 20, '0', 'a.account_segment in (<<ACC_SEGMENTLERI_FOREIGN_CORPORATE>>)');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, CONDITION)
 Values
   (22, 20, '0', 'a.invoice_pattern not like <BORC_DONEMI_1> || ''%''');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, CONDITION)
 Values
   (23, 20, '0', 'a.limit_asimi = ''0''');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, DESCRIPTION)
 Values
   (24, 16, '0', 'Son donemden borcu yok ve kalan borcu ihmal edilebilir limit altinda');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, CONDITION)
 Values
   (25, 24, '0', 'a.invoice_pattern not like <BORC_DONEMI_1> || ''%''');
Insert into SB_CONDITIONS
   (C_ID, C_PARENT_ID, C_BOUNDS, CONDITION)
 Values
   (26, 24, '0', 'a.total_debt_amount <= <LIMIT_IHMAL_EDILECEK>');
COMMIT;
