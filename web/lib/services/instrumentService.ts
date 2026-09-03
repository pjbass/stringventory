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
  serial: string, 
  name: string, 
  insType: string, 
  query: object): Promise<Instrument> {
    
    
  const owner = { connect: { id: userId } };
  const iType = await prisma.instrumentType.findFirst({
    where: {
      name: insType,
      ownerId: userId,
    },
  });
  
  const typeCon = iType !== null ? { connect: { id: iType.id } } :
    { create: { name: insType, owner } };
    
  return await prisma.instrument.create({
    ...query,
    data: {
      serial,
      name,
      owner,
      insType: typeCon,
    }
  });
}

export async function update(
  userId: string, 
  insId: number, 
  name: string, 
  query: object): Promise<Instrument> {
  
  return await prisma.instrument.update({
    ...query,
    where: {
      id: insId,
      ownerId: userId,
    },
    data: {
      name,
    }
  });
  
}

export async function rm(
  userId: string, 
  insId: number,
  query: object): Promise<Instrument> {
    
  return await prisma.instrument.delete({
    ...query,
    where: {
      id: insId,
      ownerId: userId,
    },
  });
}
