import prisma from '@/lib/prisma';
import type { Feature } from '@/generated/prisma/client';

export async function getAll(userId: string, query: object): Promise<Feature[]> {
  return await prisma.feature.findMany({
    ...query,
    where: {
      ownerId: userId,
    },
  });
}


export async function getById(userId: string, ftId: string, query: object): Promise<Feature | null> {
  return await prisma.feature.findUnique({
    ...query,
    where: {
      id: ftId,
      ownerId: userId,
    },
  });
}

export async function searchByName(userId: string, name: string, query: object): Promise<Feature[]> {
  return await prisma.feature.findMany({
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
  query: object): Promise<Feature> {
    
    
  const owner = { connect: { id: userId } };
    
  return await prisma.feature.create({
    ...query,
    data: {
      name,
      description,
      owner,
    }
  });
}

export async function update(
  userId: string, 
  ftId: number, 
  name: string | null,
  description: string | null,
  query: object): Promise<Feature> {
  
  return await prisma.feature.update({
    ...query,
    where: {
      id: ftId,
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
  ftId: number,
  query: object): Promise<Feature> {
    
  return await prisma.feature.delete({
    ...query,
    where: {
      id: ftId,
      ownerId: userId,
    },
  });
}
