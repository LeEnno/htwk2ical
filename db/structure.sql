CREATE TABLE "calendars" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "secret" varchar(255), "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "calendars_subjects" ("calendar_id" integer, "subject_id" integer);
CREATE TABLE "course_aliases" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "calendar_id" integer, "course_id" integer, "custom_name" varchar(255));
CREATE TABLE "courses" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(255), "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "courses_subjects" ("course_id" integer, "subject_id" integer);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "subjects" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "title" varchar(255), "cached_schedule" blob, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20120706152519');

INSERT INTO schema_migrations (version) VALUES ('20120706152928');

INSERT INTO schema_migrations (version) VALUES ('20120706153010');

INSERT INTO schema_migrations (version) VALUES ('20120716142823');

INSERT INTO schema_migrations (version) VALUES ('20120716143854');

INSERT INTO schema_migrations (version) VALUES ('20120716145457');

INSERT INTO schema_migrations (version) VALUES ('20120716152324');

INSERT INTO schema_migrations (version) VALUES ('20120716161825');

INSERT INTO schema_migrations (version) VALUES ('20120716162654');