-- CreateTable
CREATE TABLE "Instrument" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "purchased" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "modified" DATETIME NOT NULL,
    "typeId" INTEGER NOT NULL,
    CONSTRAINT "Instrument_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "user" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "Instrument_typeId_fkey" FOREIGN KEY ("typeId") REFERENCES "InstrumentType" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "InstrumentType" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL
);

-- CreateTable
CREATE TABLE "MaintenanceType" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "schedule" DATETIME,
    "featureId" INTEGER NOT NULL,
    CONSTRAINT "MaintenanceType_featureId_fkey" FOREIGN KEY ("featureId") REFERENCES "Feature" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Feature" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL
);

-- CreateTable
CREATE TABLE "Maintenance" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "done" DATETIME,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "due" DATETIME NOT NULL,
    "typeId" INTEGER NOT NULL,
    "insId" TEXT NOT NULL,
    CONSTRAINT "Maintenance_typeId_fkey" FOREIGN KEY ("typeId") REFERENCES "MaintenanceType" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "Maintenance_insId_fkey" FOREIGN KEY ("insId") REFERENCES "Instrument" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "PartType" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL
);

-- CreateTable
CREATE TABLE "Part" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "typeId" INTEGER NOT NULL,
    "number" INTEGER NOT NULL,
    CONSTRAINT "Part_typeId_fkey" FOREIGN KEY ("typeId") REFERENCES "PartType" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "_MaintenanceTypeToPartType" (
    "A" INTEGER NOT NULL,
    "B" INTEGER NOT NULL,
    CONSTRAINT "_MaintenanceTypeToPartType_A_fkey" FOREIGN KEY ("A") REFERENCES "MaintenanceType" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "_MaintenanceTypeToPartType_B_fkey" FOREIGN KEY ("B") REFERENCES "PartType" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "_FeatureToInstrument" (
    "A" INTEGER NOT NULL,
    "B" TEXT NOT NULL,
    CONSTRAINT "_FeatureToInstrument_A_fkey" FOREIGN KEY ("A") REFERENCES "Feature" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "_FeatureToInstrument_B_fkey" FOREIGN KEY ("B") REFERENCES "Instrument" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "_FeatureToInstrumentType" (
    "A" INTEGER NOT NULL,
    "B" INTEGER NOT NULL,
    CONSTRAINT "_FeatureToInstrumentType_A_fkey" FOREIGN KEY ("A") REFERENCES "Feature" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "_FeatureToInstrumentType_B_fkey" FOREIGN KEY ("B") REFERENCES "InstrumentType" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "_MaintenanceToPart" (
    "A" INTEGER NOT NULL,
    "B" INTEGER NOT NULL,
    CONSTRAINT "_MaintenanceToPart_A_fkey" FOREIGN KEY ("A") REFERENCES "Maintenance" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "_MaintenanceToPart_B_fkey" FOREIGN KEY ("B") REFERENCES "Part" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateIndex
CREATE UNIQUE INDEX "_MaintenanceTypeToPartType_AB_unique" ON "_MaintenanceTypeToPartType"("A", "B");

-- CreateIndex
CREATE INDEX "_MaintenanceTypeToPartType_B_index" ON "_MaintenanceTypeToPartType"("B");

-- CreateIndex
CREATE UNIQUE INDEX "_FeatureToInstrument_AB_unique" ON "_FeatureToInstrument"("A", "B");

-- CreateIndex
CREATE INDEX "_FeatureToInstrument_B_index" ON "_FeatureToInstrument"("B");

-- CreateIndex
CREATE UNIQUE INDEX "_FeatureToInstrumentType_AB_unique" ON "_FeatureToInstrumentType"("A", "B");

-- CreateIndex
CREATE INDEX "_FeatureToInstrumentType_B_index" ON "_FeatureToInstrumentType"("B");

-- CreateIndex
CREATE UNIQUE INDEX "_MaintenanceToPart_AB_unique" ON "_MaintenanceToPart"("A", "B");

-- CreateIndex
CREATE INDEX "_MaintenanceToPart_B_index" ON "_MaintenanceToPart"("B");
