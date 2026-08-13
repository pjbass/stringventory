import { getUserId, api401 } from '@/lib/auth';
import prisma from '@/lib/prisma';

export async function GET() {
  
  const uid = await getUserId();
  
  if (uid) {
    const inst = await prisma.instrument.findMany({
      where: {
        ownerId: uid,
      },
      include: {
        features: true,
        insType: true,
      },
    })
    
    return Response.json({ instruments: inst });
    
  } else {
    return api401();
  }
  
}

export async function POST(request: Request) {
  
  const uid = await getUserId();
  
  if (uid) {
    
    const {
      id, 
      name,
      typeId,
      insType,
    } = await request.json();
    
    const tid = typeId ? { connect: { id: typeId } } : undefined;
    const newType = insType ? { create: insType } : undefined;
    
    if (!newType && !tid) {
      return Response.json({ error: "No instrument type specified"}, { status: 400});
    } else {
      
      try {
        const ins = await prisma.instrument.create({
          data: {
            id,
            name,
            owner: { connect: { id: uid } },
            insType: newType || tid,
          }
        });
        
        return Response.json({ instrument: ins }, {status: 200});
        
      } catch (e: unknown) {
        return Response.json({ error: e }, {status: 500});
      }
      
    }
    
  } else {
    return api401();
  }
}
