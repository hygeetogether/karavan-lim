# Render Deployment Guide

Complete step-by-step guide to deploy Karaban CaravanShare to Render.

## Prerequisites

- GitHub account
- Render account (free tier available)
- Git repository with your code

## Quick Start (5 Minutes)

### 1. Push Code to GitHub

```bash
git add .
git commit -m "Prepare for Render deployment"
git push origin main
```

### 2. Create Render Account

1. Go to [render.com](https://render.com)
2. Sign up with GitHub
3. Authorize Render to access your repositories

### 3. Deploy Using Blueprint (Recommended)

Render will automatically detect the `render.yaml` file and set up all services.

1. Click **"New"** → **"Blueprint"**
2. Connect your GitHub repository
3. Select the repository: `karaban`
4. Render will read `render.yaml` and show:
   - ✅ PostgreSQL Database: `karaban-db`
   - ✅ Backend Service: `karaban-backend`
   - ✅ Frontend Service: `karaban-frontend`
5. Click **"Apply"**

Render will:
- Create PostgreSQL database
- Deploy backend service
- Deploy frontend service
- Set up environment variables automatically
- Run database migrations

**Deployment time:** ~5-10 minutes

### 4. Update Frontend Environment Variable

After deployment, update the frontend's backend URL:

1. Go to `karaban-frontend` service
2. Click **"Environment"**
3. Update `VITE_API_URL` to your backend URL:
   ```
   https://karaban-backend.onrender.com
   ```
4. Click **"Save Changes"** (will trigger redeploy)

### 5. Access Your Application

- **Frontend:** `https://karaban-frontend.onrender.com`
- **Backend API:** `https://karaban-backend.onrender.com`
- **Health Check:** `https://karaban-backend.onrender.com/health`

## Manual Deployment (Alternative)

If you prefer manual setup:

### Step 1: Create PostgreSQL Database

1. Click **"New"** → **"PostgreSQL"**
2. Name: `karaban-db`
3. Database: `caravanshare`
4. User: `karaban`
5. Plan: **Free**
6. Click **"Create Database"**

**Note:** Copy the **Internal Database URL** for the next step.

### Step 2: Deploy Backend

1. Click **"New"** → **"Web Service"**
2. Connect your repository
3. Configure:
   - **Name:** `karaban-backend`
   - **Environment:** Docker
   - **Dockerfile Path:** `./Dockerfile`
   - **Plan:** Free
4. Add Environment Variables:
   ```
   DATABASE_URL=<paste internal database URL>
   PORT=3001
   NODE_ENV=production
   CORS_ORIGIN=https://karaban-frontend.onrender.com
   ```
5. **Build Command:** (leave empty, Docker handles it)
6. **Start Command:** (leave empty, Docker handles it)
7. Click **"Create Web Service"**

### Step 3: Run Database Migrations

After backend deploys:

1. Go to backend service
2. Click **"Shell"**
3. Run:
   ```bash
   npx prisma migrate deploy
   npx prisma db seed
   ```

### Step 4: Deploy Frontend

1. Click **"New"** → **"Web Service"**
2. Connect your repository
3. Configure:
   - **Name:** `karaban-frontend`
   - **Environment:** Docker
   - **Dockerfile Path:** `./frontend/Dockerfile`
   - **Docker Context:** `./frontend`
   - **Plan:** Free
4. Add Environment Variable:
   ```
   VITE_API_URL=https://karaban-backend.onrender.com
   ```
5. Click **"Create Web Service"**

## Environment Variables Reference

### Backend (`karaban-backend`)

| Variable | Value | Source |
|----------|-------|--------|
| `DATABASE_URL` | Auto-generated | From database |
| `PORT` | `3001` | Manual |
| `NODE_ENV` | `production` | Manual |
| `CORS_ORIGIN` | `https://karaban-frontend.onrender.com` | Manual |

### Frontend (`karaban-frontend`)

| Variable | Value | Source |
|----------|-------|--------|
| `VITE_API_URL` | `https://karaban-backend.onrender.com` | Manual |

## Post-Deployment

### Verify Deployment

1. **Check Health:**
   ```bash
   curl https://karaban-backend.onrender.com/health
   ```

2. **Test API:**
   ```bash
   curl https://karaban-backend.onrender.com/api/caravans
   ```

3. **Open Frontend:**
   Visit `https://karaban-frontend.onrender.com`

### Monitor Services

1. Go to Render Dashboard
2. Check each service:
   - **Logs:** Real-time application logs
   - **Metrics:** CPU, Memory usage
   - **Events:** Deployment history

### Auto-Deploy on Git Push

Render automatically deploys when you push to `main`:

```bash
git add .
git commit -m "Update feature"
git push origin main
```

Render will:
1. Detect the push
2. Build new Docker images
3. Deploy with zero downtime
4. Rollback automatically if deployment fails

## Custom Domain (Optional)

### Add Custom Domain

1. Go to frontend service
2. Click **"Settings"** → **"Custom Domains"**
3. Click **"Add Custom Domain"**
4. Enter your domain: `www.karaban.com`
5. Add DNS records as shown by Render:
   ```
   CNAME www karaban-frontend.onrender.com
   ```

### SSL Certificate

Render automatically provisions SSL certificates via Let's Encrypt.

## Troubleshooting

### Backend Won't Start

**Check logs:**
1. Go to backend service
2. Click **"Logs"**
3. Look for errors

**Common issues:**
- Database connection failed → Check `DATABASE_URL`
- Port already in use → Ensure `PORT=3001`
- Prisma errors → Run migrations manually

### Frontend Shows 404

**Check:**
1. Nginx configuration is correct
2. `dist` folder was built
3. Check build logs for errors

### API Calls Fail (CORS)

**Fix:**
1. Update backend `CORS_ORIGIN` to match frontend URL
2. Redeploy backend

### Database Connection Issues

**Verify:**
1. Database is running (check database service)
2. `DATABASE_URL` is correct
3. Database accepts connections from backend

### Free Tier Limitations

**Free tier includes:**
- ✅ 750 hours/month (enough for 1 service 24/7)
- ✅ PostgreSQL with 1GB storage
- ✅ Auto-sleep after 15 minutes of inactivity
- ✅ Free SSL certificates

**Limitations:**
- ⏰ Services sleep after 15 min inactivity
- ⏰ First request after sleep: ~15 seconds
- 💾 1GB database storage
- 🌐 Shared IP address

**To prevent sleep (paid plan):**
- Upgrade to **Starter** plan ($7/month per service)
- Services stay awake 24/7
- Faster performance

## Monitoring & Maintenance

### Check Service Health

```bash
# Backend health
curl https://karaban-backend.onrender.com/health

# Frontend health
curl -I https://karaban-frontend.onrender.com
```

### View Logs

1. Render Dashboard → Service → **Logs**
2. Filter by:
   - Deploy logs
   - Runtime logs
   - Error logs

### Database Backups

Free tier: No automatic backups

**Manual backup:**
```bash
# From Render Shell
pg_dump $DATABASE_URL > backup.sql
```

**Paid plan:** Automatic daily backups

## Scaling (Paid Plans)

### Vertical Scaling

Upgrade instance size:
- **Starter:** $7/month - 0.5 GB RAM
- **Standard:** $25/month - 2 GB RAM
- **Pro:** $85/month - 4 GB RAM

### Horizontal Scaling

Add more instances (load balancing):
1. Service → **Settings** → **Scaling**
2. Increase instance count
3. Render handles load balancing

## Cost Estimation

### Free Tier (Recommended for Development)
- **Total:** $0/month
- Backend + Frontend + Database
- Perfect for learning and portfolios

### Production (Starter Plan)
- **Backend:** $7/month
- **Frontend:** $7/month
- **Database:** $7/month
- **Total:** $21/month

### Comparison with AWS EC2
| Feature | Render (Starter) | AWS EC2 (t2.micro) |
|---------|------------------|-------------------|
| Cost | $21/month | ~$10/month + extras |
| Setup Time | 5 minutes | 1-2 hours |
| SSL | Free, automatic | Manual setup |
| Auto-deploy | ✅ Built-in | ❌ Need CI/CD |
| Monitoring | ✅ Built-in | ❌ Need CloudWatch |
| Maintenance | ✅ Zero | ❌ Manual updates |

## Next Steps

1. ✅ Deploy to Render
2. ✅ Test all features
3. ⭐ Add custom domain
4. ⭐ Set up monitoring alerts
5. ⭐ Configure backups (paid plan)
6. ⭐ Add staging environment

## Support

- **Render Docs:** https://render.com/docs
- **Community:** https://community.render.com
- **Status:** https://status.render.com
