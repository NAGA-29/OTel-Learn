<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;
use Throwable;

class RequestLoggingMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $startedAt = hrtime(true);
        $requestId = $request->headers->get('X-Request-ID') ?: (string) Str::uuid();
        $request->attributes->set('request_id', $requestId);
        Log::withContext(['request_id' => $requestId]);

        try {
            /** @var Response $response */
            $response = $next($request);
        } catch (Throwable $exception) {
            $this->writeAccessLog($request, $requestId, 500, $startedAt);
            throw $exception;
        }

        $response->headers->set('X-Request-ID', $requestId);
        $this->writeAccessLog($request, $requestId, $response->getStatusCode(), $startedAt);
        return $response;
    }

    private function writeAccessLog(Request $request, string $requestId, int $statusCode, int $startedAt): void
    {
        Log::info('request completed', [
            'log_type' => 'http_access',
            'request_id' => $requestId,
            'method' => $request->method(),
            'url' => $request->fullUrl(),
            'route' => $request->route() ? '/'.$request->route()->uri() : null,
            'status_code' => $statusCode,
            'duration_ms' => round((hrtime(true) - $startedAt) / 1_000_000, 3),
            'ip' => $request->ip(),
            'user_id' => $request->user()?->getAuthIdentifier(),
        ]);
    }
}
