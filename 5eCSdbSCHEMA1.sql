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
