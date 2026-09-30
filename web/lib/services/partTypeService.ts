import prisma from '@/lib/prisma';
import type { PartType } from '@/generated/prisma/client';

export async function getAll(userId: string, query: object): Promise<PartType[]> {
  return await prisma.partType.findMany({
    ...query,
    where: {
      ownerId: userId,
    },
  });
}


export async function getById(userId: string, ptId: number, query: object): Promise<PartType | null> {
  return await prisma.partType.findUnique({
    ...query,
    where: {
      id: ptId,
      ownerId: userId,
    },
  });
}

export async function searchByName(userId: string, name: string, query: object): Promise<PartType[]> {
  return await prisma.partType.findMany({
    ...query,
    where: {
      name: {
        contains: name,
        ownerId: userId,
      },
    },
  });
}

export async function create(userId: string, name: string, description: string, query: object): Promise<PartType> {
  
  // Though technically name is not constrained in the DB as a unique value
  // (since it seems you can't do that and have Prisma create an implicit
  // join table), it should be a unique value. This should help to enforce it.
  const found = await prisma.partType.findFirst({ where: { name, ownerId: userId } })
  
  if (found) {
    throw new Error(`Part type ${name} already exists!`);
  }
  
  return await prisma.partType.create({
    ...query,
    data: {
      name,
      description,
      owner: { connect: { id: userId } },
    },
  });
}

export async function update(
  userId: string, 
  typeId: number, 
  name: string | null,
  description: string | null,
  query: object): Promise<PartType> {
  
  return await prisma.partType.update({
    ...query,
    where: {
      id: typeId,
      ownerId: userId,
    },
    data: {
      name,
      description,
    }
  });
  
}

export async function rm(
  userId: string, 
  typeId: number,
  query: object): Promise<PartType> {
    
  return await prisma.partType.delete({
    ...query,
    where: {
      id: typeId,
      ownerId: userId,
    },
  });
}
