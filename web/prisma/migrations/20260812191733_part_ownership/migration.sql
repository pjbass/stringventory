/*
  Warnings:

  - Added the required column `ownerId` to the `Part` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Maintenance" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "done" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "due" DATETIME,
    "typeId" INTEGER NOT NULL,
    "insId" TEXT NOT NULL,
    CONSTRAINT "Maintenance_typeId_fkey" FOREIGN KEY ("typeId") REFERENCES "MaintenanceType" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "Maintenance_insId_fkey" FOREIGN KEY ("insId") REFERENCES "Instrument" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "new_Maintenance" ("createdAt", "done", "due", "id", "insId", "typeId") SELECT "createdAt", "done", "due", "id", "insId", "typeId" FROM "Maintenance";
DROP TABLE "Maintenance";
ALTER TABLE "new_Maintenance" RENAME TO "Maintenance";
CREATE TABLE "new_Part" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "typeId" INTEGER NOT NULL,
    "number" INTEGER NOT NULL,
    "ownerId" TEXT NOT NULL,
    CONSTRAINT "Part_typeId_fkey" FOREIGN KEY ("typeId") REFERENCES "PartType" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "Part_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "new_Part" ("description", "id", "name", "number", "typeId") SELECT "description", "id", "name", "number", "typeId" FROM "Part";
DROP TABLE "Part";
ALTER TABLE "new_Part" RENAME TO "Part";
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
