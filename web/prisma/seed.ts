import "dotenv/config";
import { PrismaClient, Prisma } from '../generated/prisma/client';
import { PrismaBetterSqlite3 } from "@prisma/adapter-better-sqlite3";

const adapter = new PrismaBetterSqlite3({
  url: process.env.DATABASE_URL ?? "",
});

const prisma = new PrismaClient({ adapter });

const partTypeData: Prisma.PartTypeCreateInput[] = [
  {
    name: "Electric Guitar Strings (6)",
    description: "A pack of 6 electric guitar strings.",
  },
];

const maintenanceTypeData: Prisma.MaintenanceTypeCreateInput[] = [
  {
    name: "Change Strings",
    description: "Replace the strings to keep the guitar performing at its best.",
    schedule: new Date(0, 6),
    feature: {
      connect: { id: 1 },
    },
    parts: {
      connect: [
        { id: 1 },
      ],
    },
  },
];

const instrumentTypeData: Prisma.InstrumentTypeCreateInput[] = [
  {
    name: "Electric Guitar",
    features: {
      create: [
        {
          name: "6 Stringed Electric",
          description: "An electric guitar with 6 strings",
        },
      ],
    }
  },
];

const userData: Prisma.UserCreateInput[] = [
  {
    id: "testuserid",
    name: "Test User",
    email: "testuser@not-an-email.com",
    instruments: {
      create: [
        {
          id: "serial-12345-xz",
          name: "Some Guitar",
          insType: {
            connect: { id: 1 },
          },
          features: {
            connect: { id: 1 },
          },
        },
      ],
    },
    parts: {
      create: [
        {
          name: "Generic 6 String Set",
          description: "A generic set of strings for an electric guitar. 10 - 46.",
          number: 2,
          typeId: 1,
        },
      ],
    },
  }, {
    // This user can be used as the sole account for a self-hosted, single-user setup.
    id: process.env.SV_SINGLE_USER_ID ?? "singleuser",
    name: process.env.SV_SINGLE_USER_NAME ?? "Single User",
    email: process.env.SV_SINGLE_USER_EMAIL ?? "singleuser@not-an-email.com",
  },
];

const maintenanceData: Prisma.MaintenanceCreateInput[] = [
  {
    due: new Date(2027, 0, 0),
    mType: {
      connect: { id: 1 },
    },
    on: {
      connect: { id: "serial-12345-xz" },
    },
  },
];

export async function main() {
  
  for (const p of partTypeData) {
    try {
      await prisma.partType.create({ data: p });
    } catch (e: unknown) {
      console.log(e, ": Skipping");
    }
  }
  
  for (const i of instrumentTypeData) {
    try {
      await prisma.instrumentType.create({ data: i });
    } catch (e: unknown) {
      console.log(e, ": Skipping");
    }
  }
  
  for (const m of maintenanceTypeData) {
    try {
      await prisma.maintenanceType.create({ data: m });
    } catch (e: unknown) {
      console.log(e, ": Skipping");
    }
  }
  
  for (const u of userData) {
    try {
      await prisma.user.create({ data: u });
    } catch (e: unknown) {
      console.log(e, ": Skipping");
    }
  }
  
  for (const m of maintenanceData) {
    try {
      await prisma.maintenance.create({ data: m });
    } catch (e: unknown) {
      console.log(e, ": Skipping");
    }
  }
}

main();
