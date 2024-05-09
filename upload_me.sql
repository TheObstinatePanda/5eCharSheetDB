CREATE TABLE "bio" (
  "id" integer PRIMARY KEY,
  "char_name" varchar(50),
  "player_name" varchar(50),
  "race" varchar(30),
  "sub_race" varchar(30),
  "classes" varchar(30)[],
  "char_lvl" integer,
  "prof_bonus" integer
);

CREATE TABLE "stats" (
  "char_id" integer,
  "stat_name" varchar(15),
  "stat_score" integer,
  "stat_mod" integer,
  "racial_bonus" integer,
  FOREIGN KEY ("char_id") REFERENCES "bio" ("id"),
  PRIMARY KEY ("char_id", "stat_name")
);

CREATE TABLE "saves" (
  "char_id" integer,
  "save_name" varchar(15),
  "is_prof" boolean,
  "save_bonus" integer,
  FOREIGN KEY ("char_id") REFERENCES "bio" ("id"),
  PRIMARY KEY ("char_id", "save_name")
);

CREATE TABLE "skills" (
  "char_id" integer,
  "skill_name" varchar(20),
  "skill_ability" varchar(15),
  "is_prof" boolean,
  "skill_mod" integer,
  FOREIGN KEY ("char_id") REFERENCES "bio" ("id"),
  PRIMARY KEY ("char_id", "skill_name")
);

CREATE TABLE "passive_skills" (
  "char_id" integer,
  "skill_name" varchar(20),
  "pass_bonus" integer,
  FOREIGN KEY ("char_id") REFERENCES "bio" ("id"),
  PRIMARY KEY ("char_id", "skill_name") 
);

CREATE TABLE "race" (
  "race_id" integer,
  "race_name" varchar(20),
  "race_details" text,
  "race_traits" text,
  "asi_stat_name" varchar(3),
  "asi_stat_bonus" integer,
  "size" varchar(15),
  "speed" integer,
  "sub_race" varchar(20),
  "sr_asi_name" varchar(15),
  "sr_asi" integer,
  "sr_spec" text,
  PRIMARY KEY ("race_id", "race_name")
);

CREATE TABLE "equipment" (
  "equipment_name" varchar(20) PRIMARY KEY,
  "equipment_type" varchar(20),
  "is_magic" boolean,
  "req_attune" boolean,
  "req_prof" boolean,
  "prof_req" varchar(20),
  "ac_bonus" integer,
  "negative_name" varchar(15),
  "negative_effect" varchar(20),
  "stat_mod" integer
);

CREATE TABLE "character_equipment" (
  "char_id" integer,
  "equipment_name" varchar(20),
  FOREIGN KEY ("char_id") REFERENCES "bio" ("id"),
  FOREIGN KEY ("equipment_name") REFERENCES "equipment" ("equipment_name"),
  PRIMARY KEY ("char_id", "equipment_name")
);

CREATE TABLE "class" (
  "class_name" varchar(20) PRIMARY KEY,
  "hit_dice" varchar(3),
  "first_class" boolean,
  "class_prof" varchar(20)[],
  "skill_level" integer,
  "skill_rule" text,
  "is_spellcaster" boolean,
  "caster_type" varchar(10),
  "class_action_name" varchar(20),
  "class_action_desc" text,
  "class_action_option1" text,
  "class_action_option2" text,
  "class_action_option3" text,
  "class_action_option4" text,
  "class_action_option5" text
);

CREATE TABLE "character_class" (
  "char_id" integer,
  "class_name" varchar(20),
  FOREIGN KEY ("char_id") REFERENCES "bio" ("id"),
  FOREIGN KEY ("class_name") REFERENCES "class" ("class_name"),
  PRIMARY KEY ("char_id", "class_name")
);

-- add foreign keys

ALTER TABLE "passive_skills" ADD FOREIGN KEY ("char_id", "skill_name") REFERENCES "skills" ("char_id", "skill_name");


-- TRIGGERS

-- initialize proficiency bonus in the bio table
CREATE OR REPLACE FUNCTION init_prof_bonus() RETURNS TRIGGER AS $$
    BEGIN
        UPDATE bio
        SET prof_bonus = CASE
            WHEN NEW.char_lvl BETWEEN 1 AND 4 THEN 2
            WHEN NEW.char_lvl BETWEEN 5 AND 8 THEN 3
            WHEN NEW.char_lvl BETWEEN 9 AND 12 THEN 4
            WHEN NEW.char_lvl BETWEEN 13 AND 16 THEN 5
            WHEN NEW.char_lvl >= 17 THEN 6
        END
        WHERE id = NEW.id;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER init_prof_bonus_trigger
    AFTER INSERT ON bio
    FOR EACH ROW
    EXECUTE FUNCTION init_prof_bonus();

-- updating the proficiency bonus in the bio table
CREATE OR REPLACE FUNCTION update_prof_bonus() RETURNS TRIGGER AS $$
    BEGIN
        UPDATE bio
        SET prof_bonus = CASE
            WHEN NEW.char_lvl BETWEEN 1 AND 4 THEN 2
            WHEN NEW.char_lvl BETWEEN 5 AND 8 THEN 3
            WHEN NEW.char_lvl BETWEEN 9 AND 12 THEN 4
            WHEN NEW.char_lvl BETWEEN 13 AND 16 THEN 5
            WHEN NEW.char_lvl >= 17 THEN 6
        END
        WHERE id = NEW.id;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_prof_bonus_trig
    AFTER UPDATE OF char_lvl ON bio
    FOR EACH ROW
    EXECUTE FUNCTION update_prof_bonus();

-- initializing stats, saves, and skills tables on creation of a bio table.
CREATE OR REPLACE FUNCTION init_stats_skills() RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO stats (char_id, stat_name, stat_score, stat_mod)
        VALUES (NEW.id, 'Str', 10, 0),
            (NEW.id, 'Dex', 10, 0),
            (NEW.id, 'Con', 10, 0),
            (NEW.id, 'Int', 10, 0),
            (NEW.id, 'Wis', 10, 0),
            (NEW.id, 'Cha', 10, 0);
        
        INSERT INTO skills (char_id, skill_name, skill_ability, is_prof)
        VALUES (NEW.id, 'Acrobatics', 'Dex', false),
            (NEW.id, 'Animal Handling', 'Wis', false),
            (NEW.id, 'Arcana', 'Int', false),
            (NEW.id, 'Athletics', 'Str', false),
            (NEW.id, 'Deception', 'Cha', false),
            (NEW.id, 'History', 'Int', false),
            (NEW.id, 'Insight', 'Wis', false),
            (NEW.id, 'Intimidation', 'Cha', false),
            (NEW.id, 'Investigation', 'Int', false),
            (NEW.id, 'Medicine', 'Wis', false),
            (NEW.id, 'Nature', 'Int', false),
            (NEW.id, 'Perception', 'Wis', false),
            (NEW.id, 'Performance', 'Cha', false),
            (NEW.id, 'Persuasion', 'Cha', false),
            (NEW.id, 'Religion', 'Int', false),
            (NEW.id, 'Sleight of Hand', 'Dex', false),
            (NEW.id, 'Stealth', 'Dex', false),
            (NEW.id, 'Survival', 'Wis', false);

        INSERT INTO saves (char_id, save_name, is_prof, save_bonus)
        VALUES (NEW.id, 'Str', false, 0),
            (NEW.id, 'Dex', false, 0),
            (NEW.id, 'Con', false, 0),
            (NEW.id, 'Int', false, 0),
            (NEW.id, 'Wis', false, 0),
            (NEW.id, 'Cha', false, 0);        
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER init_stats_skills_trig
    AFTER INSERT ON bio
    FOR EACH ROW
    EXECUTE FUNCTION init_stats_skills();
    

-- setting skill and save proficiency
CREATE OR REPLACE FUNCTION set_prof() RETURNS TRIGGER AS $$
    BEGIN
        UPDATE skills
        SET is_prof = CASE WHEN skill_name = ANY (
            SELECT UNNEST(class_prof) FROM class
            INNER JOIN character_class ON class.class_name = character_class.class_name
            WHERE char_id = NEW.char_id
        )
        THEN true
        ELSE false
        END
        WHERE char_id = NEW.char_id;

        UPDATE saves
        SET is_prof = CASE WHEN save_name = ANY (
            SELECT UNNEST(class_prof) FROM class
            INNER JOIN character_class ON class.class_name = character_class.class_name
            WHERE char_id = NEW.char_id
        )
        THEN true
        ELSE false
        END
        WHERE char_id = NEW.char_id;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_prof_trig
    AFTER UPDATE OF class_name ON character_class
    FOR EACH ROW
    EXECUTE FUNCTION set_prof();

-- adding proficiency bonus when proficient in saves
CREATE OR REPLACE FUNCTION update_save_bonus_when_prof() RETURNS TRIGGER AS $$
    BEGIN 
        UPDATE saves
        set save_bonus = save_bonus + (SELECT prof_bonus FROM bio WHERE bio.id = NEW.char_id)
        WHERE char_id = NEW.char_id AND is_prof = TRUE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_save_bonus_when_prof_trig
    AFTER UPDATE OF is_prof ON saves
    FOR EACH ROW
    WHEN (NEW.is_prof = TRUE)
    EXECUTE FUNCTION update_save_bonus_when_prof();

-- adding proficiency bonus when proficient in skills
CREATE OR REPLACE FUNCTION update_skill_bonus_when_prof() RETURNS TRIGGER AS $$
    BEGIN 
        UPDATE skills
        set skill_mod = skill_mod + (SELECT prof_bonus FROM bio WHERE bio.id = NEW.char_id)
        WHERE char_id = NEW.char_id AND is_prof = TRUE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_skill_bonus_when_prof_trig
    AFTER UPDATE OF is_prof ON skills
    FOR EACH ROW
    WHEN (NEW.is_prof = TRUE)
    EXECUTE FUNCTION update_skill_bonus_when_prof();

-- setting passive skill bonus
-- passive is equal to 10 + skill mod
CREATE OR REPLACE FUNCTION set_passive_skill_score() RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO passive_skills (char_id, skill_name, pass_bonus)
        VALUES (NEW.char_id, NEW.skill_name, 10 + NEW.skill_mod);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_passive_skill_score_trig
    AFTER INSERT OR UPDATE ON skills
    FOR EACH ROW
    EXECUTE FUNCTION set_passive_skill_score();

-- adding ability score increase when a race is selected(inserted)
CREATE OR REPLACE FUNCTION add_asi_from_race() RETURNS TRIGGER AS $$
    BEGIN
        IF NEW.race IS NOT NULL THEN
            UPDATE stats
            SET racial_bonus = (SELECT asi_stat_bonus FROM race WHERE race_name = NEW.race)
            WHERE char_id = NEW.id AND stat_name = (SELECT asi_stat_name FROM race WHERE race_name = NEW.race);
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER add_asi_from_race_trig
    AFTER INSERT OR UPDATE OF race ON bio
    FOR EACH ROW
    EXECUTE FUNCTION add_asi_from_race();

-- adding ability score increase when a sub race is selected(inserted)
CREATE OR REPLACE FUNCTION add_asi_from_sub_race() RETURNS TRIGGER AS $$
    BEGIN
        IF NEW.race IS NOT NULL THEN
            UPDATE stats
            set racial_bonus = (SELECT sr_asi FROM race WHERE race_name = NEW.race)
            WHERE char_id = NEW.id AND stat_name = (SELECT sr_asi_name FROM race WHERE race_name = NEW.race);
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER add_asi_from_sub_race_trig
    AFTER INSERT OR UPDATE OF race ON bio
    FOR EACH ROW
    EXECUTE FUNCTION add_asi_from_sub_race();

-- populating data

INSERT INTO "race" ("race_id", "race_name", "race_details", "race_traits", "asi_stat_name", "asi_stat_bonus", "size", "speed", "sub_race", "sr_asi_name", "sr_asi", "sr_spec")
    VALUES ( 
        -- race_id
        01,
        -- race_name
        'Custom Lineage', 
        -- race_details
        E'The description of a race might suggest various things about the behavior and personality of that people’s archetypal adventurers. You may ignore those suggestions, whether they’re about alignment, moods, interests, or any other personality trait. Your character’s personality and behavior are entirely yours to determine.
        \n 
        \n Your race is considered to be a Custom Lineage for any game feature that requires a certain race, such as elf or dwarf.',
        -- race_traits
        E'Instead of choosing one of the game’s races for your character at 1st level, you can use the following traits to represent your character’s lineage, giving you full control over how your character’s origin shaped them:
        \n
        \n Creature Type
        \n You are a humanoid. You determine your appearance and whether you resemble any of your kin.
        \n 
        \n Size
        \n You are Small or Medium (your choice).
        \n 
        \n Speed
        \n Your base walking speed is 30 feet.
        \n 
        \n Ability Score Increase
        \n One Ability Score of your choice increases by 2.
        \n 
        \n Feat
        \n You gain one feat of your choice for which you qualify.
        \n 
        \n Variable Trait
        \n You gain one of the following options of your choice: (a) darkvision with a range of 60 feet or (b) proficiency in one skill of your choice.
        \n 
        \n Languages
        \n You can speak, read, and write Common and one other language that you and your DM agree is appropriate for your character.',
        -- asi_stat_name
        --choice (will be added later) increase one stat_bonus by 2
        --ARRAY['Str', 'Dex', 'Con', 'Int', 'Wis', 'Cha'],
        'Int',
        -- asi_stat_bonus
        2,
        -- size
        'Small or Medium',
        -- speed
        30,
        -- sub_race
        'N/A',
        -- sr_asi_name
        null,
        -- sr_asi
        0,
        -- sr_spec
        null
    ),
    (
        -- race_id
        02,
        -- race_name
        'Owlin', 
        -- race_details
        E'Distant kin of giant owls from the Feywild, owlin come in many shapes and sizes, from petite and fluffy to wide-winged and majestic. Owlin have arms and legs like other Humanoids, as well as wings that extend from their back and shoulders.
        \n 
        \n Like owls, owlin are graced with feathers that make no sound when they move or fly, making it easy for them to sneak up on you in the library.
        \n
        \n Your owlin character might be nocturnal. Or perhaps your character is simply prone to rise later, embodying the common nickname of night owl.',
        -- race_traits
        E'Creating Your Character
        \n
        \n If you create an owlin character, follow these additional rules during character creation.
        \n
        \n Creature Type
        \n You are a humanoid. You determine your appearance and whether you resemble any of your kin.
        \n 
        \n Size
        \n You are Medium or Small. You choose the size when you select this race.
        \n 
        \n Speed
        \n Your base walking speed is 30 feet.
        \n 
        \n Ability Score Increase
        \n One Ability Score of your choice increases by 2.
        \n 
        \n Darkvision
        \n You can see in dim light within 120 feet of yourself as if it were bright light and in darkness as if it were dim light. You discern colors in that darkness only as shades of gray.
        \n
        \n Flight
        \n Thanks to your wings, you have a flying speed equal to your walking speed. You can’t use this flying speed if you’re wearing medium or heavy armor.
        \n
        \n Silent Feathers
        \n You have proficiency in the Stealth skill.
        \n 
        \n Languages
        \n You can speak, read, and write Common and one other language that you and your DM agree is appropriate for your character.',
        -- asi_stat_name
        --choice (will be added later) +2  to one stat
        --ARRAY['Str', 'Dex', 'Con', 'Int', 'Wis', 'Cha'],
        'Str',
        -- asi_stat_bonus
        2,
        -- size
        'Small or Medium',
        -- speed
        30,
        -- sub_race
        'N/A',
        -- sr_asi_name
        'Wis',
        -- sr_asi
        1,
        -- sr_spec
        null
    ),
    (
        -- race_id
        03,
        -- race_name
        'Tiefling', 
        -- race_details
        E'To be greeted with stares and whispers, to suffer violence and insult on the street, to see mistrust and fear in every eye: this is the lot of the tiefling. And to twist the knife, tieflings know that this is because a pact struck generations ago infused the essence of Asmodeus—overlord of the Nine Hells—into their bloodline. Their appearance and their nature are not their fault but the result of an ancient sin, for which they and their children and their children’s children will always be held accountable.
        \n 
        \n Infernal Bloodline
        \n
        \n Tieflings are derived from human bloodlines, and in the broadest possible sense, they still look human. However, their infernal heritage has left a clear imprint on their appearance. Tieflings have large horns that take any of a variety of shapes: some have curling horns like a ram, others have straight and tall horns like a gazelle’s, and some spiral upward like an antelopes’ horns. They have thick tails, four to five feet long, which lash or coil around their legs when they get upset or nervous. Their canine teeth are sharply pointed, and their eyes are solid colors—black, red, white, silver, or gold—with no visible sclera or pupil. Their skin tones cover the full range of human coloration, but also include various shades of red. Their hair, cascading down from behind their horns, is usually dark, from black or brown to dark red, blue, or purple.
        \n
        \n Self-Reliant and Suspicious
        \n
        \n Tieflings subsist in small minorities found mostly in human cities or towns, often in the roughest quarters of those places, where they grow up to be swindlers, thieves, or crime lords. Sometimes they live among other minority populations in enclaves where they are treated with more respect.
        \n
        \n Lacking a homeland, tieflings know that they have to make their own way in the world and that they have to be strong to survive. They are not quick to trust anyone who claims to be a friend, but when a tiefling’s companions demonstrate that they trust him or her, the tiefling learns to extend the same trust to them. And once a tiefling gives someone loyalty, the tiefling is a firm friend or ally for life.
        \n
        \n Tiefling Names
        \n
        \n Tiefling names fall into three broad categories. Tieflings born into another culture typically have names reflective of that culture. Some have names derived from the Infernal language, passed down through generations, that reflect their fiendish heritage. And some younger tieflings, striving to find a place in the world, adopt a name that signifies a virtue or other concept and then try to embody that concept. For some, the chosen name is a noble quest. For others, it’s a grim destiny.
        \n
        \n Male Infernal Names: Akmenos, Amnon, Barakas, Damakos, Ekemon, Iados, Kairon, Leucis, Melech, Mordai, Morthos, Pelaios, Skamos, Therai
        \n
        \n Female Infernal Names: Akta, Anakis, Bryseis, Criella, Damaia, Ea, Kallista, Lerissa, Makaria, Nemeia, Orianna, Phelaia, Rieta
        \n 
        \n “Virtue” Names: Art, Carrion, Chant, Creed, Despair, Excellence, Fear, Glory, Hope, Ideal, Music, Nowhere, Open, Poetry, Quest, Random, Reverence, Sorrow, Temerity, Torment, Weary',
        -- race_traits
        E'Tiefling Traits
        \n
        \n Tieflings share certain racial traits as a result of their infernal descent.
        \n
        \n Creature Type
        \n You are a humanoid. You determine your appearance and whether you resemble any of your kin.
        \n 
        \n Size
        \n Tieflings are about the same size and build as humans. Your size is Medium.
        \n 
        \n Speed
        \n Your base walking speed is 30 feet.
        \n 
        \n Ability Score Increase
        \n Your Intelligence score increases by 1, and your Charisma score increases by 2.
        \n 
        \n Darkvision
        \n Thanks to your infernal heritage, you have superior vision in dark and dim conditions. You can see in dim light within 60 feet of you as if it were bright light, and in darkness as if it were dim light. You can’t discern color in darkness, only shades of gray.
        \n
        \n Hellish Resistance
        \n You have resistance to fire damage.
        \n
        \n Infernal Legacy
        \n You know the thaumaturgy cantrip. When you reach 3rd level, you can cast the hellish rebuke spell as a 2nd-level spell once with this trait and regain the ability to do so when you finish a long rest. When you reach 5th level, you can cast the darkness spell once with this trait and regain the ability to do so when you finish a long rest. Charisma is your spellcasting ability for these spells.
        \n 
        \n Languages
        \n You can speak, read, and write Common and Infernal.',
        -- asi_stat_name
        --ARRAY['Str', 'Dex', 'Con', 'Int', 'Wis', 'Cha'],
        'Cha',
        -- asi_stat_bonus
        2,
        -- size
        'Small or Medium',
        -- speed
        30,
        -- sub_race
        'N/A',
        -- sr_asi_name
        'Int',
        -- sr_asi
        1,
        -- sr_spec
        null
    ),
    (
        -- race_id
        04,
        -- race_name
        'Dragonborn', 
        -- race_details
        E'Born of dragons, as their name proclaims, the dragonborn walk proudly through a world that greets them with fearful incomprehension. Shaped by draconic gods or the dragons themselves, dragonborn originally hatched from dragon eggs as a unique race, combining the best attributes of dragons and humanoids. Some dragonborn are faithful servants to true dragons, others form the ranks of soldiers in great wars, and still others find themselves adrift, with no clear calling in life.
        \n 
        \n Proud Dragon Kin
        \n
        \n Dragonborn look very much like dragons standing erect in humanoid form, though they lack wings or a tail. The first dragonborn had scales of vibrant hues matching the colors of their dragon kin, but generations of interbreeding have created a more uniform appearance. Their small, fine scales are usually brass or bronze in color, sometimes ranging to scarlet, rust, gold, or copper-green. They are tall and strongly built, often standing close to 6½ feet tall and weighing 300 pounds or more. Their hands and feet are strong, talonlike claws with three fingers and a thumb on each hand.
        \n
        \n The blood of a particular type of dragon runs very strong through some dragonborn clans. These dragonborn often boast scales that more closely match those of their dragon ancestor—bright red, green, blue, or white, lustrous black, or gleaming metallic gold, silver, brass, copper, or bronze.
        \n
        \n Self-Sufficient Clans
        \n
        \n To any dragonborn, the clan is more important than life itself. Dragonborn owe their devotion and respect to their clan above all else, even the gods. Each dragonborn’s conduct reflects on the honor of his or her clan, and bringing dishonor to the clan can result in expulsion and exile. Each dragonborn knows his or her station and duties within the clan, and honor demands maintaining the bounds of that position.
        \n
        \n A continual drive for self-improvement reflects the self-sufficiency of the race as a whole. Dragonborn value skill and excellence in all endeavors. They hate to fail, and they push themselves to extreme efforts before they give up on something. A dragonborn holds mastery of a particular skill as a lifetime goal. Members of other races who share the same commitment find it easy to earn the respect of a dragonborn.
        \n
        \n Though all dragonborn strive to be self-sufficient, they recognize that help is sometimes needed in difficult situations. But the best source for such help is the clan, and when a clan needs help, it turns to another dragonborn clan before seeking aid from other races—or even from the gods.
        \n
        \n Dragonborn Names
        \n
        \n Dragonborn have personal names given at birth, but they put their clan names first as a mark of honor. A childhood name or nickname is often used among clutchmates as a descriptive term or a term of endearment. The name might recall an event or center on a habit..
        \n
        \n Male Names: Arjhan, Balasar, Bharash, Donaar, Ghesh, Heskan, Kriv, Medrash, Mehen, Nadarr, Pandjed, Patrin, Rhogar, Shamash, Shedinn, Tarhun, Torinn
        \n
        \n Female Names: Akra, Biri, Daar, Farideh, Harann, Havilar, Jheri, Kava, Korinn, Mishann, Nala, Perra, Raiann, Sora, Surina, Thava, Uadjit
        \n 
        \n Childhood Names: Climber, Earbender, Leaper, Pious, Shieldbiter, Zealous
        \n
        \n Clan Names: Clethtinthiallor, Daardendrian, Delmirev, Drachedandion, Fenkenkabradon, Kepeshkmolik, Kerrhylon, Kimbatuul, Linxakasendalor, Myastan, Nemmonis, Norixius, Ophinshtalajiir, Prexijandilin, Shestendeliath, Turnuroth, Verthisathurgiesh, Yarjerit',
        -- race_traits
        -- "Draconic Ancestry trait needs a table to go with it when rendered"
        E'Dragonborn Traits
        \n
        \n Your draconic heritage manifests in a variety of traits you share with other dragonborn.
        \n
        \n Creature Type
        \n You are a humanoid. You determine your appearance and whether you resemble any of your kin.
        \n 
        \n Size
        \n Dragonborn are taller and heavier than humans, standing well over 6 feet tall and averaging almost 250 pounds. Your size is Medium.
        \n 
        \n Speed
        \n Your base walking speed is 30 feet.
        \n 
        \n Ability Score Increase
        \n Your Strength score increases by 2, and your Charisma score increases by 1.
        \n 
        \n Draconic Ancestry
        \n You have draconic ancestry. Choose one type of dragon from the Draconic Ancestry table. Your breath weapon and damage resistance are determined by the dragon type, as shown in the table. 
        \n
        \n Breath Weapon
        \n You can use your action to exhale destructive energy. Your draconic ancestry determines the size, shape, and damage type of the exhalation. When you use your breath weapon, each creature in the area of the exhalation must make a saving throw, the type of which is determined by your draconic ancestry. The DC for this saving throw equals 8 + your Constitution modifier + your proficiency bonus. A creature takes 2d6 damage on a failed save, and half as much damage on a successful one. The damage increases to 3d6 at 6th level, 4d6 at 11th level, and 5d6 at 16th level. After you use your breath weapon, you can’t use it again until you complete a short or long rest. 
        \n
        \n Damage Resistance
        \n You have resistance to the damage type associated with your draconic ancestry.
        \n
        \n Languages
        \n You can speak, read, and write Common and Draconic. Draconic is thought to be one of the oldest languages and is often used in the study of magic. The language sounds harsh to most other creatures and includes numerous hard consonants and sibilants.',
        -- asi_stat_name
        --ARRAY['Str', 'Dex', 'Con', 'Int', 'Wis', 'Cha'],
        'Str',
        -- asi_stat_bonus
        2,
        -- size
        'Medium',
        -- speed
        30,
        -- sub_race
        'N/A',
        -- sr_asi_name
        'Cha',
        -- sr_asi
        1,
        -- sr_spec
        null
    ),
    (
        -- race_id
        05,
        -- race_name
        'Firbolg', 
        -- race_details
        E'Distant cousins of giants, the first firbolgs wandered the primeval forests of the multiverse, and the magic of those forests entwined itself with the firbolgs’ souls. Centuries later, that magic still thrums inside a firbolg, even one who has never lived under the boughs of a great forest.
        \n
        \n A firbolg’s magic is an obscuring sort, which allowed their ancestors to pass through a forest without disturbing it. So deep is the connection between a firbolg and the wild places of the world that they can communicate with flora and fauna.
        \n
        \n Firbolgs can live up to 500 years.',
        -- race_traits
        E'Firbolg Traits
        \n
        \n As a firbolg, you have the following racial traits.
        \n
        \n Creature Type
        \n You are a humanoid. You determine your appearance and whether you resemble any of your kin.
        \n 
        \n Size
        \n You are Medium.
        \n 
        \n Speed
        \n Your base walking speed is 30 feet.
        \n 
        \n Ability Score Increase
        \n Your Wisdom score increases by 2, and your Strength score increases by 1.
        \n 
        \n Firbolg Magic
        \n You can cast the detect magic and disguise self spells with this trait. When you use this version of disguise self, you can seem up to 3 feet shorter or taller. Once you cast either of these spells with this trait, you can’t cast that spell with it again until you finish a long rest. You can also cast these spells using any spell slots you have.
        \n
        \n Intelligence, Wisdom, or Charisma is your spellcasting ability for these spells when you cast them with this trait (choose when you select this race).
        \n
        \n Hidden Step
        \n As a bonus action, you can magically turn invisible until the start of your next turn or until you attack, make a damage roll, or force someone to make a saving throw. You can use this trait a number of times equal to your proficiency bonus, and you regain all expended uses when you finish a long rest. 
        \n
        \n Powerful Build
        \n You count as one size larger when determining your carrying capacity and the weight you can push, drag, or lift.
        \n
        \n Speech of Beast and Leaf
        \n You have the ability to communicate in a limited manner with Beasts, Plants, and vegetation. They can understand the meaning of your words, though you have no special ability to understand them in return. You have advantage on all Charisma checks you make to influence them.
        \n
        \n Languages
        \n Your character can speak, read, and write Common and one other language that you and your DM agree is appropriate for the character.',
        -- asi_stat_name
        --ARRAY['Str', 'Dex', 'Con', 'Int', 'Wis', 'Cha'],
        'Wis',
        -- asi_stat_bonus
        2,
        -- size
        'Medium',
        -- speed
        30,
        -- sub_race
        'N/A',
        -- sr_asi_name
        'Str',
        -- sr_asi
        1,
        -- sr_spec
        null
    ),
    (
        -- race_id
        06,
        -- race_name
        'Halfling', 
        -- race_details
        E'The comforts of home are the goals of most halflings’ lives: a place to settle in peace and quiet, far from marauding monsters and clashing armies; a blazing fire and a generous meal; fine drink and fine conversation. Though some halflings live out their days in remote agricultural communities, others form nomadic bands that travel constantly, lured by the open road and the wide horizon to discover the wonders of new lands and peoples. But even these wanderers love peace, food, hearth, and home, though home might be a wagon jostling along a dirt road or a raft floating downriver.
        \n
        \n Small and Practical
        \n
        \n The diminutive halflings survive in a world full of larger creatures by avoiding notice or, barring that, avoiding offense. Standing about 3 feet tall, they appear relatively harmless and so have managed to survive for centuries in the shadow of empires and on the edges of wars and political strife. They are inclined to be stout, weighing between 40 and 45 pounds.
        \n
        \n Halflings’ skin ranges from tan to pale with a ruddy cast, and their hair is usually brown or sandy brown and wavy. They have brown or hazel eyes. Halfling men often sport long sideburns, but beards are rare among them and mustaches even more so. They like to wear simple, comfortable, and practical clothes, favoring bright colors.
        \n
        \n Halfling practicality extends beyond their clothing. They’re concerned with basic needs and simple pleasures and have little use for ostentation. Even the wealthiest of halflings keep their treasures locked in a cellar rather than on display for all to see. They have a knack for finding the most straightforward solution to a problem, and have little patience for dithering.
        \n
        \n Kind and Curious
        \n Halflings are an affable and cheerful people. They cherish the bonds of family and friendship as well as the comforts of hearth and home, harboring few dreams of gold or glory. Even adventurers among them usually venture into the world for reasons of community, friendship, wanderlust, or curiosity. They love discovering new things, even simple things, such as an exotic food or an unfamiliar style of clothing.
        \n
        \n Halflings are easily moved to pity and hate to see any living thing suffer. They are generous, happily sharing what they have even in lean times.
        \n
        \n Blend into the Crowd
        \n Halflings are adept at fitting into a community of humans, dwarves, or elves, making themselves valuable and welcome. The combination of their inherent stealth and their unassuming nature helps halflings to avoid unwanted attention.
        \n
        \n Halflings work readily with others, and they are loyal to their friends, whether halfling or otherwise. They can display remarkable ferocity when their friends, families, or communities are threatened.
        \n
        \n Pastoral Pleasantries
        \n Most halflings live in small, peaceful communities with large farms and well-kept groves. They rarely build kingdoms of their own or even hold much land beyond their quiet shires. They typically don’t recognize any sort of halfling nobility or royalty, instead looking to family elders to guide them. Families preserve their traditional ways despite the rise and fall of empires.
        \n
        \n Many halflings live among other races, where the halflings’ hard work and loyal outlook offer them abundant rewards and creature comforts. Some halfling communities travel as a way of life, driving wagons or guiding boats from place to place and maintaining no permanent home
        \n
        \n Exploring Opportunities
        \n Halflings usually set out on the adventurer’s path to defend their communities, support their friends, or explore a wide and wonder-filled world. For them, adventuring is less a career than an opportunity or sometimes a necessity.
        \n
        \n Halfling Names
        \n A halfling has a given name, a family name, and possibly a nickname. Family names are often nicknames that stuck so tenaciously they have been passed down through the generations.
        \n
        \n Male Names: Alton, Ander, Cade, Corrin, Eldon, Errich, Finnan, Garret, Lindal, Lyle, Merric, Milo, Osborn, Perrin, Reed, Roscoe, Wellby
        \n
        \n Female Names: Andry, Bree, Callie, Cora, Euphemia, Jillian, Kithri, Lavinia, Lidda, Merla, Nedda, Paela, Portia, Seraphina, Shaena, Trym, Vani, Verna
        \n Family Names: Brushgather, Goodbarrel, Greenbottle, High-hill, Hilltopple, Leagallow, Tealeaf, Thorngage, Tosscobble, Underbough
        \n
        \n Subrace
        \n The two main kinds of halfling, lightfoot and stout, are more like closely related families than true subraces. Choose one of these subraces or one from another source.',
        -- race_traits
        E'Halfling Traits
        \n
        \n Your halfling character has a number of traits in common with all other halflings
        \n
        \n Creature Type
        \n You are a humanoid. You determine your appearance and whether you resemble any of your kin.
        \n 
        \n Size
        \n Halflings average about 3 feet tall and weigh about 40 pounds. Your size is Small.
        \n 
        \n Speed
        \n Your base walking speed is 25 feet.
        \n 
        \n Ability Score Increase
        \n Your Dexterity score increases by 2.
        \n 
        \n Lucky
        \n When you roll a 1 on the d20 for an attack roll, ability check, or saving throw, you can reroll the die and must use the new roll.
        \n
        \n Brave
        \n You have advantage on saving throws against being frightened.
        \n
        \n Halfling Nimbleness
        \n You can move through the space of any creature that is of a size larger than yours.
        \n
        \n Languages
        \n You can speak, read, and write Common and Halfling. The Halfling language isn’t secret, but halflings are loath to share it with others. They write very little, so they don’t have a rich body of literature. Their oral tradition, however, is very strong. Almost all halflings speak Common to converse with the people in whose lands they dwell or through which they are traveling.',
        -- asi_stat_name
        --ARRAY['Str', 'Dex', 'Con', 'Int', 'Wis', 'Cha'],
        'Dex',
        -- asi_stat_bonus
        2,
        -- size
        'Small',
        -- speed
        25,
        -- sub_race
        'Lightfoot',
        -- sr_asi_name
        'Cha',
        -- sr_asi
        1,
        -- sr_spec
        null
    );