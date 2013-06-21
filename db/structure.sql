CREATE TABLE "cornbowlers" ("id" binary(16) PRIMARY KEY, "name" varchar(255), "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "frames" ("id" binary(16) PRIMARY KEY, "game_id" binary(16), "cornbowler_id" binary(16), "number" integer, "frame_score" integer, "accumulated_score" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "games" ("id" binary(16) PRIMARY KEY, "name" varchar(255), "start_time" datetime, "end_time" datetime, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "matchups" ("id" binary(16) PRIMARY KEY, "game_id" binary(16), "cornbowler_id" binary(16), "order_rank" integer, "final_score" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "standings" ("id" binary(16) PRIMARY KEY, "cornbowler_id" binary(16), "wins" integer DEFAULT 0, "losses" integer DEFAULT 0, "ties" integer DEFAULT 0, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "tosses" ("id" binary(16) PRIMARY KEY, "frame_id" binary(16), "number" integer, "score" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE INDEX "index_frames_on_cornbowler_id" ON "frames" ("cornbowler_id");
CREATE INDEX "index_frames_on_game_id" ON "frames" ("game_id");
CREATE UNIQUE INDEX "index_frames_on_game_id_and_cornbowler_id_and_number" ON "frames" ("game_id", "cornbowler_id", "number");
CREATE INDEX "index_matchups_on_cornbowler_id" ON "matchups" ("cornbowler_id");
CREATE UNIQUE INDEX "index_matchups_on_game_id_and_cornbowler_id" ON "matchups" ("game_id", "cornbowler_id");
CREATE UNIQUE INDEX "index_matchups_on_game_id_and_order_rank" ON "matchups" ("game_id", "order_rank");
CREATE INDEX "index_standings_on_cornbowler_id" ON "standings" ("cornbowler_id");
CREATE UNIQUE INDEX "index_tosses_on_frame_id_and_number" ON "tosses" ("frame_id", "number");
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20130507213208');

INSERT INTO schema_migrations (version) VALUES ('20130507213223');

INSERT INTO schema_migrations (version) VALUES ('20130507213231');

INSERT INTO schema_migrations (version) VALUES ('20130507213240');

INSERT INTO schema_migrations (version) VALUES ('20130507213246');

INSERT INTO schema_migrations (version) VALUES ('20130521205801');