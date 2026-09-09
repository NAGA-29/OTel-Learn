<?php

use App\Http\Middleware\RequestLoggingMiddleware;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->api(append: [RequestLoggingMiddleware::class]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->respond(function (\Symfony\Component\HttpFoundation\Response $response): \Symfony\Component\HttpFoundation\Response {
            $request = app(\Illuminate\Http\Request::class);
            $requestId = $request->attributes->get('request_id');
            $startedAt = $request->attributes->get('request_started_at');

            if ($requestId !== null && $startedAt !== null) {
                $response->headers->set('X-Request-ID', $requestId);
                RequestLoggingMiddleware::writeAccessLog($request, $requestId, $response->getStatusCode(), $startedAt);
            }

            return $response;
        });
    })->create();
