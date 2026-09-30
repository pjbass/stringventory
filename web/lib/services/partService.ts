import prisma from '@/lib/prisma';
import type { Part } from '@/generated/prisma/client';

export async function getAll(userId: string, query: object): Promise<Part[]> {
  return await prisma.part.findMany({
    ...query,
    where: {
      ownerId: userId,
    },
  });
}


export async function getById(userId: string, ptId: number, query: object): Promise<Part | null> {
  return await prisma.part.findUnique({
    ...query,
    where: {
      id: ptId,
      ownerId: userId,
    },
  });
}

export async function searchByName(userId: string, name: string, query: object): Promise<Part[]> {
  return await prisma.part.findMany({
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
  name: string, 
  description: string,
  number: number,
  ptType: string,
  query: object): Promise<Part> {
    
    
  const owner = { connect: { id: userId } };
  const pType = await prisma.partType.findFirst({
    where: {
      name: ptType,
      ownerId: userId,
    },
  });
  
  const typeCon = pType !== null ? { connect: { id: pType.id } } :
    { create: { name: ptType, owner } };
    
  return await prisma.part.create({
    ...query,
    data: {
      name,
      description,
      number,
      owner,
      partType: typeCon,
    },
  });
}

export async function update(
  userId: string, 
  ptId: number, 
  name: string | null,
  number: number | null,
  description: string | null,
  query: object): Promise<Part> {
  
  return await prisma.part.update({
    ...query,
    where: {
      id: ptId,
      ownerId: userId,
    },
    data: {
      name,
      number,
      description,
    }
  });
  
}

export async function rm(
  userId: string, 
  ptId: number,
  query: object): Promise<Part> {
    
  return await prisma.part.delete({
    ...query,
    where: {
      id: ptId,
      ownerId: userId,
    },
  });
}
