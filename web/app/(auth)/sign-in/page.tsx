'use client';

import { signIn } from '@/lib/auth-client';
import Card from '@mui/material/Card';
import CardActions from '@mui/material/CardActions';
import CardContent from '@mui/material/CardContent';
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';
import Typography from '@mui/material/Typography';
import Stack from '@mui/material/Stack';
import Alert from '@mui/material/Alert';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';


export default function SignIn() {
  
  const [error, setError] = useState("");
  const router = useRouter();
  
  async function handleSubmit(e: React.SubmitEvent<HTMLFormElement>) {
    e.preventDefault();
    setError("");
    
    const { email, password } = e.target as typeof e.target & {
      email: { value: string };
      password: { value: string };
    };
    
    const data = await signIn.email({
      email: email.value,
      password: password.value,
    });
    
    if (data.error) {
      setError(data.error.message || "An error has occured");
    } else {
      router.push("/");
    }
  }
  
  return (
    <Card variant="outlined">
      <CardContent>
      
        <Typography gutterBottom variant="h2" component="div">
          Sign In
        </Typography>
        
        <Stack spacing={2} component="form" onSubmit={handleSubmit}>
          <TextField 
            label="Email" 
            type="email"
            id="email" 
            name="email" />
          
          <TextField 
            label="Password" 
            type="password"
            id="password"
            name="password" />
            
          <Button size="small" type="submit">Sign In</Button>
        </Stack>
        
      </CardContent>
      <CardActions>
        <Stack spacing={1}>
          <Typography>
            Need an account?
            <Button 
              size="small"
              component={Link}
              href="/sign-up">Sign Up</Button>
          </Typography>
          {error &&
            <Alert severity="error">{ error }</Alert>}
        </Stack>
      </CardActions>
    </Card>
  );
}
