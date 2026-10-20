import prisma from '@/lib/prisma';
import type { Maintenance } from '@/generated/prisma/client';

export async function getAll(userId: string, query: object): Promise<Maintenance[]> {
  return await prisma.maintenance.findMany({
    ...query,
    where: {
      ownerId: userId,
    },
  });
}


export async function getById(userId: string, mtId: number, query: object): Promise<Maintenance | null> {
  return await prisma.maintenance.findUnique({
    ...query,
    where: {
      id: mtId,
      ownerId: userId,
    },
  });
}

export async function create(
  userId: string, 
  ins: string,
  mtType: string,
  done: Date | null,
  due: Date | null,
  parts: string[],
  query: object): Promise<Maintenance> {
    
    
  const instr = await prisma.instrument.findFirst({
    where: {
      name: ins,
      ownerId: userId,
    }
  });
  
  if (!instr) {
    throw new Error(`Instrument ${ins} does not exist.`);
  }
  
  const consumed = parts ? { connect: parts.map( async (p) => {
      const part = await prisma.part.findFirst({
        where: {
          name: p,
          ownerId: userId,
        }
      });
      
      if (part) {
        return {id: part.id};
      } else {
        throw new Error(`Part ${p} does not exist.`);
      }
    }),
  } : undefined;
    
  const owner = { connect: { id: userId } };
  const mType = await prisma.maintenanceType.findFirst({
    where: {
      name: mtType,
      ownerId: userId,
    },
  });
  
  if (!mType) {
    throw new Error(`Maintenance type ${mtType} does not exist!`);
  }
    
  return await prisma.maintenance.create({
    ...query,
    data: {
      owner,
      mType: { connect: { id: mType.id } },
      done,
      due,
      on: { connect: { id: instr.id } },
      consumed,
    },
  });
}

export async function update(
  userId: string, 
  mtId: number, 
  done: Date | null,
  due: Date | null,
  parts: string[],
  query: object): Promise<Maintenance> {
    
  const consumed = parts ? { connect: parts.map( async (p) => {
      const part = await prisma.part.findFirst({
        where: {
          name: p,
          ownerId: userId,
        }
      });
      
      if (part) {
        return {id: part.id};
      } else {
        throw new Error(`Part ${p} does not exist.`);
      }
    }),
  } : undefined;
  
  return await prisma.maintenance.update({
    ...query,
    where: {
      id: mtId,
      ownerId: userId,
    },
    data: {
      done,
      due,
      consumed,
    }
  });
  
}

export async function rm(
  userId: string, 
  mtId: number,
  query: object): Promise<Maintenance> {
    
  return await prisma.maintenance.delete({
    ...query,
    where: {
      id: mtId,
      ownerId: userId,
    },
  });
}
