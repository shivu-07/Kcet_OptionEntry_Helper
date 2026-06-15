-- Map colleges to districts based on their location
-- District IDs reference: 1=Bagalkote, 2=Ballari, 3=Belagavi, 4=Bengaluru Rural,
-- 5=Bengaluru Urban, 6=Bidar, 7=Chamarajanagar, 8=Chikkaballapur, 9=Chikkamagaluru,
-- 10=Chitradurga, 11=Dakshina Kannada, 12=Davanagere, 13=Dharwad, 14=Gadag,
-- 15=Hassan, 16=Haveri, 17=Kalaburagi, 18=Kodagu, 19=Kolar, 20=Koppal,
-- 21=Mandya, 22=Mysuru, 23=Raichur, 24=Ramanagara, 25=Shivamogga,
-- 26=Tumakuru, 27=Udupi, 28=Uttara Kannada, 29=Vijayanagara, 30=Vijayapura, 31=Yadgir

-- ========================================
-- Government Engineering Colleges (1-25)
-- ========================================
UPDATE colleges SET district_id = 8 WHERE id = 1;   -- Chintamani, Chikaballapura
UPDATE colleges SET district_id = 15 WHERE id = 2;  -- Arasikere, Hassan
UPDATE colleges SET district_id = 10 WHERE id = 3;  -- Challakere, Chitradurga
UPDATE colleges SET district_id = 7 WHERE id = 4;   -- Chamarajanagara
UPDATE colleges SET district_id = 15 WHERE id = 5;  -- Hassan
UPDATE colleges SET district_id = 16 WHERE id = 6;  -- Haveri
UPDATE colleges SET district_id = 2 WHERE id = 7;   -- Hoovina Hadagali, Bellary
UPDATE colleges SET district_id = 28 WHERE id = 8;  -- Karwar, Uttara Kannada
UPDATE colleges SET district_id = 18 WHERE id = 9;  -- Kushalanagar, Kodagu
UPDATE colleges SET district_id = 15 WHERE id = 10; -- Mosale Hosahalli, Hassan
UPDATE colleges SET district_id = 23 WHERE id = 11; -- Raichur
UPDATE colleges SET district_id = 24 WHERE id = 12; -- Ramanagaram
UPDATE colleges SET district_id = 20 WHERE id = 13; -- Talakal, Koppal
UPDATE colleges SET district_id = 20 WHERE id = 14; -- Gangavathi, Koppal
UPDATE colleges SET district_id = 6 WHERE id = 15;  -- Bidar
UPDATE colleges SET district_id = 14 WHERE id = 16; -- Naragund, Gadag
UPDATE colleges SET district_id = 5 WHERE id = 17;  -- Bangalore
UPDATE colleges SET district_id = 21 WHERE id = 18; -- K R Pet, Mandya
UPDATE colleges SET district_id = 12 WHERE id = 19; -- Davanagere
UPDATE colleges SET district_id = 22 WHERE id = 20; -- University of Mysuru
UPDATE colleges SET district_id = 3 WHERE id = 21;  -- Belagavi
UPDATE colleges SET district_id = 8 WHERE id = 22;  -- Muddenahalli, Chikkaballapur
UPDATE colleges SET district_id = 17 WHERE id = 23; -- Kalburgi
UPDATE colleges SET district_id = 22 WHERE id = 24; -- Mysuru
UPDATE colleges SET district_id = 3 WHERE id = 25;  -- Gokak, Belagavi

-- ========================================
-- Aided Engineering Colleges (26-33)
-- ========================================
UPDATE colleges SET district_id = 5 WHERE id = 26;  -- BMS, Bangalore
UPDATE colleges SET district_id = 1 WHERE id = 27;  -- Bagalkote
UPDATE colleges SET district_id = 5 WHERE id = 28;  -- Dr. Ambedkar IT, Bangalore
UPDATE colleges SET district_id = 15 WHERE id = 29; -- Malnad, Hassan
UPDATE colleges SET district_id = 17 WHERE id = 30; -- PDA, Gulbarga
UPDATE colleges SET district_id = 21 WHERE id = 31; -- PES, Mandya
UPDATE colleges SET district_id = 22 WHERE id = 32; -- SJCE, Mysore
UPDATE colleges SET district_id = 22 WHERE id = 33; -- NIE, Mysore

-- ========================================
-- Private Unaided Colleges (34-183)
-- ========================================
UPDATE colleges SET district_id = 5 WHERE id = 34;  -- Acharya IT, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 35;  -- ACS, Bangalore
UPDATE colleges SET district_id = 9 WHERE id = 36;  -- Adhichunchanagiri IT, Chickamagalur
UPDATE colleges SET district_id = 5 WHERE id = 37;  -- Aditya College
UPDATE colleges SET district_id = 13 WHERE id = 38; -- AGM Rural, Hubli (Dharwad)
UPDATE colleges SET district_id = 5 WHERE id = 39;  -- Akash IT
UPDATE colleges SET district_id = 26 WHERE id = 40; -- Akshaya IT, Tumkur
UPDATE colleges SET district_id = 11 WHERE id = 41; -- Alva's IT, Moodabidre, DK
UPDATE colleges SET district_id = 5 WHERE id = 42;  -- AMC, Bangalore
UPDATE colleges SET district_id = 24 WHERE id = 43; -- Amrutha, Ramanagar
UPDATE colleges SET district_id = 3 WHERE id = 44;  -- Angadi IT, Belgaum
UPDATE colleges SET district_id = 3 WHERE id = 45;  -- Anuvartik Mirji, Belagavi
UPDATE colleges SET district_id = 5 WHERE id = 46;  -- APS, Bangalore
UPDATE colleges SET district_id = 22 WHERE id = 47; -- ATME, Mysore
UPDATE colleges SET district_id = 5 WHERE id = 48;  -- Atria IT, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 49;  -- BMS Architecture, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 50;  -- BMS CoE, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 51;  -- BMSIT, Yelahanka, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 52;  -- BNM IT, Bangalore
UPDATE colleges SET district_id = 1 WHERE id = 53;  -- BVV Sangha, Bagalkote
UPDATE colleges SET district_id = 2 WHERE id = 54;  -- Ballari IT, Bellary
UPDATE colleges SET district_id = 5 WHERE id = 55;  -- BIT, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 56;  -- Bangalore Technological Institute
UPDATE colleges SET district_id = 12 WHERE id = 57; -- Bapuji IT, Davangere
UPDATE colleges SET district_id = 6 WHERE id = 58;  -- Basavakalyana, Bidar
UPDATE colleges SET district_id = 5 WHERE id = 59;  -- BGS, Bangalore
UPDATE colleges SET district_id = 6 WHERE id = 60;  -- Bheemanna Khandre, Bhalki (Bidar)
UPDATE colleges SET district_id = 1 WHERE id = 61;  -- Biluru, Mudhol, Bagalkote
UPDATE colleges SET district_id = 30 WHERE id = 62; -- BLDEA, Bijapur (Vijayapura)
UPDATE colleges SET district_id = 5 WHERE id = 63;  -- Brindavan, Bangalore
UPDATE colleges SET district_id = 19 WHERE id = 64; -- C Byre Gowda, Kolar
UPDATE colleges SET district_id = 5 WHERE id = 65;  -- CMN IT
UPDATE colleges SET district_id = 5 WHERE id = 66;  -- CMRIT, Bangalore
UPDATE colleges SET district_id = 4 WHERE id = 67;  -- Cambridge North, Devanahalli (Bengaluru Rural)
UPDATE colleges SET district_id = 5 WHERE id = 68;  -- Cambridge KR Puram, Bangalore
UPDATE colleges SET district_id = 22 WHERE id = 69; -- Cauvery, Mysore
UPDATE colleges SET district_id = 21 WHERE id = 70; -- Cauvery IT, Mandya
UPDATE colleges SET district_id = 26 WHERE id = 71; -- Channabasaveshwara, Tumkur
UPDATE colleges SET district_id = 5 WHERE id = 72;  -- City EC, Bangalore
UPDATE colleges SET district_id = 18 WHERE id = 73; -- Coorg IT, Ponnampet, Kodagu
UPDATE colleges SET district_id = 5 WHERE id = 74;  -- DSAT, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 75;  -- DSCE, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 76;  -- Donbosco IT, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 77;  -- DR HN National, Bengaluru
UPDATE colleges SET district_id = 5 WHERE id = 78;  -- Dr. Ambedkar IT, Bangalore
UPDATE colleges SET district_id = 4 WHERE id = 79;  -- Dr. Shivakumara, Bangalore Rural
UPDATE colleges SET district_id = 19 WHERE id = 80; -- Dr. T. Thimmaiah, KGF (Kolar)
UPDATE colleges SET district_id = 5 WHERE id = 81;  -- East Point, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 82;  -- East West CoE, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 83;  -- East West IT, Bangalore
UPDATE colleges SET district_id = 13 WHERE id = 84; -- Future Forge, Hubli (Dharwad)
UPDATE colleges SET district_id = 12 WHERE id = 85; -- GM IT, Davanagere
UPDATE colleges SET district_id = 21 WHERE id = 86; -- G Madegowda, Mandya
UPDATE colleges SET district_id = 22 WHERE id = 87; -- GSSS IT for Women, Mysore
UPDATE colleges SET district_id = 5 WHERE id = 88;  -- Ghousia IT for Women, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 89;  -- Global Academy, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 90;  -- Gopalan, Bangalore
UPDATE colleges SET district_id = 23 WHERE id = 91; -- HKE Sir M Visvesvaraya, Raichur
UPDATE colleges SET district_id = 4 WHERE id = 92;  -- Harsha IT, Bengaluru Rural
UPDATE colleges SET district_id = 3 WHERE id = 93;  -- Hira Sugar, Belgaum
UPDATE colleges SET district_id = 5 WHERE id = 94;  -- Impact, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 95;  -- ISBR, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 96;  -- JSS Academy, Bangalore
UPDATE colleges SET district_id = 3 WHERE id = 97;  -- Jain CoE Research, Belgaum
UPDATE colleges SET district_id = 13 WHERE id = 98; -- Jain CoE, Hubballi (Dharwad)
UPDATE colleges SET district_id = 3 WHERE id = 99;  -- Jain CoE Machhe, Belgaum
UPDATE colleges SET district_id = 12 WHERE id = 100; -- Jain IT, Davanagere
UPDATE colleges SET district_id = 25 WHERE id = 101; -- JN New CoE, Shimoga
UPDATE colleges SET district_id = 24 WHERE id = 102; -- Jnanavikasa, Bidadi, Ramanagar
UPDATE colleges SET district_id = 5 WHERE id = 103; -- Jyothi IT, Bangalore
UPDATE colleges SET district_id = 3 WHERE id = 104; -- KLE CoE, Chikkodi, Belgaum
UPDATE colleges SET district_id = 28 WHERE id = 105; -- KLS, Haliyal, Uttara Kannada
UPDATE colleges SET district_id = 5 WHERE id = 106; -- KNS IT, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 107; -- KS IT, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 108; -- KS School, Bangalore
UPDATE colleges SET district_id = 11 WHERE id = 109; -- KVG, Sullia, DK
UPDATE colleges SET district_id = 3 WHERE id = 110; -- Gogte IT, Belgaum
UPDATE colleges SET district_id = 26 WHERE id = 111; -- Kalpatharu, Tiptur, Tumakuru
UPDATE colleges SET district_id = 11 WHERE id = 112; -- Karavali, Mangalore
UPDATE colleges SET district_id = 5 WHERE id = 113; -- Koshys, Bengaluru
UPDATE colleges SET district_id = 6 WHERE id = 114; -- Lingarajappa, Bidar
UPDATE colleges SET district_id = 5 WHERE id = 115; -- MS Engineering, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 116; -- MSRIT, Bangalore
UPDATE colleges SET district_id = 21 WHERE id = 117; -- MIT Mysore, Mandya
UPDATE colleges SET district_id = 22 WHERE id = 118; -- MIT Tandavapura, Mysore
UPDATE colleges SET district_id = 15 WHERE id = 119; -- Malnad CoE, Hassan
UPDATE colleges SET district_id = 11 WHERE id = 120; -- MITE, Moodabidri, Mangalore
UPDATE colleges SET district_id = 3 WHERE id = 121; -- Maratha Mandal, Belgaum
UPDATE colleges SET district_id = 27 WHERE id = 122; -- Moodalakatte, Kundapura, Udupi
UPDATE colleges SET district_id = 22 WHERE id = 123; -- Mysore CoE, Mysore
UPDATE colleges SET district_id = 22 WHERE id = 124; -- Mysuru Royal IT, Mysuru
UPDATE colleges SET district_id = 4 WHERE id = 125; -- Nagarjuna, Devanahalli, Bangalore Rural
UPDATE colleges SET district_id = 15 WHERE id = 126; -- Navkis, Hassan
UPDATE colleges SET district_id = 23 WHERE id = 127; -- Navodaya IT, Raichur
UPDATE colleges SET district_id = 5 WHERE id = 128; -- New Ebenezer, Bengaluru
UPDATE colleges SET district_id = 17 WHERE id = 129; -- PDA, Gulbarga (Kalaburagi)
UPDATE colleges SET district_id = 21 WHERE id = 130; -- PES CoE, Mandya
UPDATE colleges SET district_id = 25 WHERE id = 131; -- PES IT, Shimoga
UPDATE colleges SET district_id = 29 WHERE id = 132; -- Proudadevaraya, Hospet (Vijayanagara)
UPDATE colleges SET district_id = 5 WHERE id = 133; -- RV IT&M, Bengaluru
UPDATE colleges SET district_id = 5 WHERE id = 134; -- RV CoE, Bangalore
UPDATE colleges SET district_id = 4 WHERE id = 135; -- RL Jalappa, Doddaballapur
UPDATE colleges SET district_id = 5 WHERE id = 136; -- RRIT, Bangalore
UPDATE colleges SET district_id = 14 WHERE id = 137; -- RTE Rural, Hulkoti, Gadag
UPDATE colleges SET district_id = 5 WHERE id = 138; -- Rajarajeswari, Bangalore
UPDATE colleges SET district_id = 15 WHERE id = 139; -- Rajeev IT, Hassan
UPDATE colleges SET district_id = 5 WHERE id = 140; -- Rajiv Gandhi IT, Bangalore
UPDATE colleges SET district_id = 2 WHERE id = 141; -- Rao Bahadur, Bellary
UPDATE colleges SET district_id = 5 WHERE id = 142; -- Rathinam IT, Bengaluru
UPDATE colleges SET district_id = 5 WHERE id = 143; -- RNS IT, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 144; -- SEA CoE, Bangalore
UPDATE colleges SET district_id = 8 WHERE id = 145; -- SJC IT, Chikkaballapur
UPDATE colleges SET district_id = 5 WHERE id = 146; -- SJB IT, Bangalore
UPDATE colleges SET district_id = 3 WHERE id = 147; -- Balekundri IT, Belgaum
UPDATE colleges SET district_id = 11 WHERE id = 148; -- Sahyadri, Mangalore
UPDATE colleges SET district_id = 5 WHERE id = 149;  -- Sai Vidya IT, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 150;  -- Sambhram IT, Bangalore
UPDATE colleges SET district_id = 24 WHERE id = 151; -- Sampoorna, Channapatana (Ramanagara)
UPDATE colleges SET district_id = 30 WHERE id = 152; -- Secab, Bijapur (Vijayapura)
UPDATE colleges SET district_id = 22 WHERE id = 153; -- Seshadripuram, Mysuru
UPDATE colleges SET district_id = 17 WHERE id = 154; -- Shetty IT, Gulbarga (Kalaburagi)
UPDATE colleges SET district_id = 11 WHERE id = 155; -- Shreedevi IT, Mangalore (DK)
UPDATE colleges SET district_id = 27 WHERE id = 156; -- Shri Madhwa Vadiraja, Udupi
UPDATE colleges SET district_id = 26 WHERE id = 157; -- Shridevi IT, Tumkur
UPDATE colleges SET district_id = 26 WHERE id = 158; -- Siddaganga IT, Tumkur
UPDATE colleges SET district_id = 5 WHERE id = 159;  -- Sir MV School of Arch, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 160;  -- Sir MVIT, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 161;  -- SJB School of Arch, Bangalore
UPDATE colleges SET district_id = 14 WHERE id = 162; -- Smt. Kamala Agadi, Gadag
UPDATE colleges SET district_id = 26 WHERE id = 163; -- Sri Basaveswara, Tiptur (Tumakuru)
UPDATE colleges SET district_id = 22 WHERE id = 164; -- SJCE, Mysore
UPDATE colleges SET district_id = 5 WHERE id = 165;  -- Sri Krishna IT, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 166;  -- Sri Revana, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 167;  -- Sri Sairam, Anekal, Bangalore
UPDATE colleges SET district_id = 26 WHERE id = 168; -- Sri Siddhartha, Tumkur
UPDATE colleges SET district_id = 16 WHERE id = 169; -- Sri Taralabalu, Ranebennur (Haveri)
UPDATE colleges SET district_id = 5 WHERE id = 170;  -- Sri Venkateshwara, Bangalore
UPDATE colleges SET district_id = 11 WHERE id = 171; -- Srinivas IT, Mangalore (DK)
UPDATE colleges SET district_id = 5 WHERE id = 172;  -- T.John IT, Bangalore
UPDATE colleges SET district_id = 22 WHERE id = 173; -- NIE, Mysore
UPDATE colleges SET district_id = 14 WHERE id = 174; -- Tontadarya, Gadag
UPDATE colleges SET district_id = 3 WHERE id = 175; -- Nippani, Belgaum
UPDATE colleges SET district_id = 31 WHERE id = 176; -- Shorapur, Yadgir
UPDATE colleges SET district_id = 5 WHERE id = 177; -- Bangalore
UPDATE colleges SET district_id = 22 WHERE id = 178; -- Mysore
UPDATE colleges SET district_id = 22 WHERE id = 179; -- Mysore
UPDATE colleges SET district_id = 5 WHERE id = 180; -- Bangalore
UPDATE colleges SET district_id = 11 WHERE id = 181; -- Puttur, DK
UPDATE colleges SET district_id = 5 WHERE id = 182; -- Bangalore
UPDATE colleges SET district_id = 11 WHERE id = 183; -- Mangalore

-- ========================================
-- Private Minority Colleges (184-199)
-- ========================================
UPDATE colleges SET district_id = 11 WHERE id = 184; -- Mangalore
UPDATE colleges SET district_id = 28 WHERE id = 185; -- Bhatkal, Uttara Kannada
UPDATE colleges SET district_id = 15 WHERE id = 186; -- Shravanabelagola, Hassan
UPDATE colleges SET district_id = 11 WHERE id = 187; -- Bantwal, Mangalore
UPDATE colleges SET district_id = 11 WHERE id = 188; -- Bantwal, DK
UPDATE colleges SET district_id = 24 WHERE id = 189; -- Ramanagara
UPDATE colleges SET district_id = 6 WHERE id = 190;  -- Bidar
UPDATE colleges SET district_id = 5 WHERE id = 191;  -- Bangalore
UPDATE colleges SET district_id = 17 WHERE id = 192; -- Gulbarga (Kalaburagi)
UPDATE colleges SET district_id = 5 WHERE id = 193;  -- Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 194;  -- Bangalore
UPDATE colleges SET district_id = 11 WHERE id = 195; -- Mangalore
UPDATE colleges SET district_id = 11 WHERE id = 196; -- Ujire, DK
UPDATE colleges SET district_id = 13 WHERE id = 197; -- Dharwad
UPDATE colleges SET district_id = 11 WHERE id = 198; -- Mangalore
UPDATE colleges SET district_id = 5 WHERE id = 199;  -- Bangalore

-- ========================================
-- Public Universities (200)
-- ========================================
UPDATE colleges SET district_id = 5 WHERE id = 200;  -- UVCE, Bangalore

-- ========================================
-- Private Universities (201-230)
-- ========================================
UPDATE colleges SET district_id = 21 WHERE id = 201; -- Nagamangala, Mandya
UPDATE colleges SET district_id = 5 WHERE id = 202;  -- Chandapura-Anekal, Bengaluru
UPDATE colleges SET district_id = 4 WHERE id = 203;  -- Devanahalli, Bengaluru Rural
UPDATE colleges SET district_id = 5 WHERE id = 204;  -- Bull Temple Road, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 205;  -- CMR, Bangalore
UPDATE colleges SET district_id = 24 WHERE id = 206; -- Harohalli, Ramanagar
UPDATE colleges SET district_id = 5 WHERE id = 207;  -- Garden City, Bangalore
UPDATE colleges SET district_id = 12 WHERE id = 208; -- GM Uni, Davangere
UPDATE colleges SET district_id = 22 WHERE id = 209; -- JSS, Mysuru
UPDATE colleges SET district_id = 3 WHERE id = 210;  -- KLE, Belgaum
UPDATE colleges SET district_id = 17 WHERE id = 211; -- Khaja Bandanawaz, Kalaburagi
UPDATE colleges SET district_id = 2 WHERE id = 212;  -- Kishkinda, Ballari
UPDATE colleges SET district_id = 13 WHERE id = 213; -- KLE, Hubballi (Dharwad)
UPDATE colleges SET district_id = 5 WHERE id = 214;  -- MS Ramaiah, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 215;  -- PES Uni, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 216;  -- PES EC Campus, Bengaluru
UPDATE colleges SET district_id = 5 WHERE id = 217;  -- Presidency, Bangalore
UPDATE colleges SET district_id = 4 WHERE id = 218;  -- RAI, Doddaballapur
UPDATE colleges SET district_id = 5 WHERE id = 219;  -- Ramaiah Uni, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 220;  -- REVA, Bangalore
UPDATE colleges SET district_id = 22 WHERE id = 221; -- RV Uni, Nanjanagudu, Mysuru
UPDATE colleges SET district_id = 5 WHERE id = 222;  -- RV Uni, Mysore Road, Bangalore
UPDATE colleges SET district_id = 5 WHERE id = 223;  -- Sapthagiri NPS, Bengaluru
UPDATE colleges SET district_id = 22 WHERE id = 224; -- SPA, Mysore
UPDATE colleges SET district_id = 17 WHERE id = 225; -- Sharanbasava Women, Kalaburagi
UPDATE colleges SET district_id = 17 WHERE id = 226; -- Sharanbasava, Kalaburagi
UPDATE colleges SET district_id = 10 WHERE id = 227; -- Sri Jagadguru, Chitradurga
UPDATE colleges SET district_id = 11 WHERE id = 228; -- Srinivas Uni, Mangaluru
UPDATE colleges SET district_id = 4 WHERE id = 229;  -- Chanakya Uni, Devanahalli
UPDATE colleges SET district_id = 5 WHERE id = 230;  -- Vidyashilp Uni, Bengaluru

-- ========================================
-- Deemed Universities (231-232)
-- ========================================
UPDATE colleges SET district_id = 5 WHERE id = 231;  -- GITAM, Bengaluru
UPDATE colleges SET district_id = 26 WHERE id = 232; -- Sri Siddhartha, Tumkur

-- ========================================
-- Government Colleges with Higher Fees (233-236)
-- ========================================
UPDATE colleges SET district_id = 8 WHERE id = 233;  -- Chintamani, Chikaballapura
UPDATE colleges SET district_id = 12 WHERE id = 234; -- BDT, Davanagere
UPDATE colleges SET district_id = 22 WHERE id = 235; -- Mysuru
UPDATE colleges SET district_id = 3 WHERE id = 236;  -- Gokak, Belagavi
UPDATE colleges SET district_id = 30 WHERE id = 237; -- Vijayapura


-- Mark autonomous colleges based on name
UPDATE colleges SET is_autonomous = 1 WHERE name LIKE '%(Autonomous)%' OR name LIKE '%(AUTONOMOUS)%';
