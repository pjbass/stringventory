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


export async function getById(userId: string, insId: number, query: object): Promise<InstrumentType | null> {
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
  // because of ownership (multiple users can have an "Electric Guitar" type),
  // it should be unique for each user.
  const found = await prisma.instrumentType.findFirst({ where: { name, ownerId: userId } })
  
  if (found) {
    throw new Error(`Instrument type ${name} already exists!`);
  }
  
  return await prisma.instrumentType.create({
    ...query,
    data: {
      name,
      owner: { connect: { id: userId } },
    },
  });
}

export async function update(
  userId: string, 
  typeId: number, 
  name: string, 
  query: object): Promise<InstrumentType> {
  
  return await prisma.instrumentType.update({
    ...query,
    where: {
      id: typeId,
      ownerId: userId,
    },
    data: {
      name,
    }
  });
  
}

export async function rm(
  userId: string, 
  typeId: number,
  query: object): Promise<InstrumentType> {
    
  return await prisma.instrumentType.delete({
    ...query,
    where: {
      id: typeId,
      ownerId: userId,
    },
  });
}
