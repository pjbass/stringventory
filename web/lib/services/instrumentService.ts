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
  features: string[],
  query: object): Promise<Instrument> {
    
    
  const owner = { connect: { id: userId } };
  const iType = await prisma.instrumentType.findFirst({
    where: {
      name: insType,
      ownerId: userId,
    },
    include: {
      features: true,
    },
  });
  
  // This one is for existing features...
  const conF = [];
  
  // This one is for new features to create at the same time.
  const nF = [];
  
  for (const f of features) {
    const ft = await prisma.feature.findFirst({
      where: {
        ownerId: userId,
        name: f,
      },
    });

    if (ft) {
      conF.push({id: ft.id});
    } else {
      nF.push({name: f, description: "", owner});
    }
  }
  
  const typeCon = iType !== null ? { connect: { id: iType.id } } :
    { create: { name: insType, owner } };
    
  // Add default features for the instrument type.
  if (iType) {
    for (f of iType.features) {
      conF.push({id: f.id});
    }
  }
    
  return await prisma.instrument.create({
    ...query,
    data: {
      serial,
      name,
      owner,
      insType: typeCon,
      features: {
        connect: conF,
        create: nF,
      },
    },
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
