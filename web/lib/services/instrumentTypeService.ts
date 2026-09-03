import prisma from '@/lib/prisma';
import type { InstrumentType } from '@/generated/prisma/client';

export async function getAll(userId: string, query: object): Promise<InstrumentType[]> {
  return await prisma.instrumentType.findMany({
    ...query,
    where: {
      ownerId: userId,
    },
  });
}


export async function getById(userId: string, insId: string, query: object): Promise<InstrumentType | null> {
  return await prisma.instrumentType.findUnique({
    ...query,
    where: {
      id: insId,
      ownerId: userId,
    },
  });
}

export async function searchByName(userId: string, name: string, query: object): Promise<InstrumentType[]> {
  return await prisma.instrumentType.findMany({
    ...query,
    where: {
      name: {
        contains: name,
        ownerId: userId,
      },
    },
  });
}

export async function create(userId: string, name: string, query: object): Promise<InstrumentType> {
  
  // Though technically name is not constrained in the DB as a unique value
  // (since it seems you can't do that and have Prisma create an implicit
  // join table), it should be a unique value. This should help to enforce it.
  const found = await prisma.instrumentType.findFirst({ where: { name, ownerId: userId } })
  
  if (found) {
    throw new Error(`Instrument type ${name} already exists!`);
  }
  
  return await prisma.instrumentType.create({
    ...query,
    data: {
      name,
      owner: { connect: { id: ownerId } },
    },
  });
}
