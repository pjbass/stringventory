/*
  Warnings:

  - The primary key for the `Instrument` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to alter the column `id` on the `Instrument` table. The data in that column could be lost. The data in that column will be cast from `String` to `Int`.
  - You are about to alter the column `insId` on the `Maintenance` table. The data in that column could be lost. The data in that column will be cast from `String` to `Int`.
  - You are about to alter the column `B` on the `_FeatureToInstrument` table. The data in that column could be lost. The data in that column will be cast from `String` to `Int`.
  - Added the required column `ownerId` to the `Feature` table without a default value. This is not possible if the table is not empty.
  - Added the required column `serial` to the `Instrument` table without a default value. This is not possible if the table is not empty.
  - Added the required column `ownerId` to the `InstrumentType` table without a default value. This is not possible if the table is not empty.
  - Added the required column `ownerId` to the `Maintenance` table without a default value. This is not possible if the table is not empty.
  - Added the required column `ownerId` to the `MaintenanceType` table without a default value. This is not possible if the table is not empty.
  - Added the required column `ownerId` to the `PartType` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Feature" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    CONSTRAINT "Feature_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "new_Feature" ("description", "id", "name") SELECT "description", "id", "name" FROM "Feature";
DROP TABLE "Feature";
ALTER TABLE "new_Feature" RENAME TO "Feature";
CREATE TABLE "new_Instrument" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "serial" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "purchased" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "modified" DATETIME NOT NULL,
    "typeId" INTEGER NOT NULL,
    CONSTRAINT "Instrument_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "Instrument_typeId_fkey" FOREIGN KEY ("typeId") REFERENCES "InstrumentType" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Instrument" ("id", "modified", "name", "ownerId", "purchased", "typeId") SELECT "id", "modified", "name", "ownerId", "purchased", "typeId" FROM "Instrument";
DROP TABLE "Instrument";
ALTER TABLE "new_Instrument" RENAME TO "Instrument";
CREATE TABLE "new_InstrumentType" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    CONSTRAINT "InstrumentType_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "new_InstrumentType" ("id", "name") SELECT "id", "name" FROM "InstrumentType";
DROP TABLE "InstrumentType";
ALTER TABLE "new_InstrumentType" RENAME TO "InstrumentType";
CREATE TABLE "new_Maintenance" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "done" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "due" DATETIME,
    "typeId" INTEGER NOT NULL,
    "ownerId" TEXT NOT NULL,
    "insId" INTEGER NOT NULL,
    CONSTRAINT "Maintenance_typeId_fkey" FOREIGN KEY ("typeId") REFERENCES "MaintenanceType" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "Maintenance_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "Maintenance_insId_fkey" FOREIGN KEY ("insId") REFERENCES "Instrument" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "new_Maintenance" ("createdAt", "done", "due", "id", "insId", "typeId") SELECT "createdAt", "done", "due", "id", "insId", "typeId" FROM "Maintenance";
DROP TABLE "Maintenance";
ALTER TABLE "new_Maintenance" RENAME TO "Maintenance";
CREATE TABLE "new_MaintenanceType" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "schedule" DATETIME,
    "featureId" INTEGER NOT NULL,
    CONSTRAINT "MaintenanceType_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "MaintenanceType_featureId_fkey" FOREIGN KEY ("featureId") REFERENCES "Feature" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "new_MaintenanceType" ("description", "featureId", "id", "name", "schedule") SELECT "description", "featureId", "id", "name", "schedule" FROM "MaintenanceType";
DROP TABLE "MaintenanceType";
ALTER TABLE "new_MaintenanceType" RENAME TO "MaintenanceType";
CREATE TABLE "new_PartType" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    CONSTRAINT "PartType_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "new_PartType" ("description", "id", "name") SELECT "description", "id", "name" FROM "PartType";
DROP TABLE "PartType";
ALTER TABLE "new_PartType" RENAME TO "PartType";
CREATE TABLE "new__FeatureToInstrument" (
    "A" INTEGER NOT NULL,
    "B" INTEGER NOT NULL,
    CONSTRAINT "_FeatureToInstrument_A_fkey" FOREIGN KEY ("A") REFERENCES "Feature" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "_FeatureToInstrument_B_fkey" FOREIGN KEY ("B") REFERENCES "Instrument" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "new__FeatureToInstrument" ("A", "B") SELECT "A", "B" FROM "_FeatureToInstrument";
DROP TABLE "_FeatureToInstrument";
ALTER TABLE "new__FeatureToInstrument" RENAME TO "_FeatureToInstrument";
CREATE UNIQUE INDEX "_FeatureToInstrument_AB_unique" ON "_FeatureToInstrument"("A", "B");
CREATE INDEX "_FeatureToInstrument_B_index" ON "_FeatureToInstrument"("B");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
