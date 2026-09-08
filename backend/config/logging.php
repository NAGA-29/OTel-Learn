<?php

use Monolog\Formatter\JsonFormatter;
use Monolog\Handler\RotatingFileHandler;
use Monolog\Handler\StreamHandler;

return [
    'default' => env('LOG_CHANNEL', 'json'),
    'channels' => [
        'json' => [
            'driver' => 'monolog',
            'handler' => RotatingFileHandler::class,
            'handler_with' => [
                'filename' => storage_path('logs/laravel.json.log'),
                'maxFiles' => 14,
            ],
            'formatter' => JsonFormatter::class,
            'formatter_with' => [
                'batchMode' => JsonFormatter::BATCH_MODE_JSON,
                'appendNewline' => true,
                'includeStacktraces' => true,
            ],
            'level' => env('LOG_LEVEL', 'debug'),
        ],
        'stderr' => [
            'driver' => 'monolog',
            'handler' => StreamHandler::class,
            'handler_with' => ['stream' => 'php://stderr'],
            'formatter' => JsonFormatter::class,
        ],
    ],
];
