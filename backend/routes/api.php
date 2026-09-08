<?php

use App\Http\Controllers\SupplierController;
use Illuminate\Support\Facades\Route;

Route::get('/suppliers', [SupplierController::class, 'index']);
Route::get('/suppliers/{id}', [SupplierController::class, 'show'])->whereNumber('id');
Route::post('/suppliers', [SupplierController::class, 'store']);

