import { Router, Request, Response } from 'express';

const router = Router();

/**
 * Health check endpoint for monitoring and deployment platforms
 * Returns 200 OK if the service is running
 */
router.get('/health', (req: Request, res: Response) => {
    res.status(200).json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        service: 'karaban-backend',
        uptime: process.uptime()
    });
});

/**
 * Readiness check endpoint
 * Can be extended to check database connectivity
 */
router.get('/ready', (req: Request, res: Response) => {
    // TODO: Add database connectivity check
    res.status(200).json({
        status: 'ready',
        timestamp: new Date().toISOString()
    });
});

export default router;
