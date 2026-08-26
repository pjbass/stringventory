import prisma from '@/lib/prisma';
import type { Instrument } from '@/generated/prisma/client';

export async function getAll(userId: string, query: object): Promise<Instrument[]> {
  return await prisma.instrument.findMany({
    ...query,
    where: {
      ownerId: userId,
    },
  });
}


export async function getById(userId: string, insId: string, query: object): Promise<Instrument | null> {
  return await prisma.instrument.findUnique({
    ...query,
    where: {
      id: insId,
      ownerId: userId,
    },
  });
}

export async function searchByName(userId: string, name: string, query: object): Promise<Instrument[]> {
  return await prisma.instrument.findMany({
    ...query,
    where: {
      ownerId: userId,
      name: {
        contains: name,
      },
    },
  });
}

export async function create(
  userId: string, 
  insId: string, 
  name: string, 
  insType: string, 
  query: object): Promise<Instrument> {
  
  const iType = await prisma.instrumentType.findFirst({
    where: {
      name: insType,
    },
  });
  
  const typeCon = iType !== null ? { connect: { id: iType.id } } :
    { create: { name: insType } };
    
  return await prisma.instrument.create({
    ...query,
    data: {
      id: insId,
      name,
      owner: { connect: { id: userId } },
      insType: typeCon,
    }
  });
}
