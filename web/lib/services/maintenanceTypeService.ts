import prisma from '@/lib/prisma';
import type { MaintenanceType } from '@/generated/prisma/client';

export async function getAll(userId: string, query: object): Promise<MaintenanceType[]> {
  return await prisma.maintenanceType.findMany({
    ...query,
    where: {
      ownerId: userId,
    },
  });
}


export async function getById(userId: string, mtId: number, query: object): Promise<MaintenanceType | null> {
  return await prisma.maintenanceType.findUnique({
    ...query,
    where: {
      id: mtId,
      ownerId: userId,
    },
  });
}

export async function searchByName(userId: string, name: string, query: object): Promise<MaintenanceType[]> {
  return await prisma.maintenanceType.findMany({
    ...query,
    where: {
      name: {
        contains: name,
      },
      ownerId: userId,
    },
  });
}

export async function create(
  userId: string, 
  name: string, 
  description: string,
  schedule: Date | null,
  feature: string,
  query: object): Promise<MaintenanceType> {
  
  // Though technically name is not constrained in the DB as a unique value
  // (since it seems you can't do that and have Prisma create an implicit
  // join table), it should be a unique value. This should help to enforce it.
  const found = await prisma.maintenanceType.findFirst({ where: { name, ownerId: userId } });
  
  if (found) {
    throw new Error(`Maintenance type ${name} already exists!`);
  }
  
  const ft = await prisma.feature.findFirst({ where: { name: feature, ownerId: userId } });
  
  if (!ft) {
    throw new Error(`Feature ${feature} not found!`);
  }
  
  return await prisma.maintenanceType.create({
    ...query,
    data: {
      name,
      description,
      schedule,
      feature: { connect: { id: ft.id } },
      owner: { connect: { id: userId } },
    },
  });
}

export async function update(
  userId: string, 
  typeId: number, 
  name: string | undefined,
  description: string | undefined,
  schedule: Date | null | undefined,
  query: object): Promise<MaintenanceType> {
  
  return await prisma.maintenanceType.update({
    ...query,
    where: {
      id: typeId,
      ownerId: userId,
    },
    data: {
      name,
      description,
      schedule,
    }
  });
  
}

export async function rm(
  userId: string, 
  typeId: number,
  query: object): Promise<MaintenanceType> {
    
  return await prisma.maintenanceType.delete({
    ...query,
    where: {
      id: typeId,
      ownerId: userId,
    },
  });
}
