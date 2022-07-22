SET DEFINE OFF;
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (1, '<ACC_TYPE_CORPORATE>', '1', 'ACC_TYPE_CORPORATE', 'Kurumsal uyelik tipi degeri', 
    '1');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (2, '<ACC_TYPE_INDIVIDUAL>', '0', 'ACC_TYPE_INDIVIDUAL', 'Bireysel uyelik tipi degeri', 
    '1');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (3, '<ACC_SEGMENT_STANDARD>', '0', 'ACC_SEGMENT_STANDARD', 'Standard segment degeri', 
    '1');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (4, '<ACC_SEGMENT_SILVER>', '1', 'ACC_SEGMENT_SILVER', 'Silver segment degeri', 
    '1');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (5, '<ACC_SEGMENT_GOLD>', '2', 'ACC_SEGMENT_GOLD', 'Gold segment degeri', 
    '1');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (6, '<ACC_REGION_LOCAL>', '0', 'ACC_REGION_LOCAL', 'Yerli region degeri', 
    '1');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (7, '<ACC_REGION_FOREIGN>', '1', 'ACC_REGION_FOREIGN', 'Yabanci region degeri', 
    '1');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (8, '<LMT_LOCAL_CORPORATE>', '20', 'LMT_LOCAL_CORPORATE', 'Yerli kurumsal uye borc limit degeri', 
    '0');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (9, '<LMT_FOREIGN_CORPORATE>', '25', 'LMT_FOREIGN_CORPORATE', 'Yabanci kurumsal uye borc limit degeri', 
    '0');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (10, '<LMT_LOCAL_GOLD>', '30', 'LMT_LOCAL_GOLD', 'Yerli gold uye borc limit degeri', 
    '0');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (11, '<LMT_LOCAL_SILVER>', '30', 'LMT_LOCAL_SILVER', 'Yerli silver uye borc limit degeri', 
    '0');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (12, '<LMT_LOCAL_STANDARD>', '20', 'LMT_LOCAL_STANDARD', 'Yerli standard uye borc limit degeri', 
    '0');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (13, '<LMT_FOREIGN_GOLD>', '30', 'LMT_FOREIGN_GOLD', 'Yabanci gold uye borc limit degeri', 
    '0');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (14, '<LMT_FOREIGN_STANDARD>', '20', 'LMT_FOREIGN_STANDARD', 'Yabanci standard uye borc limit degeri', 
    '0');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (15, '<BORC_DONEMI_1>', '-1-', 'BORC_DONEMI_1', 'Icinde bulunulan donem 1 olmak uzere geriye dogru fatura donemi/donemleri', 
    '1');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (16, '<BORC_DONEMI_2>', '-2-', 'BORC_DONEMI_2', 'Icinde bulunulan donem 1 olmak uzere geriye dogru fatura donemi/donemleri', 
    '1');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (17, '<BORC_DONEMI_1_2>', '-1-2-', 'BORC_DONEMI_1_2', 'Icinde bulunulan donem 1 olmak uzere geriye dogru fatura donemi/donemleri', 
    '1');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (18, '<PREPARATION_TABLE>', 'BATCH_COLLECTION', 'PREPARATION_TABLE', 'Batch verisi hazirlama tablosu', 
    '0');
Insert into SB_QUERY_TAGS
   (T_ID, TAG, TAG_VALUE, TAG_NAME, TAG_DESCRIPTION, 
    TAG_QUOTED)
 Values
   (19, '<LIMIT_IHMAL_EDILECEK>', '6', 'LIMIT_IHMAL_EDILECEK', 'Ihmal edilecek borc tutari limit degeri', 
    '0');
COMMIT;

SET DEFINE OFF;
Insert into SB_QUERY_LIST_TAG_INFO
   (L_ID, LIST_TAG, TAG_NAME, TAG_DESCRIPTION)
 Values
   (1, '<<ACC_SEGMENTLERI_LOCAL_INDIVIDUAL>>', 'ACC_SEGMENTLERI_LOCAL_INDIVIDUAL', 'Yerel bireysel uyelik segmentleri');
Insert into SB_QUERY_LIST_TAG_INFO
   (L_ID, LIST_TAG, TAG_NAME, TAG_DESCRIPTION)
 Values
   (2, '<<ACC_SEGMENTLERI_FOREIGN_CORPORATE>>', 'ACC_SEGMENTLERI_FOREIGN_CORPORATE', 'Yabanci kurumsal uyelik segmentleri');
Insert into SB_QUERY_LIST_TAG_INFO
   (L_ID, LIST_TAG, TAG_NAME, TAG_DESCRIPTION)
 Values
   (3, '<<BORC_DONEMLERI_SON_2>>', 'BORC_DONEMLERI_SON_2', 'Sadece son 2 donemden borcu olanlar icin borclu sayilacagi donem kombinasyonlari');
COMMIT;

SET DEFINE OFF;
Insert into SB_QUERY_LIST_TAGS
   (L_ID, T_FROM_ID, T_TO_ID)
 Values
   (1, 3, 5);
Insert into SB_QUERY_LIST_TAGS
   (L_ID, T_FROM_ID, T_TO_ID)
 Values
   (2, 3, 4);
Insert into SB_QUERY_LIST_TAGS
   (L_ID, T_FROM_ID, T_TO_ID)
 Values
   (3, 16, 17);
COMMIT;