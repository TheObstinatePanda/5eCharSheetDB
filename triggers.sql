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