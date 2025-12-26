Locales = Locales or {}
Locales['hu'] = {
    -- Általános
    ['welcome'] = 'Üdvözöl a Last Light!',
    ['loading'] = 'Betöltés...',
    ['please_wait'] = 'Kérlek várj...',
    
    -- Login/Register
    ['login'] = 'Bejelentkezés',
    ['register'] = 'Regisztráció',
    ['username'] = 'Felhasználónév',
    ['password'] = 'Jelszó',
    ['password_confirm'] = 'Jelszó megerősítése',
    ['login_button'] = 'Belépés',
    ['register_button'] = 'Regisztráció',
    
    -- Karakter
    ['character_selection'] = 'Karakterválasztás',
    ['create_character'] = 'Új Karakter',
    ['delete_character'] = 'Karakter törlése',
    ['select_character'] = 'Kiválasztás',
    ['no_characters'] = 'Még nincs karaktered',
    ['max_characters'] = 'Elérted a maximum karakterek számát (%s)',
    
    -- Karakter létrehozás
    ['firstname'] = 'Keresztnév',
    ['lastname'] = 'Vezetéknév',
    ['dateofbirth'] = 'Születési dátum',
    ['sex'] = 'Nem',
    ['height'] = 'Magasság',
    ['male'] = 'Férfi',
    ['female'] = 'Nő',
    ['create'] = 'Létrehozás',
    ['back'] = 'Vissza',
    
    -- Spawn
    ['select_spawn'] = 'Válassz spawn pontot',
    ['spawn_location'] = 'Spawn Helyszín',
    ['confirm_spawn'] = 'Megerősítés',
    
    -- Character Creator
    ['appearance_editor'] = 'Megjelenés Szerkesztő',
    ['heritage'] = 'Öröklődés',
    ['face_features'] = 'Arcvonások',
    ['hair'] = 'Haj',
    ['facial_hair'] = 'Arcszőrzet',
    ['appearance'] = 'Megjelenés',
    ['finish_creator'] = 'Befejezés',
    ['reset_creator'] = 'Visszaállítás',
    ['character_appearance_saved'] = 'Karakter megjelenése mentve!',
    
    -- Heritage
    ['mother'] = 'Anya',
    ['father'] = 'Apa',
    ['similarity'] = 'Hasonlóság',
    ['skin_similarity'] = 'Bőr hasonlóság',
    
    -- Face Features
    ['nose_width'] = 'Orr szélesség',
    ['nose_peak_height'] = 'Orr csúcs magasság',
    ['nose_peak_length'] = 'Orr csúcs hossz',
    ['nose_bone_height'] = 'Orrcsont magasság',
    ['eyebrows_height'] = 'Szemöldök magasság',
    ['eyebrows_width'] = 'Szemöldök szélesség',
    ['cheekbone_height'] = 'Járomcsont magasság',
    ['cheekbone_width'] = 'Járomcsont szélesség',
    ['cheeks_width'] = 'Arcpofák szélesség',
    ['eyes_opening'] = 'Szem nyitottság',
    ['lips_thickness'] = 'Ajak vastagság',
    ['jaw_bone_width'] = 'Állkapocs szélesség',
    ['jaw_bone_back_length'] = 'Állkapocs hossz',
    ['chin_bone_lowering'] = 'Áll lesüllyedés',
    ['chin_bone_length'] = 'Áll hossz',
    ['chin_bone_width'] = 'Áll szélesség',
    ['chin_hole'] = 'Áll lyuk',
    ['neck_thickness'] = 'Nyak vastagság',
    
    -- Hair
    ['hair_style'] = 'Frizura',
    ['hair_color'] = 'Hajszín',
    ['hair_highlight'] = 'Melír',
    
    -- Facial
    ['beard'] = 'Szakáll',
    ['beard_style'] = 'Szakáll stílus',
    ['beard_color'] = 'Szakáll szín',
    ['beard_opacity'] = 'Szakáll átlátszóság',
    ['eyebrows'] = 'Szemöldök',
    ['eyebrows_style'] = 'Szemöldök stílus',
    ['eyebrows_color'] = 'Szemöldök szín',
    ['chest_hair'] = 'Mellkas szőrzet',
    ['makeup'] = 'Smink',
    ['lipstick'] = 'Rúzs',
    ['eye_color'] = 'Szemszín',
    
    -- Camera
    ['camera_head'] = 'Fej',
    ['camera_body'] = 'Test',
    ['camera_legs'] = 'Lábak',
    ['camera_full'] = 'Teljes',
    
    -- Validáció
    ['all_fields_required'] = 'Minden mező kitöltése kötelező!',
    ['name_too_short'] = 'A név túl rövid! (minimum %s karakter)',
    ['name_too_long'] = 'A név túl hosszú! (maximum %s karakter)',
    ['name_invalid'] = 'Érvénytelen karakterek a névben!',
    ['name_blacklisted'] = 'Ez a név nem használható!',
    ['date_invalid'] = 'Érvénytelen dátum formátum!',
    ['age_too_young'] = 'Túl fiatal vagy! (minimum %s év)',
    ['age_too_old'] = 'Túl idős vagy! (maximum %s év)',
    ['height_invalid'] = 'Érvénytelen magasság! (%s-%s cm)',
    
    -- Notifications
    ['character_created'] = 'Karakter sikeresen létrehozva!',
    ['character_deleted'] = 'Karakter törölve!',
    ['character_loaded'] = 'Üdvözlünk %s!',
    ['error_creating'] = 'Hiba a karakter létrehozása során!',
    ['error_deleting'] = 'Hiba a karakter törlése során!',
    ['error_loading'] = 'Hiba a karakter betöltése során!',
    ['database_error'] = 'Adatbázis hiba!',
    ['character_not_found'] = 'Karakter nem található!',
    
    -- Rate limit
    ['creation_cooldown'] = 'Várj még %s másodpercet mielőtt újat hozol létre!',
    ['too_many_today'] = 'Elérted a napi maximum karakterlétrehozási limitet!',
    
    -- Túlélő
    ['welcome_survivor'] = 'Üdvözlünk túlélő!',
    ['starting_kit'] = 'Kezdő felszerelést kaptál!',
    ['survival_tip'] = 'Tipp: Figyelj az éhség, szomjúság és sugárzás szintedre!',
    
    -- Tutorial
    ['tutorial_welcome'] = 'Üdvözlünk a Last Light apokalipszis túlélő szerverén!',
    ['tutorial_basics'] = 'Alapok: Keress ételt, vizet és menedéket.',
    ['tutorial_dangers'] = 'Vigyázz: Zombik, sugárzás és más játékosok is veszélyt jelentenek.',
    ['tutorial_stats'] = 'Nézd meg a statisztikáidat a HUD-on!',
    ['tutorial_complete'] = 'Tutorial befejezve! Sok sikert a túléléshez!',
    
    -- Confirmation
    ['confirm_delete'] = 'Biztosan törölni szeretnéd ezt a karaktert?',
    ['confirm_reset'] = 'Biztosan visszaállítod az alapértékekre?',
    ['yes'] = 'Igen',
    ['no'] = 'Nem',
    ['cancel'] = 'Mégse',
    
    -- Egyéb
    ['afk_kick'] = 'Inaktivitás miatt ki lettél dobva!',
    ['session_expired'] = 'A munkameneted lejárt!',
    ['reconnecting'] = 'Újracsatlakozás...',
}